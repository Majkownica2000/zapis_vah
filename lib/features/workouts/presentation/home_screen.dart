import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(workoutRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zápis váh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () => context.push('/exercises'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: repo.getWorkouts(),
        builder: (context, snapshot) {
          final workouts = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final nameCtrl = TextEditingController();
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Nový trénink'),
                      content: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Název (volitelné)'),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Vytvořit')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    final id = await repo.createWorkout(
                        name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim());
                    if (context.mounted) context.push('/workout/$id');
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Nový trénink'),
              ),
              const SizedBox(height: 16),
              Text('Poslední tréninky',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (workouts.isEmpty)
                const Text('Zatím žádný trénink.')
              else
                ...workouts.take(5).map((w) => ListTile(
                      title: Text(w.displayName),
                      subtitle: Text(w.date.toLocal().toString().split(' ').first),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/history/${w.id}'),
                    )),
            ],
          );
        },
      ),
    );
  }
}
