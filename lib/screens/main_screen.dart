import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:conversation_notebook/helpers/database_helper.dart';
import 'package:conversation_notebook/models/scene.dart';
import 'package:conversation_notebook/screens/chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Scene>> _scenesFuture;

  Future<List<Scene>> _getScenesFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));

    return await _dbHelper.getScenes();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _scenesFuture = _getScenes();
  // }

  // 在didChangeDependencies中检查当前页面是否处于栈的顶部
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isCurrent) {
      // 当前页面处于栈的顶部，执行异步数据获取操作
      _scenesFuture = _getScenesFuture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_scenesFuture]),
        // 构建页面的回调
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 检查异步操作的状态
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果正在加载数据，可以显示加载指示器
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // 如果发生错误，可以显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 数据准备好后，构建页面
            List<Scene> scenes = snapshot.data![0];
            return MainScreenContent(scenes: scenes);
          }
        },
      ),
    );
  }
}

class MainScreenContent extends StatefulWidget {
  final List<Scene> scenes;

  const MainScreenContent({Key? key, required this.scenes}) : super(key: key);

  @override
  _MainScreenContentState createState() => _MainScreenContentState();
}

class _MainScreenContentState extends State<MainScreenContent> {
  final CarouselController _carouselController = CarouselController();
  Scene? _selectedScene;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    double screenHeight = MediaQuery.of(context).size.height - statusBarHeight - bottomNavBarHeight;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              // 排除手机顶部状态栏
              padding: EdgeInsets.only(top: statusBarHeight),
              height: screenHeight * 0.2,
              child: buildTopLayout(),
            ),
            Container(
              height: screenHeight * 0.65,
              child: buildCenterLayout(),
            ),
            Container(
              // 排除手机底部导航栏
              padding: EdgeInsets.only(bottom: bottomNavBarHeight),
              height: screenHeight * 0.15,
              child: buildBottomLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopLayout() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double totalHeight = constraints.maxHeight;

        return Stack(
          children: [
            Container(
              height: totalHeight,
              child: Center(
                child: Text(
                  'Character',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                width: 48, // 调整宽度以适应按钮
                height: 48, // 调整高度以适应按钮
                child: IconButton(
                  onPressed: () {
                    // 点击按钮的操作
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black, // 调整按钮颜色
                    size: 32,
                  ),
                  alignment: Alignment.center, // 设置图标居中
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCenterLayout() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double totalWidth = constraints.maxWidth;
        double totalHeight = constraints.maxHeight;

        return CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: totalHeight * 0.85,
                aspectRatio: 16 / 9,
                viewportFraction: 0.70,
                enlargeCenterPage: true,
                pageSnapping: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    // 切换到当前卡片，但并未选择
                  });
                }),
            items: widget.scenes.map((scene) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedScene == scene) {
                          _selectedScene = null;
                        } else {
                          _selectedScene = scene;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: totalWidth,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedScene == scene ? Border.all(color: Colors.blue.shade500, width: 3) : null,
                          boxShadow: _selectedScene == scene
                              ? [BoxShadow(color: Colors.blue.shade100, blurRadius: 30, offset: Offset(0, 10))]
                              : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 5))]),
                      child: buildCardLayout(scene),
                    ),
                  );
                },
              );
            }).toList());
      },
    );
  }

  Widget buildBottomLayout() {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          _startChatScreen();
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(color: Colors.blue), // 调整边框颜色
        ),
        child: Text(
          'Start',
          style: TextStyle(
            fontSize: 24,
            color: Colors.blue, // 调整字体颜色
            fontFamily: 'Pacifico',
          ),
        ),
      ),
    );
  }

  Widget buildCardLayout(Scene scene) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                scene.backgroundPath ?? '',
                fit: BoxFit.fill,
              )),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              scene.sceneName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          user1Id: _selectedScene!.user1Id,
          user2Id: _selectedScene!.user2Id,
        ),
      ),
    );
  }
}
