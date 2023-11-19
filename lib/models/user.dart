// models/user.dart

class User {
  int? id;
  String username;
  String description;
  String avatarImage;
  String backgroundImage;

  User({
    this.id,
    required this.username,
    required this.description,
    required this.avatarImage,
    required this.backgroundImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'description': description,
      'avatarImage': avatarImage,
      'backgroundImage': backgroundImage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      description: map['description'],
      avatarImage: map['avatarImage'],
      backgroundImage: map['backgroundImage'],
    );
  }
}
