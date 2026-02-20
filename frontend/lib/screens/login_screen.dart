import 'package:flutter/material.dart';

import '../services/session_store.dart';
import 'admin_dashboard_screen.dart';
import 'student_dashboard_screen.dart';
import '../services/api_service.dart';

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
                            'Sign in with your username and password.',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
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
                            child: Text(_isLoading ? 'Logging in...' : 'Login'),
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
