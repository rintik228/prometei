import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/machine.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'machine_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE machines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            number TEXT,
            cycleTime REAL,
            product TEXT,
            caps INTEGER,
            nextProductionTime TEXT,
            addedTime TEXT,
            stopTime TEXT,
            isStopped INTEGER
          )
        ''');
      },
    );
  }

  Future<List<Machine>> getMachines() async {
    final db = await database;
    final maps = await db.query('machines');

    return List.generate(maps.length, (i) {
      return Machine(
        id: maps[i]['id'] as int?,
        number: maps[i]['number'] as String? ?? '',
        cycleTime: maps[i]['cycleTime'] as double? ?? 0.0,
        product: maps[i]['product'] as String? ?? '',
        caps: maps[i]['caps'] as int? ?? 0,
        nextProductionTime: DateTime.parse(maps[i]['nextProductionTime'] as String),
        addedTime: DateTime.parse(maps[i]['addedTime'] as String),
        stopTime: maps[i]['stopTime'] != null ? DateTime.parse(maps[i]['stopTime'] as String) : null,
        isStopped: maps[i]['isStopped'] == 1,
      );
    });
  }

  Future<void> insertMachine(Machine machine) async {
    final db = await database;
    await db.insert(
      'machines',
      machine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMachine(Machine machine) async {
    final db = await database;
    await db.update(
      'machines',
      machine.toMap(),
      where: 'id = ?',
      whereArgs: [machine.id],
    );
  }

  Future<void> deleteMachine(int id) async {
    final db = await database;
    await db.delete(
      'machines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
