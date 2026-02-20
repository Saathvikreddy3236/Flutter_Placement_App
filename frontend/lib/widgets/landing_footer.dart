import 'package:flutter/material.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({
    super.key,
    required this.onOutcomesTap,
    required this.onProcessTap,
    required this.onContactTap,
    required this.onStudentLoginTap,
  });

  final VoidCallback onOutcomesTap;
  final VoidCallback onProcessTap;
  final VoidCallback onContactTap;
  final VoidCallback onStudentLoginTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3B1F0F),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool stacked = constraints.maxWidth < 860;
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandColumn(textTheme: textTheme),
                    const SizedBox(height: 18),
                    _FooterLinks(
                      title: 'Explore',
                      links: [
                        _FooterAction(
                          label: 'Student Login',
                          onTap: onStudentLoginTap,
                        ),
                        _FooterAction(
                          label: 'Recruiter Login',
                          onTap: onStudentLoginTap,
                        ),
                        _FooterAction(
                          label: 'Dashboard Preview',
                          onTap: onStudentLoginTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FooterLinks(
                      title: 'Resources',
                      links: [
                        _FooterAction(label: 'Outcomes', onTap: onOutcomesTap),
                        _FooterAction(label: 'Process', onTap: onProcessTap),
                        _FooterAction(label: 'Contact', onTap: onContactTap),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _ContactColumn(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _BrandColumn(textTheme: textTheme)),
                  Expanded(
                    child: _FooterLinks(
                      title: 'Explore',
                      links: [
                        _FooterAction(
                          label: 'Student Login',
                          onTap: onStudentLoginTap,
                        ),
                        _FooterAction(
                          label: 'Recruiter Login',
                          onTap: onStudentLoginTap,
                        ),
                        _FooterAction(
                          label: 'Dashboard Preview',
                          onTap: onStudentLoginTap,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _FooterLinks(
                      title: 'Resources',
                      links: [
                        _FooterAction(label: 'Outcomes', onTap: onOutcomesTap),
                        _FooterAction(label: 'Process', onTap: onProcessTap),
                        _FooterAction(label: 'Contact', onTap: onContactTap),
                      ],
                    ),
                  ),
                  const Expanded(child: _ContactColumn()),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF6C3D1E)),
          const SizedBox(height: 10),
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                '(c) 2026 NIT AP Placement Portal',
                style: TextStyle(color: Color(0xFFFFDCC3)),
              ),
              Text(
                'All rights reserved',
                style: TextStyle(color: Color(0xFFFFDCC3)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandColumn extends StatelessWidget {
  const _BrandColumn({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Placement Portal',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your single destination for placements, internships, and career growth at NIT AP.',
          style: textTheme.bodyMedium?.copyWith(color: const Color(0xFFFFDCC3)),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.title, required this.links});

  final String title;
  final List<_FooterAction> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final _FooterAction link in links)
          TextButton(
            onPressed: link.onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              link.label,
              style: const TextStyle(color: Color(0xFFFFDCC3)),
            ),
          ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'placementcell@nitap.edu.in',
          style: TextStyle(color: Color(0xFFFFDCC3)),
        ),
        Text('+91 88888 88888', style: TextStyle(color: Color(0xFFFFDCC3))),
        Text(
          'Academic Block, NIT AP',
          style: TextStyle(color: Color(0xFFFFDCC3)),
        ),
      ],
    );
  }
}

class _FooterAction {
  const _FooterAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}
