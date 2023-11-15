// helpers/database_helper.dart

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:conversation_notebook/models/encryption_key.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/models/message.dart';
import 'package:conversation_notebook/models/scene.dart';

class DatabaseHelper {
  static const _databaseName = "character.db";
  static const _databaseVersion = 1;

  // 将其设计为单例类
  DatabaseHelper._privateConstructor();

  // 创建 DatabaseHelper 的单例实例
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // 只允许一个打开的连接
  static Database? _database;

  // 获取数据库实例的异步方法
  Future<Database> get database async {
    // 如果数据库已经打开，直接返回
    if (_database != null) return _database!;

    // 如果数据库未打开，初始化并打开
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database, creating the tables if necessary
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create Message table
    await db.execute('''
      CREATE TABLE message (
        id INTEGER PRIMARY KEY,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        contentType TEXT NOT NULL,
        contentText TEXT,
        contentPath TEXT
      )
    ''');

    // Create Scene table
    await db.execute('''
      CREATE TABLE scene (
        id INTEGER PRIMARY KEY,
        sceneName TEXT NOT NULL,
        backgroundPath TEXT,
        user1Id INTEGER NOT NULL,
        user2Id INTEGER NOT NULL
      )
    ''');

    // Create User table
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        description TEXT,
        avatarPath TEXT,
        backgroundPath TEXT
      )
    ''');

    // Create EncryptionKey table
    await db.execute('''
      CREATE TABLE encryptionkey (
        id INTEGER PRIMARY KEY,
        key TEXT NOT NULL
      )
    ''');
  }

  // Message table CRUD
  Future<int> insertMessage(Message message) async {
    final Database db = await instance.database;
    return await db.insert('message', message.toMap());
  }

  Future<int> deleteMessage(int messageId) async {
    final Database db = await instance.database;
    return await db.delete('message', where: 'id = ?', whereArgs: [messageId]);
  }

  Future<int> updateMessage(Message message) async {
    final Database db = await instance.database;
    return await db.update('message', message.toMap(), where: 'id = ?', whereArgs: [message.id]);
  }

  Future<List<Message>> getMessagesByUserIds(int user1Id, int user2Id) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query('message', where: 'senderId = ? AND receiverId = ? OR senderId = ? AND receiverId = ?', whereArgs: [user1Id, user2Id, user2Id, user1Id]);
    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  // Scene table CRUD
  Future<int> insertScene(Scene scene) async {
    final Database db = await instance.database;
    return await db.insert('scene', scene.toMap());
  }

  Future<int> deleteScene(int sceneId) async {
    final Database db = await instance.database;
    return await db.delete('scene', where: 'id = ?', whereArgs: [sceneId]);
  }

  Future<int> updateScene(Scene scene) async {
    final Database db = await instance.database;
    return await db.update('scene', scene.toMap(), where: 'id = ?', whereArgs: [scene.id]);
  }

  Future<Scene> getSceneById(int sceneId) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('scene', where: 'id = ?', whereArgs: [sceneId]);
    return Scene.fromMap(maps.first);
  }

  Future<List<Scene>> getScenes() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('scene');
    return List.generate(maps.length, (i) {
      return Scene.fromMap(maps[i]);
    });
  }

  // User table CRUD
  Future<int> insertUser(User user) async {
    final Database db = await instance.database;
    return await db.insert('user', user.toMap());
  }

  Future<int> deleteUser(int userId) async {
    final Database db = await instance.database;
    return await db.delete('user', where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUser(User user) async {
    final Database db = await instance.database;
    return await db.update('user', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<User> getUserById(int userId) async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('user', where: 'id = ?', whereArgs: [userId]);
    return User.fromMap(maps.first);
  }

  Future<List<User>> getUsers() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // EncryptionKey table CRUD
  Future<int> addEncryptionKey(EncryptionKey key) async {
    final Database db = await database;
    return await db.insert('EncryptionKeys', key.toMap());
  }

  Future<String?> getEncryptionKey() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('EncryptionKeys');
    if (result.isNotEmpty) {
      return result.first['key'];
    }
    return null;
  }
}
