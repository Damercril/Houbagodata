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
  final String firstName;
  final String lastName;
  final String phone;
  final String? yangoId;
  final AffiliateStatus status;
  final DateTime? lastRideDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalEarnings;

  const Affiliate({
    required this.id,
    required this.referrerId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.yangoId,
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
      firstName: json['firstname'],
      lastName: json['lastname'],
      phone: json['phone'],
      yangoId: json['yango_id'],
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

  String get fullName => '$firstName $lastName';

  bool get isActive => status == AffiliateStatus.active;
  bool get isPending => status == AffiliateStatus.pending;
  bool get isInactive => status == AffiliateStatus.inactive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'firstname': firstName,
      'lastname': lastName,
      'phone': phone,
      'yango_id': yangoId,
      'status': status.label,
      'last_ride_date': lastRideDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_earnings': totalEarnings,
    };
  }
}
