class MuscleGroup {
  final String id;
  final String name;
  MuscleGroup({required this.id, required this.name});
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  factory MuscleGroup.fromMap(Map<String, dynamic> m) =>
      MuscleGroup(id: m['id'] as String, name: m['name'] as String);
}

class Exercise {
  final String id;
  final String name;
  final String? muscleGroupId;
  String? muscleGroupName;

  Exercise({required this.id, required this.name, this.muscleGroupId, this.muscleGroupName});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscleGroupId': muscleGroupId,
      };

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'] as String,
        name: m['name'] as String,
        muscleGroupId: m['muscleGroupId'] as String?,
        muscleGroupName: m['muscleGroupName'] as String?,
      );
}
