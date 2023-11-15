// screens/management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:conversation_notebook/helpers/database_helper.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/models/scene.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Scene>> _scenesFuture;
  late Future<List<User>> _usersFuture;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isCurrent) {
      // 当前页面处于栈的顶部，执行异步数据获取操作
      _scenesFuture = _getScenesFuture();
      _usersFuture = _getUsersFuture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ,
    );
  }

  List<Scene> _scenes = [];
  List<User> _users = [];

  @override
  void initState() async {
    super.initState();
    _scenes = await _dbHelper.getScenes();
    _users = await _dbHelper.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu item selection
              if (value == 'addScene') {
                // Handle add scene
              } else if (value == 'addUser') {
                // Handle add user
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
          // Scenes tab content
          buildTabContent('Scenes'),
          // Users tab content
          buildTabContent('Users'),
        ],
      ),
    );
  }

  Widget buildTabContent(String tabName) {
    return ListView.builder(
      itemCount: tabName == 'Scenes' ? _scenes.length : _users.length, // Replace with your actual item count
      itemBuilder: (context, index) {
        return buildSlidable(
          child: ListTile(
            title: Text(tabName == 'Scenes' ? _scenes[index].sceneName : _users[index].username),
            // Add your other ListTile properties here
          ),
        );
      },
    );
  }

  Widget buildSlidable({required Widget child}) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            flex: 2,
            onPressed: doNothing,
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: doNothing,
            backgroundColor: Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      child: child,
    );
  }

  void doNothing(BuildContext context) {
    // Add your action implementation here
  }
}
