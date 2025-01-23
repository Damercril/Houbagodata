import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/affiliate.dart';
import 'package:intl/intl.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> with AutomaticKeepAliveClientMixin {
  late Future<List<Affiliate>> _affiliatesFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _affiliatesFuture = _loadAffiliates();
  }

  Future<List<Affiliate>> _loadAffiliates() async {
    try {
      // Pour le développement, créer des données de test
      await DatabaseService.insertTestData();
      
      return await DatabaseService.getMyAffiliates();
    } catch (e) {
      print('Erreur lors du chargement des affiliés: $e');
      rethrow;
    }
  }

  void _refreshAffiliates() {
    setState(() {
      _affiliatesFuture = _loadAffiliates();
    });
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

  Widget _buildAffiliateList(List<Affiliate> affiliates) {
    if (affiliates.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aucun affilié trouvé',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshAffiliates();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: affiliates.length,
        itemBuilder: (context, index) {
          final affiliate = affiliates[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${affiliate.firstName} ${affiliate.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Statut',
                    _getStatusText(affiliate.status),
                    _getStatusColor(affiliate.status),
                  ),
                  _buildInfoRow(
                    'Dernière course',
                    _formatLastRideDate(affiliate.lastRideDate),
                    Colors.black87,
                  ),
                  _buildInfoRow(
                    'Gains',
                    NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                        .format(affiliate.totalEarnings),
                    Colors.green,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AffiliateStatus status) {
    switch (status) {
      case AffiliateStatus.active:
        return Colors.green;
      case AffiliateStatus.pending:
        return Colors.orange;
      case AffiliateStatus.inactive:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon équipe'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAffiliates,
          ),
        ],
      ),
      body: FutureBuilder<List<Affiliate>>(
        future: _affiliatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Erreur lors du chargement des affiliés',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshAffiliates,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildAffiliateList(snapshot.data ?? []);
        },
      ),
    );
  }
}
