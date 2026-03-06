import 'package:flutter/material.dart';

import '../screens/student/student_applications_screen.dart';
import '../screens/student/student_bookmarks_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_jobs_screen.dart';
import '../services/session_store.dart';
import 'student_navbar.dart';

class StudentSectionShell extends StatelessWidget {
  const StudentSectionShell({
    super.key,
    required this.activeTab,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final StudentNavTab activeTab;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4E7), Color(0xFFFFFCF8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              StudentNavbar(
                studentName: SessionStore.studentName,
                onLogout: () {
                  SessionStore.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                activeTab: activeTab,
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
                        border: Border.all(color: const Color(0xFFFFE1CA)),
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
