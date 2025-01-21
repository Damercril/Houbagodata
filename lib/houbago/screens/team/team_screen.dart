import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/models/affiliate.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:intl/intl.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  Future<List<Affiliate>>? _affiliatesFuture;

  @override
  void initState() {
    super.initState();
    _loadAffiliates();
  }

  void _loadAffiliates() {
    setState(() {
      _affiliatesFuture = DatabaseService.getAffiliates();
    });
  }

  void _showAddAffiliateDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un affilié'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final affiliate = await DatabaseService.addAffiliate(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  phone: phoneController.text,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  if (affiliate != null) {
                    _loadAffiliates();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Affilié ajouté avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de l\'ajout de l\'affilié'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      appBar: AppBar(
        backgroundColor: HoubagoTheme.background,
        title: const Text('Mon équipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddAffiliateDialog,
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
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final affiliates = snapshot.data ?? [];

          if (affiliates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aucun affilié dans votre équipe',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddAffiliateDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Ajouter un affilié'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: affiliates.length,
            itemBuilder: (context, index) {
              final affiliate = affiliates[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      affiliate.firstName[0] + affiliate.lastName[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    affiliate.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(affiliate.phone),
                      const SizedBox(height: 4),
                      Text(
                        'Inscrit le ${DateFormat('dd/MM/yyyy').format(affiliate.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: _buildStatusChip(affiliate.status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(AffiliateStatus status) {
    Color color;
    switch (status) {
      case AffiliateStatus.pending:
        color = Colors.orange;
        break;
      case AffiliateStatus.active:
        color = Colors.green;
        break;
      case AffiliateStatus.inactive:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
