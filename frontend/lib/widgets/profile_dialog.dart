import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_service.dart';
import '../services/session_store.dart';
import '../utils/app_notifier.dart';

Future<bool> showProfileDialog(BuildContext context) async {
  final bool? updated = await showDialog<bool>(
    context: context,
    builder: (context) => const _ProfileDialog(),
  );
  return updated ?? false;
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog();

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  final ApiService _api = const ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  int? _selectedGraduationYear;

  late Future<UserProfileItem> _profileFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _api.fetchProfile(
      role: SessionStore.userRole,
      studentId: SessionStore.studentId,
      username: SessionStore.username,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _branchController.dispose();
    _cgpaController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  List<int> get _graduationYearOptions {
    final int currentYear = DateTime.now().year;
    return List<int>.generate(5, (index) => currentYear + index);
  }

  void _fill(UserProfileItem profile) {
    if (_nameController.text.isNotEmpty) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _branchController.text = profile.branch;
    _cgpaController.text = profile.cgpa == 0 ? '' : profile.cgpa.toString();
    final int initialYear = profile.graduationYear != 0
        ? profile.graduationYear
        : profile.year;
    if (_graduationYearOptions.contains(initialYear)) {
      _selectedGraduationYear = initialYear;
    } else {
      _selectedGraduationYear = _graduationYearOptions.first;
    }
  }

  Future<void> _save(UserProfileItem profile) async {
    if (_formKey.currentState?.validate() != true || _saving) return;

    setState(() => _saving = true);
    try {
      final UserProfileItem updated = await _api.updateProfile(
        role: profile.role,
        studentId: SessionStore.studentId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        branch: _branchController.text.trim(),
        cgpa: double.tryParse(_cgpaController.text.trim()),
        year: _selectedGraduationYear,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      SessionStore.updateProfile(
        name: updated.name.isEmpty ? updated.username : updated.name,
        usernameValue: updated.username,
        emailValue: updated.email,
      );
      if (!mounted) {
        return;
      }
      await AppNotifier.showSuccessMessage(
        'Profile Updated',
        'Your profile details have been saved successfully.',
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      await AppNotifier.showErrorMessage(
        'Update Failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: FutureBuilder<UserProfileItem>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Failed to load profile: ${snapshot.error}'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                );
              }

              final UserProfileItem profile = snapshot.data!;
              _fill(profile);

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.isStudent ? 'Student Profile' : 'Admin Profile',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter name'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          final String trimmed = (value ?? '').trim();
                          if (trimmed.isEmpty) {
                            return 'Enter email';
                          }
                          if (!trimmed.contains('@')) {
                            return 'Enter valid email';
                          }
                          if (profile.isStudent &&
                              !trimmed.toLowerCase().endsWith(
                                '@student.nitandhra.ac.in',
                              )) {
                            return 'Email must be @student.nitandhra.ac.in';
                          }
                          return null;
                        },
                      ),
                      if (profile.isStudent) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          validator: (value) {
                            final String trimmed = (value ?? '').trim();
                            if (trimmed.isEmpty) {
                              return 'Enter phone number';
                            }
                            if (trimmed.length < 10) {
                              return 'Enter valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _branchController,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _cgpaController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'CGPA'),
                          validator: (value) => () {
                            final double? cgpa = double.tryParse(
                              (value ?? '').trim(),
                            );
                            if (cgpa == null) {
                              return 'Enter valid CGPA';
                            }
                            if (cgpa < 0 || cgpa > 10) {
                              return 'CGPA must be between 0 and 10';
                            }
                            return null;
                          }(),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedGraduationYear,
                          decoration: const InputDecoration(
                            labelText: 'Graduation Year',
                          ),
                          items: _graduationYearOptions
                              .map(
                                (year) => DropdownMenuItem<int>(
                                  value: year,
                                  child: Text('$year'),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _selectedGraduationYear = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Select graduation year';
                            }
                            if (!_graduationYearOptions.contains(value)) {
                              return 'Select a valid graduation year';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      ExpansionTile(
                        title: const Text('Change Password (Optional)'),
                        children: [
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Current Password',
                              hintText: 'Enter your current password',
                            ),
                            validator: (value) {
                              if (_newPasswordController.text.isNotEmpty &&
                                  (value == null || value.isEmpty)) {
                                return 'Enter current password to change password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'New Password',
                              hintText: 'Enter new password',
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6) {
                                return 'New password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmNewPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm New Password',
                              hintText: 'Re-enter new password',
                            ),
                            validator: (value) {
                              if (_newPasswordController.text.isNotEmpty &&
                                  value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: _saving ? null : () => _save(profile),
                            child: Text(_saving ? 'Saving...' : 'Save Changes'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
