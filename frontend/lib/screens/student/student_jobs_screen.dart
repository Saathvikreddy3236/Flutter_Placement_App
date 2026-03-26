import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/student_navbar.dart';
import '../../widgets/student_section_shell.dart';

class StudentJobsScreen extends StatefulWidget {
  const StudentJobsScreen({super.key});

  static const String routeName = '/student/jobs';

  @override
  State<StudentJobsScreen> createState() => _StudentJobsScreenState();
}

class _StudentJobsScreenState extends State<StudentJobsScreen> {
  final ApiService _api = const ApiService();
  late Future<List<JobItem>> _jobsFuture;
  final Set<int> _busyApplyJobs = <int>{};
  final Set<int> _busyBookmarkJobs = <int>{};
  List<JobItem> _jobs = const <JobItem>[];
  bool _hasAcceptedOffer = false;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
  }

  Future<List<JobItem>> _loadJobs() async {
    final int? studentId = SessionStore.studentId;
    final List<JobItem> jobs = studentId == null
        ? await _api.fetchJobs()
        : await _api.fetchJobsForStudent(studentId);

    if (studentId != null) {
      final List<ApplicationItem> applications = await _api.fetchMyApplications(
        studentId,
      );
      _hasAcceptedOffer = applications.any(
        (application) => application.status == 'Accepted',
      );
    } else {
      _hasAcceptedOffer = false;
    }

    _jobs = jobs;
    return jobs;
  }

  Future<void> _refresh() async {
    setState(() {
      _jobsFuture = _loadJobs();
    });
    await _jobsFuture;
  }

  Future<void> _apply(JobItem job) async {
    final int? studentId = SessionStore.studentId;
    if (studentId == null ||
        _busyApplyJobs.contains(job.id) ||
        job.isApplied ||
        _hasAcceptedOffer) {
      return;
    }

    setState(() => _busyApplyJobs.add(job.id));
    try {
      final String message = await _api.applyJob(
        studentId: studentId,
        jobId: job.id,
      );
      _replaceJob(job.copyWith(isApplied: true));
      _showMessage(message);
    } catch (e) {
      final String message = e.toString().replaceFirst('Exception: ', '');
      if (message == 'Already applied') {
        _replaceJob(job.copyWith(isApplied: true));
      }
      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _busyApplyJobs.remove(job.id));
      }
    }
  }

  Future<void> _toggleBookmark(JobItem job) async {
    final int? studentId = SessionStore.studentId;
    if (studentId == null || _busyBookmarkJobs.contains(job.id)) {
      return;
    }

    setState(() => _busyBookmarkJobs.add(job.id));
    try {
      final bool bookmarked = await _api.toggleBookmark(
        studentId: studentId,
        jobId: job.id,
      );
      _replaceJob(job.copyWith(isBookmarked: bookmarked));
      _showMessage(bookmarked ? 'Job bookmarked' : 'Bookmark removed');
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _busyBookmarkJobs.remove(job.id));
      }
    }
  }

  void _replaceJob(JobItem updatedJob) {
    if (!mounted) return;
    setState(() {
      _jobs = _jobs
          .map((job) => job.id == updatedJob.id ? updatedJob : job)
          .toList(growable: false);
    });
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
      subtitle:
          'Discover roles tailored to your profile and save the ones you want to revisit.',
      child: FutureBuilder<List<JobItem>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _jobs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError && _jobs.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Failed to load jobs: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }

          if (_jobs.isEmpty) {
            return const Text('No jobs available right now.');
          }

          return Column(
            children: [
              if (_hasAcceptedOffer)
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
                    'You have accepted an offer, so new applications are now disabled.',
                  ),
                ),
              for (final JobItem job in _jobs) ...[
                _JobCard(
                  job: job,
                  isApplying: _busyApplyJobs.contains(job.id),
                  isBookmarkUpdating: _busyBookmarkJobs.contains(job.id),
                  applicationsLocked: _hasAcceptedOffer,
                  onApply: () => _apply(job),
                  onToggleBookmark: () => _toggleBookmark(job),
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

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isApplying,
    required this.isBookmarkUpdating,
    required this.applicationsLocked,
    required this.onApply,
    required this.onToggleBookmark,
  });

  final JobItem job;
  final bool isApplying;
  final bool isBookmarkUpdating;
  final bool applicationsLocked;
  final VoidCallback onApply;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE2CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFC75A00),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isBookmarkUpdating ? null : onToggleBookmark,
                tooltip: job.isBookmarked ? 'Remove bookmark' : 'Bookmark job',
                icon: Icon(
                  job.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: const Color(0xFFC75A00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(label: job.location, icon: Icons.location_on_outlined),
              _MetaChip(
                label: '${job.packageLpa} LPA',
                icon: Icons.payments_outlined,
              ),
              _MetaChip(
                label: 'Deadline ${job.deadline}',
                icon: Icons.event_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(job.description, style: textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              FilledButton(
                onPressed: job.isApplied || isApplying || applicationsLocked ? null : onApply,
                child: Text(
                  job.isApplied
                      ? 'Applied'
                      : applicationsLocked
                          ? 'Locked'
                          : isApplying
                              ? 'Applying...'
                              : 'Apply Now',
                ),
              ),
              const SizedBox(width: 10),
              if (job.isBookmarked)
                const Chip(
                  label: Text('Saved'),
                  avatar: Icon(Icons.bookmark, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9B4D0A)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
