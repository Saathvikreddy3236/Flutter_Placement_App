import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../services/session_store.dart';
import 'admin_navbar.dart';
import 'logout_back_guard.dart';
import 'profile_dialog.dart';

class AdminSectionShell extends StatelessWidget {
  const AdminSectionShell({
    super.key,
    required this.activeTab,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final AdminNavTab activeTab;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LogoutBackGuard(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                const Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AdminNavbar(
                  adminName: SessionStore.studentName,
                  onProfileTap: () => showProfileDialog(context),
                  onLogout: () {
                    SessionStore.clear();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  activeTab: activeTab,
                  onDashboardTap: () => Navigator.pushReplacementNamed(
                    context,
                    AdminDashboardScreen.routeName,
                  ),
                  onPostingsTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/postings',
                  ),
                  onApplicantsTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/applicants',
                  ),
                  onAnalyticsTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/analytics',
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD9E3EF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      child,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminInfoCard extends StatelessWidget {
  const AdminInfoCard({
    super.key,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 10),
            OutlinedButton(onPressed: onActionTap, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
