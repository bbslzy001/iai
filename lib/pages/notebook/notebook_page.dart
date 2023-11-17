// pages/notebook/notebook_page.dart

import 'package:flutter/material.dart';

import 'package:conversation_notebook/helpers/database_helper.dart';
import 'package:conversation_notebook/models/note.dart';

class NotebookPage extends StatefulWidget {
  const NotebookPage({Key? key}) : super(key: key);

  @override
  _NotebookPageState createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Note>> _notesFuture;

  // 异步获取数据
  Future<List<Note>> _getNotesFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getNotes();
  }

  // 第一次获取数据
  @override
  void initState() {
    super.initState();
    _notesFuture = _getNotesFuture();
  }

  // 重新获取数据，定义给子组件使用的回调函数
  void updateStateCallback() {
    // Future数据的状态从 completed 到 waiting，不需要手动设置为 null，FutureBuilder 会自动重新触发页面重新绘制
    setState(() {
      _notesFuture = _getNotesFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // 传入Future列表
        future: Future.wait([_notesFuture]),
        // 构建页面的回调
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 检查异步操作的状态
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 如果正在加载数据，可以显示加载指示器
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // 如果发生错误，可以显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 数据准备好后，构建页面
            List<Note> notes = snapshot.data![0];
            return NotebookPageContent(notes: notes, updateStateCallback: updateStateCallback);
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
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          // 排除手机顶部状态栏
          padding: EdgeInsets.only(top: statusBarHeight),
          height: screenHeight * 0.25,
          child: buildTitleLayout(context),
        ),
        Container(
          // 排除手机底部导航栏
          padding: EdgeInsets.only(bottom: bottomNavBarHeight),
          height: screenHeight * 0.75,
          child: buildContentLayout(context),
        ),
      ],
    );
  }

  Widget buildTitleLayout(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Center(
            child: Text(
              'Notebook',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/addNote').then((result) {
                if (result != null && result is bool && result) {
                  widget.updateStateCallback();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildContentLayout(BuildContext context) {
    return ListView.builder(
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(widget.notes[index].title),
            subtitle: Text(widget.notes[index].content),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _dbHelper.deleteNote(widget.notes[index].id!);
                widget.updateStateCallback();
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/editNote', arguments: {'note': widget.notes[index], 'callback': widget.updateStateCallback});
            },
          ),
        );
      },
    );
  }
}
