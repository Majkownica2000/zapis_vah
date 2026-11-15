import 'dart:convert';

import '../../features/exercises/data/exercise.dart';
import '../../features/exercises/data/exercise_repository.dart';
import '../../features/workouts/data/set_entry.dart';
import '../../features/workouts/data/workout.dart';
import '../../features/workouts/data/workout_exercise.dart';
import '../../features/workouts/data/workout_repository.dart';

class BackupService {
  BackupService(this._exRepo, this._workRepo);
  final ExerciseRepository _exRepo;
  final WorkoutRepository _workRepo;

  Future<String> exportJson() async {
    final groups = await _exRepo.getGroups();
    final exercises = await _exRepo.getAll();
    final workouts = await _workRepo.getWorkouts();

    final workoutData = <Map<String, dynamic>>[];
    for (final w in workouts) {
      final wes = await _workRepo.getWorkoutExercises(w.id);
      final exData = <Map<String, dynamic>>[];
      for (final we in wes) {
        final sets = await _workRepo.getSets(we.id);
        exData.add({
          'exerciseName': we.exerciseName,
          'sets': sets.map((s) => {
                'type': s.typeDb,
                'setIndex': s.setIndex,
                'weight': s.weight,
                'reps': s.reps,
                'note': s.note,
              }).toList(),
        });
      }
      workoutData.add({
        'name': w.name,
        'date': w.date.toIso8601String(),
        'note': w.note,
        'exercises': exData,
      });
    }

    final data = {
      'version': 1,
      'muscleGroups': groups.map((g) => {'name': g.name}).toList(),
      'exercises': exercises.map((e) => {
            'name': e.name,
            'muscleGroupName': e.muscleGroupName,
          }).toList(),
      'workouts': workoutData,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;

    // muscle groups: name -> id
    final groupMap = <String, String>{};
    final existingGroups = await _exRepo.getGroups();
    for (final g in existingGroups) {
      groupMap[g.name] = g.id;
    }
    final groupsJson = (data['muscleGroups'] as List<dynamic>?) ?? [];
    for (final g in groupsJson) {
      final name = g is String ? g.trim() : (g['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      if (!groupMap.containsKey(name)) {
        final id = await _exRepo.addGroup(name);
        groupMap[name] = id;
      }
    }

    // exercises: name -> id
    final exerciseMap = <String, String>{};
    final existingExercises = await _exRepo.getAll();
    for (final e in existingExercises) {
      exerciseMap[e.name] = e.id;
    }
    final exercisesJson = (data['exercises'] as List<dynamic>?) ?? [];
    for (final e in exercisesJson) {
      final name = (e['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      if (!exerciseMap.containsKey(name)) {
        final groupName = (e['muscleGroupName'] as String?)?.trim();
        String? groupId;
        if (groupName != null && groupName.isNotEmpty) {
          if (!groupMap.containsKey(groupName)) {
            groupId = await _exRepo.addGroup(groupName);
            groupMap[groupName] = groupId;
          } else {
            groupId = groupMap[groupName];
          }
        }
        final id = await _exRepo.add(name, muscleGroupId: groupId);
        exerciseMap[name] = id;
      }
    }

    final workoutsJson = (data['workouts'] as List<dynamic>?) ?? [];
    for (final w in workoutsJson) {
      final name = w['name'] as String?;
      final dateStr = w['date'] as String?;
      DateTime date;
      try {
        date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
      } catch (_) {
        date = DateTime.now();
      }
      final note = w['note'] as String?;
      final id = await _workRepo.createWorkout(name: name, note: note, date: date);
      final exList = (w['exercises'] as List<dynamic>?) ?? [];
      for (final e in exList) {
        final exName = (e['exerciseName'] as String?)?.trim();
        if (exName == null || exName.isEmpty) continue;
        if (!exerciseMap.containsKey(exName)) {
          final exId = await _exRepo.add(exName);
          exerciseMap[exName] = exId;
        }
        final weId = await _workRepo.addExerciseToWorkout(id, exerciseMap[exName]!);
        final sets = (e['sets'] as List<dynamic>?) ?? [];
        for (final s in sets) {
          final typeStr = s['type'] as String? ?? 'WORKING';
          final type = typeStr == 'WARMUP' ? SetType.warmup : SetType.working;
          final setId = await _workRepo.addSet(weId, type);
          final weight = (s['weight'] as num?)?.toDouble() ?? 0;
          final reps = s['reps'] as int? ?? 0;
          final note = s['note'] as String?;
          final setIndex = s['setIndex'] as int? ?? 1;
          // update set with imported values
          final setEntry = SetEntry(
            id: setId,
            workoutExerciseId: weId,
            type: type,
            setIndex: setIndex,
            weight: weight,
            reps: reps,
            note: note,
          );
          await _workRepo.updateSet(setEntry);
        }
      }
    }
  }
}
