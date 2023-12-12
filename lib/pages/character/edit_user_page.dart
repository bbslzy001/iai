// pages/character/edit_user_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/models/user.dart';
import 'package:iai/widgets/image_picker.dart';

class EditUserPage extends StatefulWidget {
  final User user;

  const EditUserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _dbHelper = DatabaseHelper();

  File? _avatarImage;
  File? _backgroundImage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      resizeToAvoidBottomInset: false, // 设置为false，禁止调整界面以避免底部被软键盘顶起
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.user.username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.user.username = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.user.description = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MyImagePicker(
                      labelText: 'Avatar',
                      getImage: () async {
                        _avatarImage = await FileHelper.getFile(widget.user.avatarImage);
                        return _avatarImage;
                      },
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
                      getImage: () async {
                        _backgroundImage = await FileHelper.getFile(widget.user.backgroundImage);
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
                onPressed: (widget.user.username != '')
                    ? () async {
                        setState(() {
                          _isSaving = true;
                        });

                        if (_avatarImage?.existsSync() == true) {
                          widget.user.avatarImage = await FileHelper.saveFile(_avatarImage!);
                        }
                        if (_backgroundImage?.existsSync() == true) {
                          widget.user.backgroundImage = await FileHelper.saveFile(_backgroundImage!);
                        }

                        await _dbHelper.updateUser(widget.user);

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
      ),
    );
  }
}
