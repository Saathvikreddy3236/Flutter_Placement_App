import 'package:flutter/material.dart';

import '../../services/session_store.dart';
import '../../widgets/admin_navbar.dart';
import 'admin_analytics_screen.dart';
import 'admin_applicants_screen.dart';
import 'admin_postings_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

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
              AdminNavbar(
                adminName: SessionStore.studentName,
                onLogout: () {
                  SessionStore.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
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
              const Expanded(child: _AdminDashboardBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 760;
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${SessionStore.studentName}!',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here's what's happening with your recruitment cycle today.",
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Post New Job'),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${SessionStore.studentName}!',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Here's what's happening with your recruitment cycle today.",
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Post New Job'),
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

            final List<Widget> cards = const [
              _StatCard(
                icon: Icons.work_outline_rounded,
                title: 'Active Job Posts',
                value: '12',
                badge: '+2 New',
              ),
              _StatCard(
                icon: Icons.groups_2_outlined,
                title: 'Total Applicants',
                value: '842',
                badge: 'Total',
              ),
              _StatCard(
                icon: Icons.how_to_reg_outlined,
                title: 'Shortlisted Students',
                value: '156',
                badge: 'Step 2',
              ),
              _StatCard(
                icon: Icons.calendar_month_outlined,
                title: 'Scheduled Interviews',
                value: '24',
                badge: 'Upcoming',
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
        const _Footer(),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: const Color(0xFFC75A00)),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            '© 2026 CampusHire CampusHeir. All rights reserved.',
            style: TextStyle(color: Color(0xFF8F715D)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                'Support Center',
                style: TextStyle(color: Color(0xFF8F715D)),
              ),
              Text(
                'Privacy Policy',
                style: TextStyle(color: Color(0xFF8F715D)),
              ),
              Text('System Status', style: TextStyle(color: Color(0xFF8F715D))),
            ],
          ),
        ],
      ),
    );
  }
}
