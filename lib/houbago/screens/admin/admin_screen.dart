import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/models/houbago_user.dart';
import 'package:houbago/houbago/screens/admin/views/service_client_view.dart';
import 'package:houbago/houbago/screens/admin/views/affilies_view.dart';
import 'package:houbago/houbago/screens/admin/views/retraits_view.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  HoubagoUser? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = DatabaseService.getCurrentUser();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await DatabaseService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Service Client';
      case 1:
        return 'Affiliés';
      case 2:
        return 'Retraits';
      default:
        return 'Administration';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: HoubagoTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: const [
                ServiceClientView(),
                AffiliesView(),
                RetraitsView(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 1; // Aller à l'onglet Affiliés
          });
        },
        backgroundColor: HoubagoTheme.primary,
        child: const Icon(Icons.people),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.support_agent,
                color: _selectedIndex == 0 ? HoubagoTheme.primary : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            const SizedBox(width: 48), // Espace pour le FAB
            IconButton(
              icon: Icon(
                Icons.payments,
                color: _selectedIndex == 2 ? HoubagoTheme.primary : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
