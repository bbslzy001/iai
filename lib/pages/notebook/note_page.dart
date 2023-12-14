import 'package:flutter/material.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/note.dart';
import 'package:iai/models/notefeedback.dart';
import 'package:iai/utils/build_future_builder.dart';

class NotePage extends StatefulWidget {
  final Note note;

  const NotePage({Key? key, required this.note}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _dbHelper = DatabaseHelper();

  List<NoteFeedback>? _noteFeedbacks;

  bool _isSaving = false;
  bool _isUpdated = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_isUpdated);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                Navigator.of(context).pop(_isUpdated);
              });
            },
          ),
          title: Text(widget.note.noteTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isSaving == false
                  ? () async {
                      final navigator = Navigator.of(context);

                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Note'),
                            content: const Text('Are you sure to delete this note?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (result == true) {
                        setState(() {
                          _isSaving = true;
                        });

                        await _dbHelper.deleteNote(widget.note.id!);

                        // 检查小部件是否仍然挂载
                        if (mounted) {
                          navigator.pop(true); // 返回管理页面，数据发生变化
                        }
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isSaving == false
                  ? () {
                      Navigator.of(context).pushNamed('/editNote', arguments: {
                        'note': widget.note,
                      }).then((result) {
                        if (result != null && result is bool && result) {
                          setState(() {
                            _isUpdated = true;
                          });
                        }
                      });
                    }
                  : null,
            ),
          ],
        ),
        body: buildFutureBuilder([
          _dbHelper.getNoteFeedbacksByNoteId(widget.note.id!),
        ], (dataList) {
          _noteFeedbacks = dataList[0];
          return NotePageContent(note: widget.note, noteFeedbacks: _noteFeedbacks!);
        }),
      ),
    );
  }
}

class NotePageContent extends StatefulWidget {
  final Note note;
  final List<NoteFeedback> noteFeedbacks;

  const NotePageContent({Key? key, required this.note, required this.noteFeedbacks}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotePageContentState();
}

class _NotePageContentState extends State<NotePageContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.note.noteContent),
                  for (var feedback in widget.noteFeedbacks) FeedbackWidget(feedback: feedback),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                // 处理按钮点击事件
                // 在这里添加您希望执行的操作
              },
              child: const Icon(Icons.add), // 按钮上显示的图标
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackWidget extends StatelessWidget {
  final NoteFeedback feedback;

  const FeedbackWidget({Key? key, required this.feedback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(feedback.contentText),
    );
  }
}
