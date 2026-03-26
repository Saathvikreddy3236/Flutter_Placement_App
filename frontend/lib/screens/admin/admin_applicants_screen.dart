import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../widgets/admin_navbar.dart';
import '../../widgets/admin_section_shell.dart';

class AdminApplicantsScreen extends StatefulWidget {
  const AdminApplicantsScreen({super.key});

  static const String routeName = '/admin/applicants';

  @override
  State<AdminApplicantsScreen> createState() => _AdminApplicantsScreenState();
}

class _AdminApplicantsScreenState extends State<AdminApplicantsScreen> {
  final ApiService _api = const ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<AdminApplicantItem>> _applicantsFuture;
  List<AdminApplicantItem> _applicants = const <AdminApplicantItem>[];

  @override
  void initState() {
    super.initState();
    _applicantsFuture = _loadApplicants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AdminApplicantItem>> _loadApplicants([String search = '']) async {
    final List<AdminApplicantItem> applicants = await _api.fetchAdminApplicants(
      search: search,
    );
    _applicants = applicants;
    return applicants;
  }

  Future<void> _search() async {
    setState(() {
      _applicantsFuture = _loadApplicants(_searchController.text);
    });
    await _applicantsFuture;
  }

  Future<void> _openProfile(AdminApplicantItem applicant) async {
    final AdminApplicantItem? updatedApplicant = await showDialog<AdminApplicantItem>(
      context: context,
      builder: (context) => _ApplicantProfileDialog(
        applicationId: applicant.id,
        api: _api,
      ),
    );

    if (updatedApplicant == null || !mounted) return;
    setState(() {
      _applicants = _applicants
          .map((item) => item.id == updatedApplicant.id ? updatedApplicant : item)
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminSectionShell(
      activeTab: AdminNavTab.applicants,
      title: 'View Applicants',
      subtitle: 'Search applicants by student name or company, open their profile, and update the result status.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by student name or company',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(onPressed: _search, child: const Text('Search')),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<AdminApplicantItem>>(
            future: _applicantsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _applicants.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError && _applicants.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Failed to load applicants: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _search, child: const Text('Retry')),
                  ],
                );
              }
              if (_applicants.isEmpty) {
                return const AdminInfoCard(
                  title: 'No applicants found',
                  detail: 'Try another search term or wait for students to apply.',
                );
              }
              return Column(
                children: [
                  for (final AdminApplicantItem applicant in _applicants) ...[
                    AdminInfoCard(
                      title: '${applicant.studentName} - ${applicant.jobTitle}',
                      detail: '${applicant.company} | ${applicant.branch} | ${applicant.status}',
                      actionLabel: 'View Profile',
                      onActionTap: () => _openProfile(applicant),
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

class _ApplicantProfileDialog extends StatefulWidget {
  const _ApplicantProfileDialog({
    required this.applicationId,
    required this.api,
  });

  final int applicationId;
  final ApiService api;

  @override
  State<_ApplicantProfileDialog> createState() => _ApplicantProfileDialogState();
}

class _ApplicantProfileDialogState extends State<_ApplicantProfileDialog> {
  late Future<AdminApplicationDetail> _detailFuture;
  String? _selectedStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.api.fetchAdminApplicationDetail(widget.applicationId);
  }

  Future<void> _save(AdminApplicationDetail detail) async {
    if (_selectedStatus == null || _selectedStatus == detail.application.status) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      final AdminApplicantItem updated = await widget.api.updateApplicationStatus(
        applicationId: widget.applicationId,
        status: _selectedStatus!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: FutureBuilder<AdminApplicationDetail>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Failed to load profile: ${snapshot.error}'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                );
              }

              final AdminApplicationDetail detail = snapshot.data!;
              _selectedStatus ??= detail.application.status;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(detail.application.studentName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('${detail.application.company} - ${detail.application.jobTitle}'),
                    const SizedBox(height: 14),
                    _ProfileLine(label: 'Email', value: detail.profile.email),
                    _ProfileLine(label: 'Phone', value: detail.profile.phone),
                    _ProfileLine(label: 'Branch', value: detail.profile.branch),
                    _ProfileLine(label: 'Year', value: '${detail.profile.year}'),
                    _ProfileLine(label: 'CGPA', value: detail.profile.cgpa.toStringAsFixed(2)),
                    _ProfileLine(label: 'Graduation Year', value: '${detail.profile.graduationYear}'),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Application Status'),
                      items: detail.statusChoices
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: _saving
                          ? null
                          : (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _saving ? null : () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _saving ? null : () => _save(detail),
                          child: Text(_saving ? 'Saving...' : 'Update Status'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: ${value.isEmpty ? 'Not added' : value}'),
    );
  }
}
