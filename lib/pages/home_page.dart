// pages/home_page.dart

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    double bottomNavBarHeight = MediaQuery
        .of(context)
        .padding
        .bottom;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height; // screenHeight中不包括状态栏和底部导航栏的高度

    return Scaffold(
      body: Column(
        children: [
          Container(
            // 排除手机顶部状态栏
            padding: EdgeInsets.only(top: statusBarHeight),
            height: screenHeight * 0.25,
            child: buildTitleLayout(context),
          ),
          Container(
            // 排除手机底部导航栏
            padding: EdgeInsets.only(bottom: bottomNavBarHeight),
            height: screenHeight * 0.75,
            child: buildContentLayout(context),
          ),
        ],
      ),
    );
  }

  Widget buildTitleLayout(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Center(
            child: Text(
              'IAI',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigator.of(context).pushNamed("/setting").then((result) {
              //   if (result != null && result is bool && result) {
              //   }
              // });
            },
          ),
        ),
      ],
    );
  }

  Widget buildContentLayout(BuildContext context) {
    final List<Section> sections = [
      Section(name: 'character', backgroundPath: ''),
      Section(name: 'notebook', backgroundPath: ''),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,  // 去除 GridView 内边距
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5 / 6, // 设置宽高比
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: sections.length,
        itemBuilder: (BuildContext context, int index) {
          // 根据索引构建每个网格项的 widget
          return Column(
            mainAxisAlignment: MainAxisAlignment.center, // 居中对齐
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/${sections[index].name}");
                },
                child: Card(
                  elevation: 6,
                  child: Image.asset(
                    'assets/images/${sections[index].name}.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Text(
                sections[index].name,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Pacifico',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Section {
  String name;
  String backgroundPath;

  Section({
    required this.name,
    required this.backgroundPath,
  });
}
