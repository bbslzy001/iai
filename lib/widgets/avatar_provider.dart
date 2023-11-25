import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:iai/helpers/file_helper.dart';

// 自定义ImageProvider类，它接受一个图像名称作为参数
class MyAvatarProvider extends ImageProvider<MyAvatarProvider> {
  final String imageName;

  MyAvatarProvider(this.imageName);

  // 这个方法用于获取图像的唯一键，用于缓存和比较
  @override
  Future<MyAvatarProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MyAvatarProvider>(this);
  }

  // 这个方法用于加载图像数据，并返回一个ImageStreamCompleter对象
  @override
  ImageStreamCompleter load(MyAvatarProvider key, DecoderCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key.imageName));
  }

  Future<ImageInfo> _loadAsync(String image) async {
    final file = await FileHelper.getMedia(image);

    if (file.existsSync()) {
      final bytes = await file.readAsBytes(); // 用于将文件对象转换为字节列表
      final codec = await PaintingBinding.instance.instantiateImageCodec(bytes); // 用于创建一个图像编解码器，用于解码图像数据
      final frameInfo = await codec.getNextFrame(); // 用于获取图像的第一帧，如果是静态图像，就是整个图像
      final image = frameInfo.image; // 用于获取图像对象
      return ImageInfo(image: image); // 用于创建并返回ImageInfo对象
    } else {
      // 如果文件不存在，抛出异常
      throw StateError('File not found: $image');
    }
  }

  // 这个方法用于比较两个ImageProvider是否相等
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is MyAvatarProvider && other.imageName == imageName;
  }

  // 这个方法用于获取ImageProvider的哈希码
  @override
  int get hashCode => imageName.hashCode;

  // 这个方法用于获取ImageProvider的字符串表示
  @override
  String toString() => '$runtimeType("$imageName")';
}
