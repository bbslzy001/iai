import 'package:flutter/material.dart';

import 'chat_screen.dart';

class UserCard {
  final String name;
  final String description;

  UserCard(this.name, this.description);
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController(viewportFraction: 0.8);
  List<UserCard> userCards = [
    UserCard('User1', 'Description for User1'),
    UserCard('User2', 'Description for User2'),
    // Add more user cards as needed
  ];

  String currentUser = 'User1';

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height - statusBarHeight;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              // 排除手机顶部状态栏
              padding: EdgeInsets.only(top: statusBarHeight),
              height: screenHeight * 0.2,
              color: Colors.blue,
              child: buildTopLayout(),
            ),
            Container(
              height: screenHeight * 0.7,
              color: Colors.green,
              child: buildCenterLayout(),
            ),
            Container(
              height: screenHeight * 0.1,
              color: Colors.red,
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
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Notebook',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: FloatingActionButton(
                onPressed: () {
                  // 点击按钮的操作
                },
                backgroundColor: Colors.red, // 调整按钮颜色
                child: Text(
                  'B',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 轮播图布局（85%）
            SizedBox(
              height: totalHeight * 0.8, // Set a fixed height or adjust as needed
              child: PageView.builder(
                controller: _pageController,
                itemCount: userCards.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      // 卡片布局（对面角色，70%）
                      return Center(
                        child: SizedBox(
                          width: totalWidth * 0.75,
                          height: Curves.easeInOut.transform(value) * totalHeight * 0.7,
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ClipRRect(
                          // 使用ClipRRect进行裁剪
                          borderRadius: BorderRadius.circular(15.0),
                          child: buildCardLayout(index),
                        ),
                      ),
                  );
                },
              ),
            ),
            // 文字布局（当前角色）
            GestureDetector(
              onTap: () {
                _showUserSelectionDrawer(context);
              },
              child: Text(
                'Current User: $currentUser',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildBottomLayout() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _startChatScreen();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        ),
        child: Text(
          'Start',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget buildCardLayout(int index) {
    final card = userCards[index];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double totalWidth = constraints.maxWidth;
        double totalHeight = constraints.maxHeight;

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: totalHeight * 0.4,
              child: Image.asset(
                'assets/test.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: totalHeight * 0.4,
              left: 0,
              right: 0,
              height: totalHeight * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一个文本框（名字，靠右对齐）
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      child: Text(
                        card.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  // 第二个文本框（描述，正常文字对齐）
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      card.description,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: totalHeight * 0.4 - 50,
              left: 0,
              right: totalWidth * 0.5,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 50,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserSelectionDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200, // Set the desired height of the drawer
          child: Column(
            children: [
              ListTile(
                title: Text('User1'),
                onTap: () {
                  _updateCurrentUser('User1');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('User2'),
                onTap: () {
                  _updateCurrentUser('User2');
                  Navigator.pop(context);
                },
                // Add more user options as needed
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateCurrentUser(String newUser) {
    setState(() {
      currentUser = newUser;
    });
  }

  void _startChatScreen() {
    int currentPage = _pageController.page?.round() ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: currentUser,
          oppositeUser: userCards[currentPage].name,
        ),
      ),
    );
  }
}
