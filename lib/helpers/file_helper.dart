import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FileDirectoryManager {
  late final String fileDirectory;

  // 创建 FileDirectoryManager 的单例实例
  static final FileDirectoryManager _instance = FileDirectoryManager._privateConstructor();

  // 获取单例实例
  factory FileDirectoryManager() {
    return _instance;
  }

  FileDirectoryManager._privateConstructor();

  Future<void> initialize() async {
    final appDocDir = await getApplicationDocumentsDirectory(); // 获取应用文档目录
    fileDirectory = '${appDocDir.path}/idata';
    await Directory(fileDirectory).create(recursive: true); // 创建文件夹
  }
}

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

  // 保存视频缩略图
  static Future<String> saveThumbnail(File videoFile) async {
    final thumbnailBytes = await VideoThumbnail.thumbnailData(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      timeMs: 1000, // 获取视频缩略图的时间位置，这里设置为第一秒
      quality: 100,
    );
    if (thumbnailBytes != null) {
      return await _saveFileBytes(thumbnailBytes);
    } else {
      return '';
    }
  }

  // 保存文件到文档目录
  static Future<String> saveFile(File file) async {
    final fileBytes = await file.readAsBytes();
    return await _saveFileBytes(fileBytes);
  }

  static Future<String> _saveFileBytes(Uint8List fileBytes) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.txt';
    await File('${FileDirectoryManager().fileDirectory}/$fileName').writeAsBytes(fileBytes); // 保存文件到文档目录
    return fileName;
  }

  // 从文档目录读取文件
  static Future<File> getFile(String fileName) async {
    final file = File('${FileDirectoryManager().fileDirectory}/$fileName');
    if (await file.exists()) {
      return file;
    } else {
      return File('');
    }
  }
}
