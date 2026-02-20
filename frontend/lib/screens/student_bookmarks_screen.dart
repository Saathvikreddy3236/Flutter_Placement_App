import 'package:flutter/material.dart';

import '../widgets/student_navbar.dart';
import '../widgets/student_section_shell.dart';

class StudentBookmarksScreen extends StatelessWidget {
  const StudentBookmarksScreen({super.key});

  static const String routeName = '/student/bookmarks';

  @override
  Widget build(BuildContext context) {
    return const StudentSectionShell(
      activeTab: StudentNavTab.bookmarks,
      title: 'My Bookmarks',
      subtitle: 'Saved opportunities so you can apply at the right time.',
      child: Column(
        children: [
          StudentInfoCard(
            title: 'Wipro - Software Engineer I',
            detail: 'Deadline: Feb 28, 2026 | Eligibility: 7.0+ CGPA',
          ),
          SizedBox(height: 10),
          StudentInfoCard(
            title: 'Accenture - QA Automation Trainee',
            detail: 'Deadline: Mar 2, 2026 | Hybrid interview process',
          ),
        ],
      ),
    );
  }
}
