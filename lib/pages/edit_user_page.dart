// pages/edit_user_page.dart

import 'package:flutter/material.dart';

import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/helpers/database_helper.dart';

class EditUserPage extends StatefulWidget {
  final int userId;

  const EditUserPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<User> _userFuture;

  // 异步获取数据
  Future<User> _getUserFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getUserById(widget.userId);
  }

  @override
  void initState() async {
    super.initState();
    _userFuture = _getUserFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('Edit User'),
      ),
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_userFuture]),
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
            User user = snapshot.data![0];
            return EditUserPageContent(user: user);
          }
        },
      ),
    );
  }
}

class EditUserPageContent extends StatefulWidget {
  final User user;

  const EditUserPageContent({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserPageContentState createState() => _EditUserPageContentState();
}

class _EditUserPageContentState extends State<EditUserPageContent> {
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
              initialValue: widget.user.username,
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (value) {
                setState(() {
                  widget.user.username = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: widget.user.description,
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                setState(() {
                  widget.user.description = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: widget.user.avatarPath,
              decoration: InputDecoration(labelText: 'Avatar Path'),
              onChanged: (value) {
                setState(() {
                  widget.user.avatarPath = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: widget.user.backgroundPath,
              decoration: InputDecoration(labelText: 'Background Path'),
              onChanged: (value) {
                setState(() {
                  widget.user.backgroundPath = value;
                });
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: (widget.user.username != '')
                  ? () async {
                      await _dbHelper.insertUser(widget.user);
                      // 返回管理页面，数据发生变化
                      Navigator.pop(context, true);
                    }
                  : null, // 设置为null禁用按钮
              style: ElevatedButton.styleFrom(
                backgroundColor: (widget.user.username != '')
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
