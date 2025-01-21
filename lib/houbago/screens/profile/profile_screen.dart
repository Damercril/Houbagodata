import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/screens/profile/user_id_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Mon ID Utilisateur'),
            subtitle: const Text('Voir mon identifiant unique'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserIdScreen(),
                ),
              );
            },
          ),
          // Autres options du profil à ajouter ici
        ],
      ),
    );
  }
}
