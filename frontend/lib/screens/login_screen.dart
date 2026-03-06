import 'package:flutter/material.dart';

import '../services/session_store.dart';
import 'admin/admin_dashboard_screen.dart';
import '../services/api_service.dart';
import 'student/student_dashboard_screen.dart';

enum _LoginRole { student, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _api = const ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  _LoginRole _selectedRole = _LoginRole.student;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final String selectedRole = _selectedRole == _LoginRole.admin
          ? 'admin'
          : 'student';
      if (response.role != selectedRole) {
        setState(() {
          _errorMessage = selectedRole == 'admin'
              ? 'This account is not an admin account.'
              : 'This account is not a student account.';
        });
        return;
      }
      SessionStore.setSession(
        id: response.studentId,
        name: response.fullName,
        role: response.role,
      );
      if (!mounted) return;
      if (response.role == 'admin') {
        Navigator.pushReplacementNamed(context, AdminDashboardScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, StudentDashboardScreen.routeName);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Portal Login')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1E2), Color(0xFFFFFAF4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE7D1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'NIT AP Placement Cell',
                              textAlign: TextAlign.center,
                              style: textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF8C3900),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Welcome Back', style: textTheme.headlineSmall),
                          const SizedBox(height: 6),
                          Text(
                            _selectedRole == _LoginRole.admin
                                ? 'Admin sign in with your username and password.'
                                : 'Student sign in with your username and password.',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          _RoleToggle(
                            selectedRole: _selectedRole,
                            onChanged: (role) {
                              setState(() {
                                _selectedRole = role;
                                _errorMessage = null;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 10),
                          ],
                          FilledButton(
                            onPressed: _isLoading ? null : _login,
                            child: Text(
                              _isLoading
                                  ? 'Logging in...'
                                  : _selectedRole == _LoginRole.admin
                                  ? 'Login as Admin'
                                  : 'Login as Student',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
    required this.selectedRole,
    required this.onChanged,
  });

  final _LoginRole selectedRole;
  final ValueChanged<_LoginRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDFC2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleToggleButton(
              label: 'Student',
              active: selectedRole == _LoginRole.student,
              onTap: () => onChanged(_LoginRole.student),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _RoleToggleButton(
              label: 'Admin',
              active: selectedRole == _LoginRole.admin,
              onTap: () => onChanged(_LoginRole.admin),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleToggleButton extends StatelessWidget {
  const _RoleToggleButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFC75A00) : const Color(0xFFFFFCF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFC75A00) : const Color(0xFFFFE2CA),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF7B5538),
          ),
        ),
      ),
    );
  }
}
