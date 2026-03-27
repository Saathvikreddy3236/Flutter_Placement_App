import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/logout_back_guard.dart';
import '../../widgets/student_navbar.dart';
import '../../widgets/profile_dialog.dart';
import 'student_applications_screen.dart';
import 'student_bookmarks_screen.dart';
import 'student_jobs_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  static const String routeName = '/student-dashboard';

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final ApiService _api = const ApiService();
  late Future<StudentDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<StudentDashboardData> _loadDashboard() {
    final int? studentId = SessionStore.studentId;
    if (studentId == null) {
      throw Exception('Please login first.');
    }
    return _api.fetchStudentDashboard(studentId);
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
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
                StudentNavbar(
                  studentName: SessionStore.studentName,
                  onProfileTap: () => showProfileDialog(context),
                  onLogout: () {
                    SessionStore.clear();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                  child: FutureBuilder<StudentDashboardData>(
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
                              Text('Failed to load dashboard: ${snapshot.error}'),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _refresh,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final StudentDashboardData dashboard = snapshot.data!;
                      return _DashboardBody(data: dashboard);
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

  final StudentDashboardData data;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (data.acceptedOffer != null) ...[
          _CongratulationsBanner(application: data.acceptedOffer!),
          const SizedBox(height: 14),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth > 980;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _HeroText(data: data)),
                  const SizedBox(width: 14),
                  Expanded(flex: 4, child: _ProfileCard(profile: data.profile, stats: data.stats)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroText(data: data),
                const SizedBox(height: 12),
                _ProfileCard(profile: data.profile, stats: data.stats),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Placement Overview',
          tag: 'Live data',
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
              children: [
                _OverviewCard(
                  title: 'Applied Roles',
                  count: '${data.stats.appliedRoles}',
                  footnote: 'Applications submitted so far',
                ),
                _OverviewCard(
                  title: 'Bookmarked Roles',
                  count: '${data.stats.bookmarkedRoles}',
                  footnote: 'Saved for review',
                ),
                _OverviewCard(
                  title: 'Shortlisted',
                  count: '${data.stats.shortlisted}',
                  footnote: 'Selected applications',
                  showDot: data.stats.shortlisted > 0,
                ),
                _OverviewCard(
                  title: 'Pending Reviews',
                  count: '${data.stats.pendingReviews}',
                  footnote: 'Awaiting recruiter updates',
                  showBadge: data.stats.pendingReviews > 0,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth > 920;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _ActivityPanel(data: data)),
                  const SizedBox(width: 14),
                  Expanded(child: _RecommendationPanel(jobs: data.recommendedJobs)),
                ],
              );
            }
            return Column(
              children: [
                _ActivityPanel(data: data),
                const SizedBox(height: 14),
                _RecommendationPanel(jobs: data.recommendedJobs),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.data});

  final StudentDashboardData data;

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
          Text('Welcome, ${data.profile.fullName.isEmpty ? SessionStore.studentName : data.profile.fullName}!', style: textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'You have ${data.stats.availableJobs} active jobs in the system. Keep your momentum going with saved roles, recent applications, and fresh recommendations.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  StudentJobsScreen.routeName,
                ),
                child: const Text('Explore Opportunities'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  StudentApplicationsScreen.routeName,
                ),
                child: const Text('View Applications'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CongratulationsBanner extends StatelessWidget {
  const _CongratulationsBanner({required this.application});

  final ApplicationItem application;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC75A00), Color(0xFFE79A45)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Congratulations!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have accepted the offer for ${application.jobTitle} at ${application.company}.',
            style: const TextStyle(
              color: Color(0xFFFFF2E6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your placement is confirmed and other applications are now closed.',
            style: TextStyle(color: Color(0xFFFFF2E6)),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.stats});

  final StudentProfileItem profile;
  final DashboardStats stats;

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
          Text(
            'Profile Snapshot',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            '${profile.branch} | Year ${profile.year}',
            style: textTheme.bodyMedium?.copyWith(color: const Color(0xFFFFEEDA)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill('CGPA ${profile.cgpa.toStringAsFixed(1)}'),
              _MetaPill('Grad ${profile.graduationYear}'),
              _MetaPill('${stats.availableJobs} open roles'),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileLine(label: 'Email', value: profile.email.isEmpty ? 'Not added' : profile.email),
          const SizedBox(height: 8),
          _ProfileLine(label: 'Phone', value: profile.phone.isEmpty ? 'Not added' : profile.phone),
          const SizedBox(height: 8),
          _ProfileLine(label: 'Username', value: profile.username),
        ],
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
    return Text(
      '$label: $value',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({required this.data});

  final StudentDashboardData data;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recent Activity',
      child: Column(
        children: [
          if (data.recentApplications.isEmpty)
            const _EmptyNote('No applications yet. Start exploring jobs to build your pipeline.')
          else
            for (final ApplicationItem application in data.recentApplications) ...[
              _ListTileCard(
                icon: Icons.description_outlined,
                title: '${application.company} - ${application.jobTitle}',
                subtitle: '${application.status} | ${application.location}',
              ),
              const SizedBox(height: 10),
            ],
          if (data.recentBookmarks.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved jobs',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            for (final BookmarkItem bookmark in data.recentBookmarks) ...[
              _ListTileCard(
                icon: Icons.bookmark_border,
                title: '${bookmark.company} - ${bookmark.jobTitle}',
                subtitle: '${bookmark.location} | ${bookmark.packageLpa} LPA',
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({required this.jobs});

  final List<JobItem> jobs;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recommended Jobs',
      child: jobs.isEmpty
          ? const _EmptyNote('No fresh recommendations right now. Check back after new job postings arrive.')
          : Column(
              children: [
                for (final JobItem job in jobs) ...[
                  _ListTileCard(
                    icon: Icons.work_outline,
                    title: '${job.company} - ${job.title}',
                    subtitle: '${job.location} | ${job.packageLpa} LPA',
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE8D7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC75A00)),
          const SizedBox(width: 10),
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

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE8D7)),
      ),
      child: Text(text),
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
                Text('Shortlist active'),
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
                Text('In progress'),
              ],
            )
          else
            Text(footnote, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
