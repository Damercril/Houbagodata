import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houbago/houbago/screens/auth/login_screen.dart';
import 'package:houbago/houbago/screens/auth/register_screen.dart';
import 'package:houbago/houbago/screens/auth/auth_wrapper.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('\n=== Démarrage de l\'application ===');
    
    // Forcer l'orientation portrait
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    print('Chargement du fichier .env...');
    await dotenv.load();
    print('Variables d\'environnement chargées !');
    print('URL Supabase: ${dotenv.env['SUPABASE_URL']}');
    
    print('Initialisation des services...');
    // Initialiser les services
    await DatabaseService.initialize();
    print('Services initialisés avec succès !');
    
    print('Vérification des utilisateurs...');
    await DatabaseService.createTestUserIfNeeded();
    
    runApp(const MyApp());
  } catch (e) {
    print('\nErreur fatale lors du démarrage:');
    print(e);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Houbago',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: HoubagoTheme.primary,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: HoubagoTheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2,
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
