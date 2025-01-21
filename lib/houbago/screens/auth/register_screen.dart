import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/user.dart';
import 'package:houbago/houbago/screens/home/home_screen.dart';
import 'package:houbago/houbago/houbago_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  String? _selectedCourse;
  String? _selectedMotoPartner;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _checkDatabaseContent();
    DatabaseService.checkTableStructure();
  }

  Future<void> _loadInitialData() async {
    try {
      final courses = await DatabaseService.getCourses();
      if (courses.isNotEmpty) {
        setState(() {
          _selectedCourse = courses[0]['id'];
        });
      }

      final partners = await DatabaseService.getMotoPartners();
      if (partners.isNotEmpty) {
        setState(() {
          _selectedMotoPartner = partners[0]['id'];
        });
      }
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  Future<void> _checkDatabaseContent() async {
    await DatabaseService.checkTableContents();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DatabaseService.registerUser(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        pin: _pinController.text.trim(),
        courseId: _selectedCourse!,
        motoPartnerId: _selectedMotoPartner,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'Code PIN (4 chiffres)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un code PIN';
                  }
                  if (value.length != 4) {
                    return 'Le code PIN doit contenir 4 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, String>>>(
                future: DatabaseService.getCourses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    print('Erreur courses: ${snapshot.error}');
                    return const Text('Erreur lors du chargement des partenaires course');
                  }
                  
                  final courses = snapshot.data ?? [];
                  print('Courses disponibles: $courses');
                  
                  if (courses.isEmpty) {
                    return const Text('Aucun partenaire course disponible');
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'Partenaire Course',
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course['id'],
                        child: Text(course['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value;
                        print('Course sélectionnée: $value');
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner un partenaire course';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, String>>>(
                future: DatabaseService.getMotoPartners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    print('Erreur moto: ${snapshot.error}');
                    return const Text('Erreur lors du chargement des partenaires moto');
                  }
                  
                  final partners = snapshot.data ?? [];
                  print('Partenaires moto disponibles: $partners');
                  
                  if (partners.isEmpty) {
                    return const Text('Aucun partenaire moto disponible');
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedMotoPartner,
                    decoration: const InputDecoration(
                      labelText: 'Partenaire Moto',
                      prefixIcon: Icon(Icons.motorcycle),
                    ),
                    items: partners.map((partner) {
                      return DropdownMenuItem(
                        value: partner['id'],
                        child: Text(partner['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMotoPartner = value;
                        print('Partenaire moto sélectionné: $value');
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner un partenaire moto';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
