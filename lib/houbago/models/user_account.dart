class UserAccount {
  final String id;
  final String userId;
  final double balance;
  final String referralCode;
  final DateTime createdAt;

  const UserAccount({
    required this.id,
    required this.userId,
    required this.balance,
    required this.referralCode,
    required this.createdAt,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      userId: json['id'] as String, // Même que l'ID car plus de user_id séparé
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      referralCode: json['referral_code'] as String? ?? '', // Optionnel maintenant
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'referral_code': referralCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static final dummyUserAccount = UserAccount(
    id: '12345',
    userId: '12345',
    balance: 0,
    referralCode: '',
    createdAt: DateTime.now(),
  );
}
