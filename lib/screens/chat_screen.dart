import 'package:conversation_notebook/helpers/database_helper.dart';
import 'package:flutter/material.dart';

import 'package:conversation_notebook/models/message.dart';
import 'package:conversation_notebook/models/user.dart';
import 'package:conversation_notebook/screens/setting_screen.dart';

class ChatScreen extends StatefulWidget {
  final int user1Id;
  final int user2Id;

  const ChatScreen({Key? key, required this.user1Id, required this.user2Id}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  User? _currentUser;
  User? _oppositeUser;

  void addMessage(String text) async {
    Message message = Message(
      senderId: _currentUser!.id!,
      receiverId: _oppositeUser!.id!,
      contentType: 'text',
      contentText: text,
    );
    message.id = await _dbHelper.insertMessage(message);
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  void initState() async {
    super.initState();
    _currentUser = await _dbHelper.getUserById(widget.user1Id);
    _oppositeUser = await _dbHelper.getUserById(widget.user2Id);
    _messages = await _dbHelper.getMessagesByUserIds(widget.user1Id, widget.user2Id);
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    double screenHeight = MediaQuery.of(context).size.height - statusBarHeight - bottomNavBarHeight;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        centerTitle: false,
        titleSpacing: 0,
        title: ListTile(
          onTap: () {
            // 点击对方触发的效果
            // 相互切换角色？
          },
          leading: CircleAvatar(
            backgroundImage: AssetImage(
              _oppositeUser!.avatarPath ?? '', // Assuming avatarPath is the image asset path
            ),
          ),
          title: Text(
            _oppositeUser!.username,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            splashRadius: 20,
            icon: Icon(
              Icons.menu,
              color: Colors.grey.shade700,
            ),
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
                      bool isMe = message.senderId == _currentUser!.id;
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
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade400,
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
                  splashRadius: 20,
                  icon: Icon(Icons.add, color: Colors.grey.shade700),
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
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(right: 16, left: 20, bottom: 10, top: 10),
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          gapPadding: 0,
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          gapPadding: 0,
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    Icons.send,
                    color: _messageController.text.isNotEmpty ? Colors.blue : Colors.grey.shade700,
                  ),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      addToMessages(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageWidget(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.contentType,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void addToMessages(String text) {}
}
