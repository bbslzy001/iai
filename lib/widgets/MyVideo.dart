import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

enum OrientationStatus {
  portrait,
  landscape,
}

class MyVideo extends StatefulWidget {
  const MyVideo({Key? key, required this.videoFile}) : super(key: key);

  final File videoFile;

  @override
  State<MyVideo> createState() => _MyVideoState();
}

class _MyVideoState extends State<MyVideo> {
  bool _isInitialized = false;

  late VideoPlayerController _controller;
  Timer? _timer; // 计时器，用于延迟隐藏控件ui

  bool _controlWidgetHidden = true; // 控制是否隐藏控件ui
  double _playControlOpacity = 0; // 通过透明度动画显示/隐藏控件ui
  bool get _isFullScreen => MediaQuery.of(context).orientation == Orientation.landscape; // 是否全屏

  OrientationStatus _orientationStatus = OrientationStatus.portrait;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            setState(() {
              _controller.pause();
              _controller.seekTo(const Duration(seconds: 0));
            });
          }
        });
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return OrientationBuilder(
      builder: (context, orientation) {
        _orientationStatus =
        orientation == Orientation.landscape ? OrientationStatus.landscape : OrientationStatus.portrait;

        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _togglePlayControl();
                },
                child: _isInitialized
                    ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
                    : const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              controlWidget(screenWidth),
            ],
          ),
        );
      },
    );
  }

  void _togglePlayControl() {
    setState(() {
      if (_controlWidgetHidden) {
        _controlWidgetHidden = false;
        _playControlOpacity = 1;
        _startControlWidgetStatusTimer(); // 开始计时器，计时后隐藏
      } else {
        _playControlOpacity = 0;
        _controlWidgetHidden = true;
      }
    });
  }

  void _startControlWidgetStatusTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 3000), () {
      _timer?.cancel();
      setState(() {
        _playControlOpacity = 0;
        _controlWidgetHidden = true;
      });
    });
  }

  // void _toggleFullScreen() {
  //   setState(() {
  //     if (_isFullScreen) {
  //       // 退出全屏，改为竖屏
  //     } else {
  //       // 开启全屏，如果视频宽度大于高度，那么横向全屏，反之竖向全屏
  //     }
  //     _startControlWidgetStatusTimer(); // 操作完控件开始计时隐藏
  //   });
  // }
  void _toggleFullScreen() {
    setState(() {
      if (_isFullScreen) {
        // Exit fullscreen, switch to portrait
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      } else {
        // Check if the video's aspect ratio is greater than 1 for landscape, or else switch to portrait
        if (_controller.value.aspectRatio > 1) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
        } else {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }
      }
      _startControlWidgetStatusTimer(); // Hide controls after performing the operation
    });
  }

  // 控件ui下半部
  Widget controlWidget(double screenWidth) {
    return Positioned(
      // 需要定位
      left: 0,
      bottom: 0,
      child: Offstage(
        // 控制是否隐藏
        offstage: _controlWidgetHidden,
        child: AnimatedOpacity(
          // 加入透明度动画
          opacity: _playControlOpacity,
          duration: const Duration(milliseconds: 300),
          child: Container(
            // 底部控件的容器
            width: screenWidth,
            height: 60,
            // 黑色到透明的渐变背景
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color.fromRGBO(0, 0, 0, .7), Color.fromRGBO(0, 0, 0, .1)],
              ),
            ),
            child: _isInitialized
                ? Row(
                    children: [
                      IconButton(
                        // 播放按钮
                        padding: EdgeInsets.zero,
                        iconSize: 26,
                        icon: Icon(
                          // 根据控制器动态变化播放图标还是暂停
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            // 同样的，点击动态播放或者暂停
                            _controller.value.isPlaying ? _controller.pause() : _controller.play();
                            _startControlWidgetStatusTimer(); // 操作控件后，重置延迟隐藏控件的timer
                          });
                        },
                      ),
                      Flexible(
                        // video_player自带的进度条
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true, // 允许手势操作进度条
                          padding: const EdgeInsets.all(0),
                          colors: VideoProgressColors(
                            playedColor: Theme.of(context).primaryColor, // 已播放的颜色
                            bufferedColor: const Color.fromRGBO(255, 255, 255, .5), // 缓存中的颜色
                            backgroundColor: const Color.fromRGBO(255, 255, 255, .2), // 未缓存的颜色
                          ),
                        ),
                      ),
                      Container(
                        // 播放时间
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${_durationToTime(_controller.value.position)}/${_durationToTime(_controller.value.duration)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        // 全屏/横屏按钮
                        padding: EdgeInsets.zero,
                        iconSize: 26,
                        icon: Icon(
                          // 根据当前屏幕方向切换图标
                          _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // 点击切换是否全屏
                          _toggleFullScreen();
                        },
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }

  String _durationToTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds.remainder(60);

    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}
