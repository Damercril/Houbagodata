import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/affiliate.dart';
import 'package:intl/intl.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<Affiliate> _affiliates = [];
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  @override
  void initState() {
    super.initState();
    _loadAffiliates();
  }

  Future<void> _loadAffiliates() async {
    try {
      final affiliates = await DatabaseService.getMyAffiliates();
      setState(() => _affiliates = affiliates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des affiliés')),
        );
      }
    }
  }

  String _formatLastRideDate(DateTime? date) {
    if (date == null) return 'Aucune course';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getStatusText(AffiliateStatus status) {
    switch (status) {
      case AffiliateStatus.active:
        return 'Actif';
      case AffiliateStatus.pending:
        return 'En attente';
      case AffiliateStatus.inactive:
        return 'Inactif';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon équipe')),
      body: _affiliates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _affiliates.length,
              itemBuilder: (context, index) {
                final affiliate = _affiliates[index];
                return ListTile(
                  title: Text('${affiliate.firstName} ${affiliate.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statut: ${_getStatusText(affiliate.status)}'),
                      Text('Dernière course: ${_formatLastRideDate(affiliate.lastRideDate)}'),
                      Text('Gains: ${_currencyFormat.format(affiliate.totalEarnings)}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
