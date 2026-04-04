import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../utils/app_notifier.dart';
import '../../utils/formatters.dart';
import '../../widgets/admin_navbar.dart';
import '../../widgets/admin_section_shell.dart';

class AdminPostingsScreen extends StatefulWidget {
  const AdminPostingsScreen({super.key});

  static const String routeName = '/admin/postings';

  @override
  State<AdminPostingsScreen> createState() => _AdminPostingsScreenState();
}

class _AdminPostingsScreenState extends State<AdminPostingsScreen> {
  final ApiService _api = const ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _packageController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  late Future<List<JobItem>> _jobsFuture;
  List<JobItem> _jobs = const <JobItem>[];
  bool _submitting = false;
  final Set<int> _deletingJobIds = <int>{};

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _packageController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<List<JobItem>> _loadJobs() async {
    final List<JobItem> jobs = await _api.fetchAdminJobs();
    _jobs = jobs;
    return jobs;
  }

  Future<void> _refresh() async {
    setState(() {
      _jobsFuture = _loadJobs();
    });
    await _jobsFuture;
  }

  Future<void> _pickDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (selected == null) return;

    final String month = selected.month.toString().padLeft(2, '0');
    final String day = selected.day.toString().padLeft(2, '0');
    _deadlineController.text = '${selected.year}-$month-$day';
  }

  Future<void> _createJob() async {
    if (_formKey.currentState?.validate() != true || _submitting) return;

    setState(() => _submitting = true);
    try {
      final JobItem job = await _api.createAdminJob(
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        packageLpa: int.parse(_packageController.text.trim()),
        deadline: _deadlineController.text.trim(),
      );
      setState(() {
        _jobs = [job, ..._jobs];
      });
      _formKey.currentState?.reset();
      _titleController.clear();
      _companyController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _packageController.clear();
      _deadlineController.clear();
      await AppNotifier.showSuccessMessage(
        'Job Posting Added',
        'The job has been published successfully.',
      );
    } catch (e) {
      await AppNotifier.showErrorMessage(
        'Unable To Add Job',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deleteJob(JobItem job) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: Text('Delete ${job.title} at ${job.company}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || _deletingJobIds.contains(job.id)) return;

    setState(() => _deletingJobIds.add(job.id));
    try {
      final String message = await _api.deleteAdminJob(job.id);
      if (!mounted) return;
      setState(() {
        _jobs = _jobs
            .where((item) => item.id != job.id)
            .toList(growable: false);
      });
      await AppNotifier.showInfoMessage('Job Deleted', message);
    } catch (e) {
      await AppNotifier.showErrorMessage(
        'Delete Failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingJobIds.remove(job.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminSectionShell(
      activeTab: AdminNavTab.postings,
      title: 'My Postings',
      subtitle:
          'Add polished job postings, pick the deadline from a calendar, and manage all posted jobs below.',
      child: Column(
        children: [
          _PostJobForm(
            formKey: _formKey,
            titleController: _titleController,
            companyController: _companyController,
            locationController: _locationController,
            descriptionController: _descriptionController,
            packageController: _packageController,
            deadlineController: _deadlineController,
            submitting: _submitting,
            onSubmit: _createJob,
            onPickDeadline: _pickDeadline,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'All Jobs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<JobItem>>(
            future: _jobsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _jobs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError && _jobs.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Failed to load jobs: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }
              if (_jobs.isEmpty) {
                return const AdminInfoCard(
                  title: 'No jobs posted yet',
                  detail: 'Create the first job using the form above.',
                );
              }
              return Column(
                children: [
                  for (final JobItem job in _jobs) ...[
                    _JobCard(
                      job: job,
                      deleting: _deletingJobIds.contains(job.id),
                      onDelete: () => _deleteJob(job),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostJobForm extends StatelessWidget {
  const _PostJobForm({
    required this.formKey,
    required this.titleController,
    required this.companyController,
    required this.locationController,
    required this.descriptionController,
    required this.packageController,
    required this.deadlineController,
    required this.submitting,
    required this.onSubmit,
    required this.onPickDeadline,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController companyController;
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  final TextEditingController packageController;
  final TextEditingController deadlineController;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onPickDeadline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE1CA)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: Color(0xFFC75A00),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Job',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fill in the job details clearly so students get a clean posting experience.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool wide = constraints.maxWidth > 760;
                if (wide) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: 'Job Title',
                              child: TextFormField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  hintText: 'Software Engineer',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Enter job title'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LabeledField(
                              label: 'Company',
                              child: TextFormField(
                                controller: companyController,
                                decoration: const InputDecoration(
                                  hintText: 'Google',
                                  prefixIcon: Icon(Icons.apartment_outlined),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Enter company'
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _LabeledField(
                              label: 'Location',
                              child: TextFormField(
                                controller: locationController,
                                decoration: const InputDecoration(
                                  hintText: 'Bengaluru',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? 'Enter location'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LabeledField(
                              label: 'Package (LPA)',
                              child: TextFormField(
                                controller: packageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '12',
                                  prefixIcon: Icon(Icons.payments_outlined),
                                ),
                                validator: (value) {
                                  final int? parsed = int.tryParse(
                                    (value ?? '').trim(),
                                  );
                                  if (parsed == null) {
                                    return 'Enter valid package';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _LabeledField(
                      label: 'Job Title',
                      child: TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Software Engineer',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter job title'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Company',
                      child: TextFormField(
                        controller: companyController,
                        decoration: const InputDecoration(
                          hintText: 'Google',
                          prefixIcon: Icon(Icons.apartment_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter company'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Location',
                      child: TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          hintText: 'Bengaluru',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter location'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Package (LPA)',
                      child: TextFormField(
                        controller: packageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '12',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: (value) {
                          final int? parsed = int.tryParse(
                            (value ?? '').trim(),
                          );
                          if (parsed == null) return 'Enter valid package';
                          return null;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Deadline',
              child: TextFormField(
                controller: deadlineController,
                readOnly: true,
                onTap: onPickDeadline,
                decoration: InputDecoration(
                  hintText: 'Select deadline',
                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                  suffixIcon: IconButton(
                    onPressed: onPickDeadline,
                    icon: const Icon(Icons.date_range_outlined),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Select deadline'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Description',
              child: TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Explain the role, eligibility, and process...',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter description'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(submitting ? 'Adding...' : 'Add Job Posting'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.deleting,
    required this.onDelete,
  });

  final JobItem job;
  final bool deleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE1CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.title} - ${job.company}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: deleting ? null : onDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(deleting ? 'Deleting...' : 'Delete'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _JobMeta(label: job.location, icon: Icons.location_on_outlined),
              _JobMeta(
                label: '${job.packageLpa} LPA',
                icon: Icons.payments_outlined,
              ),
              _JobMeta(
                label: 'Deadline ${AppFormatters.date(job.deadline)}',
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobMeta extends StatelessWidget {
  const _JobMeta({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E7),
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
