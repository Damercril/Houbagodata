import 'dart:io';
import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:image_picker/image_picker.dart';

enum DriverType { moto, car }

class AddDriverModal extends StatelessWidget {
  const AddDriverModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HoubagoTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ajouter un chauffeur',
            style: HoubagoTheme.textTheme.titleLarge,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ChoiceButton(
                icon: Icons.motorcycle,
                label: 'Chauffeur Moto',
                onTap: () => _showDriverForm(context, DriverType.moto),
              ),
              _ChoiceButton(
                icon: Icons.directions_car,
                label: 'Chauffeur Voiture',
                onTap: () => _showDriverForm(context, DriverType.car),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showDriverForm(BuildContext context, DriverType type) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DriverForm(type: type),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: HoubagoTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: HoubagoTheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: HoubagoTheme.textTheme.titleMedium?.copyWith(
                color: HoubagoTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverForm extends StatefulWidget {
  const DriverForm({
    super.key,
    required this.type,
  });

  final DriverType type;

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPhoneController = TextEditingController();
  XFile? _registrationImage;
  XFile? _licenseImage;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source, bool isRegistration) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      setState(() {
        if (isRegistration) {
          _registrationImage = image;
        } else {
          _licenseImage = image;
        }
      });
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
    }
  }

  void _showImagePicker(bool isRegistration) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isRegistration);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isRegistration);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadImage(XFile image) async {
    try {
      // Upload l'image dans le dossier 'drivers'
      return await DatabaseService.uploadImage(image, 'drivers');
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      throw Exception('Erreur lors de l\'upload de l\'image');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_registrationImage == null || _licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les deux images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('\n=== Enregistrement d\'un chauffeur ===');
      
      // Upload des images
      print('Upload de la photo...');
      final photoUrl = await DatabaseService.uploadImage(_registrationImage!, 'profile-photos');
      print('Photo URL: $photoUrl');
      
      print('Upload de la carte d\'identité...');
      final idCardUrl = await DatabaseService.uploadImage(_licenseImage!, 'id-cards');
      print('ID Card URL: $idCardUrl');

      // Enregistrer l'affilié
      print('Enregistrement de l\'affilié...');
      final success = await DatabaseService.registerAffiliate(
        firstname: _firstNameController.text,
        lastname: _lastNameController.text,
        phone: _phoneController.text,
        photoUrl: photoUrl,
        idCardUrl: idCardUrl,
      );

      if (!mounted) return;

      if (success) {
        // Fermer le formulaire
        Navigator.pop(context);
        
        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre demande a été envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erreur lors de l\'enregistrement de l\'affilié');
      }
    } catch (e) {
      print('Erreur: $e');
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: HoubagoTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nouveau chauffeur ${widget.type == DriverType.moto ? "moto" : "voiture"}',
                style: HoubagoTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  // Vérifier que le numéro commence par +225 ou 0
                  if (!value!.startsWith('+225') && !value.startsWith('0')) {
                    return 'Le numéro doit commencer par +225 ou 0';
                  }
                  // Vérifier la longueur (10 chiffres après le préfixe)
                  String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length != 10) {
                    return 'Le numéro doit contenir 10 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le numéro de téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez confirmer le numéro de téléphone';
                  }
                  if (value != _phoneController.text) {
                    return 'Les numéros de téléphone ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _ImagePickerButton(
                label: 'Photo de la carte grise',
                image: _registrationImage,
                onTap: () => _showImagePicker(true),
              ),
              const SizedBox(height: 16),
              _ImagePickerButton(
                label: 'Photo du permis de conduire',
                image: _licenseImage,
                onTap: () => _showImagePicker(false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HoubagoTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isLoading ? 'En cours...' : 'Enregistrer',
                  style: HoubagoTheme.textTheme.titleMedium?.copyWith(
                    color: HoubagoTheme.textLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _confirmPhoneController.dispose();
    super.dispose();
  }
}

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({
    required this.label,
    required this.image,
    required this.onTap,
  });

  final String label;
  final XFile? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: image != null
              ? DecorationImage(
                  image: FileImage(File(image!.path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
