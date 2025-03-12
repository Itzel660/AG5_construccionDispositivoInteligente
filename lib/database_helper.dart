import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clima.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lecturas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        temperatura REAL,
        humedad REAL,
        fecha TEXT
      )
    ''');
  }

  Future<int> insertarLectura(double temp, double hum) async {
    final db = await instance.database;
    return await db.insert('lecturas', {
      'temperatura': temp,
      'humedad': hum,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> obtenerLecturas() async {
    final db = await instance.database;
    return await db.query('lecturas', orderBy: 'id DESC', limit: 20);
  }
}
