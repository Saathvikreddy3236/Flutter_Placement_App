import 'package:flutter/material.dart';

import '../../widgets/admin_navbar.dart';
import '../../widgets/admin_section_shell.dart';

class AdminApplicantsScreen extends StatelessWidget {
  const AdminApplicantsScreen({super.key});

  static const String routeName = '/admin/applicants';

  @override
  Widget build(BuildContext context) {
    return AdminSectionShell(
      activeTab: AdminNavTab.applicants,
      title: 'View Applicants',
      subtitle: 'Review applicants and profile status for each posting.',
      child: const Column(
        children: [
          AdminInfoCard(
            title: 'John Doe - Software Engineer (Frontend)',
            detail: 'Status: New applicant | Stanford University',
            actionLabel: 'View Profile',
          ),
          SizedBox(height: 10),
          AdminInfoCard(
            title: 'Sarah Jenkins - Product Management Intern',
            detail: 'Status: Shortlisted | MIT',
            actionLabel: 'View Profile',
          ),
        ],
      ),
    );
  }
}
