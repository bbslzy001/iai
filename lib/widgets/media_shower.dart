import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iai/helpers/file_helper.dart';

class MyMediaShower extends StatefulWidget {
  final BoxFit fit;
  final String? image;
  final String? videoThumbnail;
  final String? video;
  final File? imageFile;
  final File? videoThumbnailFile;
  final File? videoFile;
  final String? defaultPicture;
  final bool clickable;

  const MyMediaShower({
    Key? key,
    this.fit = BoxFit.cover,
    this.image,
    this.videoThumbnail,
    this.video,
    this.imageFile,
    this.videoThumbnailFile,
    this.videoFile,
    this.defaultPicture,
    this.clickable = true,
  }) : super(key: key);

  @override
  State<MyMediaShower> createState() => _MyMediaShowerState();
}

class _MyMediaShowerState extends State<MyMediaShower> {
  bool _isImage = true;

  Future<File>? _imageFuture;
  Future<File>? _videoThumbnailFuture;
  Future<File>? _videoFuture;

  // 异步获取数据
  Future<File> _getImageFuture() async {
    return await FileHelper.getFile(widget.image!);
  }

  Future<File> _getVideoThumbnailFuture() async {
    return await FileHelper.getFile(widget.videoThumbnail!);
  }

  Future<File> _getVideoFuture() async {
    return await FileHelper.getFile(widget.video!);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (widget.imageFile != null) {
      return _buildImage(context, widget.imageFile!);
    } else if (widget.videoThumbnailFile != null && widget.videoFile != null) {
      return _buildVideo(context, widget.videoThumbnailFile!, widget.videoFile!, colorScheme.primary);
    }

    if (_imageFuture == null && widget.image != null) {
      _imageFuture = _getImageFuture();
    } else if (_videoThumbnailFuture == null && _videoFuture == null && widget.videoThumbnail != null && widget.video != null) {
      _isImage = false;
      _videoThumbnailFuture = _getVideoThumbnailFuture();
      _videoFuture = _getVideoFuture();
    }

    if (widget.image == null &&
        widget.videoThumbnail == null &&
        widget.video == null &&
        widget.imageFile == null &&
        widget.videoThumbnailFile == null &&
        widget.videoFile == null &&
        widget.defaultPicture != null) {
      return Image.asset(
        widget.defaultPicture!,
        fit: widget.fit,
      );
    }

    return FutureBuilder(
      future: _isImage ? Future.wait([_imageFuture!]) : Future.wait([_videoThumbnailFuture!, _videoFuture!]),
      builder: (context, snapshot) {
        // 检查异步操作的状态
        if (snapshot.hasData) {
          // 数据准备完成，构建页面
          if (_isImage) {
            File imageFile = snapshot.data![0];
            if (imageFile.existsSync()) {
              return _buildImage(context, imageFile);
            }
          } else {
            File videoThumbnailFile = snapshot.data![0];
            File videoFile = snapshot.data![1];
            if (videoThumbnailFile.existsSync() && videoFile.existsSync()) {
              return _buildVideo(context, videoThumbnailFile, videoFile, colorScheme.primary);
            }
          }
          return Container(
            alignment: Alignment.center,
            color: colorScheme.primaryContainer,
            child: const Text('Error: File not found'),
          );
        } else if (snapshot.hasError) {
          // 如果发生错误，显示错误信息
          return Container(
            alignment: Alignment.center,
            color: colorScheme.primaryContainer,
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          // 如果正在加载数据，显示填充颜色
          return Container(
            color: colorScheme.primaryContainer,
          );
        }
      },
    );
  }

  Widget _buildImage(BuildContext context, File imageFile) {
    Widget imageWidget = Image.file(
      imageFile,
      fit: widget.fit,
    );

    if (widget.clickable) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("/fullImage", arguments: {
            'imageFile': imageFile as File,
          });
        },
        child: Hero(
          // ObjectKey是一个用于创建一个基于对象的键（key）的类。
          // 在Flutter中，ObjectKey通常用于为具有唯一身份的对象生成全局唯一的标识符，以便在构建小部件树时，框架可以识别它们。
          tag: ObjectKey(imageFile), // 使用相同的tag以便Flutter知道这两个Hero是相关联的
          child: imageWidget,
        ),
      );
    } else {
      return imageWidget;
    }
  }

  Widget _buildVideo(BuildContext context, File videoThumbnailFile, File videoFile, Color primaryColor) {
    Widget videoWidget = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.file(
            videoThumbnailFile,
            fit: widget.fit,
          ),
        ),
        Icon(
          Icons.play_arrow,
          color: primaryColor,
          size: 48,
        ),
      ],
    );

    if (widget.clickable) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("/fullVideo", arguments: {
            'videoThumbnailFile': videoThumbnailFile as File,
            'videoFile': videoFile as File,
          });
        },
        child: Hero(
          tag: ObjectKey(videoThumbnailFile),
          child: videoWidget,
        ),
      );
    } else {
      return videoWidget;
    }
  }
}
