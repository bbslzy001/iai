// models/note.dart

class Note {
  int? id;
  int identityId;
  String noteTitle;
  String noteContent;
  int noteStatus;

  Note({
    this.id,
    required this.identityId,
    required this.noteTitle,
    required this.noteContent,
    required this.noteStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identityId': identityId,
      'noteTitle': noteTitle,
      'noteContent': noteContent,
      'noteStatus': noteStatus,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      identityId: map['identityId'],
      noteTitle: map['noteTitle'],
      noteContent: map['noteContent'],
      noteStatus: map['noteStatus'],
    );
  }
}
