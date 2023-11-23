import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:iai/helpers/encrypt_helper.dart';

class FileHelper {
  // 从相册获取单个图片文件
  static Future<XFile?> pickImageFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    return imagePicker.pickImage(source: ImageSource.gallery);
  }

  // 从相机获取单个图片文件
  static Future<XFile?> pickImageFromCamera() async {
    final ImagePicker imagePicker = ImagePicker();
    return imagePicker.pickImage(source: ImageSource.camera);
  }

  // 从相册获取单个视频文件
  static Future<XFile?> pickVideoFromGallery() async {
    final ImagePicker imagePicker = ImagePicker();
    return imagePicker.pickVideo(source: ImageSource.gallery);
  }

  // 从视频中解析出缩略图
  static Future<Uint8List?> getThumbnailBytes(File videoFile) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      timeMs: 1000, // 获取视频缩略图的时间位置，这里设置为第一秒
      quality: 100,
    );
    return thumbnail;
  }

  // 保存视频缩略图（仅保存到缓存中）
  static Future<Map<String, File>> saveThumbnail(File videoFile) async {
    final thumbnailBytes = await FileHelper.getThumbnailBytes(videoFile);
    if (thumbnailBytes != null) {
      final thumbnailName = '${DateTime.now().millisecondsSinceEpoch}.temp';
      final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
      final thumbnailFile = await DefaultCacheManager().putFile(cachePath.path, thumbnailBytes, key: thumbnailName);
      return {thumbnailName: thumbnailFile};
    } else {
      return {};
    }
  }

  // 获取视频缩略图
  static Future<File> getThumbnail(String thumbnailName, String videoName) async {
    if (thumbnailName.isNotEmpty) {
      // 缩略图存在于缓存中，直接返回缩略图
      final fileInfo = await DefaultCacheManager().getFileFromCache(thumbnailName);
      if (fileInfo != null) {
        return fileInfo.file; // 如果缩略图存在于缓存中，直接返回缓存的缩略图
      }
    }
    final videoFile = await getMedia(videoName);
    if (videoFile.existsSync()) {
      final thumbnailBytes = await FileHelper.getThumbnailBytes(videoFile);
      if (thumbnailBytes != null) {
        // 如果上一次生成缩略图出错，就生成新的缩略图名称
        final newThumbnailName = thumbnailName.isNotEmpty ? thumbnailName : '${DateTime.now().millisecondsSinceEpoch}.temp';
        final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
        return DefaultCacheManager().putFile(cachePath.path, thumbnailBytes, key: newThumbnailName); // 保存缩略图到缓存目录，并返回缩略图
        // TODO: 更新数据库中缩略图的名称
      }
    }
    return File(''); // 获取失败，可能是获取视频失败，也可能是生成缓存图失败
  }

  static Future<String> saveMedia(File file) async {
    final fileBytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';

    // 缓存
    final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
    await DefaultCacheManager().putFile(cachePath.path, fileBytes, key: fileName); // 保存原始文件到缓存目录

    // 加密存储
    final encryptedFileBytes = await compute(EncryptHelper.encryptData, EncryptData(fileBytes, EncryptManager().encrypter)); // 使用encryptHelper进行加密
    final savePath = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    await File('${savePath.path}/$fileName').writeAsBytes(encryptedFileBytes); // 保存加密文件到文档目录

    return fileName;
  }

  static Future<File> getMedia(String fileName) async {
    // 文件存在于缓存中，直接返回原始文件
    final fileInfo = await DefaultCacheManager().getFileFromCache(fileName);
    if (fileInfo != null) {
      return fileInfo.file; // 如果文件存在于缓存中，直接返回缓存的原始文件
    }

    // 文件不存在于缓存中，则从文档目录中读取并解密文件，缓存后返回原始文件
    final savePath = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    final encryptedFile = File('${savePath.path}/$fileName');
    if (encryptedFile.existsSync()) {
      final encryptedFileBytes = await encryptedFile.readAsBytes(); // 提取二进制信息

      // 解密
      final fileBytes = await compute(EncryptHelper.decryptData, EncryptData(encryptedFileBytes, EncryptManager().encrypter)); // 解密文件
      final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
      return DefaultCacheManager().putFile(cachePath.path, fileBytes, key: fileName); // 保存原始文件到缓存目录，并返回原始文件
    }

    // 如果文件不存在于文档目录中，返回空文件
    return File('');
  }
}
