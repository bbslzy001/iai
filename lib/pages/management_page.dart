// screens/management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:conversation_notebook/helpers/database_helper.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/models/scene.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  _ManagementPageState createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  // 通过持有GlobalKey来获取相应的_TabContentState对象，然后调用其方法来刷新数据
  final GlobalKey<_TabWidgetState> _scenesTabWidgetKey = GlobalKey<_TabWidgetState>();
  final GlobalKey<_TabWidgetState> _usersTabWidgetKey = GlobalKey<_TabWidgetState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          title: Text('Management'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'addScene') {
                  Navigator.of(context).pushNamed('/addScene').then((result) {
                    if (result != null && result is bool && result) {
                      // 通过持有GlobalKey来获取相应的_TabContentState对象，然后调用其方法来刷新数据
                      _scenesTabWidgetKey.currentState?.updateStateCallback();
                    }
                  });
                } else if (value == 'addUser') {
                  Navigator.of(context).pushNamed('/addUser').then((result) {
                    if (result != null && result is bool && result) {
                      // 通过持有GlobalKey来获取相应的_TabContentState对象，然后调用其方法来刷新数据
                      _usersTabWidgetKey.currentState?.updateStateCallback();
                    }
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'addScene',
                  child: Text('Add Scene'),
                ),
                const PopupMenuItem<String>(
                  value: 'addUser',
                  child: Text('Add User'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Scenes'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TabWidget(tabName: 'Scenes', key: _scenesTabWidgetKey),
            TabWidget(tabName: 'Users', key: _usersTabWidgetKey),
          ],
        ),
      ),
    );
  }
}

class TabWidget extends StatefulWidget {
  final String tabName;

  const TabWidget({Key? key, required this.tabName}) : super(key: key);

  @override
  _TabWidgetState createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<dynamic>> _dataFuture;

  Future<List<Scene>> _getScenesFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getScenes();
  }

  Future<List<User>> _getUsersFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getUsers();
  }

  // 第一次获取数据
  @override
  void initState() {
    super.initState();
    // 当前页面处于栈的顶部，执行异步数据获取操作
    if (widget.tabName == 'Scenes') {
      _dataFuture = _getScenesFuture();
    } else if (widget.tabName == 'Users') {
      _dataFuture = _getUsersFuture();
    }
  }

  // 重新获取数据，定义给子组件使用的回调函数
  void updateStateCallback() {
    // Future数据的状态从 completed 到 waiting，不需要手动设置为 null，FutureBuilder 会自动重新触发页面重新绘制
    setState(() {
      if (widget.tabName == 'Scenes') {
        _dataFuture = _getScenesFuture();
      } else if (widget.tabName == 'Users') {
        _dataFuture = _getUsersFuture();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 使用AutomaticKeepAliveClientMixin需要调用super.build(context)

    return Scaffold(
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_dataFuture]),
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
            List<dynamic> data = snapshot.data![0];
            return TabWidgetContent(data);
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // 保持状态
}

class TabWidgetContent extends StatelessWidget {
  final List<dynamic> _data;

  const TabWidgetContent(this._data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (context, index) {
        return Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: doNothing,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
              SlidableAction(
                onPressed: doNothing,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),
          child: ListTile(
            title: Text(_data is List<Scene> ? _data[index].sceneName : _data[index].username),
          ),
        );
      },
    );
  }

  void doNothing(BuildContext context) {
    // Add your action implementation here
  }
}
