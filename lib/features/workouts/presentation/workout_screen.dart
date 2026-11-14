import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../data/set_entry.dart';
import '../data/workout.dart';
import '../data/workout_exercise.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({required this.workoutId, super.key});
  final String workoutId;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  List<WorkoutExercise> _items = [];
  final Map<String, List<SetEntry>> _sets = {};
  Workout? _workout;
  bool _loading = true;

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
        title: const Text('Prejmenovat trenink'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nazev')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrusit')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ulozit')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(workoutRepositoryProvider).renameWorkout(widget.workoutId, ctrl.text.trim().isEmpty ? null : ctrl.text.trim());
      await _reload();
    }
  }

  Future<void> _addExercise() async {
    final repo = ref.read(exerciseRepositoryProvider);
    final exercises = await repo.getAll();
    if (!mounted) return;
    if (exercises.isEmpty) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Zadne cviky'),
          content: const Text('Nejdriv pridej cviky v knihovne.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrusit')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Otevrit knihovnu')),
          ],
        ),
      );
      if (go == true && mounted) context.push('/exercises');
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Vyber cvik'),
        children: [
          for (final e in exercises)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.id),
              child: Text(e.name),
            ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(workoutRepositoryProvider).addExerciseToWorkout(widget.workoutId, selected);
      await _reload();
    }
  }

  Future<void> _addSet(String weId, SetType type) async {
    await ref.read(workoutRepositoryProvider).addSet(weId, type);
    await _reload();
  }

  Future<void> _deleteSet(String setId) async {
    await ref.read(workoutRepositoryProvider).deleteSet(setId);
    await _reload();
  }

  Future<void> _deleteExercise(String weId) async {
    await ref.read(workoutRepositoryProvider).removeExerciseFromWorkout(weId);
    await _reload();
  }

  Future<void> _updateSet(SetEntry s) async {
    await ref.read(workoutRepositoryProvider).updateSet(s);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_workout?.displayName ?? 'Trenink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Prejmenovat',
            onPressed: _renameWorkout,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Hlavni menu',
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final we in _items) _buildExerciseCard(we),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add),
            label: const Text('Pridat cvik'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise we) {
    final sets = _sets[we.id] ?? [];
    final warmups = sets.where((s) => s.type == SetType.warmup).toList();
    final workings = sets.where((s) => s.type == SetType.working).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(we.exerciseName ?? 'Cvik',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteExercise(we.id),
                ),
              ],
            ),
            const Text('Warm-up', style: TextStyle(fontWeight: FontWeight.w600)),
            ...warmups.map((s) => _setRow(s)),
            TextButton.icon(
              onPressed: () => _addSet(we.id, SetType.warmup),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Warm-up serie'),
            ),
            const SizedBox(height: 4),
            const Text('Pracovni serie', style: TextStyle(fontWeight: FontWeight.w600)),
            ...workings.map((s) => _setRow(s)),
            TextButton.icon(
              onPressed: () => _addSet(we.id, SetType.working),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Pracovni serie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setRow(SetEntry s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: s.weight == 0 ? '' : s.weight.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'vaha'),
              onChanged: (v) {
                s.weight = double.tryParse(v) ?? 0;
              },
              onEditingComplete: () => _updateSet(s),
              onTapOutside: (_) => _updateSet(s),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: s.reps == 0 ? '' : s.reps.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'reps'),
              onChanged: (v) {
                s.reps = int.tryParse(v) ?? 0;
              },
              onEditingComplete: () => _updateSet(s),
              onTapOutside: (_) => _updateSet(s),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: s.note,
              decoration: const InputDecoration(labelText: 'poznamka'),
              onChanged: (v) {
                s.note = v;
              },
              onEditingComplete: () => _updateSet(s),
              onTapOutside: (_) => _updateSet(s),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => _deleteSet(s.id),
          ),
        ],
      ),
    );
  }
}
