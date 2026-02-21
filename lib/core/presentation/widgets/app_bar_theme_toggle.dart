import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';

/// An app bar with a theme toggle button
class ThemedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showThemeToggle;

  const ThemedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Widget> appBarActions = actions ?? [];

    if (showThemeToggle) {
      appBarActions.add(const ThemeToggleButton());
    }

    return AppBar(
      title: Text(title),
      leading: leading,
      centerTitle: centerTitle,
      actions: appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// A simple app bar with theme toggle
class SimpleThemedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  const SimpleThemedAppBar({super.key, required this.title, this.leading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title),
      leading: leading,
      centerTitle: true,
      actions: const [ThemeToggleButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
