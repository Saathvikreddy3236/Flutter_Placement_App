import 'package:flutter/material.dart';

import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_applicants_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_postings_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/student/student_applications_screen.dart';
import 'screens/student/student_bookmarks_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_jobs_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PlacementPortalApp());
}

class PlacementPortalApp extends StatelessWidget {
  const PlacementPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Placement Portal NIT AP',
      theme: AppTheme.light,
      initialRoute: LandingScreen.routeName,
      routes: <String, WidgetBuilder>{
        LandingScreen.routeName: (_) => const LandingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        StudentDashboardScreen.routeName: (_) => const StudentDashboardScreen(),
        StudentJobsScreen.routeName: (_) => const StudentJobsScreen(),
        StudentApplicationsScreen.routeName: (_) =>
            const StudentApplicationsScreen(),
        StudentBookmarksScreen.routeName: (_) => const StudentBookmarksScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        AdminPostingsScreen.routeName: (_) => const AdminPostingsScreen(),
        AdminApplicantsScreen.routeName: (_) => const AdminApplicantsScreen(),
        AdminAnalyticsScreen.routeName: (_) => const AdminAnalyticsScreen(),
      },
    );
  }
}
