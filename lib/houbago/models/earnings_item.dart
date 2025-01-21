class EarningsItem {
  final String id;
  final double amount;
  final DateTime createdAt;
  final String? description;
  final String status;

  const EarningsItem({
    required this.id,
    required this.amount,
    required this.createdAt,
    this.description,
    required this.status,
  });

  factory EarningsItem.fromJson(Map<String, dynamic> json) {
    return EarningsItem(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'status': status,
    };
  }
}
