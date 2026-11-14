import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../data/set_entry.dart';
import '../data/workout.dart';
import '../data/workout_exercise.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({required this.workoutId, super.key});
  final String workoutId;

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  bool _loading = true;
  Workout? _workout;
  List<WorkoutExercise> _items = [];
  final Map<String, List<SetEntry>> _sets = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final repo = ref.read(workoutRepositoryProvider);
    _workout = await repo.getWorkout(widget.workoutId);
    final items = await repo.getWorkoutExercises(widget.workoutId);
    _sets.clear();
    for (final we in items) {
      _sets[we.id] = await repo.getSets(we.id);
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _renameWorkout() async {
    if (_workout == null) return;
    final ctrl = TextEditingController(text: _workout!.name ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Přejmenovat trénink'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Název')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Uložit')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(workoutRepositoryProvider).renameWorkout(widget.workoutId, ctrl.text.trim().isEmpty ? null : ctrl.text.trim());
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_workout?.displayName ?? 'Detail tréninku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Přejmenovat',
            onPressed: _renameWorkout,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Hlavní menu',
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Upravit',
            onPressed: () => context.push('/workout/${widget.workoutId}'),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Zopakovat',
            onPressed: () async {
              final newId = await ref
                  .read(workoutRepositoryProvider)
                  .cloneWorkout(widget.workoutId);
              if (context.mounted) context.go('/workout/$newId');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(workoutRepositoryProvider).deleteWorkout(widget.workoutId);
              if (context.mounted) context.go('/history');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final we in _items) ...[
            Text(we.exerciseName ?? 'Cvik',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...(_sets[we.id] ?? []).map((s) => Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 2),
                  child: Text(
                      '${s.type == SetType.warmup ? "W" : "S"}${s.setIndex}: ${s.weight} x ${s.reps}${s.note != null && s.note!.isNotEmpty ? "  (${s.note})" : ""}'),
                )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
