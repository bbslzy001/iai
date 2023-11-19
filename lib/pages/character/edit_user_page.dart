// pages/character/edit_user_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/utils/saving_dialog.dart';
import 'package:iai/models/user.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/widgets/image_picker.dart';

class EditUserPage extends StatefulWidget {
  final int userId;

  const EditUserPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([
          _dbHelper.getUserById(widget.userId),
        ]),
        // 构建页面的回调
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 检查异步操作的状态
          if (snapshot.hasData) {
            // 数据准备完成，构建页面
            User user = snapshot.data![0];
            return EditUserPageContent(user: user);
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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FileHelper _fileHelper = FileHelper();
  late File _avatarImage;
  late File _backgroundImage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.user.username,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  widget.user.username = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: widget.user.description,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  widget.user.description = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ImagePickerWidget(
                    labelText: 'Avatar',
                    getImage: () async {
                      _avatarImage = await _fileHelper.getMedia(widget.user.avatarImage);
                      return _avatarImage;
                    },
                    onTap: () async {
                      XFile? pickedFile = await _fileHelper.pickMediaFromGallery();
                      if (pickedFile != null) {
                        _avatarImage = File(pickedFile.path);
                        return _avatarImage;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                SizedBox(width: 8), // 可以根据需要调整间距
                Expanded(
                  child: ImagePickerWidget(
                    labelText: 'Background',
                    getImage: () async {
                      _backgroundImage = await _fileHelper.getMedia(widget.user.backgroundImage);
                      return _backgroundImage;
                    },
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
            FilledButton.tonal(
              onPressed: (widget.user.username != '')
                  ? () async {
                      SavingDialog.show(context);

                      if (_avatarImage.existsSync()) {
                        widget.user.avatarImage = await _fileHelper.saveMedia(_avatarImage);
                      }
                      if (_backgroundImage.existsSync()) {
                        widget.user.backgroundImage = await _fileHelper.saveMedia(_backgroundImage);
                      }

                      await _dbHelper.updateUser(widget.user);

                      SavingDialog.hide(context);

                      Navigator.pop(context, true); // 返回管理页面，数据发生变化
                    }
                  : null, // 设置为null禁用按钮
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
