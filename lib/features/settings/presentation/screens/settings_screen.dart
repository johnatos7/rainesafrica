import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/app_lock_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/app_lock_settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Settings screen with various app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: Consumer(
        builder: (context, ref, child) {
          // final appLockState = ref.watch(appLockProvider);

          return ListView(
            children: [
              // Language settings
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(context.tr('language')),
                subtitle: Text(context.tr('change_language')),
                onTap: () => context.go(AppConstants.languageSettingsRoute),
              ),

              const Divider(),

              // Theme settings
              const ThemeToggleWidget(),

              //const Divider(),

              // App Lock settings
              // ListTile(
              //   leading: const Icon(Icons.security),
              //   title: Text(context.tr('app_lock')),
              //   subtitle: Text(context.tr('app_lock_description')),
              //   // trailing: Switch(
              //   //   value: appLockState.isEnabled,
              //   //   onChanged: (value) {
              //   //     try {
              //   //       if (value) {
              //   //         ref.read(appLockProvider.notifier).enableAppLock();
              //   //       } else {
              //   //         ref.read(appLockProvider.notifier).disableAppLock();
              //   //       }
              //   //     } catch (e) {
              //   //       debugPrint('Error toggling app lock: $e');
              //   //     }
              //   //   },
              //   // ),
              //   onTap: () {
              //     // Navigate to app lock settings screen
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const AppLockSettingsScreen(),
              //       ),
              //     );
              //   },
              // ),
              // About Raines removed — already accessible from main account screen

              // Other settings...
              // ListTile(
              //   leading: const Icon(Icons.notifications),
              //   title: Text(context.tr('notifications')),
              //   subtitle: Text(context.tr('notification_settings')),
              //   onTap: () {
              //     // Notification settings (to be implemented)
              //   },
              // ),
            ],
          );
        },
      ),
    );
  }
}
