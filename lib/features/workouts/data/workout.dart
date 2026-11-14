class Workout {
  final String id;
  final DateTime date;
  final String? note;

  Workout({required this.id, required this.date, this.note});

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String?,
      );
}
