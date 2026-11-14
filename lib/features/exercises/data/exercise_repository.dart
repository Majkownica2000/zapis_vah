import 'package:uuid/uuid.dart';

import '../../../core/db/database_helper.dart';
import 'exercise.dart';

class ExerciseRepository {
  ExerciseRepository(this._db);
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  Future<List<Exercise>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<void> add(String name, {String? muscleGroup}) async {
    final db = await _db.database;
    await db.insert('exercises', {
      'id': _uuid.v4(),
      'name': name,
      'muscleGroup': muscleGroup,
    });
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }
}
