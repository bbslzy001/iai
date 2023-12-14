import 'package:flutter/material.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/note.dart';
import 'package:iai/models/notefeedback.dart';

class AddReplyPage extends StatefulWidget {
  final Note note;

  const AddReplyPage({Key? key, required this.note}) : super(key: key);

  @override
  State<AddReplyPage> createState() => _AddReplyPageState();
}

class _AddReplyPageState extends State<AddReplyPage> {
  final _dbHelper = DatabaseHelper();

  bool _isSaving = false;

  String contentType = 'text';

  @override
  Widget build(BuildContext context) {
    final noteFeedback = NoteFeedback(
      noteId: widget.note.id!,
      contentType: '',
      contentText: '',
      contentImage: '',
      contentVideo: '',
    );

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
            icon: const Icon(Icons.send),
            onPressed: _isSaving == false
                ? () async {
                    final navigator = Navigator.of(context);

                    setState(() {
                      _isSaving = true;
                    });

                    await _dbHelper.insertNoteFeedback(noteFeedback);

                    if (mounted) {
                      navigator.pop(true);
                    }
                  }
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: () {
          if (contentType == 'text') {
            return TextFormField(
              initialValue: noteFeedback.contentText,
              decoration: const InputDecoration(
                hintText: 'Reply',
              ),
              onChanged: (value) {
                setState(() {
                  noteFeedback.contentText = value;
                });
              },
            );
          } else if (contentType == 'image') {
            return InkWell(
              onTap: () {
                //selectPictures();
              },
              child: Container(
                color: Color(0xFFF0F0F0),
                child: Center(
                  child: Icon(
                    Icons.add,
                  ),
                ),
              ),
            );
            return TextFormField(
              initialValue: noteFeedback.contentImage,
              decoration: const InputDecoration(
                hintText: 'Reply',
              ),
              onChanged: (value) {
                setState(() {
                  noteFeedback.contentImage = value;
                });
              },
            );
          } else if (contentType == 'video') {
            return TextFormField(
              initialValue: noteFeedback.contentVideo,
              decoration: const InputDecoration(
                hintText: 'Reply',
              ),
              onChanged: (value) {
                setState(() {
                  noteFeedback.contentVideo = value;
                });
              },
            );
          } else {
            return Container(); // Return a default widget if contentType is not recognized
          }
        }(),
      ),
    );
  }
}
