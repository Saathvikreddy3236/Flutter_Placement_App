import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/admin_navbar.dart';
import '../../widgets/logout_back_guard.dart';
import '../../widgets/profile_dialog.dart';
import 'admin_analytics_screen.dart';
import 'admin_applicants_screen.dart';
import 'admin_postings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = const ApiService();
  late Future<AdminDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _api.fetchAdminDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _api.fetchAdminDashboard();
    });
    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    if (SessionStore.userRole != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Access')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'You do not have admin access.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return LogoutBackGuard(
      child: Scaffold(
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
                AdminNavbar(
                  adminName: SessionStore.studentName,
                  onProfileTap: () => showProfileDialog(context),
                  onLogout: () {
                    SessionStore.clear();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  activeTab: AdminNavTab.dashboard,
                  onDashboardTap: () {},
                  onPostingsTap: () => Navigator.pushReplacementNamed(
                    context,
                    AdminPostingsScreen.routeName,
                  ),
                  onApplicantsTap: () => Navigator.pushReplacementNamed(
                    context,
                    AdminApplicantsScreen.routeName,
                  ),
                  onAnalyticsTap: () => Navigator.pushReplacementNamed(
                    context,
                    AdminAnalyticsScreen.routeName,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<AdminDashboardData>(
                    future: _dashboardFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Failed to load admin dashboard: ${snapshot.error}'),
                              const SizedBox(height: 10),
                              OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
                            ],
                          ),
                        );
                      }

                      final AdminDashboardData data = snapshot.data!;
                      return _DashboardBody(data: data);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${SessionStore.studentName}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track new postings, student applications, and company activity from one place.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AdminPostingsScreen.routeName,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Post New Job'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth > 1100
                ? 4
                : constraints.maxWidth > 640
                    ? 2
                    : 1;
            final List<Widget> cards = [
              _StatCard(
                icon: Icons.work_outline_rounded,
                title: 'Active Job Posts',
                value: '${data.stats.activeJobPosts}',
                badge: 'Live',
              ),
              _StatCard(
                icon: Icons.groups_2_outlined,
                title: 'Total Applicants',
                value: '${data.stats.totalApplicants}',
                badge: 'All jobs',
              ),
              _StatCard(
                icon: Icons.workspace_premium_outlined,
                title: 'Offered',
                value: '${data.stats.offeredStudents}',
                badge: 'Final stage',
              ),
              _StatCard(
                icon: Icons.person_off_outlined,
                title: 'Rejected',
                value: '${data.stats.rejectedStudents}',
                badge: 'Completed',
              ),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 138,
              ),
              itemBuilder: (context, index) => cards[index],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth > 920;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _RecentJobsCard(jobs: data.recentJobs)),
                  const SizedBox(width: 12),
                  Expanded(child: _RecentApplicantsCard(applicants: data.recentApplicants)),
                ],
              );
            }
            return Column(
              children: [
                _RecentJobsCard(jobs: data.recentJobs),
                const SizedBox(height: 12),
                _RecentApplicantsCard(applicants: data.recentApplicants),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String value;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE1CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEDD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFFC75A00)),
              ),
              const Spacer(),
              Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFFC75A00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: const Color(0xFFC75A00)),
          ),
        ],
      ),
    );
  }
}

class _RecentJobsCard extends StatelessWidget {
  const _RecentJobsCard({required this.jobs});

  final List<JobItem> jobs;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Recent Jobs',
      child: jobs.isEmpty
          ? const Text('No jobs posted yet.')
          : Column(
              children: [
                for (final JobItem job in jobs) ...[
                  _MiniRow(
                    title: '${job.company} - ${job.title}',
                    subtitle: '${job.location} | ${job.packageLpa} LPA | ${job.deadline}',
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _RecentApplicantsCard extends StatelessWidget {
  const _RecentApplicantsCard({required this.applicants});

  final List<AdminApplicantItem> applicants;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Recent Applicants',
      child: applicants.isEmpty
          ? const Text('No applications received yet.')
          : Column(
              children: [
                for (final AdminApplicantItem applicant in applicants) ...[
                  _MiniRow(
                    title: '${applicant.studentName} - ${applicant.jobTitle}',
                    subtitle: '${applicant.company} | ${applicant.status}',
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE1CA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE9D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}
