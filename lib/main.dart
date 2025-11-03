import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/app_shell.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BoojyDrawApp(),
    ),
  );
}

class BoojyDrawApp extends StatelessWidget {
  const BoojyDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boojy Draw',
      debugShowCheckedModeBanner: false,

      // Material 3 Dark Theme (default for digital painting)
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark, // Start with dark theme

      home: const AppShell(),
    );
  }

  /// Material 3 Light Theme
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  /// Material 3 Dark Theme (optimized for digital painting)
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      // Dark backgrounds for better canvas focus
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      cardColor: const Color(0xFF2D2D2D),
    );
  }
}

class BoojyDrawHome extends StatelessWidget {
  const BoojyDrawHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.brush,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Boojy Draw',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Digital Painting & Illustration',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Open new canvas dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New Canvas - Coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Canvas'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Open existing file
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Open File - Coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Open File'),
            ),
          ],
        ),
      ),
    );
  }
}
