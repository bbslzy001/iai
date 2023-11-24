// models/identity.dart

class Identity {
  int? id;
  String identityName;
  String backgroundImage;

  Identity({
    this.id,
    required this.identityName,
    required this.backgroundImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identityName': identityName,
      'backgroundImage': backgroundImage,
    };
  }

  factory Identity.fromMap(Map<String, dynamic> map) {
    return Identity(
      id: map['id'],
      identityName: map['identityName'],
      backgroundImage: map['backgroundImage'],
    );
  }
}
