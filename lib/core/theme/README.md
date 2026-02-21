# Theme System Documentation

This document explains how to use the comprehensive dark/light theme system implemented in the app.

## Overview

The app now supports:
- **Light Theme**: Clean, bright interface
- **Dark Theme**: Dark interface for low-light environments  
- **System Theme**: Automatically follows device theme settings
- **Persistence**: Theme preference is saved and restored between app sessions

## Core Components

### 1. Theme Provider (`lib/core/providers/theme_providers.dart`)

The main provider that manages theme state with persistence:

```dart
// Watch current theme mode
final themeMode = ref.watch(persistentThemeModeProvider);

// Change theme
ref.read(persistentThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
ref.read(persistentThemeModeProvider.notifier).toggleTheme();
ref.read(persistentThemeModeProvider.notifier).resetToSystemTheme();

// Check current theme
final isDark = ref.watch(persistentThemeModeProvider.notifier).isDark;
```

### 2. Theme Data (`lib/core/theme/app_theme.dart`)

Comprehensive theme definitions with Material 3 design:

```dart
// Access themes
AppTheme.lightTheme  // Light theme
AppTheme.darkTheme   // Dark theme

// Access theme colors
AppTheme.primaryColor
AppTheme.secondaryColor
AppTheme.errorColor
```

### 3. Theme Toggle Widgets

#### ThemeToggleWidget
A complete theme selector for settings screens:

```dart
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';

// In your settings screen
const ThemeToggleWidget()
```

#### ThemeToggleButton
A simple toggle button for app bars:

```dart
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';

// Simple toggle button
const ThemeToggleButton()
```

#### ThemedAppBar
App bar with built-in theme toggle:

```dart
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/app_bar_theme_toggle.dart';

// App bar with theme toggle
ThemedAppBar(
  title: 'My Screen',
  showThemeToggle: true, // optional, defaults to true
)
```

## Usage Examples

### 1. Basic Screen with Theme Support

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: ThemedAppBar(title: 'My Screen'),
      body: Column(
        children: [
          // Your content here
          // Theme will automatically adapt
        ],
      ),
    );
  }
}
```

### 2. Custom App Bar with Theme Toggle

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
        actions: [
          const ThemeToggleButton(),
          // Other actions...
        ],
      ),
      body: Column(
        children: [
          // Your content
        ],
      ),
    );
  }
}
```

### 3. Settings Screen Integration

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // Other settings...
          const ThemeToggleWidget(),
          // More settings...
        ],
      ),
    );
  }
}
```

### 4. Programmatic Theme Control

```dart
class ThemeController {
  static void setLightTheme(WidgetRef ref) {
    ref.read(persistentThemeModeProvider.notifier).setThemeMode(ThemeMode.light);
  }
  
  static void setDarkTheme(WidgetRef ref) {
    ref.read(persistentThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
  }
  
  static void setSystemTheme(WidgetRef ref) {
    ref.read(persistentThemeModeProvider.notifier).setThemeMode(ThemeMode.system);
  }
  
  static void toggleTheme(WidgetRef ref) {
    ref.read(persistentThemeModeProvider.notifier).toggleTheme();
  }
}
```

## Theme Customization

### Adding Custom Colors

Edit `lib/core/theme/app_theme.dart`:

```dart
class AppTheme {
  // Add your custom colors
  static const Color customColor = Color(0xFF123456);
  
  // Use in themes
  static ThemeData lightTheme = ThemeData(
    // ... existing config
    colorScheme: ColorScheme.fromSeed(
      seedColor: customColor,
      brightness: Brightness.light,
    ),
  );
}
```

### Custom Theme Components

```dart
// Create custom themed widgets
class ThemedCard extends StatelessWidget {
  final Widget child;
  
  const ThemedCard({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}
```

## Best Practices

1. **Always use Theme.of(context)** instead of hardcoded colors
2. **Use the provided theme widgets** for consistency
3. **Test both light and dark themes** during development
4. **Use semantic colors** (primary, secondary, error, etc.) instead of specific colors
5. **Leverage Material 3 color schemes** for automatic theme adaptation

## Migration Guide

### From Hardcoded Colors

```dart
// Before
Container(
  color: Colors.blue,
  child: Text('Hello', style: TextStyle(color: Colors.white)),
)

// After
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello', 
    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
  ),
)
```

### From Custom AppBars

```dart
// Before
AppBar(
  title: Text('My Screen'),
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
)

// After
ThemedAppBar(title: 'My Screen')
// or
AppBar(
  title: Text('My Screen'),
  // Remove hardcoded colors - theme handles this
)
```

## Troubleshooting

### Theme Not Persisting
- Ensure `persistentThemeModeProvider` is used instead of `themeModeProvider`
- Check that SharedPreferences is properly initialized

### Colors Not Updating
- Use `Theme.of(context)` instead of hardcoded colors
- Ensure widgets are wrapped in `ConsumerWidget` or `Consumer`

### App Bar Not Theming
- Use `ThemedAppBar` or add `ThemeToggleButton` to actions
- Remove hardcoded `backgroundColor` and `foregroundColor`

## Testing

Test theme switching by:
1. Using the theme toggle in settings
2. Changing device theme settings (for system mode)
3. Restarting the app to verify persistence
4. Checking all screens in both light and dark modes
