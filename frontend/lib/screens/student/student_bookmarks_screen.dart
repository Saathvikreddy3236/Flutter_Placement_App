import 'package:flutter/material.dart';

import '../../models/api_models.dart';
import '../../services/api_service.dart';
import '../../services/session_store.dart';
import '../../widgets/student_navbar.dart';
import '../../widgets/student_section_shell.dart';

class StudentBookmarksScreen extends StatefulWidget {
  const StudentBookmarksScreen({super.key});

  static const String routeName = '/student/bookmarks';

  @override
  State<StudentBookmarksScreen> createState() => _StudentBookmarksScreenState();
}

class _StudentBookmarksScreenState extends State<StudentBookmarksScreen> {
  final ApiService _api = const ApiService();
  late Future<List<BookmarkItem>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _bookmarksFuture = _fetchBookmarks();
  }

  Future<List<BookmarkItem>> _fetchBookmarks() {
    final int? studentId = SessionStore.studentId;
    if (studentId == null) {
      throw Exception('Please login first.');
    }
    return _api.fetchBookmarks(studentId);
  }

  Future<void> _refresh() async {
    setState(() {
      _bookmarksFuture = _fetchBookmarks();
    });
    await _bookmarksFuture;
  }

  @override
  Widget build(BuildContext context) {
    return StudentSectionShell(
      activeTab: StudentNavTab.bookmarks,
      title: 'My Bookmarks',
      subtitle: 'Saved opportunities so you can compare and apply at the right time.',
      child: FutureBuilder<List<BookmarkItem>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Failed to load bookmarks: ${snapshot.error}'),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }

          final List<BookmarkItem> bookmarks = snapshot.data ?? const [];
          if (bookmarks.isEmpty) {
            return const Text('No bookmarked jobs yet. Save jobs from All Jobs to see them here.');
          }

          return Column(
            children: [
              for (final BookmarkItem bookmark in bookmarks) ...[
                _BookmarkCard(bookmark: bookmark),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.bookmark});

  final BookmarkItem bookmark;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4CE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark, color: Color(0xFFC75A00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${bookmark.company} - ${bookmark.jobTitle}',
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(bookmark.description, style: textTheme.bodyMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BookmarkTag(icon: Icons.location_on_outlined, label: bookmark.location),
              _BookmarkTag(icon: Icons.payments_outlined, label: '${bookmark.packageLpa} LPA'),
              _BookmarkTag(icon: Icons.event_outlined, label: 'Deadline ${bookmark.deadline}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookmarkTag extends StatelessWidget {
  const _BookmarkTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9B4D0A)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
