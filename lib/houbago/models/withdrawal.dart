class Withdrawal {
  final String id;
  final double amount;
  final DateTime date;
  final String status; // 'pending', 'completed', 'failed'
  final String? bankName;
  final String? accountNumber;
  final String? failureReason;

  const Withdrawal({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.failureReason,
  });
}

// Données de test
final List<Withdrawal> dummyWithdrawals = [
  Withdrawal(
    id: 'W001',
    amount: 25000,
    date: DateTime.now().subtract(const Duration(days: 2)),
    status: 'completed',
    bankName: 'UBA',
    accountNumber: '****1234',
  ),
  Withdrawal(
    id: 'W002',
    amount: 15000,
    date: DateTime.now().subtract(const Duration(days: 5)),
    status: 'completed',
    bankName: 'Ecobank',
    accountNumber: '****5678',
  ),
  Withdrawal(
    id: 'W003',
    amount: 30000,
    date: DateTime.now().subtract(const Duration(days: 7)),
    status: 'failed',
    bankName: 'UBA',
    accountNumber: '****1234',
    failureReason: 'Solde insuffisant',
  ),
  Withdrawal(
    id: 'W004',
    amount: 50000,
    date: DateTime.now().subtract(const Duration(days: 15)),
    status: 'completed',
    bankName: 'UBA',
    accountNumber: '****1234',
  ),
];
