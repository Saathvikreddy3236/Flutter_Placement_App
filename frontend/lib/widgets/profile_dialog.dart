import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_service.dart';
import '../services/session_store.dart';

Future<void> showProfileDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => const _ProfileDialog(),
  );
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
  final TextEditingController _yearController = TextEditingController();

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
    _yearController.dispose();
    super.dispose();
  }

  void _fill(UserProfileItem profile) {
    if (_nameController.text.isNotEmpty) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _branchController.text = profile.branch;
    _cgpaController.text = profile.cgpa == 0 ? '' : profile.cgpa.toString();
    _yearController.text = profile.year == 0 ? '' : '${profile.year}';
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
        year: int.tryParse(_yearController.text.trim()),
      );
      SessionStore.updateProfile(
        name: updated.name.isEmpty ? updated.username : updated.name,
        usernameValue: updated.username,
        emailValue: updated.email,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _saving = false);
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
                      ),
                      if (profile.isStudent) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _branchController,
                          decoration: const InputDecoration(labelText: 'Branch'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _cgpaController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'CGPA'),
                          validator: (value) =>
                              double.tryParse((value ?? '').trim()) == null
                                  ? 'Enter valid CGPA'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Year'),
                          validator: (value) =>
                              int.tryParse((value ?? '').trim()) == null
                                  ? 'Enter valid year'
                                  : null,
                        ),
                      ],
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
