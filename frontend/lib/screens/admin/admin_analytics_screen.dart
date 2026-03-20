import 'package:flutter/material.dart';

import '../../widgets/admin_navbar.dart';
import '../../widgets/admin_section_shell.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  static const String routeName = '/admin/analytics';

  @override
  Widget build(BuildContext context) {
    return AdminSectionShell(
      activeTab: AdminNavTab.analytics,
      title: 'Analytics',
      subtitle: 'Track recruitment funnel and interview performance.',
      child: const Column(
        children: [
          AdminInfoCard(
            title: 'Application Conversion',
            detail: '842 total applicants | 156 shortlisted | 24 interviews',
          ),
          SizedBox(height: 10),
          AdminInfoCard(
            title: 'Top Hiring Locations',
            detail: 'Bengaluru, Hyderabad, Pune, Chennai',
          ),
        ],
      ),
    );
  }
}
