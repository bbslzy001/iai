// pages/character/add_user_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/utils/saving_dialog.dart';
import 'package:iai/models/user.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/widgets/image_picker.dart';

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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FileHelper _fileHelper = FileHelper();
  final User _user = User(username: '', description: '', avatarImage: '', backgroundImage: '');
  late File _avatarImage;
  late File _backgroundImage;

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
          Row(
            children: [
              Expanded(
                child: ImagePickerWidget(
                  labelText: 'Avatar',
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
            onPressed: (_user.username != '')
                ? () async {
                    SavingDialog.show(context);

                    if (_avatarImage.existsSync()) {
                      _user.avatarImage = await _fileHelper.saveMedia(_avatarImage);
                    }
                    if (_backgroundImage.existsSync()) {
                      _user.backgroundImage = await _fileHelper.saveMedia(_backgroundImage);
                    }

                    await _dbHelper.insertUser(_user);

                    SavingDialog.hide(context);

                    Navigator.pop(context, true);  // 返回管理页面，数据发生变化
                  }
                : null, // 设置为null禁用按钮
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }
}
