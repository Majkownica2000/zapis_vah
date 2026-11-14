import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/database_helper.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/workouts/data/workout_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(databaseHelperProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(ref.watch(databaseHelperProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
