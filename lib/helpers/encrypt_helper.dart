import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/encryption_key.dart';

class EncryptManager {
  late final Encrypter encrypter;

  // 创建 EncryptHelper 的单例实例
  static final EncryptManager _instance = EncryptManager._privateConstructor();

  // 获取单例实例
  factory EncryptManager() {
    return _instance;
  }

  EncryptManager._privateConstructor();

  Future<void> initialize() async {
    final encryptionKey = await _initEncryptionKey();
    // 创建加密器对象
    encrypter = Encrypter(AES(Key.fromBase64(encryptionKey), mode: AESMode.ecb));
  }

  // 从数据库初始化加密密钥
  Future<String> _initEncryptionKey() async {
    final DatabaseHelper dbHelper = DatabaseHelper();
    final String? storedKey = await dbHelper.getEncryptionKey();

    // 如果数据库中存在密钥，直接返回
    if (storedKey != null) {
      return storedKey;
    }

    // 如果数据库中不存在密钥，生成随机密钥
    final String newKey = _generateRandomKey();
    await dbHelper.addEncryptionKey(EncryptionKey(key: newKey));
    return newKey;
  }

  String _generateRandomKey() {
    const keyLengthBytes = 32; // 设置密钥长度为32字节，即256喂
    final random = FortunaRandom(); // 创建安全随机数生成器实例
    final sGen = Random.secure(); // 生成随机种子（密钥参数）
    random.seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => sGen.nextInt(255))))); // 初始化安全随机数生成器
    final keyBytes = Uint8List.fromList(List.generate(keyLengthBytes, (index) => random.nextUint8())); // 生成随机字节码
    return base64.encode(keyBytes); // 将字节码转换为base64字符串并返回
  }
}

// 定义一个自定义的类，用于封装data和encrypter
class EncryptData {
  final Uint8List data;
  final Encrypter encrypter;

  EncryptData(this.data, this.encrypter);
}

// 当执行耗时较长耗资源较多的任务时，使用 async/await 异步处理仍会阻塞UI刷新，造成动画卡顿
// 因为该任务仍处于UI线程，异步只是允许先执行其他代码，等异步结果返回后再继续执行异步代码（异步只是在同一个线程的并发操作）
// 需要通过创建新的线程来执行该类任务
class EncryptHelper {
  // 加密数据
  static Future<Uint8List> encryptData(EncryptData encryptData) async {
    final data = encryptData.data;
    final encrypter = encryptData.encrypter;
    final Encrypted encrypted = encrypter.encryptBytes(data);
    return Uint8List.fromList(encrypted.bytes);
  }

  // 解密媒体文件数据
  static Future<Uint8List> decryptData(EncryptData encryptData) async {
    final data = encryptData.data;
    final encrypter = encryptData.encrypter;
    final List<int> decrypted = encrypter.decryptBytes(Encrypted(data));
    return Uint8List.fromList(decrypted);
  }
}
