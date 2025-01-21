// Renommé en HoubagoUser pour éviter les conflits avec User de Supabase
import 'package:houbago/houbago/database/database_service.dart';

class HoubagoUser {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final double balance;

  const HoubagoUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.balance,
    this.email,
  });

  factory HoubagoUser.fromJson(Map<String, dynamic> json) {
    return HoubagoUser(
      id: json['id'] as String,
      firstName: json['firstname'] as String,
      lastName: json['lastname'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,  // Valeur par défaut 0.0 si null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'phone': phone,
      'email': email,
      'balance': balance,
    };
  }
}
