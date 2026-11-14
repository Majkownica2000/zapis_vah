import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'settings_controller.dart';

String _themeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Světlý';
    case ThemeMode.dark:
      return 'Tmavý';
    case ThemeMode.system:
      return 'Systémový';
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Hlavní menu',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Chyba: $e')),
        data: (s) => ListView(
          children: [
            ListTile(
              title: const Text('Jednotky'),
              subtitle: Text(s.unit),
              trailing: DropdownButton<String>(
                value: s.unit,
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'lb', child: Text('lb')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsControllerProvider.notifier).setUnit(v);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Motiv'),
              subtitle: Text(_themeLabel(s.themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: s.themeMode,
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Systémový')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Světlý')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Tmavý')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsControllerProvider.notifier).setThemeMode(v);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
