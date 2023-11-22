import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:iai/helpers/encrypt_helper.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  // 从相册获取单个图片文件
  Future<XFile?> pickImageFromGallery() async {
    return _imagePicker.pickImage(source: ImageSource.gallery);
  }

  // 从相机获取单个图片文件
  Future<XFile?> pickImageFromCamera() async {
    return _imagePicker.pickImage(source: ImageSource.camera);
  }

  // 从相册获取单个视频文件
  Future<XFile?> pickVideoFromGallery() async {
    return _imagePicker.pickVideo(source: ImageSource.gallery);
  }

  // 保存视频缩略图（仅保存到缓存中）
  Future<String> saveThumbnail(Uint8List? thumbnailBytes) async {
    if (thumbnailBytes != null) {
      final thumbnailName = '${DateTime.now().millisecondsSinceEpoch}.temp';
      final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
      await DefaultCacheManager().putFile(cachePath.path, thumbnailBytes, key: thumbnailName);
      return thumbnailName;
    } else {
      return '';
    }
  }

  // 获取视频缩略图
  Future<File> getThumbnail(String thumbnailName, String videoName) async {
    if (thumbnailName.isNotEmpty) {
      // 缩略图存在于缓存中，直接返回缩略图
      final FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(thumbnailName);
      if (fileInfo != null) {
        return fileInfo.file; // 如果缩略图存在于缓存中，直接返回缓存的缩略图
      }
    }
    File videoFile = await getMedia(videoName);
    if (videoFile.existsSync()) {
      final thumbnailBytes = await getThumbnailBytes(videoFile);
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

  // 从视频中解析出缩略图
  Future<Uint8List?> getThumbnailBytes(File videoFile) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      timeMs: 1000, // 获取视频缩略图的时间位置，这里设置为第一秒
      quality: 100,
    );
    return thumbnail;
  }

  Future<String> saveMedia(File file) async {
    final fileBytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.enc';

    // 缓存
    final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
    await DefaultCacheManager().putFile(cachePath.path, fileBytes, key: fileName); // 保存原始文件到缓存目录

    // 加密存储
    final Uint8List encryptedFileBytes = await encryptHelper.encryptData(fileBytes); // 使用encryptHelper进行加密
    final savePath = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    await File('${savePath.path}/$fileName').writeAsBytes(encryptedFileBytes); // 保存加密文件到文档目录

    return fileName;
  }

  Future<File> getMedia(String fileName) async {
    // 文件存在于缓存中，直接返回原始文件
    final FileInfo? fileInfo = await DefaultCacheManager().getFileFromCache(fileName);
    if (fileInfo != null) {
      return fileInfo.file; // 如果文件存在于缓存中，直接返回缓存的原始文件
    }

    // 文件不存在于缓存中，则从文档目录中读取并解密文件，缓存后返回原始文件
    final savePath = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    final File encryptedFile = File('${savePath.path}/$fileName');
    if (encryptedFile.existsSync()) {
      final encryptedFileBytes = await encryptedFile.readAsBytes(); // 提取二进制信息
      final Uint8List fileBytes = await encryptHelper.decryptData(encryptedFileBytes); // 解密文件
      final cachePath = await getTemporaryDirectory(); // 获取应用缓存目录
      return DefaultCacheManager().putFile(cachePath.path, fileBytes, key: fileName); // 保存原始文件到缓存目录，并返回原始文件
    }

    // 如果文件不存在于文档目录中，返回空文件
    return File('');
  }
}
