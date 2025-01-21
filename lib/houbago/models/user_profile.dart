class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String photoUrl;
  final String vehicleType;
  final String yangoId;
  final bool notificationsEnabled;
  final String language;
  final String currency;
  final DateTime registrationDate;
  final String referralCode;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.photoUrl,
    required this.vehicleType,
    required this.yangoId,
    required this.notificationsEnabled,
    required this.language,
    required this.currency,
    required this.registrationDate,
    required this.referralCode,
  });

  String get fullName => '$firstName $lastName';
}

// Données factices pour le profil
final dummyProfile = UserProfile(
  id: '123',
  firstName: 'Jean',
  lastName: 'Dupont',
  phoneNumber: '06 12 34 56 78',
  email: 'jean.dupont@example.com',
  photoUrl: 'https://i.pravatar.cc/150?img=1',
  vehicleType: 'car',
  yangoId: 'YG-12345',
  notificationsEnabled: true,
  language: 'Français',
  currency: 'EUR',
  registrationDate: DateTime(2023, 6, 15),
  referralCode: 'JEAN2023',
);
