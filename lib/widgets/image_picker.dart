import 'dart:io';

import 'package:flutter/material.dart';

class ImagePickerWidget extends StatefulWidget {
  final Future<dynamic> Function() onTap;
  final Future<dynamic> Function()? getImage;
  final double width;
  final double height;
  final String labelText;

  const ImagePickerWidget({
    Key? key,
    required this.onTap,
    this.getImage,
    this.width = 100.0,
    this.height = 100.0,
    this.labelText = 'image',
  }) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _file;
  bool isGotten = false;  // 避免编辑图片时切换图片后再次执行getImage导致循环

  @override
  Widget build(BuildContext context) {
    if (!isGotten && widget.getImage != null) {
      print(widget.labelText);
      return FutureBuilder(
        future: widget.getImage!(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            isGotten = true;
            _file = snapshot.data;
            return buildImagePicker();
          } else if (snapshot.hasError) {
            return buildImagePickerContainer(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return buildImagePickerContainer(
              child: const CircularProgressIndicator(),
            );
          } else {
            print('snapshot: $snapshot');
            return SizedBox();
          }
        },
      );
    } else {
      return buildImagePicker();
    }
  }

  Widget buildImagePickerContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(width: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: child,
    );
  }

  Widget buildImagePickerContent() {
    if (_file?.existsSync() == true) {
      return Image.file(
        _file!,
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中
        crossAxisAlignment: CrossAxisAlignment.center, // 水平方向居中
        children: [
          const Icon(Icons.add_photo_alternate),
          widget.labelText.isNotEmpty ? Text(widget.labelText) : const SizedBox.shrink(), // 以确保不占用空间,
        ],
      );
    }
  }

  Widget buildImagePicker() {
    return GestureDetector(
      child: buildImagePickerContainer(child: buildImagePickerContent()),
      onTap: () async {
        File? file = await widget.onTap();
        setState(() {
          _file = file;
        });
      },
    );
  }
}
