import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';

class PasswordDatabase {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final path = join(await getDatabasesPath(), 'passwords.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            platform TEXT,
            account TEXT,
            password TEXT,
            note TEXT,
            last_updated TEXT
          )
        ''');
      },
    );

    return _database!;
  }

  static Future<int> insertPassword(PasswordEntry entry) async {
    final db = await getDatabase();
    return await db.insert('passwords', entry.toMap());
  }

  static Future<List<PasswordEntry>> getAllPasswords() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('passwords');

    return List.generate(maps.length, (i) {
      return PasswordEntry.fromMap(maps[i]);
    });
  }

  static Future<int> updatePassword(PasswordEntry entry) async {
    final db = await getDatabase();
    return await db.update(
      'passwords',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<int> deletePassword(int id) async {
    final db = await getDatabase();
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}

