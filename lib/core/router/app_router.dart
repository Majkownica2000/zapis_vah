import 'package:go_router/go_router.dart';

import '../../features/exercises/presentation/exercises_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/workouts/presentation/history_screen.dart';
import '../../features/workouts/presentation/home_screen.dart';
import '../../features/workouts/presentation/workout_detail_screen.dart';
import '../../features/workouts/presentation/workout_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/workout/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WorkoutScreen(workoutId: id);
      },
    ),
    GoRoute(
      path: '/exercises',
      builder: (context, state) => const ExercisesScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return WorkoutDetailScreen(workoutId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
