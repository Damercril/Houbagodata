class HoubagoUser {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final String? profilePicture;
  final double balance;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HoubagoUser({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    this.profilePicture,
    this.balance = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  factory HoubagoUser.fromJson(Map<String, dynamic> json) {
    return HoubagoUser(
      id: json['id'],
      phone: json['phone'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      profilePicture: json['profile_picture'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_picture': profilePicture,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  HoubagoUser copyWith({
    String? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HoubagoUser(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
