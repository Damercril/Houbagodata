import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/screens/auth/login_screen.dart';
import 'package:houbago/houbago/screens/main/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DatabaseService.getCurrentUser();
    
    if (user == null) {
      return const LoginScreen();
    }
    
    return const MainScreen();
  }
}
