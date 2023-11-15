// models/scene.dart

import 'package:conversation_notebook/models/user.dart';

class Scene {
  int? id;
  String sceneName;
  String? backgroundPath;
  User user1;
  User user2;

  Scene({
    this.id,
    required this.sceneName,
    this.backgroundPath,
    required this.user1,
    required this.user2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sceneName': sceneName,
      'backgroundPath': backgroundPath,
      'user1': user1.toMap(),
      'user2': user2.toMap(),
    };
  }
}
