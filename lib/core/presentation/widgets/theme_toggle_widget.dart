import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/theme_providers.dart';

/// A widget that displays the current theme mode and allows toggling between themes
class ThemeToggleWidget extends ConsumerWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeString = ref.watch(themeModeStringProvider);
    final themeModeIcon = ref.watch(themeModeIconProvider);

    return ListTile(
      leading: Icon(themeModeIcon),
      title: const Text('Theme'),
      subtitle: Text(themeModeString),
      trailing: PopupMenuButton<ThemeMode>(
        icon: const Icon(Icons.arrow_drop_down),
        onSelected: (ThemeMode selectedTheme) {
          ref
              .read(persistentThemeModeProvider.notifier)
              .setThemeMode(selectedTheme);
        },
        itemBuilder:
            (BuildContext context) => [
              const PopupMenuItem<ThemeMode>(
                value: ThemeMode.light,
                child: ListTile(
                  leading: Icon(Icons.light_mode),
                  title: Text('Light'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<ThemeMode>(
                value: ThemeMode.dark,
                child: ListTile(
                  leading: Icon(Icons.dark_mode),
                  title: Text('Dark'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<ThemeMode>(
                value: ThemeMode.system,
                child: ListTile(
                  leading: Icon(Icons.brightness_auto),
                  title: Text('System'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
      ),
    );
  }
}

/// A simple theme toggle button that switches between light and dark
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(persistentThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        ref.read(persistentThemeModeProvider.notifier).toggleTheme();
      },
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}

/// A theme mode selector dialog
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(persistentThemeModeProvider);

    return AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            subtitle: const Text('Always use light theme'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref
                    .read(persistentThemeModeProvider.notifier)
                    .setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            subtitle: const Text('Always use dark theme'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref
                    .read(persistentThemeModeProvider.notifier)
                    .setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Follow system theme'),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref
                    .read(persistentThemeModeProvider.notifier)
                    .setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
