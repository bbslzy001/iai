import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/models/identity.dart';
import 'package:iai/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';

class EditIdentityPage extends StatefulWidget {
  final Identity identity;

  const EditIdentityPage({Key? key, required this.identity}) : super(key: key);

  @override
  State<EditIdentityPage> createState() => _EditIdentityPageState();
}

class _EditIdentityPageState extends State<EditIdentityPage> {
  final _dbHelper = DatabaseHelper();

  File? _backgroundImage;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Identity'),
      ),
      resizeToAvoidBottomInset: false, // 设置为false，禁止调整界面以避免底部被软键盘顶起
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.identity.identityName,
                decoration: const InputDecoration(
                  labelText: 'IdentityName',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.identity.identityName = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MyImagePicker(
                      labelText: 'Background',
                      getImage: () async {
                        _backgroundImage = await FileHelper.getFile(widget.identity.backgroundImage);
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
                onPressed: (widget.identity.identityName != '')
                    ? () async {
                        final navigator = Navigator.of(context);

                        setState(() {
                          _isSaving = true;
                        });

                        if (_backgroundImage?.existsSync() == true) {
                          widget.identity.backgroundImage = await FileHelper.saveFile(_backgroundImage!);
                        }

                        await _dbHelper.updateIdentity(widget.identity);

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
        ),
      ),
    );
  }
}
