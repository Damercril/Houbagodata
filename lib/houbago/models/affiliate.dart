enum AffiliateStatus {
  pending('En attente'),
  active('Actif'),
  inactive('Inactif');

  final String label;
  const AffiliateStatus(this.label);
}

class Affiliate {
  final String id;
  final String referrerId;
  final String? userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? driverType;
  final String? photoIdentityUrl;
  final String? photoLicenseUrl;
  final AffiliateStatus status;
  final DateTime? lastRideDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalEarnings;

  const Affiliate({
    required this.id,
    required this.referrerId,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.driverType,
    this.photoIdentityUrl,
    this.photoLicenseUrl,
    required this.status,
    this.lastRideDate,
    required this.createdAt,
    required this.updatedAt,
    this.totalEarnings = 0,
  });

  factory Affiliate.fromJson(Map<String, dynamic> json) {
    return Affiliate(
      id: json['id'],
      referrerId: json['referrer_id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      driverType: json['driver_type'],
      photoIdentityUrl: json['photo_identity_url'],
      photoLicenseUrl: json['photo_license_url'],
      status: _statusFromString(json['status']),
      lastRideDate: json['last_ride_date'] != null 
          ? DateTime.parse(json['last_ride_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static AffiliateStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return AffiliateStatus.pending;
      case 'active':
        return AffiliateStatus.active;
      case 'inactive':
        return AffiliateStatus.inactive;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'driver_type': driverType,
      'photo_identity_url': photoIdentityUrl,
      'photo_license_url': photoLicenseUrl,
      'status': status.label,
      'last_ride_date': lastRideDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_earnings': totalEarnings,
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isActive => status == AffiliateStatus.active;
  bool get isPending => status == AffiliateStatus.pending;
  bool get isInactive => status == AffiliateStatus.inactive;
}
