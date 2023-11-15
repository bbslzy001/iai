import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/user.dart';
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
  List<User> userList = [];
  String currentUser = 'User1';

  @override
  void initState() {
    super.initState();
    // Load user cards from the database when the screen initializes
    _loadUserCards();
  }

  Future<void> _loadUserCards() async {
    // Fetch user information from the database
    List<User> users = await DatabaseHelper().getUsers();

    setState(() {
      userList = users;
    });
  }

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
              child: buildTopLayout(),
            ),
            Container(
              height: screenHeight * 0.65,
              child: buildCenterLayout(),
            ),
            Container(
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
                  'Note Book',
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
                    Icons.add,
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 轮播图布局（85%）
            SizedBox(
              height: totalHeight * 0.85, // Set a fixed height or adjust as needed
              child: PageView.builder(
                controller: _pageController,
                itemCount: userList.length,
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
                          height: Curves.easeInOut.transform(value) * totalHeight * 0.75,
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

  Widget buildCardLayout(int index) {
    final user = userList[index];

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
                        user.username,
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
                      user.description ?? '', // Use an empty string if user.description is null
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
          padding: EdgeInsets.all(16.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4, // 设置最大高度为屏幕高度的80%
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (User user in userList)
                ListTile(
                  title: Text(user.username),
                  onTap: () {
                    _updateCurrentUser(user.username);
                    Navigator.pop(context); // 关闭底部弹窗
                  },
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
          oppositeUser: userList[currentPage].username,
        ),
      ),
    );
  }
}
