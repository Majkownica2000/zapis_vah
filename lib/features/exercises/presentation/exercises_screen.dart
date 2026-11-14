import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/exercise.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _search = TextEditingController();
  List<Exercise> _items = [];
  List<Exercise> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_applyFilter);
  }

  Future<void> _load() async {
    final repo = ref.read(exerciseRepositoryProvider);
    final items = await repo.getAll();
    setState(() {
      _items = items;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _items
          : _items.where((e) => e.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _addExercise() async {
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novy cvik'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nazev')),
            const SizedBox(height: 8),
            TextField(controller: muscleCtrl, decoration: const InputDecoration(labelText: 'Svalova skupina (volitelne)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrusit')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Pridat')),
        ],
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      await ref
          .read(exerciseRepositoryProvider)
          .add(nameCtrl.text.trim(), muscleGroup: muscleCtrl.text.trim().isEmpty ? null : muscleCtrl.text.trim());
      await _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cviky')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Hledat',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final e = _filtered[i];
                return ListTile(
                  title: Text(e.name),
                  subtitle: e.muscleGroup != null ? Text(e.muscleGroup!) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(exerciseRepositoryProvider).delete(e.id);
                      await _load();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
