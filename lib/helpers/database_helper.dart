// helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:conversation_notebook/models/encryption_key.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/models/message.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late Database _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database_name.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建用户表
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        description TEXT,
        avatarPath TEXT,
        backgroundPath TEXT
      )
    ''');

    // 创建消息表
    await db.execute('''
      CREATE TABLE Messages (
        id INTEGER PRIMARY KEY,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        contentType TEXT NOT NULL,
        contentPath TEXT,
        FOREIGN KEY (senderId) REFERENCES Users(id),
        FOREIGN KEY (receiverId) REFERENCES Users(id)
      )
    ''');

    // 创建密钥表
    await db.execute('''
      CREATE TABLE EncryptionKeys (
        id INTEGER PRIMARY KEY,
        key TEXT NOT NULL
      )
    ''');
  }

  // 添加用户
  Future<int> addUser(User user) async {
    final Database db = await database;
    return await db.insert('Users', user.toMap());
  }

  // 删除用户
  Future<int> deleteUser(int userId) async {
    final Database db = await database;
    return await db.delete('Users', where: 'id = ?', whereArgs: [userId]);
  }

  // 修改用户
  Future<int> updateUser(User user) async {
    final Database db = await database;
    return await db.update('Users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // 获取所有用户
  Future<List<User>> getUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Users');
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        username: maps[i]['username'],
        description: maps[i]['description'],
        avatarPath: maps[i]['avatarPath'],
        backgroundPath: maps[i]['backgroundPath'],
      );
    });
  }

  // 添加消息
  Future<int> addMessage(Message message) async {
    final Database db = await database;
    return await db.insert('Messages', message.toMap());
  }

  // 删除消息
  Future<int> deleteMessage(int messageId) async {
    final Database db = await database;
    return await db.delete('Messages', where: 'id = ?', whereArgs: [messageId]);
  }

  // 获取所有消息
  Future<List<Message>> getMessages() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Messages');
    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'],
        senderId: maps[i]['senderId'],
        receiverId: maps[i]['receiverId'],
        contentType: maps[i]['contentType'],
        contentPath: maps[i]['contentPath'],
      );
    });
  }

  // 添加密钥
  Future<int> addEncryptionKey(EncryptionKey key) async {
    final Database db = await database;
    return await db.insert('EncryptionKeys', key.toMap());
  }

  // 查询密钥
  Future<String?> getEncryptionKey() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('EncryptionKeys');
    if (result.isNotEmpty) {
      return result.first['key'];
    }
    return null;
  }
}
