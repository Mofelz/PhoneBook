class Contact {
  final String id;
  final String name;
  final String phone;
  final String? avatarBase64; // null = нет фото, иначе — base64-строка

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatarBase64': avatarBase64,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      avatarBase64: map['avatarBase64'] as String?,
    );
  }
}
