// models/message.dart

class Message {
  int? id;
  int senderId;
  int receiverId;
  String contentType;
  String? contentText;
  String? contentPath;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.contentType,
    this.contentText,
    this.contentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'contentType': contentType,
      'contentText': contentText,
      'contentPath': contentPath,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      contentType: map['contentType'],
      contentText: map['contentText'],
      contentPath: map['contentPath'],
    );
  }
}
