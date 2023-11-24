// pages/notebook/notebook_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/identity.dart';
import 'package:iai/models/note.dart';

class NotebookPage extends StatefulWidget {
  final Identity identity;

  const NotebookPage({Key? key, required this.identity}) : super(key: key);

  @override
  _NotebookPageState createState() => _NotebookPageState();
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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/addNote').then((result) {
                if (result != null && result is bool && result) {

                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_notesFuture]),
        // 构建页面的回调
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 检查异步操作的状态
          if (snapshot.hasData) {
            // 数据准备完成，构建页面
            final notes = snapshot.data![0];
            return NotebookPageContent(notes: notes, updateStateCallback: updateStateCallback);
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 如果正在加载数据，显示加载指示器
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class NotebookPageContent extends StatefulWidget {
  final List<Note> notes;
  final VoidCallback updateStateCallback;

  const NotebookPageContent({Key? key, required this.notes, required this.updateStateCallback}) : super(key: key);

  @override
  _NotebookPageContentState createState() => _NotebookPageContentState();
}

class _NotebookPageContentState extends State<NotebookPageContent> {
  final _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (BuildContext context) {
                  Navigator.of(context).pushNamed('/editNote', arguments: {
                    'note': widget.notes[index] as Note,
                  }).then((result) {
                    if (result != null && result is bool && result) {
                      widget.updateStateCallback();
                    }
                  });
                },
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.primaryContainer,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (BuildContext context) async {
                  await _dbHelper.deleteIdentity(widget.notes[index].id!);
                  widget.updateStateCallback();
                },
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.errorContainer,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            title: Text(widget.notes[index].title),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        );
      },
    );
  }
}
