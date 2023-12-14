import 'package:flutter/material.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/note.dart';

class AddNotePage extends StatefulWidget {
  final int identityId;

  const AddNotePage({Key? key, required this.identityId}) : super(key: key);

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _dbHelper = DatabaseHelper();

  final _note = Note(identityId: 0, noteTitle: '', noteContent: '', noteStatus: -1);
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    _note.identityId = widget.identityId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: (_note.noteTitle != '' && _isSaving == false)
                ? () async {
                    final navigator = Navigator.of(context);

                    setState(() {
                      _isSaving = true;
                    });

                    await _dbHelper.insertNote(_note);

                    // 检查小部件是否仍然挂载
                    if (mounted) {
                      navigator.pop(true); // 返回管理页面，数据发生变化
                    }
                  }
                : null, // 设置为null禁用按钮,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: _note.noteTitle,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
                maxLength: 50,
                onChanged: (value) {
                  setState(() {
                    _note.noteTitle = value;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                initialValue: _note.noteContent,
                decoration: const InputDecoration(
                  hintText: 'Content',
                  border: InputBorder.none, // 不显示横线
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  setState(() {
                    _note.noteContent = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
