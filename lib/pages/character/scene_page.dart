import 'package:flutter/material.dart';

import 'package:iai/models/scene.dart';
import 'package:iai/widgets/image_shower.dart';

class ScenePage extends StatefulWidget {
  final Scene scene;

  const ScenePage({Key? key, required this.scene}) : super(key: key);

  @override
  _ScenePageState createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scene.sceneName),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Stack(
        children: [
          // 上半部分背景
          Container(
            height: screenHeight * 0.1,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                    child: MyImageShower(
                      image: widget.scene.backgroundImage,
                      defaultImage: 'assets/images/scene.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
