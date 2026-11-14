import 'package:uuid/uuid.dart';

import '../../../core/db/database_helper.dart';
import 'set_entry.dart';
import 'workout.dart';
import 'workout_exercise.dart';

class WorkoutRepository {
  WorkoutRepository(this._db);
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  Future<List<Workout>> getWorkouts() async {
    final db = await _db.database;
    final rows = await db.query('workouts', orderBy: 'date DESC');
    return rows.map(Workout.fromMap).toList();
  }

  Future<Workout?> getWorkout(String id) async {
    final db = await _db.database;
    final rows = await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Workout.fromMap(rows.first);
  }

  Future<String> createWorkout({String? note}) async {
    final db = await _db.database;
    final id = _uuid.v4();
    await db.insert('workouts', {
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'note': note,
    });
    return id;
  }

  Future<void> deleteWorkout(String id) async {
    final db = await _db.database;
    final we = await db.query('workout_exercises',
        where: 'workoutId = ?', whereArgs: [id]);
    for (final r in we) {
      await db.delete('sets',
          where: 'workoutExerciseId = ?', whereArgs: [r['id']]);
    }
    await db.delete('workout_exercises',
        where: 'workoutId = ?', whereArgs: [id]);
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(String workoutId) async {
    final db = await _db.database;
    final rows = await db.query('workout_exercises',
        where: 'workoutId = ?', whereArgs: [workoutId], orderBy: 'orderIndex ASC');
    final list = rows.map(WorkoutExercise.fromMap).toList();
    // attach exercise names
    for (final we in list) {
      final ex = await db.query('exercises',
          where: 'id = ?', whereArgs: [we.exerciseId]);
      if (ex.isNotEmpty) {
        we.exerciseName = ex.first['name'] as String?;
      }
    }
    return list;
  }

  Future<String> addExerciseToWorkout(String workoutId, String exerciseId) async {
    final db = await _db.database;
    final existing = await db.query('workout_exercises',
        where: 'workoutId = ?', whereArgs: [workoutId]);
    final id = _uuid.v4();
    await db.insert('workout_exercises', {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'orderIndex': existing.length,
    });
    return id;
  }

  Future<void> removeExerciseFromWorkout(String workoutExerciseId) async {
    final db = await _db.database;
    await db.delete('sets',
        where: 'workoutExerciseId = ?', whereArgs: [workoutExerciseId]);
    await db.delete('workout_exercises',
        where: 'id = ?', whereArgs: [workoutExerciseId]);
  }

  Future<List<SetEntry>> getSets(String workoutExerciseId) async {
    final db = await _db.database;
    final rows = await db.query('sets',
        where: 'workoutExerciseId = ?',
        whereArgs: [workoutExerciseId],
        orderBy: 'setIndex ASC');
    return rows.map(SetEntry.fromMap).toList();
  }

  Future<String> addSet(String workoutExerciseId, SetType type) async {
    final db = await _db.database;
    final existing = await db.query('sets',
        where: 'workoutExerciseId = ?', whereArgs: [workoutExerciseId]);
    final warmups = existing.where((r) => r['type'] == 'WARMUP').length;
    final workings = existing.where((r) => r['type'] == 'WORKING').length;
    final index = type == SetType.warmup ? warmups + 1 : workings + 1;
    final id = _uuid.v4();
    await db.insert('sets', {
      'id': id,
      'workoutExerciseId': workoutExerciseId,
      'type': type == SetType.warmup ? 'WARMUP' : 'WORKING',
      'setIndex': index,
      'weight': 0.0,
      'reps': 0,
      'note': null,
    });
    return id;
  }

  Future<void> updateSet(SetEntry set) async {
    final db = await _db.database;
    await db.update('sets', set.toMap(),
        where: 'id = ?', whereArgs: [set.id]);
  }

  Future<void> deleteSet(String setId) async {
    final db = await _db.database;
    await db.delete('sets', where: 'id = ?', whereArgs: [setId]);
  }

  Future<String> cloneWorkout(String sourceId) async {
    final db = await _db.database;
    final newWorkoutId = _uuid.v4();
    await db.insert('workouts', {
      'id': newWorkoutId,
      'date': DateTime.now().toIso8601String(),
      'note': null,
    });
    final wes = await getWorkoutExercises(sourceId);
    for (final we in wes) {
      final newWeId = _uuid.v4();
      await db.insert('workout_exercises', {
        'id': newWeId,
        'workoutId': newWorkoutId,
        'exerciseId': we.exerciseId,
        'orderIndex': we.orderIndex,
      });
      final sets = await getSets(we.id);
      for (final s in sets) {
        await db.insert('sets', {
          'id': _uuid.v4(),
          'workoutExerciseId': newWeId,
          'type': s.typeDb,
          'setIndex': s.setIndex,
          'weight': s.weight,
          'reps': s.reps,
          'note': null,
        });
      }
    }
    return newWorkoutId;
  }
}
