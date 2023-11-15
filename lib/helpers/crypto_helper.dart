import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encryptLib;
import 'package:pointycastle/random/fortuna_random.dart';

import 'database_helper.dart';
import 'package:conversation_notebook/models/encryption_key.dart';


class CryptoHelper {
  static final CryptoHelper _instance = CryptoHelper._internal();

  factory CryptoHelper() => _instance;

  CryptoHelper._internal() {
    _initKey(); // 在构造函数中进行初始化
  }

  late Future<String> _key;

  Future<void> _initKey() async {
    _key = _getKey();
  }

  Future<String> _getKey() async {
    String? storedKey = await DatabaseHelper().getEncryptionKey();
    if (storedKey != null) {
      return storedKey;
    } else {
      // 生成随机密钥
      String newKey = generateRandomKey();
      await DatabaseHelper().addEncryptionKey(EncryptionKey(key: newKey));
      return newKey;
    }
  }

  static String generateRandomKey() {
    const keyLength = 32; // 256 bits
    final random = FortunaRandom(); // 使用密码学安全的随机数生成器
    final keyBytes = Uint8List.fromList(List.generate(keyLength, (index) => random.nextUint8()));
    return base64Url.encode(keyBytes);
  }

  Future<Uint8List> encrypt(Uint8List data) async {
    final key = await _key;
    final encrypter = encryptLib.Encrypter(
      encryptLib.AES(encryptLib.Key.fromUtf8(key), mode: encryptLib.AESMode.ecb),
    );
    final encrypted = encrypter.encryptBytes(data);
    return Uint8List.fromList(encrypted.bytes);
  }

  Future<Uint8List> decrypt(Uint8List encryptedData) async {
    final key = await _key;
    final encrypter = encryptLib.Encrypter(
      encryptLib.AES(encryptLib.Key.fromUtf8(key), mode: encryptLib.AESMode.ecb),
    );
    final decrypted = encrypter.decrypt(encryptLib.Encrypted(encryptedData));
    return Uint8List.fromList(decrypted.codeUnits);
  }
}


// void main() async {
//   // 创建 CryptoHelper 实例
//   CryptoHelper cryptoHelper = CryptoHelper();
//
//   // 加密和解密操作
//   Uint8List data = Uint8List.fromList([1, 2, 3, 4, 5]);
//
//   // 加密
//   Uint8List encryptedData = await cryptoHelper.encrypt(data);
//   print('Encrypted Data: $encryptedData');
//
//   // 解密
//   Uint8List decryptedData = await cryptoHelper.decrypt(encryptedData);
//   print('Decrypted Data: $decryptedData');
// }