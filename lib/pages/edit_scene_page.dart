// pages/edit_scene_page.dart

import 'package:flutter/material.dart';

import 'package:conversation_notebook/models/scene.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/helpers/database_helper.dart';

class EditScenePage extends StatefulWidget {
  final int sceneId;

  const EditScenePage({Key? key, required this.sceneId}) : super(key: key);

  @override
  _EditScenePageState createState() => _EditScenePageState();
}

class _EditScenePageState extends State<EditScenePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<User>> _usersFuture;
  late Future<Scene> _sceneFuture;

  // 异步获取数据
  Future<List<User>> _getUsersFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getUsers();
  }

  Future<Scene> _getSceneFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getSceneById(widget.sceneId);
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = _getUsersFuture();
    _sceneFuture = _getSceneFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('Edit Scene'),
      ),
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_usersFuture, _sceneFuture]),
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
            // 如果没有错误，显示数据列表
            // 从snapshot中取出数据
            List<User> users = snapshot.data![0];
            Scene scene = snapshot.data![1];
            return EditScenePageContent(users: users, scene: scene);
          }
        },
      ),
    );
  }
}

class EditScenePageContent extends StatefulWidget {
  final List<User> users;
  final Scene scene;

  const EditScenePageContent({Key? key, required this.users, required this.scene}) : super(key: key);

  @override
  _EditScenePageContentState createState() => _EditScenePageContentState();
}

class _EditScenePageContentState extends State<EditScenePageContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              initialValue: widget.scene.sceneName,
              decoration: InputDecoration(labelText: 'Scene Name'),
              onChanged: (value) {
                setState(() {
                  widget.scene.sceneName = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: widget.scene.backgroundPath,
              decoration: InputDecoration(labelText: 'Background Path'),
              onChanged: (value) {
                setState(() {
                  widget.scene.backgroundPath = value;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButton<int>(
              value: widget.scene.user1Id,
              items: widget.users.map((user) {
                return DropdownMenuItem<int>(
                  value: user.id,
                  child: Text(user.username),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.scene.user1Id = value ?? widget.scene.user1Id;
                });
              },
              hint: Text('Select User 1'),
            ),
            SizedBox(height: 16),
            DropdownButton<int>(
              value: widget.scene.user2Id,
              items: widget.users.map((user) {
                return DropdownMenuItem<int>(
                  value: user.id,
                  child: Text(user.username),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.scene.user2Id = value ?? widget.scene.user2Id;
                });
              },
              hint: Text('Select User 2'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: (widget.scene.sceneName != '')
                  ? () async {
                      await _dbHelper.updateScene(widget.scene);
                      // 返回管理页面，数据发生变化
                      Navigator.pop(context, true);
                    }
                  : null, // 设置为null禁用按钮
              style: ElevatedButton.styleFrom(
                backgroundColor: (widget.scene.sceneName != '')
                    ? Colors.blue // 按钮颜色
                    : Colors.grey, // 禁用时的颜色
              ),
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
