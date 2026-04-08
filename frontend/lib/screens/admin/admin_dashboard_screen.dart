import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../utils/formatters.dart';
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
                  onProfileTap: () async {
                    final bool updated = await showProfileDialog(context);
                    if (!mounted || !updated) return;
                    await _refresh();
                  },
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
    final int pendingApplicants = data.stats.totalApplicants -
        data.stats.offeredStudents -
        data.stats.rejectedStudents;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _AdminHero(
          pendingApplicants: pendingApplicants < 0 ? 0 : pendingApplicants,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth > 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _QuickActionsPanel(
                      onPostJob: () => Navigator.pushReplacementNamed(
                        context,
                        AdminPostingsScreen.routeName,
                      ),
                      onViewApplicants: () => Navigator.pushReplacementNamed(
                        context,
                        AdminApplicantsScreen.routeName,
                      ),
                      onViewCompanies: () => Navigator.pushReplacementNamed(
                        context,
                        AdminAnalyticsScreen.routeName,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _SnapshotPanel(
                      activeJobs: data.stats.activeJobPosts,
                      totalApplicants: data.stats.totalApplicants,
                      offeredStudents: data.stats.offeredStudents,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _QuickActionsPanel(
                  onPostJob: () => Navigator.pushReplacementNamed(
                    context,
                    AdminPostingsScreen.routeName,
                  ),
                  onViewApplicants: () => Navigator.pushReplacementNamed(
                    context,
                    AdminApplicantsScreen.routeName,
                  ),
                  onViewCompanies: () => Navigator.pushReplacementNamed(
                    context,
                    AdminAnalyticsScreen.routeName,
                  ),
                ),
                const SizedBox(height: 12),
                _SnapshotPanel(
                  activeJobs: data.stats.activeJobPosts,
                  totalApplicants: data.stats.totalApplicants,
                  offeredStudents: data.stats.offeredStudents,
                ),
              ],
            );
          },
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
                badge: 'Live now',
                accent: const Color(0xFF12355B),
                iconSurface: const Color(0xFFEAF1F8),
                border: const Color(0xFFD7E4F3),
              ),
              _StatCard(
                icon: Icons.groups_2_outlined,
                title: 'Total Applicants',
                value: '${data.stats.totalApplicants}',
                badge: 'Across roles',
                accent: const Color(0xFF9C5B13),
                iconSurface: const Color(0xFFFFF0E1),
                border: const Color(0xFFFFE2CB),
              ),
              _StatCard(
                icon: Icons.workspace_premium_outlined,
                title: 'Offered',
                value: '${data.stats.offeredStudents}',
                badge: 'Decision stage',
                accent: const Color(0xFF2B6B4B),
                iconSurface: const Color(0xFFE6F4EA),
                border: const Color(0xFFCBE6D4),
              ),
              _StatCard(
                icon: Icons.person_off_outlined,
                title: 'Rejected',
                value: '${data.stats.rejectedStudents}',
                badge: 'Closed out',
                accent: const Color(0xFF9F2D2D),
                iconSurface: const Color(0xFFFFECEC),
                border: const Color(0xFFF3D1D1),
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
    required this.accent,
    required this.iconSurface,
    required this.border,
  });

  final IconData icon;
  final String title;
  final String value;
  final String badge;
  final Color accent;
  final Color iconSurface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
              Text(
                badge,
                style: TextStyle(
                  color: accent,
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
                ?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({required this.pendingApplicants});

  final int pendingApplicants;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF12355B), Color(0xFF1E527F), Color(0xFFB98930)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stacked = constraints.maxWidth < 760;
          final Widget copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Admin Command Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome back, ${SessionStore.studentName}.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Review live hiring activity, push new openings, and keep placement operations moving without jumping between screens.',
                style: TextStyle(
                  color: Color(0xFFE9F0F7),
                  height: 1.45,
                ),
              ),
            ],
          );

          final Widget highlight = Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Needs Attention',
                  style: TextStyle(
                    color: Color(0xFFDCE8F4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$pendingApplicants',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'applications are still pending a final review or status update.',
                  style: TextStyle(color: Color(0xFFE8EFF6), height: 1.4),
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 16),
                highlight,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: highlight),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({
    required this.onPostJob,
    required this.onViewApplicants,
    required this.onViewCompanies,
  });

  final VoidCallback onPostJob;
  final VoidCallback onViewApplicants;
  final VoidCallback onViewCompanies;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Quick Actions',
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.add_business_outlined,
            title: 'Post a new opening',
            subtitle: 'Create a fresh job post and make it available to students immediately.',
            accent: const Color(0xFF12355B),
            onTap: onPostJob,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.fact_check_outlined,
            title: 'Review applicants',
            subtitle: 'Open the applicant pipeline and update statuses for pending candidates.',
            accent: const Color(0xFFB96C17),
            onTap: onViewApplicants,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.business_center_outlined,
            title: 'Check company activity',
            subtitle: 'Compare company-level hiring traction, offers, rejections, and pending counts.',
            accent: const Color(0xFF2B6B4B),
            onTap: onViewCompanies,
          ),
        ],
      ),
    );
  }
}

class _SnapshotPanel extends StatelessWidget {
  const _SnapshotPanel({
    required this.activeJobs,
    required this.totalApplicants,
    required this.offeredStudents,
  });

  final int activeJobs;
  final int totalApplicants;
  final int offeredStudents;

  @override
  Widget build(BuildContext context) {
    final double offerRate = totalApplicants == 0
        ? 0
        : (offeredStudents / totalApplicants) * 100;

    return _PanelCard(
      title: 'Snapshot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SnapshotRow(label: 'Live openings', value: '$activeJobs'),
          const SizedBox(height: 10),
          _SnapshotRow(label: 'Applicant volume', value: '$totalApplicants'),
          const SizedBox(height: 10),
          _SnapshotRow(label: 'Offer conversion', value: '${offerRate.toStringAsFixed(1)}%'),
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
                    icon: Icons.work_outline_rounded,
                    title: '${job.company} - ${job.title}',
                    subtitle:
                        '${job.location} | ${job.packageLpa} LPA | ${AppFormatters.date(job.deadline)}',
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
                    icon: Icons.person_outline_rounded,
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
  const _MiniRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFDF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFC75A00)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5ECF4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: accent),
          ],
        ),
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE6F2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF12355B),
            ),
          ),
        ],
      ),
    );
  }
}
