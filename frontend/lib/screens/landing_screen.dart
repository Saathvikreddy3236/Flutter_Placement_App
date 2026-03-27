import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_service.dart';
import '../widgets/landing_footer.dart';
import '../widgets/landing_navbar.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  static const String routeName = '/';

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _recruitmentKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final ApiService _api = const ApiService();
  late Future<LandingSummaryData> _landingFuture = _api.fetchLandingSummary();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  void _scrollToKey(GlobalKey key) {
    final BuildContext? targetContext = key.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5EA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              LandingNavbar(
                onOutcomesTap: () => _scrollToKey(_statsKey),
                onProcessTap: () => _scrollToKey(_recruitmentKey),
                onContactTap: () => _scrollToKey(_contactKey),
                onLoginTap: _goToLogin,
              ),
              Expanded(
                child: FutureBuilder<LandingSummaryData>(
                  future: _landingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Failed to load landing page: ${snapshot.error}'),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _landingFuture = _api.fetchLandingSummary();
                                  });
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final LandingSummaryData data = snapshot.data!;
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1160),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HeroSection(
                                  data: data,
                                  onLoginTap: _goToLogin,
                                  onViewOutcomesTap: () => _scrollToKey(_statsKey),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  key: _statsKey,
                                  child: _Section(
                                    title: 'Placement outcomes at a glance',
                                    subtitle:
                                        'Live metrics from the backend so the placement story stays current and transparent.',
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final int columns = constraints.maxWidth > 980
                                            ? 5
                                            : constraints.maxWidth > 640
                                                ? 3
                                                : 2;

                                        return _ResponsiveGrid(
                                          columns: columns,
                                          itemHeight: 148,
                                          children: [
                                            _StatCard(
                                              value: '${data.outcomes.studentsPlaced}+',
                                              label: 'Students placed',
                                            ),
                                            _StatCard(
                                              value: '${data.outcomes.placementRate}%',
                                              label: 'Placement rate',
                                            ),
                                            _StatCard(
                                              value: 'INR ${data.outcomes.highestPackageLpa} LPA',
                                              label: 'Highest package',
                                            ),
                                            _StatCard(
                                              value: 'INR ${data.outcomes.averagePackageLpa.toStringAsFixed(1)} LPA',
                                              label: 'Average package',
                                            ),
                                            _StatCard(
                                              value: '${data.outcomes.companiesVisited}+',
                                              label: 'Companies visited',
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  key: _recruitmentKey,
                                  child: _Section(
                                    title: 'Recruitment process',
                                    subtitle:
                                        'A structured journey that keeps students, recruiters, and the placement cell aligned.',
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final int columns = constraints.maxWidth > 980
                                            ? 3
                                            : constraints.maxWidth > 650
                                                ? 2
                                                : 1;
                                        return _ResponsiveGrid(
                                          columns: columns,
                                          itemHeight: 210,
                                          children: const [
                                            _StepCard(
                                              index: 1,
                                              title: 'Company registration',
                                              body:
                                                  'Recruiters submit details for placement cell verification.',
                                            ),
                                            _StepCard(
                                              index: 2,
                                              title: 'Role publishing',
                                              body:
                                                  'Job roles, criteria, and timelines go live on the portal.',
                                            ),
                                            _StepCard(
                                              index: 3,
                                              title: 'Student applications',
                                              body:
                                                  'Eligible students apply and track progress instantly.',
                                            ),
                                            _StepCard(
                                              index: 4,
                                              title: 'Shortlisting',
                                              body:
                                                  'Recruiters review profiles and shortlist candidates.',
                                            ),
                                            _StepCard(
                                              index: 5,
                                              title: 'Interviews & tests',
                                              body:
                                                  'Technical rounds and HR discussions happen on schedule.',
                                            ),
                                            _StepCard(
                                              index: 6,
                                              title: 'Offer decisions',
                                              body:
                                                  'Offers are released through the portal for acceptance.',
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const SizedBox(height: 26),
                                Container(
                                  key: _contactKey,
                                  child: LandingFooter(
                                    onOutcomesTap: () => _scrollToKey(_statsKey),
                                    onProcessTap: () => _scrollToKey(_recruitmentKey),
                                    onContactTap: () => _scrollToKey(_contactKey),
                                    onStudentLoginTap: _goToLogin,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.data,
    required this.onLoginTap,
    required this.onViewOutcomesTap,
  });

  final LandingSummaryData data;
  final VoidCallback onLoginTap;
  final VoidCallback onViewOutcomesTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 900;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _HeroText(
                      outcomes: data.outcomes,
                      onLoginTap: onLoginTap,
                      onViewOutcomesTap: onViewOutcomesTap,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: _HeroCard(hero: data.hero)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroText(
                    outcomes: data.outcomes,
                    onLoginTap: onLoginTap,
                    onViewOutcomesTap: onViewOutcomesTap,
                  ),
                  const SizedBox(height: 14),
                  _HeroCard(hero: data.hero),
                ],
              );
      },
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.outcomes,
    required this.onLoginTap,
    required this.onViewOutcomesTap,
  });

  final LandingOutcomeStats outcomes;
  final VoidCallback onLoginTap;
  final VoidCallback onViewOutcomesTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4CC),
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'NIT AP Placement Cell',
              style: textTheme.labelLarge?.copyWith(
                color: const Color(0xFFE65100),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Build your career pathway with clarity and confidence.',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'From applications to offers, the portal keeps every placement milestone in one modern workspace.',
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF7A5A45),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: onLoginTap,
                child: const Text('Get Started'),
              ),
              OutlinedButton(
                onPressed: onViewOutcomesTap,
                child: const Text('View Outcomes'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _MetaTag(text: '${outcomes.companiesVisited}+ recruiters'),
              _MetaTag(text: '${outcomes.placementRate}% placements'),
              const _MetaTag(text: 'Career support year-round'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hero});

  final LandingHeroStats hero;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF6BFFA8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Live season updates',
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Placement Drive 2025-26',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track deadlines, shortlists, and interview schedules in a single dashboard.',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          _ResponsiveGrid(
            columns: 2,
            itemHeight: 88,
            children: [
              _HeroMetric(value: '${hero.upcomingDrives}+', label: 'Upcoming drives'),
              _HeroMetric(value: '${hero.activeRoles}', label: 'Active roles'),
              _HeroMetric(value: '${hero.interviewSlots}', label: 'Interview slots'),
              _HeroMetric(value: '${hero.offerCalls}', label: 'Offer calls'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6E4B2E),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7A5A45),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: itemHeight,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFFE65100),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE65100),
            child: Text('$index', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}
