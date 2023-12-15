import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iai/helpers/database_helper.dart';
import 'package:iai/helpers/file_helper.dart';
import 'package:iai/models/note.dart';
import 'package:iai/models/notefeedback.dart';
import 'package:iai/utils/build_future_builder.dart';
import 'package:iai/widgets/expandable_floating_action_button.dart';
import 'package:iai/widgets/media_message_shower.dart';
import 'package:image_picker/image_picker.dart';

class NotePage extends StatefulWidget {
  final Note note;

  const NotePage({Key? key, required this.note}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _dbHelper = DatabaseHelper();

  List<CacheNoteFeedback>? _cacheNoteFeedbacks;

  bool _isSaving = false;
  bool _isUpdated = false;

  late Future<List<NoteFeedback>> _noteFeedbacksFuture;

  // 异步获取数据
  Future<List<NoteFeedback>> _getNoteFeedbacksFuture() async {
    return await _dbHelper.getNoteFeedbacksByNoteId(widget.note.id!);
  }

  // 第一次获取数据
  @override
  void initState() {
    super.initState();
    _noteFeedbacksFuture = _getNoteFeedbacksFuture();
  }

  // 重新获取数据，定义给子组件使用的回调函数
  void updateStateCallback() {
    // Future数据的状态从 completed 到 waiting，不需要手动设置为 null，FutureBuilder 会自动重新触发页面重新绘制
    setState(() {
      _noteFeedbacksFuture = _getNoteFeedbacksFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_isUpdated);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                Navigator.of(context).pop(_isUpdated);
              });
            },
          ),
          title: Text(widget.note.noteTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isSaving == false
                  ? () async {
                      final navigator = Navigator.of(context);

                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Note'),
                            content: const Text('Are you sure to delete this note?'),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (result == true) {
                        setState(() {
                          _isSaving = true;
                        });

                        await _dbHelper.deleteNote(widget.note.id!);

                        // 检查小部件是否仍然挂载
                        if (mounted) {
                          navigator.pop(true); // 返回管理页面，数据发生变化
                        }
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isSaving == false
                  ? () {
                      Navigator.of(context).pushNamed('/editNote', arguments: {
                        'note': widget.note,
                      }).then((result) {
                        if (result != null && result is bool && result) {
                          setState(() {
                            _isUpdated = true;
                          });
                        }
                      });
                    }
                  : null,
            ),
          ],
        ),
        body: buildFutureBuilder([_noteFeedbacksFuture], (dataList) {
          final noteFeedbacks = dataList[0] as List<NoteFeedback>;
          _cacheNoteFeedbacks ??= noteFeedbacks.map((noteFeedback) => CacheNoteFeedback(noteFeedback)).toList();
          return NotePageContent(note: widget.note, cacheNoteFeedbacks: _cacheNoteFeedbacks!);
        }),
        floatingActionButton: FutureBuilder(
          future: _noteFeedbacksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              _cacheNoteFeedbacks ??= snapshot.data!.map((noteFeedback) => CacheNoteFeedback(noteFeedback)).toList(); // 确保数据已经加载完成
              return ExpandableFab(
                distance: 80,
                children: [
                  ActionButton(
                    icon: const Icon(Icons.format_size),
                    onPressed: () async {
                      TextEditingController textController = TextEditingController();

                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Reply...'),
                            content: TextField(
                              controller: textController,
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop('');
                                },
                              ),
                              TextButton(
                                child: const Text('Finish'),
                                onPressed: () {
                                  Navigator.of(context).pop(textController.text); // 传递输入内容
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (result != null && result.isNotEmpty) {
                        _replyText(result);
                      }
                    },
                  ),
                  ActionButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () async {
                      XFile? pickedFile = await FileHelper.pickImageFromGallery();
                      if (pickedFile != null) {
                        File imageFile = File(pickedFile.path);
                        _replyImage(imageFile);
                      }
                    },
                  ),
                  ActionButton(
                    icon: const Icon(Icons.videocam),
                    onPressed: () async {
                      XFile? pickedFile = await FileHelper.pickVideoFromGallery();
                      if (pickedFile != null) {
                        File videoFile = File(pickedFile.path);
                        _replyVideo(videoFile);
                      }
                    },
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  void _replyText(String text) async {
    final noteFeedback = NoteFeedback(
      noteId: widget.note.id!,
      contentType: 'text',
      contentText: text,
      contentImage: '',
      contentVideo: '',
    );
    setState(() {
      _cacheNoteFeedbacks!.add(CacheNoteFeedback(noteFeedback));
    });
    _dbHelper.insertNoteFeedback(noteFeedback);
  }

  void _replyImage(File imageFile) async {
    final noteFeedback = NoteFeedback(
      noteId: widget.note.id!,
      contentType: 'image',
      contentText: '',
      contentImage: '',
      contentVideo: '',
    );
    setState(() {
      _cacheNoteFeedbacks!.add(CacheNoteFeedback(noteFeedback, imageFile: imageFile));
    });
    final fileName = await FileHelper.saveFile(imageFile);
    noteFeedback.contentImage = fileName;
    await _dbHelper.insertNoteFeedback(noteFeedback);
  }

  void _replyVideo(File videoFile) async {
    final noteFeedback = NoteFeedback(
      noteId: widget.note.id!,
      contentType: 'video',
      contentText: '',
      contentImage: '',
      contentVideo: '',
    );
    late final File thumbnailFile;
    final thumbnailName = await FileHelper.saveThumbnail(videoFile);
    if (thumbnailName.isNotEmpty) {
      noteFeedback.contentImage = thumbnailName;
      thumbnailFile = await FileHelper.getFile(thumbnailName);
    }
    setState(() {
      _cacheNoteFeedbacks!.add(CacheNoteFeedback(noteFeedback, videoFile: videoFile, videoThumbnailFile: thumbnailFile));
    });
    final videoName = await FileHelper.saveFile(videoFile);
    noteFeedback.contentVideo = videoName;
    _dbHelper.insertNoteFeedback(noteFeedback);
  }
}

class NotePageContent extends StatefulWidget {
  final Note note;
  final List<CacheNoteFeedback> cacheNoteFeedbacks;

  const NotePageContent({Key? key, required this.note, required this.cacheNoteFeedbacks}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotePageContentState();
}

class _NotePageContentState extends State<NotePageContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(widget.note.noteContent),
              ),
              Visibility(
                visible: widget.note.noteContent.isNotEmpty,
                child: const Divider(height: 1, thickness: 1),
              ),
              for (int index = 0; index < widget.cacheNoteFeedbacks.length; index++)
                Column(
                  children: [
                    _buildNoteFeedbackWidget(widget.cacheNoteFeedbacks[index]),
                    if (index < widget.cacheNoteFeedbacks.length - 1) const Divider(height: 1, thickness: 1),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteFeedbackWidget(CacheNoteFeedback cacheNoteFeedback) {
    final noteFeedback = cacheNoteFeedback.noteFeedback;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16.0, right: 0), // 调整水平内边距
      title: noteFeedback.contentText.isNotEmpty ? Text(noteFeedback.contentText) : null,
      subtitle: noteFeedback.contentType != 'text' ? _buildMediaReplyWidget(cacheNoteFeedback) : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'delete') {
            setState(() {
              widget.cacheNoteFeedbacks.remove(cacheNoteFeedback);
            });
            await DatabaseHelper().deleteNoteFeedback(noteFeedback.id!);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaReplyWidget(CacheNoteFeedback cacheNoteFeedback) {
    final noteFeedback = cacheNoteFeedback.noteFeedback;

    if (noteFeedback.contentType == 'image') {
      if (noteFeedback.contentImage.isNotEmpty) {
        return MyMediaMessageShower(image: noteFeedback.contentImage, key: ObjectKey(cacheNoteFeedback));
      } else {
        return MyMediaMessageShower(imageFile: cacheNoteFeedback.imageFile, key: ObjectKey(cacheNoteFeedback));
      }
    } else {
      if (noteFeedback.contentVideo.isNotEmpty) {
        return MyMediaMessageShower(video: noteFeedback.contentVideo, videoThumbnail: noteFeedback.contentImage, key: ObjectKey(cacheNoteFeedback));
      } else {
        return MyMediaMessageShower(videoThumbnailFile: cacheNoteFeedback.videoThumbnailFile, videoFile: cacheNoteFeedback.videoFile, key: ObjectKey(cacheNoteFeedback));
      }
    }
  }
}

class CacheNoteFeedback {
  final NoteFeedback noteFeedback;
  final File? imageFile;
  final File? videoThumbnailFile;
  final File? videoFile;

  CacheNoteFeedback(this.noteFeedback, {this.imageFile, this.videoThumbnailFile, this.videoFile});
}
