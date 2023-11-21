import 'package:flutter/material.dart';

import 'package:iai/helpers/file_helper.dart';

class MyImageShower extends StatefulWidget {
  final String image;
  final String defaultImage;

  const MyImageShower({Key? key, required this.image, required this.defaultImage}) : super(key: key);

  @override
  _MyImageShowerState createState() => _MyImageShowerState();
}

class _MyImageShowerState extends State<MyImageShower> {
  final FileHelper _fileHelper = FileHelper();

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (widget.image.isNotEmpty) {
      return FutureBuilder(
        future: _fileHelper.getMedia(widget.image),
        builder: (context, snapshot) {
          // 检查异步操作的状态
          if (snapshot.hasData) {
            // 数据准备完成，构建页面
            if (snapshot.data!.existsSync()) {
              return Image.file(
                snapshot.data!,
                fit: BoxFit.fill,
              );
            } else {
              return Container(
                alignment: Alignment.center,
                color: colorScheme.primaryContainer,
                child: Text('Error: ${snapshot.error}'),
              );
            }
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
    } else {
      return Image.asset(widget.defaultImage);
    }
  }
}
