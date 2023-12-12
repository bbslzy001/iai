// pages/notebook/notebook_page.dart

import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/identity.dart';
import 'package:iai/models/note.dart';
import 'package:iai/utils/build_future_builder.dart';
import 'package:iai/utils/my_color.dart';

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
        title: Text(widget.identity.identityName),
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
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return ListView.separated(
      itemCount: widget.notes.length,
      separatorBuilder: (context, index) => Divider(height: 8, thickness: 8, color: isLightMode ? MyLightModeColor.divider : MyDarkModeColor.divider),
      itemBuilder: (context, index) {
        Note note = widget.notes[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/note', arguments: {
              'note': note,
            }).then((result) {
              if (result != null && result is bool && result) {
                widget.updateStateCallback();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note.noteTitle,
                      style: const TextStyle(fontSize: 20),
                    ),
                    _buildStatusIndicator(context, note),
                  ],
                ),
                const SizedBox(height: 8), // Add some space between title and content
                Text(
                  note.noteContent,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context, Note note) {
    final Color foregroundColor;
    final Color backgroundColor;
    final String statusText;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    switch (note.noteStatus) {
      case -1: // 设置Undo状态的颜色
        foregroundColor = isLightMode ? MyLightModeColor.warningForeground : MyDarkModeColor.warningForeground;
        backgroundColor = isLightMode ? MyLightModeColor.warningBackground : MyDarkModeColor.warningBackground;
        statusText = 'Undo';
        break;
      case 0: // 设置Doing状态的颜色
        foregroundColor = isLightMode ? MyLightModeColor.primaryForeground : MyDarkModeColor.primaryForeground;
        backgroundColor = isLightMode ? MyLightModeColor.primaryBackground : MyDarkModeColor.primaryBackground;
        statusText = 'Doing';
        break;
      case 1: // 设置Done状态的颜色
        foregroundColor = isLightMode ? MyLightModeColor.successForeground : MyDarkModeColor.successForeground;
        backgroundColor = isLightMode ? MyLightModeColor.successBackground : MyDarkModeColor.successBackground;
        statusText = 'Done';
        break;
      default: // 默认状态的颜色
        foregroundColor = isLightMode ? MyLightModeColor.infoForeground : MyDarkModeColor.infoForeground;
        backgroundColor = isLightMode ? MyLightModeColor.infoBackground : MyDarkModeColor.infoBackground;
        statusText = 'Unknown';
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildStatusOption(context, note, -1, 'Undo'),
                  _buildStatusOption(context, note, 0, 'Doing'),
                  _buildStatusOption(context, note, 1, 'Done'),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          statusText,
          style: TextStyle(color: foregroundColor),
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, Note note, int value, String text) {
    return ListTile(
      title: Text(text),
      onTap: () async {
        final navigator = Navigator.of(context);

        setState(() {
          note.noteStatus = value;
        });

        await _dbHelper.updateNote(note);

        // 检查小部件是否仍然挂载
        if (mounted) {
          navigator.pop(true); // 返回管理页面，数据发生变化
        }
      },
    );
  }
}
