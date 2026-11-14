class WorkoutExercise {
  final String id;
  final String workoutId;
  final String exerciseId;
  final int orderIndex;
  String? exerciseName;

  WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    this.exerciseName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'orderIndex': orderIndex,
      };

  factory WorkoutExercise.fromMap(Map<String, dynamic> m) => WorkoutExercise(
        id: m['id'] as String,
        workoutId: m['workoutId'] as String,
        exerciseId: m['exerciseId'] as String,
        orderIndex: m['orderIndex'] as int,
      );
}
