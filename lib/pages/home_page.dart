// pages/home_page.dart

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height; // screenHeight中不包括状态栏和底部导航栏的高度

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
        const Center(
          child: Text(
            'IAI',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pacifico',
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed("/setting");
            },
          ),
        ),
      ],
    );
  }

  Widget buildContentLayout(BuildContext context) {
    final sections = [
      Section(name: 'character', path: '/character'),
      Section(name: 'notebook', path: '/identity'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        padding: EdgeInsets.zero, // 去除 GridView 内边距
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  Navigator.of(context).pushNamed(sections[index].path);
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
                style: const TextStyle(
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
  final String name;
  final String path;

  Section({
    required this.name,
    required this.path,
  });
}
