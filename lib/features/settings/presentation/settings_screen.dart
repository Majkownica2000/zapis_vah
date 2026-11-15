import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Obnovit výchozí partie'),
              subtitle: const Text('Přidá výchozí partie (sloučí)'),
              onTap: () async {
                try {
                  final json = await rootBundle.loadString('assets/default_groups.json');
                  await ref.read(backupServiceProvider).importJson(json);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Výchozí partie obnoveny')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chyba: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Exportovat data'),
              subtitle: const Text('Uložit zálohu do souboru'),
              onTap: () async {
                try {
                  final json = await ref.read(backupServiceProvider).exportJson();
                  final path = await FilePicker.platform.saveFile(
                    dialogTitle: 'Uložit zálohu',
                    fileName: 'zapis_vah_backup.json',
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    bytes: Uint8List.fromList(json.codeUnits),
                  );
                  if (path == null) return;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Záloha uložena: $path')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chyba exportu: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Importovat data'),
              subtitle: const Text('Nahrát zálohu ze souboru'),
              onTap: () async {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );
                  if (result == null || result.files.single.path == null) return;
                  final file = File(result.files.single.path!);
                  final json = await file.readAsString();
                  await ref.read(backupServiceProvider).importJson(json);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import dokončen')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Chyba importu: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
