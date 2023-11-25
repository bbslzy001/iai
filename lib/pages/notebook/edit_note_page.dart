import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/note.dart';
import 'package:iai/models/notefeedback.dart';
import 'package:iai/utils/build_future_builder.dart';

class EditNotePage extends StatefulWidget {
  final Note note;
  final List<NoteFeedback> noteFeedbacks;

  const EditNotePage({Key? key, required this.note, required this.noteFeedbacks}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _dbHelper = DatabaseHelper();

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
            onPressed: () async {
              await _dbHelper.updateNote(widget.note);
              for (final feedback in widget.noteFeedbacks) {
                await _dbHelper.updateNoteFeedback(feedback);
              }
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: widget.noteFeedbacks.isEmpty
          ? buildFutureBuilder([
                _dbHelper.getNoteFeedbacksByNoteId(widget.note.id!),
              ],
              (dataList) {
                final noteFeedbacks = dataList[0];
                return EditNoteContentPage(note: widget.note, noteFeedbacks: noteFeedbacks);
              },
            )
          : EditNoteContentPage(note: widget.note, noteFeedbacks: widget.noteFeedbacks),
    );
  }
}

class EditNoteContentPage extends StatefulWidget {
  final Note note;
  final List<NoteFeedback> noteFeedbacks;

  const EditNoteContentPage({Key? key, required this.note, required this.noteFeedbacks}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditNoteContentPageState();
}

class _EditNoteContentPageState extends State<EditNoteContentPage> {
  final _dbHelper = DatabaseHelper();

  final _textController = TextEditingController();

  final _imageController = TextEditingController();

  final _videoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.note.noteContent;
    _imageController.text = widget.note.noteImage;
    _videoController.text = widget.note.noteVideo;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: '笔记内容',
                  hintText: '请输入笔记内容',
                ),
                maxLines: 5,
                maxLength: 1000,
                onChanged: (value) {
                  widget.note.noteContent = value;
                },
              ),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: '笔记图片',
                  hintText: '请输入笔记图片',
                ),
                maxLines: 1,
                maxLength: 1000,
                onChanged: (value) {
                  widget.note.noteImage = value;
                },
              ),
              TextField(
                controller: _videoController,
                decoration: const InputDecoration(
                  labelText: '笔记视频',
                  hintText: '请输入笔记视频',
                ),
                maxLines: 1,
                maxLength: 1000,
                onChanged: (value) {
                  widget.note.noteVideo = value;
                },
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  widget.note.noteStatus = 0;
                  await _dbHelper.updateNoteStatus(widget.note);
                  Navigator.pop(context, true);
                },
                child: const Text('暂存'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  widget.note.noteStatus = 1;
                  await _dbHelper.updateNoteStatus(widget.note);
                  Navigator.pop(context, true);
                },
                child: const Text('发布'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
