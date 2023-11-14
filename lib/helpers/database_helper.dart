import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/message_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        text TEXT
      )
    ''');
  }

  // Future<int> insertMessage(Message message) async {
  //   Database db = await instance.database;
  //   return await db.insert('messages', message.toMap());
  // }
  //
  // Future<List<Message>> getMessages() async {
  //   Database db = await instance.database;
  //   List<Map<String, dynamic>> maps = await db.query('messages');
  //   return List.generate(maps.length, (index) {
  //     return Message.fromMap(maps[index]);
  //   });
  // }
}
