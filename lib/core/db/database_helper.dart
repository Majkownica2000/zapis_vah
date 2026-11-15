import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'zapis_vah.db';
  static const _dbVersion = 4;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE exercises (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            muscleGroupId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE muscle_groups (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');
        const defaults = [
          'Hrudník', 'Hrudník (horní)', 'Hrudník (střední)', 'Hrudník (spodní)',
          'Záda', 'Záda (šířka)', 'Záda (tloušťka)', 'Trapézy', 'Spodní záda',
          'Nohy', 'Kvadricepsy', 'Hamstringy', 'Lýtka', 'Hýždě',
          'Ramena', 'Ramena (přední)', 'Ramena (střední)', 'Ramena (zadní)',
          'Ruce', 'Biceps', 'Triceps', 'Předloktí',
          'Core', 'Břicho',
          'Celé tělo', 'Kardio',
        ];
        for (final n in defaults) {
          await db.insert('muscle_groups', {'id': const Uuid().v4(), 'name': n});
        }
        await db.execute('''
          CREATE TABLE workouts (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            name TEXT,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE workout_exercises (
            id TEXT PRIMARY KEY,
            workoutId TEXT NOT NULL,
            exerciseId TEXT NOT NULL,
            orderIndex INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sets (
            id TEXT PRIMARY KEY,
            workoutExerciseId TEXT NOT NULL,
            type TEXT NOT NULL,
            setIndex INTEGER NOT NULL,
            weight REAL NOT NULL,
            reps INTEGER NOT NULL,
            note TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE workouts ADD COLUMN name TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS muscle_groups (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
          const defaults = ['Hrudník', 'Záda', 'Nohy', 'Ramena', 'Ruce', 'Core', 'Celé tělo', 'Kardio'];
          for (final n in defaults) {
            final existing = await db.query('muscle_groups', where: 'name = ?', whereArgs: [n]);
            if (existing.isEmpty) {
              await db.insert('muscle_groups', {'id': const Uuid().v4(), 'name': n});
            }
          }
          // add column if missing
          try {
            await db.execute('ALTER TABLE exercises ADD COLUMN muscleGroupId TEXT');
          } catch (_) {}
          // migrate old text values
          final rows = await db.query('exercises');
          final groups = await db.query('muscle_groups');
          final nameToId = <String, String>{};
          for (final g in groups) {
            nameToId[g['name'] as String] = g['id'] as String;
          }
          for (final r in rows) {
            final oldName = r['muscleGroup'] as String?;
            if (oldName == null || oldName.trim().isEmpty) continue;
            if (!nameToId.containsKey(oldName)) {
              final gid = const Uuid().v4();
              await db.insert('muscle_groups', {'id': gid, 'name': oldName});
              nameToId[oldName] = gid;
            }
            await db.update('exercises', {'muscleGroupId': nameToId[oldName]},
                where: 'id = ?', whereArgs: [r['id']]);
          }
          // drop old column if supported
          try {
            await db.execute('ALTER TABLE exercises DROP COLUMN muscleGroup');
          } catch (_) {}
        }
        if (oldVersion < 4) {
          const defaults = [
            'Hrudník (horní)', 'Hrudník (střední)', 'Hrudník (spodní)',
            'Záda (šířka)', 'Záda (tloušťka)', 'Trapézy', 'Spodní záda',
            'Kvadricepsy', 'Hamstringy', 'Lýtka', 'Hýždě',
            'Ramena (přední)', 'Ramena (střední)', 'Ramena (zadní)',
            'Biceps', 'Triceps', 'Předloktí',
            'Břicho',
          ];
          for (final n in defaults) {
            final existing = await db.query('muscle_groups', where: 'name = ?', whereArgs: [n]);
            if (existing.isEmpty) {
              await db.insert('muscle_groups', {'id': const Uuid().v4(), 'name': n});
            }
          }
        }
      },
    );
  }
}
