import 'package:flutter/material.dart';

class LandingNavbar extends StatelessWidget {
  const LandingNavbar({
    super.key,
    required this.onOutcomesTap,
    required this.onProcessTap,
    required this.onContactTap,
    required this.onLoginTap,
  });

  final VoidCallback onOutcomesTap;
  final VoidCallback onProcessTap;
  final VoidCallback onContactTap;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFFFE1CC))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 860;

          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandTitle(),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _NavLink(label: 'Outcomes', onTap: onOutcomesTap),
                        _NavLink(label: 'Process', onTap: onProcessTap),
                        _NavLink(label: 'Contact', onTap: onContactTap),
                        FilledButton(
                          onPressed: onLoginTap,
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    const _BrandTitle(),
                    const Spacer(),
                    _NavLink(label: 'Outcomes', onTap: onOutcomesTap),
                    _NavLink(label: 'Process', onTap: onProcessTap),
                    _NavLink(label: 'Contact', onTap: onContactTap),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: onLoginTap,
                      child: const Text('Login'),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        text: 'Placement Portal\n',
        style: TextStyle(
          color: Color(0xFF7A3E00),
          fontSize: 19,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        children: [
          TextSpan(
            text: 'NIT AP',
            style: TextStyle(
              color: Color(0xFFA06A3B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onTap, child: Text(label));
  }
}
