// models/message.dart

class Message {
  int? id;
  int senderId;
  int receiverId;
  String contentType;
  String? contentPath;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.contentType,
    this.contentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'contentType': contentType,
      'contentPath': contentPath,
    };
  }
}
