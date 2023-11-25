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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.noteTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/editNote', arguments: {
                'note': widget.note,
                'noteFeedbacks': _noteFeedbacks ?? [],
              }).then((result) {
                if (result != null && result is bool && result) {
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
      body: buildFutureBuilder([
        _dbHelper.getNoteFeedbacksByNoteId(widget.note.id!),
      ], (dataList) {
        _noteFeedbacks = dataList[0];
        return NotePageContent(note: widget.note, noteFeedbacks: _noteFeedbacks!);
      }),
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
    return Column(
      children: [
        Text(widget.note.noteContent),
        for (var feedback in widget.noteFeedbacks) FeedbackWidget(feedback: feedback),
      ],
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
