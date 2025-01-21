import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/notification.dart';
import 'package:houbago/houbago/models/user_account.dart';
import 'package:houbago/houbago/screens/auth/login_screen.dart';
import 'package:houbago/houbago/theme/houbago_theme.dart';
import 'package:houbago/houbago/utils/currency_formatter.dart';
import 'package:houbago/houbago/widgets/earnings_chart.dart';
import 'package:houbago/houbago/widgets/notification_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = DatabaseService.getCurrentUser();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } else {
      await DatabaseService.insertTestData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      appBar: AppBar(
        title: const Text('Houbago'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Première section : Informations chauffeur
              FutureBuilder<UserAccount?>(
                future: DatabaseService.getCurrentUserAccount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final account = snapshot.data;
                  if (account == null) {
                    return const Center(child: Text('Erreur de chargement du compte'));
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HoubagoTheme.primary,
                          HoubagoTheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: HoubagoTheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec photo de profil, nom et statistiques
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo de profil et nom
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    child: Builder(
                                      builder: (context) {
                                        final user = DatabaseService.getCurrentUser();
                                        if (user == null) return const Icon(Icons.person);
                                        return Text(
                                          '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final user = DatabaseService.getCurrentUser();
                                        if (user == null) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Chargement...',
                                                style: HoubagoTheme.textTheme.titleLarge?.copyWith(
                                                  color: HoubagoTheme.textLight,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.firstName,
                                              style: HoubagoTheme.textTheme.titleLarge?.copyWith(
                                                color: HoubagoTheme.textLight,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              user.lastName,
                                              style: HoubagoTheme.textTheme.titleMedium?.copyWith(
                                                color: HoubagoTheme.textLight.withOpacity(0.9),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Statistiques
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildCompactStat(
                                    '0',
                                    'actifs',
                                    Icons.people,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  _buildCompactStat(
                                    '0',
                                    'parrainés',
                                    Icons.group_add,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Solde disponible
                        Text(
                          'Solde disponible',
                          style: HoubagoTheme.textTheme.bodyLarge?.copyWith(
                            color: HoubagoTheme.textLight.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatFCFA(account.balance),
                          style: HoubagoTheme.textTheme.headlineSmall?.copyWith(
                            color: HoubagoTheme.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Bouton de retrait en bas
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: HoubagoTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Faire un retrait'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Deuxième section : Graphique des gains
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos gains',
                      style: HoubagoTheme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Expanded(child: EarningsChart()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Troisième section : Notifications
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FutureBuilder<List<NotificationModel>>(
                  future: DatabaseService.getNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Aucune notification'),
                      );
                    }
                    return NotificationList(notifications: snapshot.data!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Déjà sur l'écran d'accueil
              break;
            case 1:
              // Navigation vers l'écran des commandes
              break;
            case 2:
              // Navigation vers l'historique
              break;
            case 3:
              // Navigation vers le compte
              Navigator.pushNamed(context, '/account');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: HoubagoTheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Commander',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: HoubagoTheme.textLight,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: HoubagoTheme.textTheme.titleMedium?.copyWith(
            color: HoubagoTheme.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: HoubagoTheme.textTheme.bodySmall?.copyWith(
            color: HoubagoTheme.textLight.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
