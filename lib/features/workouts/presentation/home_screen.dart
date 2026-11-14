import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<dynamic> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(workoutRepositoryProvider);
    final items = await repo.getWorkouts();
    if (!mounted) return;
    setState(() {
      _workouts = items;
      _loading = false;
    });
  }

  Future<void> _newWorkout() async {
    final repo = ref.read(workoutRepositoryProvider);
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
    if (ok == true && mounted) {
      final id = await repo.createWorkout(
          name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim());
      if (mounted) {
        await context.push('/workout/$id');
        await _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(workoutRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zápis váh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () => context.push('/exercises').then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history').then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings').then((_) => _load()),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FilledButton.icon(
                  onPressed: _newWorkout,
                  icon: const Icon(Icons.add),
                  label: const Text('Nový trénink'),
                ),
                const SizedBox(height: 16),
                Text('Poslední tréninky',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...(_workouts.isEmpty
                    ? [const Text('Zatím žádný trénink.')]
                    : _workouts.take(5).map((w) => ListTile(
                          title: Text((w as dynamic).displayName as String),
                          subtitle: Text(w.date.toLocal().toString().split(' ').first),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/history/${w.id}').then((_) => _load()),
                        )).toList()),
              ],
            ),
    );
  }
}