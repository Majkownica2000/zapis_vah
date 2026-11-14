class Exercise {
  final String id;
  final String name;
  final String? muscleGroup;

  Exercise({required this.id, required this.name, this.muscleGroup});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
      };

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'] as String,
        name: m['name'] as String,
        muscleGroup: m['muscleGroup'] as String?,
      );
}
