import 'dart:io';

import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 判断视频是否已加载并准备好播放
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Text("Error"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
