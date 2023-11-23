import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class FullImagePage extends StatelessWidget {
  final File imageFile;

  const FullImagePage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 设置全屏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // 点击屏幕时退出页面并恢复系统UI模式
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
          Navigator.of(context).pop();
        },
        child: PhotoView(
          imageProvider: FileImage(imageFile),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2.0,
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: ObjectKey(imageFile)), // 设置Hero小部件
        ),
      ),
    );
  }
}
