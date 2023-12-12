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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        return true; // 允许返回动作
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            // 点击屏幕时退出页面并恢复系统UI模式
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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
      ),
    );
  }
}
