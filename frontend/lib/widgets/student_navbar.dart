import 'package:flutter/material.dart';

enum StudentNavTab { jobs, applications, bookmarks }

class StudentNavbar extends StatelessWidget {
  const StudentNavbar({
    super.key,
    required this.studentName,
    required this.onProfileTap,
    required this.onLogout,
    required this.activeTab,
    required this.onHomeTap,
    required this.onJobsTap,
    required this.onApplicationsTap,
    required this.onBookmarksTap,
  });

  final String studentName;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;
  final StudentNavTab? activeTab;
  final VoidCallback onHomeTap;
  final VoidCallback onJobsTap;
  final VoidCallback onApplicationsTap;
  final VoidCallback onBookmarksTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFD9E3EF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 980;

          final List<Widget> navChips = [
            _NavChip(
              label: 'All Jobs',
              active: activeTab == StudentNavTab.jobs,
              onTap: onJobsTap,
            ),
            _NavChip(
              label: 'My Applications',
              active: activeTab == StudentNavTab.applications,
              onTap: onApplicationsTap,
            ),
            _NavChip(
              label: 'My Bookmarks',
              active: activeTab == StudentNavTab.bookmarks,
              onTap: onBookmarksTap,
            ),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandCard(onTap: onHomeTap),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: navChips),
                const SizedBox(height: 10),
                _ProfileCard(
                  studentName: studentName,
                  onProfileTap: onProfileTap,
                  onLogout: onLogout,
                ),
              ],
            );
          }

          return Row(
            children: [
              _BrandCard(onTap: onHomeTap),
              const SizedBox(width: 14),
              Expanded(
                child: Wrap(spacing: 8, runSpacing: 8, children: navChips),
              ),
              const SizedBox(width: 12),
              _ProfileCard(
                studentName: studentName,
                onProfileTap: onProfileTap,
                onLogout: onLogout,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF12355B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF12355B)),
        ),
        child: const Text.rich(
          TextSpan(
            text: 'Placement Portal\n',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'NIT AP',
                style: TextStyle(
                  color: Color(0xFFD7E3F0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEAF1F8) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFF9FB7D2) : const Color(0xFFD8E2ED),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF12355B) : const Color(0xFF435365),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.studentName,
    required this.onProfileTap,
    required this.onLogout,
  });

  final String studentName;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_circle,
                  color: Color(0xFF12355B),
                  size: 27,
                ),
                const SizedBox(width: 8),
                Text(
                  studentName,
                  style: const TextStyle(
                    color: Color(0xFF24374E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onLogout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Color(0xFF12355B), size: 20),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
