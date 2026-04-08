import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../widgets/admin_navbar.dart';
import '../../widgets/admin_section_shell.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  static const String routeName = '/admin/analytics';

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final ApiService _api = const ApiService();
  late Future<List<CompanySummaryItem>> _companiesFuture;

  @override
  void initState() {
    super.initState();
    _companiesFuture = _api.fetchCompanySummaries();
  }

  Future<void> _refresh() async {
    setState(() {
      _companiesFuture = _api.fetchCompanySummaries();
    });
    await _companiesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return AdminSectionShell(
      activeTab: AdminNavTab.analytics,
      title: 'Companies',
      subtitle:
          'See all companies that have come to campus and how many jobs and applications each company has.',
      onProfileUpdated: _refresh,
      child: FutureBuilder<List<CompanySummaryItem>>(
        future: _companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _CompaniesLoadingView();
          }
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Failed to load companies: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }

          final List<CompanySummaryItem> companies = snapshot.data ?? const [];
          if (companies.isEmpty) {
            return const AdminInfoCard(
              title: 'No companies yet',
              detail: 'Companies will appear here after jobs are posted.',
            );
          }

          return Column(
            children: [
              for (final CompanySummaryItem company in companies) ...[
                _CompanyCard(company: company),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CompaniesLoadingView extends StatelessWidget {
  const _CompaniesLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LoadingCompanyCard(),
        SizedBox(height: 10),
        _LoadingCompanyCard(),
        SizedBox(height: 10),
        _LoadingCompanyCard(),
      ],
    );
  }
}

class _LoadingCompanyCard extends StatefulWidget {
  const _LoadingCompanyCard();

  @override
  State<_LoadingCompanyCard> createState() => _LoadingCompanyCardState();
}

class _LoadingCompanyCardState extends State<_LoadingCompanyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
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
            Container(
              height: 18,
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAD8),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(
                4,
                (index) => Container(
                  height: 34,
                  width: 112,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company});

  final CompanySummaryItem company;

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
          Text(company.company, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(label: 'Jobs ${company.totalJobs}', icon: Icons.work_outline),
              _MetricChip(
                label: 'Applications ${company.totalApplications}',
                icon: Icons.description_outlined,
              ),
              _MetricChip(label: 'Offered ${company.offeredCount}', icon: Icons.workspace_premium_outlined),
              _MetricChip(label: 'Pending ${company.pendingCount}', icon: Icons.timelapse_outlined),
              _MetricChip(label: 'Rejected ${company.rejectedCount}', icon: Icons.person_off_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.icon});

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
