import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('blupp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('DEBUG: Database path: $path');

    final db = await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from $oldVersion to $newVersion');
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE bank_accounts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              balance REAL
            )
          ''');
          await db.execute('''
            CREATE TABLE loans (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              amount REAL,
              type TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE transactions (
              id TEXT PRIMARY KEY,
              title TEXT,
              amount REAL,
              date TEXT,
              category TEXT,
              type TEXT
            )
          ''');
        }
      },
    );
    print('Database version: ${await db.getVersion()}');
    return db;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        balance REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        amount REAL,
        type TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT,
        amount REAL,
        date TEXT,
        category TEXT,
        type TEXT
      )
    ''');
  }

  Future<int> createUser(String email, String password) async {
    final db = await instance.database;
    try {
      return await db.insert('users', {'email': email, 'password': password});
    } catch (e) {
      return -1; // Indicates error (e.g., email exists)
    }
  }

  Future<bool> authenticateUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }
}
