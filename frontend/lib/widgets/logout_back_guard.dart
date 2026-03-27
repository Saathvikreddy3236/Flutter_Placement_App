import 'package:flutter/material.dart';

import '../services/session_store.dart';

Future<void> confirmLogoutOnBack(BuildContext context) async {
  final bool? shouldLogout = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Leave portal?'),
        content: const Text(
          'Do you want to logout and return to the landing screen, or stay and continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );

  if (shouldLogout == true && context.mounted) {
    SessionStore.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}

class LogoutBackGuard extends StatelessWidget {
  const LogoutBackGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        confirmLogoutOnBack(context);
      },
      child: child,
    );
  }
}
