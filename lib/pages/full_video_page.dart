import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:iai/widgets/MyVideo.dart';
import 'package:video_player/video_player.dart';

// class FullVideoPage extends StatefulWidget {
//   final File videoThumbnailFile;
//   final File videoFile;
//
//   const FullVideoPage({
//     Key? key,
//     required this.videoThumbnailFile,
//     required this.videoFile,
//   }) : super(key: key);
//
//   @override
//   _FullVideoPageState createState() => _FullVideoPageState();
// }
//
// class _FullVideoPageState extends State<FullVideoPage> {
//   late VideoPlayerController _videoPlayerController;
//   late ChewieController _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     _videoPlayerController = VideoPlayerController.file(widget.videoFile)
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }
//
//   @override
//   void dispose() {
//     // 释放视频控制器资源
//     _videoPlayerController.dispose();
//     _chewieController.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child:
//             // 判断视频是否已加载并准备好播放
//             _videoPlayerController.value.isInitialized
//                 ? Chewie(
//                     controller: _chewieController = ChewieController(
//                     videoPlayerController: _videoPlayerController,
//                     autoPlay: true,
//                     aspectRatio: _videoPlayerController.value.aspectRatio,
//                     showOptions: false,
//                     // autoInitialize: true,
//                   ))
//                 : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child:
        MyVideo(videoFile: widget.videoFile),
      ),
    );
  }
}