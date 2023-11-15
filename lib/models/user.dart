// models/user.dart

class User {
  int? id;
  String username;
  String? description;
  String? avatarPath;
  String? backgroundPath;

  User({
    this.id,
    required this.username,
    this.description,
    this.avatarPath,
    this.backgroundPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'description': description,
      'avatarPath': avatarPath,
      'backgroundPath': backgroundPath,
    };
  }
}
