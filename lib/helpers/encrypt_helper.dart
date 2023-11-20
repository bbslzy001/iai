import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/encryption_key.dart';

class EncryptHelper {
  // 私有构造函数
  EncryptHelper._privateConstructor();

  // 创建 EncryptHelper 的单例实例
  static final EncryptHelper _instance = EncryptHelper._privateConstructor();

  // 获取单例实例
  factory EncryptHelper() {
    return _instance;
  }

  // 只允许一个加密密钥
  static String? _encryptionKey;

  // 只允许一个加密器对象
  static Encrypter? _encrypter;

  static String generateRandomKey() {
    const keyLengthBytes = 32;  // 设置密钥长度为32字节，即256喂
    final random = FortunaRandom();  // 创建安全随机数生成器实例
    final sGen = Random.secure();  // 生成随机种子（密钥参数）
    random.seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => sGen.nextInt(255)))));  // 初始化安全随机数生成器
    final keyBytes = Uint8List.fromList(List.generate(keyLengthBytes, (index) => random.nextUint8()));  // 生成随机字节码
    return base64.encode(keyBytes);  // 将字节码转换为base64字符串并返回
  }

  // 获取加密器对象的异步方法
  Future<Encrypter> get encrypter async {
    // 如果加密器已创建，直接返回
    if (_encrypter != null) {
      return _encrypter!;
    }

    // 如果加密密钥未设置，从数据库初始化
    _encryptionKey ??= await _initEncryptionKey();

    // 创建加密器对象
    _encrypter = Encrypter(AES(Key.fromBase64(_encryptionKey!), mode: AESMode.ecb));
    return _encrypter!;
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
    final String newKey = generateRandomKey();
    await dbHelper.addEncryptionKey(EncryptionKey(key: newKey));
    return newKey;
  }

  // 加密数据
  Future<Uint8List> encryptData(Uint8List data) async {
    final Encrypter encrypter = await _instance.encrypter;
    final Encrypted encrypted = encrypter.encryptBytes(data);
    return Uint8List.fromList(encrypted.bytes);
  }

  // 解密媒体文件数据
  Future<Uint8List> decryptData(Uint8List data) async {
    final Encrypter encrypter = await _instance.encrypter;
    final String decrypted = encrypter.decrypt(Encrypted(data));
    return Uint8List.fromList(decrypted.codeUnits);
  }
}
