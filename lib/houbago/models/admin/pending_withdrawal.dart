class PendingWithdrawal {
  final String id;
  final String userId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PendingWithdrawal({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory PendingWithdrawal.fromJson(Map<String, dynamic> json) {
    return PendingWithdrawal(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
