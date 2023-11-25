import 'package:flutter/material.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/note.dart';

class AddNotePage extends StatefulWidget {
  final int identityId;

  const AddNotePage({Key? key, required this.identityId}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      resizeToAvoidBottomInset: false, // 设置为false，禁止调整界面以避免底部被软键盘顶起
      body: AddNotePageContent(identityId: widget.identityId),
    );
  }
}

class AddNotePageContent extends StatefulWidget {
  final int identityId;

  const AddNotePageContent({Key? key, required this.identityId}) : super(key: key);

  @override
  _AddNotePageContentState createState() => _AddNotePageContentState();
}

class _AddNotePageContentState extends State<AddNotePageContent> {
  final _dbHelper = DatabaseHelper();

  final _note = Note(identityId: 0, noteTitle: '', noteContent: '', noteStatus: -1);
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    _note.identityId = widget.identityId;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: _note.noteTitle,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _note.noteTitle = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: _note.noteContent,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _note.noteContent = value;
              });
            },
          ),
          const SizedBox(height: 16.0),
          FilledButton.tonal(
            onPressed: (_note.noteTitle != '')
                ? () async {
                    setState(() {
                      _isSaving = true;
                    });

                    await _dbHelper.insertNote(_note);

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
    );
  }
}
