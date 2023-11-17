// pages/character/chat_page.dart

import 'package:flutter/material.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/message.dart';
import 'package:iai/models/user.dart';

class ChatPage extends StatefulWidget {
  final int user1Id;
  final int user2Id;

  const ChatPage({Key? key, required this.user1Id, required this.user2Id}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Message>> _messagesFuture;
  late Future<User> _user1Future;
  late Future<User> _user2Future;

  // 异步获取数据
  Future<List<Message>> getMessagesFuture() async {
    // 模拟异步操作的延迟
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getMessagesByUserIds(widget.user1Id, widget.user2Id);
  }

  Future<User> getUser1Future() async {
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getUserById(widget.user1Id);
  }

  Future<User> getUser2Future() async {
    await Future.delayed(Duration(seconds: 2));
    return await _dbHelper.getUserById(widget.user2Id);
  }

  @override
  void initState() {
    super.initState();
    _messagesFuture = getMessagesFuture();
    _user1Future = getUser1Future();
    _user2Future = getUser2Future();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        FutureBuilder(
          future: Future.wait([_messagesFuture, _user1Future, _user2Future]),
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
              List<Message> messages = snapshot.data![0];
              User user1 = snapshot.data![1];
              User user2 = snapshot.data![2];
              return ChatPageContent(messages: messages, user1: user1, user2: user2);
            }
          },
        ),
    );
  }
}

class ChatPageContent extends StatefulWidget {
  final List<Message> messages;
  final User user1;
  final User user2;

  const ChatPageContent({Key? key, required this.messages, required this.user1, required this.user2}) : super(key: key);

  @override
  _ChatPageContentState createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<ChatPageContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final TextEditingController _messageController = TextEditingController();

  late List<Message> _messages;
  late User _currentUser;
  late User _oppositeUser;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages.reversed.toList();
    _currentUser = widget.user1;
    _oppositeUser = widget.user2;
  }

  void sendMessage(String text) async {
    Message message = Message(
      senderId: _currentUser.id!,
      receiverId: _oppositeUser.id!,
      contentType: 'text',
      contentText: text,
      contentPath: '',
    );
    setState(() {
      _messages.insert(0, message);
    });
    _dbHelper.insertMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: false,
        titleSpacing: 0,
        title: ListTile(
          onTap: () {
            // 点击对方触发的效果
            // 相互切换角色
            setState(() {
              User temp = _currentUser;
              _currentUser = _oppositeUser;
              _oppositeUser = temp;
            });
          },
          leading: CircleAvatar(
            backgroundImage: AssetImage(
              _oppositeUser.avatarPath.isNotEmpty ? _oppositeUser.avatarPath : 'assets/images/useravatar.png',
            ),
          ),
          title: Text(
            _oppositeUser.username,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // 打开菜单
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isNotEmpty
                ? ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    // controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      Message message = _messages[index];
                      bool isMe = message.senderId == _currentUser.id;
                      return buildMessageWidget(message, isMe);
                    },
                  )
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            size: 80,
                            color: colorScheme.outline,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 8 + bottomNavBarHeight,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // 发送媒体文件
                  },
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    child: TextField(
                      controller: _messageController,
                      // 监听输入框的变化，更新UI组件
                      onChanged: (text) {
                        setState(() {});
                      },
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // 调整垂直和水平内边距
                        hintText: 'Type a message',
                        border:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _messageController.text.isNotEmpty ? colorScheme.primary : colorScheme.outline,
                  ),
                  onPressed: _messageController.text.isNotEmpty
                      ? () {
                          sendMessage(_messageController.text);
                          _messageController.clear();
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageWidget(Message message, bool isMe) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.contentText,
              style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
