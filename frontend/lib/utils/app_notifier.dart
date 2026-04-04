import 'package:flutter/material.dart';

enum AppNoticeType { success, error, info }

class AppNotifier {
  AppNotifier._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static OverlayEntry? _activeOverlay;

  static Future<void> showSuccess(
    BuildContext context,
    String title,
    String message,
  ) {
    return _show(context, title, message, AppNoticeType.success);
  }

  static Future<void> showError(
    BuildContext context,
    String title,
    String message,
  ) {
    return _show(context, title, message, AppNoticeType.error);
  }

  static Future<void> showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    return _show(context, title, message, AppNoticeType.info);
  }

  static Future<void> showSuccessMessage(String title, String message) {
    return _show(null, title, message, AppNoticeType.success);
  }

  static Future<void> showErrorMessage(String title, String message) {
    return _show(null, title, message, AppNoticeType.error);
  }

  static Future<void> showInfoMessage(String title, String message) {
    return _show(null, title, message, AppNoticeType.info);
  }

  static Future<void> _show(
    BuildContext? context,
    String title,
    String message,
    AppNoticeType type,
  ) async {
    final BuildContext? activeContext = context ?? navigatorKey.currentContext;
    if (activeContext == null || !activeContext.mounted) return;

    final _NoticePalette palette = switch (type) {
      AppNoticeType.success => const _NoticePalette(
        icon: Icons.check_circle_outline,
        accent: Color(0xFF2B6B4B),
        surface: Color(0xFFF3FBF6),
        border: Color(0xFFB9E3C8),
        iconSurface: Color(0xFFE2F5E8),
      ),
      AppNoticeType.error => const _NoticePalette(
        icon: Icons.error_outline,
        accent: Color(0xFF9F2D2D),
        surface: Color(0xFFFFF5F5),
        border: Color(0xFFF1C5C5),
        iconSurface: Color(0xFFFFE7E7),
      ),
      AppNoticeType.info => const _NoticePalette(
        icon: Icons.info_outline,
        accent: Color(0xFF234A79),
        surface: Color(0xFFF4F8FC),
        border: Color(0xFFC9D9EE),
        iconSurface: Color(0xFFE6EFF8),
      ),
    };

    final OverlayState? overlay =
        navigatorKey.currentState?.overlay ??
        Overlay.maybeOf(activeContext, rootOverlay: true);
    if (overlay == null) return;

    _activeOverlay?.remove();
    final OverlayEntry entry = OverlayEntry(
      builder: (overlayContext) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            constraints: const BoxConstraints(maxWidth: 640),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: palette.iconSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(palette.icon, color: palette.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(overlayContext).textTheme.titleSmall
                                ?.copyWith(
                                  color: palette.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: Theme.of(overlayContext).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF2D3A48),
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    _activeOverlay = entry;
    overlay.insert(entry);
    await Future<void>.delayed(const Duration(seconds: 3));
    if (_activeOverlay == entry) {
      _activeOverlay?.remove();
      _activeOverlay = null;
    }
  }
}

class _NoticePalette {
  const _NoticePalette({
    required this.icon,
    required this.accent,
    required this.surface,
    required this.border,
    required this.iconSurface,
  });

  final IconData icon;
  final Color accent;
  final Color surface;
  final Color border;
  final Color iconSurface;
}
