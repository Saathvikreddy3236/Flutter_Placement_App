import 'package:flutter/material.dart';

import '../../widgets/admin_navbar.dart';
import '../../widgets/admin_section_shell.dart';

class AdminPostingsScreen extends StatelessWidget {
  const AdminPostingsScreen({super.key});

  static const String routeName = '/admin/postings';

  @override
  Widget build(BuildContext context) {
    return AdminSectionShell(
      activeTab: AdminNavTab.postings,
      title: 'My Postings',
      subtitle: 'Manage all active and draft job postings.',
      child: const Column(
        children: [
          AdminInfoCard(
            title: 'Prompt Engineer - GOOGLE',
            detail: 'Bengaluru | 12 LPA | Deadline: 2026-03-28',
            actionLabel: 'Edit',
          ),
          SizedBox(height: 10),
          AdminInfoCard(
            title: 'SD - Techno Frost',
            detail: 'Hyderabad | 10 LPA | Deadline: 2026-02-28',
            actionLabel: 'Edit',
          ),
        ],
      ),
    );
  }
}
