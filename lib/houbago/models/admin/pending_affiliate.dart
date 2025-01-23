class PendingAffiliate {
  final String id;
  final String? userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String status;
  final String? photoIdentityUrl;
  final String? photoLicenseUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PendingAffiliate({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.status,
    this.photoIdentityUrl,
    this.photoLicenseUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory PendingAffiliate.fromJson(Map<String, dynamic> json) {
    print('=== Conversion JSON en PendingAffiliate ===');
    print('JSON reçu: $json');
    
    // Vérification des champs requis
    if (json['id'] == null) throw 'Le champ id est null';
    if (json['first_name'] == null) throw 'Le champ first_name est null';
    if (json['last_name'] == null) throw 'Le champ last_name est null';
    if (json['phone'] == null) throw 'Le champ phone est null';
    if (json['status'] == null) throw 'Le champ status est null';
    if (json['created_at'] == null) throw 'Le champ created_at est null';

    return PendingAffiliate(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      firstName: json['first_name'].toString(),
      lastName: json['last_name'].toString(),
      phone: json['phone'].toString(),
      status: json['status'].toString(),
      photoIdentityUrl: json['photo_identity_url']?.toString(),
      photoLicenseUrl: json['photo_license_url']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'status': status,
      'photo_identity_url': photoIdentityUrl,
      'photo_license_url': photoLicenseUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
