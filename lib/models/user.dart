// models/user.dart

class User {
  int? id;
  String username;
  String description;
  String avatarPath;
  String backgroundPath;

  User({
    this.id,
    required this.username,
    required this.description,
    required this.avatarPath,
    required this.backgroundPath,
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

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      description: map['description'],
      avatarPath: map['avatarPath'],
      backgroundPath: map['backgroundPath'],
    );
  }
}
