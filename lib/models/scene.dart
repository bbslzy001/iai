// models/scene.dart

class Scene {
  int? id;
  String sceneName;
  String backgroundPath;
  int user1Id;
  int user2Id;

  Scene({
    this.id,
    required this.sceneName,
    required this.backgroundPath,
    required this.user1Id,
    required this.user2Id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sceneName': sceneName,
      'backgroundPath': backgroundPath,
      'user1Id': user1Id,
      'user2Id': user2Id,
    };
  }

  factory Scene.fromMap(Map<String, dynamic> map) {
    return Scene(
      id: map['id'],
      sceneName: map['sceneName'],
      backgroundPath: map['backgroundPath'],
      user1Id: map['user1Id'],
      user2Id: map['user2Id'],
    );
  }
}
