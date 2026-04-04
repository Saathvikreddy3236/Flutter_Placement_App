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
import 'services/session_store.dart';
import 'theme/app_theme.dart';
import 'utils/app_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionStore.initialize();
  runApp(const PlacementPortalApp());
}

class PlacementPortalApp extends StatelessWidget {
  const PlacementPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNotifier.navigatorKey,
      scaffoldMessengerKey: AppNotifier.messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Placement Portal NIT AP',
      theme: AppTheme.light,
      initialRoute: SessionStore.initialRoute,
      navigatorObservers: <NavigatorObserver>[_SessionRouteObserver()],
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

class _SessionRouteObserver extends NavigatorObserver {
  void _remember(Route<dynamic>? route) {
    final String? routeName = route?.settings.name;
    SessionStore.rememberRoute(routeName);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _remember(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _remember(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _remember(previousRoute);
  }
}
