import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Hlavní menu',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
              ? const Center(child: Text('Zatím žádný trénink.'))
              : ListView.builder(
                  itemCount: _workouts.length,
                  itemBuilder: (ctx, i) {
                    final w = _workouts[i];
                    return ListTile(
                      title: Text((w as dynamic).displayName as String),
                      subtitle: Text('${w.date.toLocal().toString().split(' ').first}${w.note != null && w.note!.isNotEmpty ? "  –  ${w.note}" : ""}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/history/${w.id}').then((_) => _load()),
                    );
                  },
                ),
    );
  }
}
