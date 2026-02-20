import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_service.dart';
import '../services/session_store.dart';
import '../widgets/student_navbar.dart';
import 'student_applications_screen.dart';
import 'student_bookmarks_screen.dart';
import 'student_dashboard_screen.dart';

class StudentJobsScreen extends StatefulWidget {
  const StudentJobsScreen({super.key});

  static const String routeName = '/student/jobs';

  @override
  State<StudentJobsScreen> createState() => _StudentJobsScreenState();
}

class _StudentJobsScreenState extends State<StudentJobsScreen> {
  final ApiService _api = const ApiService();
  late Future<List<JobItem>> _jobsFuture;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _api.fetchJobs();
  }

  Future<void> _refresh() async {
    setState(() {
      _jobsFuture = _api.fetchJobs();
    });
    await _jobsFuture;
  }

  Future<void> _apply(JobItem job) async {
    final int? studentId = SessionStore.studentId;
    if (studentId == null) {
      _showMessage('Please login again.');
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);
    try {
      final String message = await _api.applyJob(
        studentId: studentId,
        jobId: job.id,
      );
      _showMessage(message);
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StudentSectionShell(
      activeTab: StudentNavTab.jobs,
      title: 'All Jobs',
      subtitle: 'Discover roles tailored to your profile.',
      child: FutureBuilder<List<JobItem>>(
        future: _jobsFuture,
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
                Text('Failed to load jobs: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }

          final List<JobItem> jobs = snapshot.data ?? const [];
          if (jobs.isEmpty) {
            return const Text('No jobs available right now.');
          }

          return Column(
            children: jobs
                .map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StudentInfoCard(
                      title: '${job.title} - ${job.company}',
                      detail:
                          '${job.location} | CTC: ${job.packageLpa} LPA | Deadline: ${job.deadline}',
                      actionLabel: 'Apply',
                      onActionTap: _submitting ? null : () => _apply(job),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE1CA)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(subtitle),
                          const SizedBox(height: 14),
                          child,
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
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
  const StudentInfoCard({
    super.key,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String detail;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE4CE)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: Color(0xFFC75A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(detail),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 10),
            OutlinedButton(onPressed: onActionTap, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
