import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'zapis_vah.db';
  static const _dbVersion = 2;

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
            muscleGroup TEXT
          )
        ''');
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
      },
    );
  }
}
