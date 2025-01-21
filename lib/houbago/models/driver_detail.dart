class DriverDetail {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime registrationDate;
  final DateTime lastRideDate;
  final String photoUrl;
  final String vehicleType; // 'moto' ou 'car'
  final int totalRides;
  final double rating;
  final double totalEarnings;
  final int referredDrivers;
  final String status; // 'active', 'inactive', 'pending'

  DriverDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.registrationDate,
    required this.lastRideDate,
    required this.photoUrl,
    required this.vehicleType,
    required this.totalRides,
    required this.rating,
    required this.totalEarnings,
    required this.referredDrivers,
    required this.status,
  });

  String get fullName => '$firstName $lastName';
}
