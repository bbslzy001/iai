import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/models/identity.dart';
import 'package:iai/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';

class AddIdentityPage extends StatefulWidget {
  const AddIdentityPage({Key? key}) : super(key: key);

  @override
  State<AddIdentityPage> createState() => _AddIdentityPageState();
}

class _AddIdentityPageState extends State<AddIdentityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Identity'),
      ),
      resizeToAvoidBottomInset: false, // 设置为false，禁止调整界面以避免底部被软键盘顶起
      body: const AddIdentityPageContent(),
    );
  }
}

class AddIdentityPageContent extends StatefulWidget {
  const AddIdentityPageContent({Key? key}) : super(key: key);

  @override
  State<AddIdentityPageContent> createState() => _AddIdentityPageContentState();
}

class _AddIdentityPageContentState extends State<AddIdentityPageContent> {
  final _dbHelper = DatabaseHelper();

  final _identity = Identity(identityName: '', backgroundImage: '');
  File? _backgroundImage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: _identity.identityName,
            decoration: const InputDecoration(
              labelText: 'IdentityName',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _identity.identityName = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
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
          const SizedBox(height: 16.0),
          FilledButton.tonal(
            onPressed: (_identity.identityName != '')
                ? () async {
                    final navigator = Navigator.of(context);

                    setState(() {
                      _isSaving = true;
                    });

                    if (_backgroundImage?.existsSync() == true) {
                      _identity.backgroundImage = await FileHelper.saveFile(_backgroundImage!);
                    }

                    await _dbHelper.insertIdentity(_identity);

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
