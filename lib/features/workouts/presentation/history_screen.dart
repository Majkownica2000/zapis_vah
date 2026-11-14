import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(workoutRepositoryProvider);
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
      body: FutureBuilder(
        future: repo.getWorkouts(),
        builder: (context, snapshot) {
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const Center(child: Text('Zatím žádný trénink.'));
          }
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (ctx, i) {
              final w = workouts[i];
              return ListTile(
                title: Text(w.displayName),
                subtitle: Text('${w.date.toLocal().toString().split(' ').first}${w.note != null && w.note!.isNotEmpty ? "  –  ${w.note}" : ""}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/history/${w.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
