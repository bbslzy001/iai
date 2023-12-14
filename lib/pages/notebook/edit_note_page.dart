import 'package:flutter/material.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/note.dart';

class EditNotePage extends StatefulWidget {
  final Note note;

  const EditNotePage({Key? key, required this.note}) : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _dbHelper = DatabaseHelper();

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.noteTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              Navigator.of(context).pop();
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (widget.note.noteTitle != '' && _isSaving == false)
                ? () async {
                    final navigator = Navigator.of(context);

                    setState(() {
                      _isSaving = true;
                    });

                    await _dbHelper.updateNote(widget.note);

                    // 检查小部件是否仍然挂载
                    if (mounted) {
                      navigator.pop(true); // 返回管理页面，数据发生变化
                    }
                  }
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.note.noteTitle,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
                maxLength: 50,
                onChanged: (value) {
                  setState(() {
                    widget.note.noteTitle = value;
                  });
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                initialValue: widget.note.noteContent,
                decoration: const InputDecoration(
                  hintText: 'Content',
                  border: InputBorder.none, // 不显示横线
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {
                  setState(() {
                    widget.note.noteContent = value;
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
