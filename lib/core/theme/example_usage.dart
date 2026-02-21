import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/app_bar_theme_toggle.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/theme_providers.dart';

/// Example screen showing how to use the theme system
class ExampleThemedScreen extends ConsumerWidget {
  const ExampleThemedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current theme mode for conditional logic
    final themeMode = ref.watch(persistentThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      // Option 1: Use ThemedAppBar (recommended)
      appBar: ThemedAppBar(title: 'Example Screen', showThemeToggle: true),

      // Option 2: Use SimpleThemedAppBar
      // appBar: SimpleThemedAppBar(title: 'Example Screen'),

      // Option 3: Custom AppBar with theme toggle
      // appBar: AppBar(
      //   title: Text('Example Screen'),
      //   actions: [const ThemeToggleButton()],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme-aware content
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Theme: ${isDark ? 'Dark' : 'Light'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This text automatically adapts to the current theme.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Theme toggle widget (for settings screens)
            const Card(child: ThemeToggleWidget()),

            const SizedBox(height: 16),

            // Example of theme-aware buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(persistentThemeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                    },
                    child: const Text('Light Theme'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(persistentThemeModeProvider.notifier)
                          .setThemeMode(ThemeMode.dark);
                    },
                    child: const Text('Dark Theme'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(persistentThemeModeProvider.notifier)
                          .toggleTheme();
                    },
                    child: const Text('Toggle Theme'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ref
                          .read(persistentThemeModeProvider.notifier)
                          .resetToSystemTheme();
                    },
                    child: const Text('System Theme'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Example of theme-aware content
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Colors',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ColorChip(
                          label: 'Primary',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        _ColorChip(
                          label: 'Secondary',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        _ColorChip(
                          label: 'Error',
                          color: Theme.of(context).colorScheme.error,
                        ),
                        _ColorChip(
                          label: 'Surface',
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget to display color chips
class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
    );
  }
}
