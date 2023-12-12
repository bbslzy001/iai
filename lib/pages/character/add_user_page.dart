// pages/character/add_user_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/models/user.dart';
import 'package:iai/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      resizeToAvoidBottomInset: false, // 设置为false，禁止调整界面以避免底部被软键盘顶起
      body: const AddUserPageContent(),
    );
  }
}

class AddUserPageContent extends StatefulWidget {
  const AddUserPageContent({Key? key}) : super(key: key);

  @override
  State<AddUserPageContent> createState() => _AddUserPageContentState();
}

class _AddUserPageContentState extends State<AddUserPageContent> {
  final _dbHelper = DatabaseHelper();

  final _user = User(username: '', description: '', avatarImage: '', backgroundImage: '');
  File? _avatarImage;
  File? _backgroundImage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: _user.username,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _user.username = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _user.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _user.description = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MyImagePicker(
                  labelText: 'Avatar',
                  onTap: () async {
                    XFile? pickedFile = await FileHelper.pickImageFromGallery();
                    if (pickedFile != null) {
                      _avatarImage = File(pickedFile.path);
                      return _avatarImage;
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              const SizedBox(width: 8), // 可以根据需要调整间距
              Expanded(
                child: MyImagePicker(
                  labelText: 'Background',
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
            onPressed: (_user.username != '')
                ? () async {
                    final navigator = Navigator.of(context);

                    setState(() {
                      _isSaving = true;
                    });

                    if (_avatarImage?.existsSync() == true) {
                      _user.avatarImage = await FileHelper.saveFile(_avatarImage!);
                    }
                    if (_backgroundImage?.existsSync() == true) {
                      _user.backgroundImage = await FileHelper.saveFile(_backgroundImage!);
                    }

                    await _dbHelper.insertUser(_user);

                    // 检查小部件是否仍然挂载
                    if (mounted) {
                      navigator.pop(true); // 返回管理页面，数据发生变化
                    }
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
    );
  }
}
