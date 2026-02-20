import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Admin Dashboard Page')));
  }
}
