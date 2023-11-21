// pages/character/character_page.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/scene.dart';
import 'package:iai/widgets/image_shower.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({Key? key}) : super(key: key);

  @override
  _CharacterPageState createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Scene>> _scenesFuture;

  // 异步获取数据
  Future<List<Scene>> _getScenesFuture() async {
    return await _dbHelper.getScenes();
  }

  // 第一次获取数据
  @override
  void initState() {
    super.initState();
    _scenesFuture = _getScenesFuture();
  }

  // 重新获取数据，定义给子组件使用的回调函数
  void updateStateCallback() {
    // Future数据的状态从 completed 到 waiting，不需要手动设置为 null，FutureBuilder 会自动重新触发页面重新绘制
    setState(() {
      _scenesFuture = _getScenesFuture();
    });
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
          if (snapshot.hasData) {
            // 数据准备完成，构建页面
            List<Scene> scenes = snapshot.data![0];
            return CharacterPageContent(scenes: scenes, updateStateCallback: updateStateCallback);
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 如果正在加载数据，显示加载指示器
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class CharacterPageContent extends StatefulWidget {
  final List<Scene> scenes;
  final VoidCallback updateStateCallback;

  const CharacterPageContent({Key? key, required this.scenes, required this.updateStateCallback}) : super(key: key);

  @override
  _CharacterPageContentState createState() => _CharacterPageContentState();
}

class _CharacterPageContentState extends State<CharacterPageContent> {
  final CarouselController _carouselController = CarouselController();
  Scene? _selectedScene;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          // 排除手机顶部状态栏
          padding: EdgeInsets.only(top: statusBarHeight),
          height: screenHeight * 0.25,
          child: buildTopLayout(context),
        ),
        Container(
          height: screenHeight * 0.6,
          child: buildCenterLayout(),
        ),
        Container(
          // 排除手机底部导航栏
          padding: EdgeInsets.only(bottom: bottomNavBarHeight),
          height: screenHeight * 0.15,
          child: buildBottomLayout(context),
        ),
      ],
    );
  }

  Widget buildTopLayout(BuildContext context) {
    return Stack(
      children: [
        Container(
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
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // 跳转到管理页面，返回该页面是判断是否返回true，如返回则代表数据发生了变化，需要callback
              Navigator.of(context).pushNamed("/management").then((result) {
                if (result != null && result is bool && result) {
                  widget.updateStateCallback();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildCenterLayout() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double totalHeight = constraints.maxHeight;

        return CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: totalHeight * 0.9,
                aspectRatio: 16 / 9,
                viewportFraction: 0.70,
                enlargeCenterPage: true,
                pageSnapping: true,
                enableInfiniteScroll: widget.scenes.length >= 3, // 根据卡片数量决定是否启用无限滚动
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
                    child: Card(
                      elevation: _selectedScene == scene ? 12 : 3,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 8,
                            child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: MyImageShower(
                                  image: scene.backgroundImage,
                                  defaultImage: 'assets/images/scene.png',
                                ),
                            ),
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
                      ),
                    ),
                  );
                },
              );
            }).toList());
      },
    );
  }

  Widget buildBottomLayout(BuildContext context) {
    return Visibility(
      visible: _selectedScene != null,
      child: Center(
        child: Container(
          width: 180.0,
          height: 60.0,
          child: FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pushNamed('/chat', arguments: {
                'user1Id': _selectedScene!.user1Id,
                'user2Id': _selectedScene!.user2Id,
              });
            },
            child: Text(
              'Start',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
        )
      ),
    );
  }
}
