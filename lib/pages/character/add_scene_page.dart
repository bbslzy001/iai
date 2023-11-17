// pages/character/add_scene_page.dart

import 'package:flutter/material.dart';

import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/helpers/database_helper.dart';

class AddScenePage extends StatefulWidget {
  const AddScenePage({Key? key}) : super(key: key);

  @override
  _AddScenePageState createState() => _AddScenePageState();
}

class _AddScenePageState extends State<AddScenePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<User>> _usersFuture;

  // 异步获取数据
  Future<List<User>> _getUsersFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getUsers();
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = _getUsersFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text('Add Scene'),
        ),
        body: FutureBuilder(
          // 传入Future列表
          future: Future.wait([_usersFuture]),
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
              return AddScenePageContent(users: users);
            }
          },
        ));
  }
}

class AddScenePageContent extends StatefulWidget {
  final List<User> users;

  const AddScenePageContent({Key? key, required this.users}) : super(key: key);

  @override
  _AddScenePageContentState createState() => _AddScenePageContentState();
}

class _AddScenePageContentState extends State<AddScenePageContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Scene _scene = Scene(sceneName: '', backgroundPath: '', user1Id: -1, user2Id: -1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: _scene.sceneName,
            decoration: InputDecoration(
              labelText: 'Scene Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _scene.sceneName = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: _scene.backgroundPath,
            decoration: InputDecoration(
              labelText: 'Background Path',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _scene.backgroundPath = value;
              });
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Select User 1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            value: _scene.user1Id == -1 ? null : _scene.user1Id,
            items: widget.users.map<DropdownMenuItem<int>>((User user) {
              return DropdownMenuItem<int>(
                value: user.id,
                child: Text(user.username),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                _scene.user1Id = newValue ?? _scene.user1Id;
              });
            },
            icon: const Icon(Icons.arrow_drop_down),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Select User 2',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            value: _scene.user2Id == -1 ? null : _scene.user2Id,
            items: widget.users.map<DropdownMenuItem<int>>((User user) {
              return DropdownMenuItem<int>(
                value: user.id,
                child: Text(user.username),
              );
            }).toList(),
            onChanged: (int? newValue) {
              setState(() {
                _scene.user2Id = newValue ?? _scene.user2Id;
              });
            },
            icon: const Icon(Icons.arrow_drop_down),
          ),
          SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: (_scene.sceneName != '' && _scene.user1Id != -1 && _scene.user2Id != -1)
                ? () async {
                    await _dbHelper.insertScene(_scene);
                    // 返回管理页面，数据发生变化
                    Navigator.pop(context, true);
                  }
                : null, // 设置为null禁用按钮
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }
}
