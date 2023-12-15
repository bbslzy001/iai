// pages/character/chat_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/models/message.dart';
import 'package:iai/models/scene.dart';
import 'package:iai/models/user.dart';
import 'package:iai/utils/build_future_builder.dart';
import 'package:iai/utils/avatar_provider.dart';
import 'package:iai/widgets/media_message_shower.dart';

class ChatPage extends StatefulWidget {
  final Scene scene;

  const ChatPage({Key? key, required this.scene}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return buildFutureBuilder([
      _dbHelper.getMessagesBySceneId(widget.scene.id!),
      _dbHelper.getUserById(widget.scene.user1Id),
      _dbHelper.getUserById(widget.scene.user2Id),
    ], (dataList) {
      final messages = dataList[0];
      final user1 = dataList[1];
      final user2 = dataList[2];
      return ChatPageContent(sceneId: widget.scene.id!, messages: messages, user1: user1, user2: user2);
    });
  }
}

class ChatPageContent extends StatefulWidget {
  final int sceneId;
  final List<Message> messages;
  final User user1;
  final User user2;

  const ChatPageContent({Key? key, required this.sceneId, required this.messages, required this.user1, required this.user2}) : super(key: key);

  @override
  State<ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<ChatPageContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _textInputController = TextEditingController();

  late List<CacheMessage> _cacheMessages;
  late User _currentUser;
  late User _oppositeUser;
  bool _showExtraButtons = false;

  @override
  void initState() {
    super.initState();
    _cacheMessages = widget.messages.reversed.map((message) => CacheMessage(message)).toList();
    _currentUser = widget.user1;
    _oppositeUser = widget.user2;
  }

  void _sendTextMessage(String text) async {
    final message = Message(
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
    final fileName = await FileHelper.saveFile(imageFile);
    message.contentImage = fileName;
    await _dbHelper.insertMessage(message);
  }

  void _sendVideoMessage(File videoFile) async {
    final message = Message(
      sceneId: widget.sceneId,
      senderId: _currentUser.id!,
      receiverId: _oppositeUser.id!,
      contentType: 'video',
      contentText: '',
      contentImage: '',
      contentVideo: '',
    );
    late final File thumbnailFile;
    final thumbnailName = await FileHelper.saveThumbnail(videoFile);
    if (thumbnailName.isNotEmpty) {
      message.contentImage = thumbnailName;
      thumbnailFile = await FileHelper.getFile(thumbnailName);
    }
    setState(() {
      _cacheMessages.insert(0, CacheMessage(message, videoFile: videoFile, videoThumbnailFile: thumbnailFile));
    });
    final videoName = await FileHelper.saveFile(videoFile);
    message.contentVideo = videoName;
    _dbHelper.insertMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBarHeight = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: ListTile(
          onTap: () {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _cacheMessages.length,
                    itemBuilder: (context, index) {
                      CacheMessage cacheMessage = _cacheMessages[index];
                      bool isMe = cacheMessage.message.senderId == _currentUser.id;
                      return buildMessageWidget(context, cacheMessage, isMe);
                    },
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            size: 80,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 20),
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
                          _showExtraButtons = !_showExtraButtons;
                        });
                      },
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child: TextField(
                          controller: _textInputController,
                          // 监听输入框的变化，更新UI组件
                          onChanged: (text) {
                            setState(() {});
                          },
                          minLines: 1,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // 调整垂直和水平内边距
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
                if (_showExtraButtons)
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
                            _sendVideoMessage(videoFile);
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
    final colorScheme = Theme.of(context).colorScheme;

    final isText = cacheMessage.message.contentType == 'text';

    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
        return MyMediaMessageShower(image: message.contentImage, key: ObjectKey(cacheMessage));
      } else {
        return MyMediaMessageShower(imageFile: cacheMessage.imageFile!, key: ObjectKey(cacheMessage));
      }
    } else {
      if (message.contentVideo.isNotEmpty) {
        return MyMediaMessageShower(video: message.contentVideo, videoThumbnail: message.contentImage, key: ObjectKey(cacheMessage));
      } else {
        return MyMediaMessageShower(videoThumbnailFile: cacheMessage.videoThumbnailFile, videoFile: cacheMessage.videoFile, key: ObjectKey(cacheMessage));
      }
    }
  }
}

class CacheMessage {
  final Message message;
  final File? imageFile;
  final File? videoThumbnailFile;
  final File? videoFile;

  CacheMessage(this.message, {this.imageFile, this.videoThumbnailFile, this.videoFile});
}
