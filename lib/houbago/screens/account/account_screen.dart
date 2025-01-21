import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/user.dart';
import 'package:houbago/houbago/screens/auth/login_screen.dart';
import 'package:houbago/houbago/theme/houbago_theme.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;

  void _copyReferralCode() {
    final user = DatabaseService.getCurrentUser();
    if (user == null) return;
    
    Clipboard.setData(ClipboardData(text: user.phone));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code de parrainage copié !'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    await DatabaseService.logout();
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DatabaseService.getCurrentUser();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Compte Yango',
                children: [
                  _buildListTile(
                    icon: Icons.business,
                    title: 'Nom du partenaire',
                    subtitle: 'Non renseigné',
                  ),
                  _buildListTile(
                    icon: Icons.calendar_today,
                    title: 'Date d\'inscription',
                    subtitle: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  ),
                  _buildListTile(
                    icon: Icons.share,
                    title: 'Code de parrainage',
                    subtitle: user.phone,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyReferralCode,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implémenter la demande de paiement
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HoubagoTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Faire une demande de paiement',
                            style: HoubagoTheme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              _buildSection(
                title: 'Préférences',
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      Icons.notifications,
                      color: HoubagoTheme.primary,
                    ),
                    title: const Text('Notifications'),
                    subtitle: const Text('Recevoir les notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              _buildSection(
                title: 'Support',
                children: [
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: 'Centre d\'aide',
                    onTap: () {
                      // TODO: Ouvrir le centre d'aide
                    },
                  ),
                  _buildListTile(
                    icon: Icons.contact_support,
                    title: 'Contacter le support',
                    onTap: () {
                      // TODO: Ouvrir le formulaire de contact
                    },
                  ),
                  _buildListTile(
                    icon: Icons.policy,
                    title: 'Politique de confidentialité',
                    onTap: () {
                      // TODO: Afficher la politique de confidentialité
                    },
                  ),
                  _buildListTile(
                    icon: Icons.delete_forever,
                    title: 'Supprimer mon compte',
                    textColor: Colors.red,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer mon compte'),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: Implémenter la suppression du compte
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              _buildSection(
                title: 'Application',
                children: [
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                  _buildListTile(
                    icon: Icons.logout,
                    title: 'Déconnexion',
                    textColor: Colors.red,
                    onTap: () async {
                      await _logout();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(HoubagoUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: HoubagoTheme.primary.withOpacity(0.1),
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: HoubagoTheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: HoubagoTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: user.phone,
                  drawText: false,
                  width: 100,
                  height: 100,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${user.firstName} ${user.lastName}',
            style: HoubagoTheme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            user.phone,
            style: HoubagoTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Text(
            title,
            style: HoubagoTheme.textTheme.titleMedium?.copyWith(
              color: HoubagoTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? HoubagoTheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                )
              : null),
      onTap: onTap,
    );
  }
}
