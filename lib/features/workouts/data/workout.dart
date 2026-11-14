class Workout {
  final String id;
  final DateTime date;
  String? name;
  final String? note;

  Workout({required this.id, required this.date, this.name, this.note});

  String get displayName => (name != null && name!.trim().isNotEmpty)
      ? name!.trim()
      : 'Trénink ${date.day}.${date.month}.';

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'name': name,
        'note': note,
      };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        name: m['name'] as String?,
        note: m['note'] as String?,
      );
}
