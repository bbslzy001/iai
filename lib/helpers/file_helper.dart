import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:iai/helpers/encrypt_helper.dart';

class FileHelper {
  final ImagePicker _imagePicker = ImagePicker();
  final EncryptHelper encryptHelper = EncryptHelper();

  // 私有构造函数
  FileHelper._privateConstructor();

  // 创建 FileHelper 的单例实例
  static final FileHelper _instance = FileHelper._privateConstructor();

  // 获取单例实例
  factory FileHelper() {
    return _instance;
  }

  Future<XFile?> pickMediaFromGallery() async {
    return _imagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<String> saveMedia(File file) async {
    final fileBytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';

    // 缓存
    final cachePath = await getTemporaryDirectory();  // 获取应用缓存目录
    await DefaultCacheManager().putFile(cachePath.path, fileBytes, key: fileName);  // 保存原始文件到缓存目录

    // 加密存储
    final Uint8List encryptedFileBytes = await encryptHelper.encryptData(fileBytes);  // 使用encryptHelper进行加密
    final savePath = await getApplicationDocumentsDirectory();  // 获取应用文档目录
    await File('${savePath.path}/$fileName').writeAsBytes(encryptedFileBytes);  // 保存加密文件到文档目录

    return fileName;
  }

  Future<File> getMedia(String fileName) async {
    // 文件存在于缓存中，直接返回原始文件
    final FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(fileName);
    if (fileInfo != null) {
      return fileInfo.file; // 如果文件存在于缓存中，直接返回缓存的原始文件
    }

    // 文件不存在于缓存中，则从文档目录中读取并解密文件，缓存后返回原始文件
    final savePath = await getApplicationDocumentsDirectory();  // 获取应用文档目录
    final File encryptedFile = File('${savePath.path}/$fileName');
    if (encryptedFile.existsSync()) {
      final encryptedFileBytes = await encryptedFile.readAsBytes();  // 提取二进制信息
      final Uint8List fileBytes = await encryptHelper.decryptData(encryptedFileBytes);  // 解密文件
      final cachePath = await getTemporaryDirectory();  // 获取应用缓存目录
      await DefaultCacheManager().putFile(cachePath.path, fileBytes, key: fileName);  // 保存原始文件到缓存目录
      return DefaultCacheManager().getFileFromCache(fileName).then((fileInfo) {
        return fileInfo!.file;
      });  // 返回原始文件
    }

    // 如果文件不存在于文档目录中，返回空文件
    return File('');
  }
}
