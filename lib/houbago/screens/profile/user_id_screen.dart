import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/houbago_theme.dart';

class UserIdScreen extends StatefulWidget {
  const UserIdScreen({super.key});

  @override
  State<UserIdScreen> createState() => _UserIdScreenState();
}

class _UserIdScreenState extends State<UserIdScreen> {
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await DatabaseService.getCurrentUserId();
    setState(() {
      userId = id;
      isLoading = false;
    });
  }

  Future<void> _copyToClipboard() async {
    if (userId != null) {
      await Clipboard.setData(ClipboardData(text: userId!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID copié dans le presse-papiers')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon ID Utilisateur'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : userId == null
                  ? const Text('Impossible de récupérer votre ID')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Votre ID Utilisateur :',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: HoubagoTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: HoubagoTheme.textHint),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userId!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Monospace',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: _copyToClipboard,
                                tooltip: 'Copier l\'ID',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
