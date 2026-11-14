enum SetType { warmup, working }

class SetEntry {
  final String id;
  final String workoutExerciseId;
  final SetType type;
  final int setIndex;
  double weight;
  int reps;
  String? note;

  SetEntry({
    required this.id,
    required this.workoutExerciseId,
    required this.type,
    required this.setIndex,
    required this.weight,
    required this.reps,
    this.note,
  });

  String get typeDb => type == SetType.warmup ? 'WARMUP' : 'WORKING';

  static SetType typeFromDb(String v) =>
      v == 'WARMUP' ? SetType.warmup : SetType.working;

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutExerciseId': workoutExerciseId,
        'type': typeDb,
        'setIndex': setIndex,
        'weight': weight,
        'reps': reps,
        'note': note,
      };

  factory SetEntry.fromMap(Map<String, dynamic> m) => SetEntry(
        id: m['id'] as String,
        workoutExerciseId: m['workoutExerciseId'] as String,
        type: typeFromDb(m['type'] as String),
        setIndex: m['setIndex'] as int,
        weight: (m['weight'] as num).toDouble(),
        reps: m['reps'] as int,
        note: m['note'] as String?,
      );
}
