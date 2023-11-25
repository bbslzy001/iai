// helpers/database_helper.dart

import 'dart:io';

import 'package:iai/models/identity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:iai/models/encryption_key.dart';
import 'package:iai/models/message.dart';
import 'package:iai/models/note.dart';
import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/models/notefeedback.dart';

// TODO: 提供级联删除
class DatabaseHelper {
  static const _databaseName = "iai.db";
  static const _databaseVersion = 1;

  // 私有构造函数
  DatabaseHelper._privateConstructor();

  // 创建 DatabaseHelper 的单例实例
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  // 获取单例实例
  factory DatabaseHelper() {
    return _instance;
  }

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
    String path = '${documentsDirectory.path}/$_databaseName';
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create Message table
    await db.execute('''
      CREATE TABLE message (
        id INTEGER PRIMARY KEY,
        sceneId INTEGER NOT NULL,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        contentType TEXT NOT NULL,
        contentText TEXT NOT NULL,
        contentImage TEXT NOT NULL,
        contentVideo TEXT NOT NULL
      )
    ''');

    // Create Scene table
    await db.execute('''
      CREATE TABLE scene (
        id INTEGER PRIMARY KEY,
        sceneName TEXT NOT NULL,
        backgroundImage TEXT NOT NULL,
        user1Id INTEGER NOT NULL,
        user2Id INTEGER NOT NULL
      )
    ''');

    // Create User table
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        description TEXT NOT NULL,
        avatarImage TEXT NOT NULL,
        backgroundImage TEXT NOT NULL
      )
    ''');

    // Create Identity table
    await db.execute('''
      CREATE TABLE identity (
        id INTEGER PRIMARY KEY,
        identityName TEXT NOT NULL,
        backgroundImage TEXT NOT NULL
      )
    ''');

    // Create Note table
    await db.execute('''
      CREATE TABLE note (
        id INTEGER PRIMARY KEY,
        identityId INTEGER NOT NULL,
        noteTitle TEXT NOT NULL,
        noteContent TEXT NOT NULL,
        noteStatus INTEGER NOT NULL
      )
    ''');

    // Create NoteFeedback table
    await db.execute('''
      CREATE TABLE notefeedback (
        id INTEGER PRIMARY KEY,
        noteId INTEGER NOT NULL,
        contentType TEXT NOT NULL,
        contentText TEXT NOT NULL,
        contentImage TEXT NOT NULL,
        contentVideo TEXT NOT NULL
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
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('message', message.toMap());
  }

  Future<int> deleteMessage(int messageId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.delete('message', where: 'id = ?', whereArgs: [messageId]);
  }

  Future<int> updateMessage(Message message) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.update('message', message.toMap(), where: 'id = ?', whereArgs: [message.id]);
  }

  Future<List<Message>> getMessagesBySceneId(int sceneId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('message', where: 'sceneId = ?', whereArgs: [sceneId]);
    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  // Scene table CRUD
  Future<int> insertScene(Scene scene) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('scene', scene.toMap());
  }

  Future<int> deleteScene(int sceneId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.delete('scene', where: 'id = ?', whereArgs: [sceneId]);
  }

  Future<int> updateScene(Scene scene) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.update('scene', scene.toMap(), where: 'id = ?', whereArgs: [scene.id]);
  }

  Future<Scene> getSceneById(int sceneId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('scene', where: 'id = ?', whereArgs: [sceneId]);
    return Scene.fromMap(maps.first);
  }

  Future<List<Scene>> getScenes() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('scene');
    return List.generate(maps.length, (i) {
      return Scene.fromMap(maps[i]);
    });
  }

  // User table CRUD
  Future<int> insertUser(User user) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('user', user.toMap());
  }

  Future<int> deleteUser(int userId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.delete('user', where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUser(User user) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.update('user', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<User> getUserById(int userId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('user', where: 'id = ?', whereArgs: [userId]);
    return User.fromMap(maps.first);
  }

  Future<List<User>> getUsers() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Identity table CRUD
  Future<int> insertIdentity(Identity identity) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('identity', identity.toMap());
  }

  Future<int> deleteIdentity(int identityId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.delete('identity', where: 'id = ?', whereArgs: [identityId]);
  }

  Future<int> updateIdentity(Identity identity) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.update('identity', identity.toMap(), where: 'id = ?', whereArgs: [identity.id]);
  }

  Future<Identity> getIdentityById(int identityId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('identity', where: 'id = ?', whereArgs: [identityId]);
    return Identity.fromMap(maps.first);
  }

  Future<List<Identity>> getIdentities() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('identity');
    return List.generate(maps.length, (i) {
      return Identity.fromMap(maps[i]);
    });
  }

  // Note table CRUD
  Future<int> insertNote(Note note) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('note', note.toMap());
  }

  Future<int> deleteNote(int noteId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.delete('note', where: 'id = ?', whereArgs: [noteId]);
  }

  Future<int> updateNote(Note note) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.update('note', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<Note> getNoteById(int noteId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('note', where: 'id = ?', whereArgs: [noteId]);
    return Note.fromMap(maps.first);
  }

  Future<List<Note>> getNotesByIdentityId(int identityId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('note', where: 'identityId = ?', whereArgs: [identityId]);
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // NoteFeedback table CRUD
  Future<int> insertNoteFeedback(NoteFeedback noteFeedback) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('notefeedback', noteFeedback.toMap());
  }

  Future<int> deleteNoteFeedback(int noteFeedbackId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.delete('notefeedback', where: 'id = ?', whereArgs: [noteFeedbackId]);
  }

  Future<int> updateNoteFeedback(NoteFeedback noteFeedback) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.update('notefeedback', noteFeedback.toMap(), where: 'id = ?', whereArgs: [noteFeedback.id]);
  }

  Future<NoteFeedback> getNoteFeedbackById(int noteFeedbackId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('notefeedback', where: 'id = ?', whereArgs: [noteFeedbackId]);
    return NoteFeedback.fromMap(maps.first);
  }

  Future<List<NoteFeedback>> getNoteFeedbacksByNoteId(int noteId) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('notefeedback', where: 'noteId = ?', whereArgs: [noteId]);
    return List.generate(maps.length, (i) {
      return NoteFeedback.fromMap(maps[i]);
    });
  }

  // EncryptionKey table CRUD
  Future<int> insertEncryptionKey(EncryptionKey key) async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    return await db.insert('encryptionkey', key.toMap());
  }

  Future<String?> getEncryptionKey() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    final Database db = await _instance.database;
    final List<Map<String, dynamic>> maps = await db.query('encryptionkey');
    if (maps.isNotEmpty) {
      return maps.first['key'];
    }
    return null;
  }
}
