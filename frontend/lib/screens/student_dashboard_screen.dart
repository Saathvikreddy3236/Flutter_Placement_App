import 'package:flutter/material.dart';

import '../services/session_store.dart';
import '../widgets/student_navbar.dart';
import 'student_applications_screen.dart';
import 'student_bookmarks_screen.dart';
import 'student_jobs_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const String routeName = '/student-dashboard';

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
                activeTab: null,
                onHomeTap: () {},
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
                child: _DashboardBody(studentName: SessionStore.studentName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.studentName});

  final String studentName;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth > 980;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _HeroText(studentName: studentName)),
                  const SizedBox(width: 14),
                  const Expanded(flex: 4, child: _CurrentDrive()),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroText(studentName: studentName),
                const SizedBox(height: 12),
                const _CurrentDrive(),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Placement Overview',
          tag: 'This month',
          textTheme: textTheme,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth > 1000
                ? 4
                : constraints.maxWidth > 640
                    ? 2
                    : 1;
            return _Grid(
              columns: columns,
              itemHeight: 170,
              children: const [
                _OverviewCard(
                  title: 'Applied Roles',
                  count: '5',
                  footnote: '2 new since last week',
                ),
                _OverviewCard(
                  title: 'Bookmarked Roles',
                  count: '3',
                  footnote: 'Shortlist to stay focused',
                ),
                _OverviewCard(
                  title: 'Shortlisted',
                  count: '2',
                  footnote: 'Interviews scheduled',
                  showDot: true,
                ),
                _OverviewCard(
                  title: 'Offers Received',
                  count: '1',
                  footnote: 'Congratulations!',
                  showBadge: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.studentName});

  final String studentName;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFDFC7)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9D6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Student Hub',
              style: TextStyle(
                color: Color(0xFF8E3D00),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Welcome, $studentName!', style: textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Track applications, prepare for interviews, and discover roles tailored to your journey.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () {},
                child: const Text('Explore Opportunities'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentDrive extends StatelessWidget {
  const _CurrentDrive();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC75A00), Color(0xFFE48A2E)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF7DFFAE),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE DRIVE',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Placement Drive 2025 - 26',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock your potential with our latest placement drive.',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFFFEEDA),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _MetaPill('30+ companies'),
              _MetaPill('Hybrid interviews'),
              _MetaPill('Starts this week'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x2EFFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.tag,
    required this.textTheme,
  });

  final String title;
  final String tag;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: textTheme.titleLarge)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAD7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Color(0xFF8C4100),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.itemHeight,
    required this.children,
  });

  final int columns;
  final double itemHeight;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: itemHeight,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.count,
    required this.footnote,
    this.showDot = false,
    this.showBadge = false,
  });

  final String title;
  final String count;
  final String footnote;
  final bool showDot;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE1CA)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            count,
            style: textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFC75A00),
            ),
          ),
          const Spacer(),
          if (showDot)
            const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Color(0xFFC75A00)),
                SizedBox(width: 6),
                Text('Interviews scheduled'),
              ],
            )
          else if (showBadge)
            const Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(0xFFE9A86E),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 9, color: Colors.white),
                  ),
                ),
                SizedBox(width: 6),
                Text('Congratulations!'),
              ],
            )
          else
            Text(footnote, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
