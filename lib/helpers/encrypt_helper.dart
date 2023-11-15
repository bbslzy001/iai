import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/random/fortuna_random.dart';

import 'package:conversation_notebook/helpers/database_helper.dart';
import 'package:conversation_notebook/models/encryption_key.dart';


class EncryptHelper {
  // 将其设计为单例类
  EncryptHelper._privateConstructor();

  // 创建 EncryptHelper 的单例实例
  static final EncryptHelper instance = EncryptHelper._privateConstructor();

  // 只允许一个加密密钥
  static String? _encryptionKey;

  // 只允许一个加密器对象
  static Encrypter? _encrypter;

  // 获取加密器对象的异步方法
  Future<Encrypter> get encrypter async {
    // 如果加密器已创建，直接返回
    if (_encrypter != null) {
      return _encrypter!;
    }

    // 创建加密器对象
    _encrypter = Encrypter(AES(Key.fromUtf8(_encryptionKey!), mode: AESMode.ecb));
    return _encrypter!;
  }

  // 获取加密密钥的异步方法
  Future<String> get encryptionKey async {
    // 如果加密密钥已设置，直接返回
    if (_encryptionKey != null) {
      return _encryptionKey!;
    }

    // 如果加密密钥未设置，从数据库初始化
    _encryptionKey = await _initEncryptionKey();
    return _encryptionKey!;
  }

  // 从数据库初始化加密密钥
  Future<String> _initEncryptionKey() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    String? storedKey = await dbHelper.getEncryptionKey();

    // 如果数据库中存在密钥，直接返回
    if (storedKey != null) {
      return storedKey;
    }

    // 如果数据库中不存在密钥，生成随机密钥
    String newKey = generateRandomKey();
    await dbHelper.addEncryptionKey(EncryptionKey(key: newKey));
    return newKey;
  }

  static String generateRandomKey() {
    const keyLength = 32; // 256 bits
    final random = FortunaRandom(); // 使用密码学安全的随机数生成器
    final keyBytes = Uint8List.fromList(List.generate(keyLength, (index) => random.nextUint8()));
    return base64Url.encode(keyBytes);
  }

  // 加密数据
  Uint8List encryptData(Uint8List data) {
    Encrypted encrypted = _encrypter!.encryptBytes(data);
    return Uint8List.fromList(encrypted.bytes);
  }

  // 解密媒体文件数据
  Uint8List decryptData(Uint8List data) {
    String decrypted = _encrypter!.decrypt(Encrypted(data));
    return Uint8List.fromList(decrypted.codeUnits);
  }
}


// EncryptHelper encryptHelper = EncryptHelper.instance;
// Uint8List originalData = ...; // 要加密的数据
//
// // 加密
// Uint8List encryptedData = encryptHelper.encryptData(originalData);
//
// // 解密
// Uint8List decryptedData = encryptHelper.decryptData(encryptedData);