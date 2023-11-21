import 'package:flutter/material.dart';

import 'package:iai/models/scene.dart';

import '../../widgets/image_shower.dart';

class ScenePage extends StatefulWidget {
  final Scene scene;

  ScenePage({Key? key, required this.scene}) : super(key: key);

  @override
  _ScenePageState createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    double screenHeight = MediaQuery.of(context).size.height;

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scene.sceneName),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          // 上半部分背景
          Container(
            height: screenHeight * 0.15,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),
                Container(
                  height: screenHeight * 0.2,
                  child: MyImageShower(
                    image: widget.scene.backgroundImage,
                    defaultImage: 'assets/images/scene.png',
                  ),
                ),
                // Text(
                //   'Title: ${widget.scene.title}',
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                // SizedBox(height: 16),
                // Text(
                //   'Description: ${widget.scene.description}',
                //   style: TextStyle(fontSize: 18),
                // ),
                // 在这里添加显示 Scene 内容的其他部分
              ],
            ),
          ),
        ],
      ),
    );
  }
}
