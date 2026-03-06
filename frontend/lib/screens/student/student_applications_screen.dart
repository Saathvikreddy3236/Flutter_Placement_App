import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/student_navbar.dart';
import '../../widgets/student_section_shell.dart';

class StudentApplicationsScreen extends StatefulWidget {
  const StudentApplicationsScreen({super.key});

  static const String routeName = '/student/applications';

  @override
  State<StudentApplicationsScreen> createState() =>
      _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState extends State<StudentApplicationsScreen> {
  final ApiService _api = const ApiService();
  late Future<List<ApplicationItem>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _fetchApplications();
  }

  Future<List<ApplicationItem>> _fetchApplications() {
    final int? studentId = SessionStore.studentId;
    if (studentId == null) {
      throw Exception('Please login first.');
    }
    return _api.fetchMyApplications(studentId);
  }

  Future<void> _refresh() async {
    setState(() {
      _applicationsFuture = _fetchApplications();
    });
    await _applicationsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return StudentSectionShell(
      activeTab: StudentNavTab.applications,
      title: 'My Applications',
      subtitle: 'Track all roles you applied for and their latest status.',
      child: FutureBuilder<List<ApplicationItem>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Failed to load applications: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }

          final List<ApplicationItem> applications = snapshot.data ?? const [];
          if (applications.isEmpty) {
            return const Text('You have not applied to any jobs yet.');
          }

          return Column(
            children: applications
                .map(
                  (application) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StudentInfoCard(
                      title: '${application.company} - ${application.jobTitle}',
                      detail:
                          'Status: ${application.status} | ${application.location}',
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
