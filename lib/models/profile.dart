class Profile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return Profile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
