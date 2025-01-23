import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/screens/main/main_screen.dart';
import 'package:houbago/houbago/screens/admin/admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Vérifier les utilisateurs au démarrage
    _checkUsers();
  }

  Future<void> _checkUsers() async {
    await DatabaseService.checkUsers();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('\n=== Tentative de connexion depuis l\'interface ===');
      print('Numéro: ${_phoneController.text.trim()}');
      print('PIN: ${_pinController.text.trim()}');

      // Essayer d'abord la connexion admin
      final adminSuccess = await DatabaseService.signInAsAdmin(
        phone: _phoneController.text.trim(),
        pin: _pinController.text.trim(),
      );

      if (adminSuccess) {
        print('\nConnexion admin réussie');
        if (!mounted) return;
        
        // Rediriger vers l'interface admin
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminScreen()),
          (route) => false,
        );
        return;
      }

      // Si ce n'est pas un admin, essayer la connexion utilisateur normale
      final success = await DatabaseService.signInWithPhone(
        _phoneController.text.trim(),
        _pinController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        final user = DatabaseService.getCurrentUser();
        if (user != null) {
          print('\nNavigation vers l\'écran principal...');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else {
          print('\nErreur: utilisateur non trouvé après la connexion');
          setState(() {
            _errorMessage = 'Erreur lors de la connexion. Veuillez réessayer.';
          });
        }
      } else {
        print('\nÉchec de la connexion');
        setState(() {
          _errorMessage = 'Numéro de téléphone ou code PIN incorrect';
        });
      }
    } catch (e) {
      print('\nErreur lors de la connexion:');
      print(e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Fermer le clavier quand on clique en dehors des champs
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO: Remplacer par le vrai logo une fois disponible
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: HoubagoTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.motorcycle_outlined,
                        size: 60,
                        color: HoubagoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Connexion',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          // Valider le numéro quand on quitte le champ
                          _formKey.currentState?.validate();
                        }
                      },
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de téléphone';
                          }
                          if (value.length != 10) {
                            return 'Le numéro doit contenir 10 chiffres';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          // Valider le PIN quand on quitte le champ
                          _formKey.currentState?.validate();
                        }
                      },
                      child: TextFormField(
                        controller: _pinController,
                        decoration: const InputDecoration(
                          labelText: 'Code PIN (4 chiffres)',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre code PIN';
                          }
                          if (value.length != 4) {
                            return 'Le code PIN doit contenir 4 chiffres';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HoubagoTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text(
                        'Pas encore de compte ? S\'inscrire',
                        style: TextStyle(
                          color: HoubagoTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
