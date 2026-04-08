import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../utils/app_notifier.dart';
import '../../utils/formatters.dart';
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
  List<ApplicationItem> _applications = const <ApplicationItem>[];
  final Set<int> _busyApplicationIds = <int>{};

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _fetchApplications();
  }

  Future<List<ApplicationItem>> _fetchApplications() async {
    final int? studentId = SessionStore.studentId;
    if (studentId == null) {
      throw Exception('Please login first.');
    }
    final List<ApplicationItem> applications = await _api.fetchMyApplications(
      studentId,
    );
    _applications = applications;
    return applications;
  }

  Future<void> _refresh() async {
    setState(() {
      _applicationsFuture = _fetchApplications();
    });
    await _applicationsFuture;
  }

  Future<void> _respond(ApplicationItem application, String decision) async {
    final int? studentId = SessionStore.studentId;
    if (studentId == null || _busyApplicationIds.contains(application.id)) {
      return;
    }

    setState(() => _busyApplicationIds.add(application.id));
    try {
      final String message = await _api.respondToOffer(
        studentId: studentId,
        applicationId: application.id,
        decision: decision,
      );
      await _refresh();
      await AppNotifier.showSuccessMessage(
        decision == 'accept' ? 'Offer Accepted' : 'Offer Rejected',
        message,
      );
    } catch (e) {
      await AppNotifier.showErrorMessage(
        'Update Failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _busyApplicationIds.remove(application.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentSectionShell(
      activeTab: StudentNavTab.applications,
      title: 'My Applications',
      subtitle:
          'Track all roles you applied for. If an offer arrives, you can accept or reject it here.',
      onProfileUpdated: _refresh,
      child: FutureBuilder<List<ApplicationItem>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _applications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError && _applications.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Failed to load applications: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }

          if (_applications.isEmpty) {
            return const Text('You have not applied to any jobs yet.');
          }

          return Column(
            children: [
              if (_applications.any((item) => item.status == 'Accepted'))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC75A00), Color(0xFFE79A45)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'You have accepted an offer. Your placement is confirmed and all other applications are now closed.',
                        style: TextStyle(color: Color(0xFFFFF2E6)),
                      ),
                    ],
                  ),
                ),
              if (_applications.any((item) => item.status == 'Accepted'))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD9BA)),
                  ),
                  child: const Text(
                    'You have already accepted an offer. New job applications are now locked.',
                  ),
                ),
              for (final ApplicationItem application in _applications) ...[
                _ApplicationCard(
                  application: application,
                  loading: _busyApplicationIds.contains(application.id),
                  onAccept: () => _respond(application, 'accept'),
                  onReject: () => _respond(application, 'reject'),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.loading,
    required this.onAccept,
    required this.onReject,
  });

  final ApplicationItem application;
  final bool loading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final bool canRespond = application.status == 'Offered';

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
          Text(
            '${application.company} - ${application.jobTitle}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Status: ${application.status} | ${application.location} | ${application.packageLpa} LPA | Deadline ${AppFormatters.date(application.deadline)}',
          ),
          const SizedBox(height: 10),
          if (canRespond)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: loading ? null : onAccept,
                  child: Text(loading ? 'Updating...' : 'Accept Offer'),
                ),
                OutlinedButton(
                  onPressed: loading ? null : onReject,
                  child: const Text('Reject Offer'),
                ),
              ],
            )
          else
            _StatusChip(status: application.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status),
    );
  }
}
