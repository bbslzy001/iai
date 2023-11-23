// pages/character/chat_page.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/models/scene.dart';
import 'package:iai/models/message.dart';
import 'package:iai/models/user.dart';
import 'package:iai/widgets/avatar_provider.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/widgets/media_message_shower.dart';

class ChatPage extends StatefulWidget {
  final Scene scene;

  const ChatPage({Key? key, required this.scene}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          _dbHelper.getMessagesBySceneId(widget.scene.id!),
          _dbHelper.getUserById(widget.scene.user1Id),
          _dbHelper.getUserById(widget.scene.user2Id),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          // 检查异步操作的状态
          if (snapshot.hasData) {
            // 数据准备完成，构建页面
            List<Message> messages = snapshot.data![0];
            User user1 = snapshot.data![1];
            User user2 = snapshot.data![2];
            return ChatPageContent(sceneId: widget.scene.id!, messages: messages, user1: user1, user2: user2);
          } else if (snapshot.hasError) {
            // 如果发生错误，显示错误信息
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // 如果正在加载数据，显示加载指示器
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ChatPageContent extends StatefulWidget {
  final int sceneId;
  final List<Message> messages;
  final User user1;
  final User user2;

  const ChatPageContent({Key? key, required this.sceneId, required this.messages, required this.user1, required this.user2}) : super(key: key);

  @override
  _ChatPageContentState createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<ChatPageContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final TextEditingController _textInputController = TextEditingController();

  late List<CacheMessage> _cacheMessages;
  late User _currentUser;
  late User _oppositeUser;

  bool showExtraButtons = false;

  @override
  void initState() {
    super.initState();
    _cacheMessages = widget.messages.reversed.map((message) => CacheMessage(message)).toList();
    _currentUser = widget.user1;
    _oppositeUser = widget.user2;
  }

  void _sendTextMessage(String text) async {
    Message message = Message(
      sceneId: widget.sceneId,
      senderId: _currentUser.id!,
      receiverId: _oppositeUser.id!,
      contentType: 'text',
      contentText: text,
      contentImage: '',
      contentVideo: '',
    );
    setState(() {
      _cacheMessages.insert(0, CacheMessage(message));
    });
    _dbHelper.insertMessage(message);
  }

  void _sendImageMessage(File imageFile) async {
    final message = Message(
      sceneId: widget.sceneId,
      senderId: _currentUser.id!,
      receiverId: _oppositeUser.id!,
      contentType: 'image',
      contentText: '',
      contentImage: '',
      contentVideo: '',
    );
    setState(() {
      _cacheMessages.insert(0, CacheMessage(message, imageFile: imageFile));
    });
    final fileName = await FileHelper.saveMedia(imageFile);
    message.contentImage = fileName;
    await _dbHelper.insertMessage(message);
  }

  void _sendVideoMessage(File videoFile, Uint8List? thumbnailBytes) async {
    final message = Message(
      sceneId: widget.sceneId,
      senderId: _currentUser.id!,
      receiverId: _oppositeUser.id!,
      contentType: 'video',
      contentText: '',
      contentImage: '',
      contentVideo: '',
    );
    setState(() {
      _cacheMessages.insert(0, CacheMessage(message, videoFile: videoFile, videoThumbnailBytes: thumbnailBytes));
    });
    final thumbnailName = await FileHelper.saveThumbnail(thumbnailBytes);
    message.contentImage = thumbnailName;
    final videoName = await FileHelper.saveMedia(videoFile);
    message.contentVideo = videoName;
    _dbHelper.insertMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    double bottomNavBarHeight = MediaQuery.of(context).padding.bottom;

    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
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
            foregroundImage: _oppositeUser.avatarImage.isNotEmpty ? MyAvatarProvider(_oppositeUser.avatarImage) : null,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(_oppositeUser.username[0]),
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
            child: _cacheMessages.isNotEmpty
                ? ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _cacheMessages.length,
                    itemBuilder: (context, index) {
                      CacheMessage cacheMessage = _cacheMessages[index];
                      bool isMe = cacheMessage.message.senderId == _currentUser.id;
                      return buildMessageWidget(context, cacheMessage, isMe);
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
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          showExtraButtons = !showExtraButtons;
                        });
                      },
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: TextField(
                          controller: _textInputController,
                          // 监听输入框的变化，更新UI组件
                          onChanged: (text) {
                            setState(() {});
                          },
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // 调整垂直和水平内边距
                            hintText: 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _textInputController.text.isNotEmpty ? colorScheme.primary : colorScheme.outline,
                      ),
                      onPressed: _textInputController.text.isNotEmpty
                          ? () {
                              _sendTextMessage(_textInputController.text);
                              _textInputController.clear();
                            }
                          : null,
                    ),
                  ],
                ),
                if (showExtraButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {
                          // Handle microphone button press
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera),
                        onPressed: () async {
                          XFile? pickedFile = await FileHelper.pickImageFromCamera();
                          if (pickedFile != null) {
                            File imageFile = File(pickedFile.path);
                            _sendImageMessage(imageFile);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: () async {
                          XFile? pickedFile = await FileHelper.pickImageFromGallery();
                          if (pickedFile != null) {
                            File imageFile = File(pickedFile.path);
                            _sendImageMessage(imageFile);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam),
                        onPressed: () async {
                          XFile? pickedFile = await FileHelper.pickVideoFromGallery();
                          if (pickedFile != null) {
                            File videoFile = File(pickedFile.path);
                            Uint8List? thumbnailBytes = await FileHelper.getThumbnailBytes(videoFile);
                            _sendVideoMessage(videoFile, thumbnailBytes);
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageWidget(BuildContext context, CacheMessage cacheMessage, bool isMe) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final isText = cacheMessage.message.contentType == 'text';

    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(isText ? 10 : 5),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isText
            ? Text(
                cacheMessage.message.contentText,
                style: TextStyle(color: isMe ? colorScheme.onPrimary : colorScheme.onSecondary),
              )
            : SizedBox(
                width: 240,
                height: 160,
                child: SizedBox.expand(
                  child: buildMediaMessageWidget(cacheMessage),
                ),
              ),
      ),
    );
  }

  Widget buildMediaMessageWidget(CacheMessage cacheMessage) {
    Message message = cacheMessage.message;

    if (message.contentType == 'image') {
      if (message.contentImage.isNotEmpty) {
        // TODO: 修改成MyMediaMessageShower
        return MyMediaMessageShower(image: message.contentImage);
      } else {
        return Image.file(
          cacheMessage.imageFile!,
          fit: BoxFit.cover,
        );
      }
    } else {
      if (message.contentVideo.isNotEmpty) {
        // TODO: 修改成MyMediaMessageShower，在内部判断是否有缩略图
        return MyMediaMessageShower(image: message.contentImage);
      } else {
        return Image.memory(
          cacheMessage.videoThumbnailBytes!,
          fit: BoxFit.cover,
        );
      }
    }
  }
}

class CacheMessage {
  final Message message;
  final File? imageFile;
  final Uint8List? videoThumbnailBytes;
  final File? videoFile;

  CacheMessage(this.message, {this.imageFile, this.videoThumbnailBytes, this.videoFile});
}
