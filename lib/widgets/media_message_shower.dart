import 'package:flutter/material.dart';

import 'package:iai/helpers/file_helper.dart';

class MyMediaMessageShower extends StatefulWidget {
  final String image;

  const MyMediaMessageShower({Key? key, required this.image}) : super(key: key);

  @override
  _MyMediaMessageShowerState createState() => _MyMediaMessageShowerState();
}

class _MyMediaMessageShowerState extends State<MyMediaMessageShower> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: FileHelper.getMedia(widget.image),
      builder: (context, snapshot) {
        // 检查异步操作的状态
        if (snapshot.hasData) {
          // 数据准备完成，构建页面
          if (snapshot.data!.existsSync()) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
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
  }
}
