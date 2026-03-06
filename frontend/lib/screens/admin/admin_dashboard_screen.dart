import 'package:flutter/material.dart';

import '../../services/session_store.dart';

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
              _AdminNavbar(adminName: SessionStore.studentName),
              const Expanded(child: _AdminDashboardBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavbar extends StatelessWidget {
  const _AdminNavbar({required this.adminName});

  final String adminName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFFFE6D2))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 980;

          final List<Widget> navItems = const [
            _NavItem(label: 'Dashboard', active: true),
            _NavItem(label: 'My Postings'),
            _NavItem(label: 'View Applicants'),
            _NavItem(label: 'Analytics'),
          ];

          final Widget profile = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE4CE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFFC75A00),
                ),
                const SizedBox(width: 8),
                Text(
                  adminName,
                  style: const TextStyle(
                    color: Color(0xFF4B2D18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () {
                    SessionStore.clear();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BrandCard(),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: navItems),
                const SizedBox(height: 10),
                profile,
              ],
            );
          }

          return Row(
            children: [
              const _BrandCard(),
              const SizedBox(width: 14),
              Expanded(
                child: Wrap(spacing: 8, runSpacing: 8, children: navItems),
              ),
              const SizedBox(width: 12),
              profile,
            ],
          );
        },
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD8B0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7984E)),
      ),
      child: const Text.rich(
        TextSpan(
          text: 'CampusHire\n',
          style: TextStyle(
            color: Color(0xFFB24B00),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          children: [
            TextSpan(
              text: 'Admin Portal',
              style: TextStyle(
                color: Color(0xFFE27B19),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFE1C5) : const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? const Color(0xFFE9A66A) : const Color(0xFFFFE4CE),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF934400) : const Color(0xFF7A5A45),
          fontWeight: FontWeight.w600,
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFE1CA)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    Text('Recent Activity', style: textTheme.titleLarge),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All Applications'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFFFE9D8)),
              const _ActivityRow(
                name: 'John Doe',
                role: 'Applied for Software Engineer (Frontend)',
                when: '2 hours ago',
                college: 'Stanford University',
              ),
              const _ActivityRow(
                name: 'Sarah Jenkins',
                role: 'Applied for Product Management Intern',
                when: '5 hours ago',
                college: 'MIT',
              ),
              const _ActivityRow(
                name: 'Michael Chen',
                role: 'Applied for Backend Developer (L3)',
                when: 'Yesterday',
                college: 'UC Berkeley',
              ),
              const _ActivityRow(
                name: 'Emily Rodriguez',
                role: 'Applied for UX Design Associate',
                when: 'Yesterday',
                college: 'RISD',
                isLast: true,
              ),
            ],
          ),
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.name,
    required this.role,
    required this.when,
    required this.college,
    this.isLast = false,
  });

  final String name;
  final String role;
  final String when;
  final String college;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFEBD9),
                child: Icon(Icons.person, color: Color(0xFFB5611E)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF3E220F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: const TextStyle(color: Color(0xFF775844)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    when,
                    style: const TextStyle(
                      color: Color(0xFF4B2D18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    college,
                    style: const TextStyle(
                      color: Color(0xFF8F715D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                child: const Text('View Profile'),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFFFE9D8)),
      ],
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
            '© 2024 CampusHire Recruitment Portal. All rights reserved.',
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
