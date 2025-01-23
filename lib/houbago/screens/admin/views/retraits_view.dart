import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/admin/pending_withdrawal.dart';
import 'package:houbago/houbago/houbago_theme.dart';

class RetraitsView extends StatelessWidget {
  const RetraitsView({super.key});

  Future<void> _showDetailsDialog(BuildContext context, PendingWithdrawal withdrawal) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Détails du retrait'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montant: ${withdrawal.amount} FCFA'),
              const SizedBox(height: 8),
              Text(
                'Date de demande: ${withdrawal.createdAt.toLocal().toString().split('.')[0]}',
              ),
              const SizedBox(height: 16),
              const Text(
                'Êtes-vous sûr de vouloir traiter cette demande de retrait ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Rejeter'),
              onPressed: () async {
                await DatabaseService.updateWithdrawalStatus(
                  withdrawal.id,
                  'rejected',
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Retrait rejeté'),
                    ),
                  );
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Approuver'),
              onPressed: () async {
                await DatabaseService.updateWithdrawalStatus(
                  withdrawal.id,
                  'approved',
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Retrait approuvé'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PendingWithdrawal>>(
      stream: DatabaseService.getPendingWithdrawals(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final withdrawals = snapshot.data!;
        
        if (withdrawals.isEmpty) {
          return const Center(
            child: Text('Aucun retrait en attente'),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: HoubagoTheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total des retraits en attente: ${withdrawals.fold(0.0, (sum, w) => sum + w.amount)} FCFA',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: withdrawals.length,
                itemBuilder: (context, index) {
                  final withdrawal = withdrawals[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: HoubagoTheme.primary,
                        child: Icon(Icons.payments, color: Colors.white),
                      ),
                      title: Text(
                        '${withdrawal.amount} FCFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Demandé le: ${withdrawal.createdAt.toLocal().toString().split('.')[0]}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showDetailsDialog(context, withdrawal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green,
                            onPressed: () async {
                              await DatabaseService.updateWithdrawalStatus(
                                withdrawal.id,
                                'approved',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Retrait approuvé'),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                            onPressed: () async {
                              await DatabaseService.updateWithdrawalStatus(
                                withdrawal.id,
                                'rejected',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Retrait rejeté'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => _showDetailsDialog(context, withdrawal),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
