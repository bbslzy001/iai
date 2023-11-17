// models/note.dart

class Note {
  int? id;
  String title;
  String content;
  int isCompleted;
  String feedback;
  String feedbackMediaPaths;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
    required this.feedback,
    required this.feedbackMediaPaths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isCompleted': isCompleted,
      'feedback': feedback,
      'feedbackMediaPaths': feedbackMediaPaths,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isCompleted: map['isCompleted'],
      feedback: map['feedback'],
      feedbackMediaPaths: map['feedbackMediaPaths'],
    );
  }
}
