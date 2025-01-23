import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/admin/pending_affiliate.dart';
import 'package:houbago/houbago/houbago_theme.dart';

class AffiliesView extends StatefulWidget {
  const AffiliesView({super.key});

  @override
  State<AffiliesView> createState() => _AffiliesViewState();
}

class _AffiliesViewState extends State<AffiliesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showDetailsDialog(BuildContext context, PendingAffiliate affiliate) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${affiliate.firstName} ${affiliate.lastName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Téléphone: ${affiliate.phone}'),
                const SizedBox(height: 8),
                Text(
                  'Date de demande: ${affiliate.createdAt.toLocal().toString().split('.')[0]}',
                ),
                const SizedBox(height: 16),
                const Text('Photo d\'identité:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (affiliate.photoIdentityUrl != null && affiliate.photoIdentityUrl!.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        affiliate.photoIdentityUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Text('Erreur de chargement')),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Non fourni')),
                  ),
                const SizedBox(height: 16),
                const Text('Photo de la licence:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (affiliate.photoLicenseUrl != null && affiliate.photoLicenseUrl!.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        affiliate.photoLicenseUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Text('Erreur de chargement')),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('Non fourni')),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAffiliateList(List<PendingAffiliate> affiliates, bool isPending) {
    final filteredAffiliates = affiliates.where((a) => 
      isPending ? a.status == 'pending' : a.status != 'pending'
    ).toList();

    if (filteredAffiliates.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'Aucun affilié en attente' : 'Aucun affilié traité',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAffiliates.length,
      itemBuilder: (context, index) {
        final affiliate = filteredAffiliates[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: HoubagoTheme.primary,
              child: Text(
                affiliate.firstName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              '${affiliate.firstName} ${affiliate.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tél: ${affiliate.phone}'),
                Text(
                  'Demande: ${affiliate.createdAt.toLocal().toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (!isPending)
                  Text(
                    'Status: ${affiliate.status == 'approved' ? 'Approuvé' : 'Rejeté'}',
                    style: TextStyle(
                      color: affiliate.status == 'approved' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showDetailsDialog(context, affiliate),
                ),
                if (isPending) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                    onPressed: () async {
                      try {
                        await DatabaseService.updateAffiliateStatusAdmin(
                          affiliateId: affiliate.id,
                          status: 'approved',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Affilié approuvé'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    color: Colors.red,
                    onPressed: () async {
                      try {
                        await DatabaseService.updateAffiliateStatusAdmin(
                          affiliateId: affiliate.id,
                          status: 'rejected',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Affilié rejeté'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ] else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      try {
                        await DatabaseService.updateAffiliateStatusAdmin(
                          affiliateId: affiliate.id,
                          status: 'pending',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demande remise en attente'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
            isThreeLine: true,
            onTap: () => _showDetailsDialog(context, affiliate),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: HoubagoTheme.primary,
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Traités'),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<PendingAffiliate>>(
            stream: DatabaseService.getAllAffiliatesAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildAffiliateList(snapshot.data!, true),
                  _buildAffiliateList(snapshot.data!, false),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
