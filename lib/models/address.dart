class Address {
  final int id;
  final String userId;
  final String name;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedAddress {
    final line2 = addressLine2 != null && addressLine2!.isNotEmpty
        ? '$addressLine2, '
        : '';
    return '$addressLine1, ${line2}$city, $state $postalCode, $country';
  }

  Address copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      userId: userId,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
