import 'package:flutter/material.dart';

import '../screens/student/student_applications_screen.dart';
import '../screens/student/student_bookmarks_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_jobs_screen.dart';
import '../services/session_store.dart';
import 'logout_back_guard.dart';
import 'profile_dialog.dart';
import 'student_navbar.dart';

class StudentSectionShell extends StatefulWidget {
  const StudentSectionShell({
    super.key,
    required this.activeTab,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onProfileUpdated,
  });

  final StudentNavTab activeTab;
  final String title;
  final String subtitle;
  final Widget child;
  final Future<void> Function()? onProfileUpdated;

  @override
  State<StudentSectionShell> createState() => _StudentSectionShellState();
}

class _StudentSectionShellState extends State<StudentSectionShell> {
  Future<void> _handleProfileTap() async {
    final bool updated = await showProfileDialog(context);
    if (!mounted || !updated) return;
    setState(() {});
    await widget.onProfileUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LogoutBackGuard(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF4F7FB), Color(0xFFFFFFFF), Color(0xFFEEF3F9)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                StudentNavbar(
                  studentName: SessionStore.studentName,
                  onProfileTap: _handleProfileTap,
                  onLogout: () {
                    SessionStore.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  activeTab: widget.activeTab,
                  onHomeTap: () => Navigator.pushReplacementNamed(
                    context,
                    StudentDashboardScreen.routeName,
                  ),
                  onJobsTap: () => Navigator.pushReplacementNamed(
                    context,
                    StudentJobsScreen.routeName,
                  ),
                  onApplicationsTap: () => Navigator.pushReplacementNamed(
                    context,
                    StudentApplicationsScreen.routeName,
                  ),
                  onBookmarksTap: () => Navigator.pushReplacementNamed(
                    context,
                    StudentBookmarksScreen.routeName,
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
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x100D2340),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      widget.child,
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

class StudentInfoCard extends StatelessWidget {
  const StudentInfoCard({super.key, required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE1CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(detail, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
