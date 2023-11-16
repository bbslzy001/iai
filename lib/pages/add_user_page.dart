// pages/add_user_page.dart

import 'package:flutter/material.dart';

import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/helpers/database_helper.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Add User'),
      ),
      body: AddUserPageContent(),
    );
  }
}

class AddUserPageContent extends StatefulWidget {
  const AddUserPageContent({Key? key}) : super(key: key);

  @override
  _AddUserPageContentState createState() => _AddUserPageContentState();
}

class _AddUserPageContentState extends State<AddUserPageContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final User _user = User(username: '', description: '', avatarPath: '', backgroundPath: '');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: _user.username,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _user.username = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: _user.description,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _user.description = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: _user.avatarPath,
            decoration: InputDecoration(
              labelText: 'Avatar Path',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _user.avatarPath = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: _user.backgroundPath,
            decoration: InputDecoration(
              labelText: 'Background Path',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _user.backgroundPath = value;
              });
            },
          ),
          SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: (_user.username != '')
                ? () async {
                    await _dbHelper.insertUser(_user);
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
