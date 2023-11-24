// models/notefeedback.dart

class NoteFeedback {
  int? id;
  int noteId;
  String contentType;
  String contentText;
  String contentImage;
  String contentVideo;

  NoteFeedback({
    this.id,
    required this.noteId,
    required this.contentType,
    required this.contentText,
    required this.contentImage,
    required this.contentVideo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noteId': noteId,
      'contentType': contentType,
      'contentText': contentText,
      'contentImage': contentImage,
      'contentVideo': contentVideo,
    };
  }

  factory NoteFeedback.fromMap(Map<String, dynamic> map) {
    return NoteFeedback(
      id: map['id'],
      noteId: map['noteId'],
      contentType: map['contentType'],
      contentText: map['contentText'],
      contentImage: map['contentImage'],
      contentVideo: map['contentVideo'],
    );
  }
}
