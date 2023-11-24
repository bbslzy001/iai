// models/note.dart

class Note {
  int? id;
  int identityId;
  String title;
  String content;
  int isCompleted;

  Note({
    this.id,
    required this.identityId,
    required this.title,
    required this.content,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identityId': identityId,
      'title': title,
      'content': content,
      'isCompleted': isCompleted,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      identityId: map['identityId'],
      title: map['title'],
      content: map['content'],
      isCompleted: map['isCompleted'],
    );
  }
}
