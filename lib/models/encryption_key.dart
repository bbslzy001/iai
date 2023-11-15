// models/encryption_key.dart

class EncryptionKey {
  int? id;
  String key;

  EncryptionKey({this.id, required this.key});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
    };
  }
}
