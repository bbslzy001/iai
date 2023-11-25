// pages/character/edit_scene_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/widgets/image_picker.dart';
import 'package:iai/utils/build_future_builder.dart';

class EditScenePage extends StatefulWidget {
  final Scene scene;

  const EditScenePage({Key? key, required this.scene}) : super(key: key);

  @override
  _EditScenePageState createState() => _EditScenePageState();
}

class _EditScenePageState extends State<EditScenePage> {
  final _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Scene'),
      ),
      resizeToAvoidBottomInset: false, // 设置为false，禁止调整界面以避免底部被软键盘顶起
      body: buildFutureBuilder([
        _dbHelper.getUsers(),
      ], (dataList) {
        final users = dataList[0];
        return EditScenePageContent(users: users, scene: widget.scene);
      }),
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
  final _dbHelper = DatabaseHelper();

  File? _backgroundImage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.scene.sceneName,
              decoration: const InputDecoration(
                labelText: 'Scene Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  widget.scene.sceneName = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Select User 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              value: widget.scene.user1Id,
              items: widget.users.map<DropdownMenuItem<int>>((User user) {
                return DropdownMenuItem<int>(
                  value: user.id,
                  child: Text(user.username),
                );
              }).toList(),
              // scene中的message取决于user1和user2，禁止修改
              onChanged: null,
              icon: const Icon(Icons.arrow_drop_down),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Select User 2',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              value: widget.scene.user2Id,
              items: widget.users.map<DropdownMenuItem<int>>((User user) {
                return DropdownMenuItem<int>(
                  value: user.id,
                  child: Text(user.username),
                );
              }).toList(),
              // scene中的message取决于user1和user2，禁止修改
              onChanged: null,
              icon: const Icon(Icons.arrow_drop_down),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyImagePicker(
                    labelText: 'Background',
                    getImage: () async {
                      _backgroundImage = await FileHelper.getMedia(widget.scene.backgroundImage);
                      return _backgroundImage;
                    },
                    onTap: () async {
                      XFile? pickedFile = await FileHelper.pickImageFromGallery();
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
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: (widget.scene.sceneName != '')
                  ? () async {
                      setState(() {
                        _isSaving = true;
                      });

                      if (_backgroundImage?.existsSync() == true) {
                        widget.scene.backgroundImage = await FileHelper.saveMedia(_backgroundImage!);
                      }

                      await _dbHelper.updateScene(widget.scene);

                      Navigator.pop(context, true); // 返回管理页面，数据发生变化
                    }
                  : null, // 设置为null禁用按钮
              child: Container(
                width: 96,
                height: 48,
                alignment: Alignment.center,
                child: _isSaving
                    ? const SizedBox(
                        width: 24.0, // 设置宽度
                        height: 24.0, // 设置高度
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0, // 设置线条粗细
                        ),
                      )
                    : const Text('Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
