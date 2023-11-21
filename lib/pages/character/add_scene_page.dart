// pages/character/add_scene_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/widgets/image_picker.dart';

class AddScenePage extends StatefulWidget {
  const AddScenePage({Key? key}) : super(key: key);

  @override
  _AddScenePageState createState() => _AddScenePageState();
}

class _AddScenePageState extends State<AddScenePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Scene'),
        ),
        body: FutureBuilder(
          // 传入Future列表
          future: Future.wait([
            _dbHelper.getUsers(),
          ]),
          // 构建页面的回调
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            // 检查异步操作的状态
            if (snapshot.hasData) {
              // 数据准备完成，构建页面
              List<User> users = snapshot.data![0];
              return AddScenePageContent(users: users);
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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FileHelper _fileHelper = FileHelper();
  final Scene _scene = Scene(sceneName: '', backgroundImage: '', user1Id: -1, user2Id: -1);
  File? _backgroundImage;

  bool _isSaving = false;

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
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MyImagePicker(
                  labelText: 'Background',
                  onTap: () async {
                    XFile? pickedFile = await _fileHelper.pickMediaFromGallery();
                    if (pickedFile != null) {
                      _backgroundImage = File(pickedFile.path);
                      return _backgroundImage;
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          // TODO：圆形指示器卡顿问题
          FilledButton.tonal(
            onPressed: (_scene.sceneName != '' && _scene.user1Id != -1 && _scene.user2Id != -1)
                ? () async {
                    setState(() {
                      _isSaving = true;
                    });

                    if (_backgroundImage?.existsSync() == true) {
                      _scene.backgroundImage = await _fileHelper.saveMedia(_backgroundImage!);
                    }

                    await _dbHelper.insertScene(_scene);

                    Navigator.pop(context, true);  // 返回管理页面，数据发生变化
                  }
                : null, // 设置为null禁用按钮
            child: Container(
              width: 96,
              height: 48,
              alignment: Alignment.center,
              child: _isSaving
                  ? SizedBox(
                width: 24.0, // 设置宽度
                height: 24.0, // 设置高度
                child: CircularProgressIndicator(
                  strokeWidth: 2.0, // 设置线条粗细
                ),
              )
                  : Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }
}
