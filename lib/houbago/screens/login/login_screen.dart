import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rememberMe = prefs.getBool('rememberMe') ?? false;
        if (_rememberMe) {
          _phoneController.text = prefs.getString('phone') ?? '';
          final savedPin = prefs.getString('pin') ?? '';
          for (int i = 0; i < savedPin.length && i < 4; i++) {
            _pinControllers[i].text = savedPin[i];
          }
        }
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des préférences: $e');
    }
  }

  Future<void> _saveLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('phone', _phoneController.text);
        final pin = _pinControllers.map((c) => c.text).join();
        await prefs.setString('pin', pin);
      } else {
        await prefs.remove('phone');
        await prefs.remove('pin');
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des préférences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo ou Titre
              Text(
                'Houbago',
                style: HoubagoTheme.textTheme.displayMedium?.copyWith(
                  color: HoubagoTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Connectez-vous pour continuer',
                style: HoubagoTheme.textTheme.titleMedium?.copyWith(
                  color: HoubagoTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Champ téléphone
              TextField(
                controller: _phoneController,
                style: HoubagoTheme.textTheme.bodyLarge,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: HoubagoTheme.textTheme.labelLarge?.copyWith(
                    color: HoubagoTheme.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: HoubagoTheme.secondary,
                  ),
                  filled: true,
                  fillColor: HoubagoTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: HoubagoTheme.secondaryLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: HoubagoTheme.secondaryLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: HoubagoTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Code PIN
              Text(
                'Code PIN',
                style: HoubagoTheme.textTheme.labelLarge?.copyWith(
                  color: HoubagoTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _pinControllers[index],
                        focusNode: _pinFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        obscureText: true,
                        style: HoubagoTheme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: HoubagoTheme.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: HoubagoTheme.secondaryLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: HoubagoTheme.secondaryLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: HoubagoTheme.primary, width: 2),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 3) {
                              _pinFocusNodes[index + 1].requestFocus();
                            } else {
                              _pinFocusNodes[index].unfocus();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Se souvenir de moi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: HoubagoTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Se souvenir de moi',
                    style: HoubagoTheme.textTheme.bodyMedium?.copyWith(
                      color: HoubagoTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Code PIN oublié
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    // Action code PIN oublié
                  },
                  child: Text(
                    'Code PIN oublié ?',
                    style: HoubagoTheme.textTheme.labelLarge?.copyWith(
                      color: HoubagoTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // Bouton de connexion
              ElevatedButton(
                onPressed: () async {
                  // Vérifier si tous les champs du PIN sont remplis
                  bool isPinComplete = _pinControllers.every((controller) => controller.text.isNotEmpty);
                  if (isPinComplete) {
                    // Sauvegarder les informations si "Se souvenir de moi" est coché
                    await _saveLoginInfo();
                    // Redirection vers la page d'accueil
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  } else {
                    // Afficher un message d'erreur
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez entrer un code PIN complet'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HoubagoTheme.primary,
                  foregroundColor: HoubagoTheme.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Se connecter',
                  style: HoubagoTheme.buttonText,
                ),
              ),
              const SizedBox(height: 24),

              // Lien d'inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pas encore de compte ? ',
                    style: HoubagoTheme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Inscrivez-vous',
                      style: HoubagoTheme.textTheme.labelLarge?.copyWith(
                        color: HoubagoTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
