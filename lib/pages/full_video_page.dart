import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullVideoPage extends StatefulWidget {
  final File videoThumbnailFile;
  final File videoFile;

  const FullVideoPage({
    Key? key,
    required this.videoThumbnailFile,
    required this.videoFile,
  }) : super(key: key);

  @override
  _FullVideoPageState createState() => _FullVideoPageState();
}

class _FullVideoPageState extends State<FullVideoPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 恢复系统 UI 模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

    // 释放视频控制器资源
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 设置全屏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 判断视频是否已加载并准备好播放
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
            IconButton(
              icon: Icon(_controller.value.position == _controller.value.duration
                  ? Icons.replay
                  : _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
              iconSize: 48.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
