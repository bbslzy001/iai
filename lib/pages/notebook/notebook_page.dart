// pages/notebook/notebook_page.dart

import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/identity.dart';
import 'package:iai/models/note.dart';
import 'package:iai/utils/build_future_builder.dart';

class NotebookPage extends StatefulWidget {
  final Identity identity;

  const NotebookPage({Key? key, required this.identity}) : super(key: key);

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final _dbHelper = DatabaseHelper();

  late Future<List<Note>> _notesFuture;

  // 异步获取数据
  Future<List<Note>> _getNotesFuture() async {
    return await _dbHelper.getNotesByIdentityId(widget.identity.id!);
  }

  // 第一次获取数据
  @override
  void initState() {
    super.initState();
    _notesFuture = _getNotesFuture();
  }

  // 重新获取数据，定义给子组件使用的回调函数
  void updateStateCallback() {
    setState(() {
      _notesFuture = _getNotesFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notebook: ${widget.identity.identityName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/addNote', arguments: {
                'identityId': widget.identity.id!,
              }).then((result) {
                if (result != null && result is bool && result) {
                  updateStateCallback();
                }
              });
            },
          ),
        ],
      ),
      body: buildFutureBuilder([_notesFuture], (dataList) {
        final notes = dataList[0];
        return NotebookPageContent(notes: notes, updateStateCallback: updateStateCallback);
      }),
    );
  }
}

class NotebookPageContent extends StatefulWidget {
  final List<Note> notes;
  final VoidCallback updateStateCallback;

  const NotebookPageContent({Key? key, required this.notes, required this.updateStateCallback}) : super(key: key);

  @override
  State<NotebookPageContent> createState() => _NotebookPageContentState();
}

class _NotebookPageContentState extends State<NotebookPageContent> {
  final _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        Note note = widget.notes[index];
        return ListTile(
          key: ValueKey<int>(note.id!), // 使用note.id作为Key
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.noteTitle,
                style: const TextStyle(fontSize: 20),
              ),
              _buildStatusIndicator(note.noteStatus),
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/note', arguments: {
              'note': note,
            }).then((result) {
              if (result != null && result is bool && result) {
                widget.updateStateCallback();
              }
            });
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildStatusOption(note, -1, 'Undo'),
                      _buildStatusOption(note, 0, 'Doing'),
                      _buildStatusOption(note, 1, 'Done'),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIndicator(int status) {
    Color indicatorColor;
    String statusText;

    switch (status) {
      case -1:
        indicatorColor = Colors.yellow; // 设置Undo状态的颜色
        statusText = 'Undo';
        break;
      case 0:
        indicatorColor = Colors.blue; // 设置Doing状态的颜色
        statusText = 'Doing';
        break;
      case 1:
        indicatorColor = Colors.green; // 设置Done状态的颜色
        statusText = 'Done';
        break;
      default:
        indicatorColor = Colors.grey; // 默认状态的颜色
        statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        statusText,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildStatusOption(Note note, int value, String text) {
    return ListTile(
      title: Text(text),
      onTap: () async {
        setState(() {
          note.noteStatus = value;
        });
        _dbHelper.updateNote(note);
        Navigator.of(context).pop();
      },
    );
  }
}
