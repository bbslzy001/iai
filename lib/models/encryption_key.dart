// models/encryption_key.dart

class EncryptionKey {
  int? id;
  String key;

  EncryptionKey({
    this.id, required this.key
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
    };
  }

  factory EncryptionKey.fromMap(Map<String, dynamic> map) {
    return EncryptionKey(
      id: map['id'],
      key: map['key'],
    );
  }
}
