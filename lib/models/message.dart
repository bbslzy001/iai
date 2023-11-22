// models/message.dart

class Message {
  int? id;
  int sceneId;
  int senderId;
  int receiverId;
  String contentType;
  String contentText;
  String contentImage;
  String contentVideo;

  Message({
    this.id,
    required this.sceneId,
    required this.senderId,
    required this.receiverId,
    required this.contentType,
    required this.contentText,
    required this.contentImage,
    required this.contentVideo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sceneId': sceneId,
      'senderId': senderId,
      'receiverId': receiverId,
      'contentType': contentType,
      'contentText': contentText,
      'contentImage': contentImage,
      'contentVideo': contentVideo,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      sceneId: map['sceneId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      contentType: map['contentType'],
      contentText: map['contentText'],
      contentImage: map['contentImage'],
      contentVideo: map['contentVideo'],
    );
  }
}
