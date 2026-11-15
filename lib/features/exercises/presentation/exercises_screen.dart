import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  List<MuscleGroup> _groups = [];
  String? _filterGroupId; // null = all
  List<Exercise> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_applyFilter);
  }

  Future<void> _load() async {
    final repo = ref.read(exerciseRepositoryProvider);
    final groups = await repo.getGroups();
    final items = await repo.getAll(groupId: _filterGroupId);
    setState(() {
      _groups = groups;
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

  Future<void> _addGroup() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nová partia'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Název')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Přidat')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await ref.read(exerciseRepositoryProvider).addGroup(ctrl.text.trim());
      await _load();
    }
  }

  Future<void> _deleteGroup(MuscleGroup g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Smazat partii?'),
        content: Text('Cviky s touto partií zůstanou bez partie. "${g.name}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Smazat')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(exerciseRepositoryProvider).deleteGroup(g.id);
      if (_filterGroupId == g.id) _filterGroupId = null;
      await _load();
    }
  }

  Future<void> _addExercise() async {
    final nameCtrl = TextEditingController();
    String? selectedGroupId = _filterGroupId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Nový cvik'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Název')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: selectedGroupId,
                decoration: const InputDecoration(labelText: 'Partie'),
                items: [
                  ..._groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
                  const DropdownMenuItem(value: '__new__', child: Text('+ Nová partia...')),
                ],
                onChanged: (v) async {
                  if (v == '__new__') {
                    await _addGroup();
                    final groups = await ref.read(exerciseRepositoryProvider).getGroups();
                    setSt(() {
                      _groups = groups;
                      selectedGroupId = groups.isNotEmpty ? groups.last.id : null;
                    });
                  } else {
                    setSt(() => selectedGroupId = v);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Přidat')),
          ],
        ),
      ),
    );
    if (ok == true && nameCtrl.text.trim().isNotEmpty) {
      await ref.read(exerciseRepositoryProvider).add(
            nameCtrl.text.trim(),
            muscleGroupId: selectedGroupId == '__new__' ? null : selectedGroupId,
          );
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
      appBar: AppBar(
        title: const Text('Cviky'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Hlavní menu',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
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
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Vše'),
                    selected: _filterGroupId == null,
                    onSelected: (_) {
                      setState(() => _filterGroupId = null);
                      _load();
                    },
                  ),
                ),
                ..._groups.map((g) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onLongPress: () => _deleteGroup(g),
                        child: ChoiceChip(
                          label: Text(g.name),
                          selected: _filterGroupId == g.id,
                          onSelected: (_) {
                            setState(() => _filterGroupId = g.id);
                            _load();
                          },
                        ),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: const Text('Partie'),
                    onPressed: _addGroup,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final e = _filtered[i];
                return ListTile(
                  title: Text(e.name),
                  subtitle: e.muscleGroupName != null ? Text(e.muscleGroupName!) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Smazat cvik?'),
                          content: Text('Opravdu smazat „${e.name}“?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Smazat'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref.read(exerciseRepositoryProvider).delete(e.id);
                        await _load();
                      }
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