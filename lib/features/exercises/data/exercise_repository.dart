import 'package:uuid/uuid.dart';

import '../../../core/db/database_helper.dart';
import 'exercise.dart';

class ExerciseRepository {
  ExerciseRepository(this._db);
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  Future<List<MuscleGroup>> getGroups() async {
    final db = await _db.database;
    final rows = await db.query('muscle_groups', orderBy: 'name ASC');
    return rows.map(MuscleGroup.fromMap).toList();
  }

  Future<String> addGroup(String name) async {
    final db = await _db.database;
    final id = _uuid.v4();
    await db.insert('muscle_groups', {'id': id, 'name': name.trim()});
    return id;
  }

  Future<void> deleteGroup(String id) async {
    final db = await _db.database;
    await db.update('exercises', {'muscleGroupId': null},
        where: 'muscleGroupId = ?', whereArgs: [id]);
    await db.delete('muscle_groups', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Exercise>> getAll({String? groupId}) async {
    final db = await _db.database;
    final where = groupId == null ? null : 'e.muscleGroupId = ?';
    final whereArgs = groupId == null ? null : [groupId];
    final rows = await db.rawQuery('''
      SELECT e.id, e.name, e.muscleGroupId, g.name AS groupName
      FROM exercises e
      LEFT JOIN muscle_groups g ON g.id = e.muscleGroupId
      ${where == null ? '' : 'WHERE $where'}
      ORDER BY e.name ASC
    ''', whereArgs);
    return rows.map((r) => Exercise(
          id: r['id'] as String,
          name: r['name'] as String,
          muscleGroupId: r['muscleGroupId'] as String?,
          muscleGroupName: r['groupName'] as String?,
        )).toList();
  }

  Future<void> add(String name, {String? muscleGroupId}) async {
    final db = await _db.database;
    await db.insert('exercises', {
      'id': _uuid.v4(),
      'name': name,
      'muscleGroupId': muscleGroupId,
    });
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }
}
