import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:houbago/houbago/models/houbago_user.dart';
import 'package:houbago/houbago/models/affiliate.dart';
import 'package:houbago/houbago/models/notification.dart';
import 'package:houbago/houbago/models/earnings.dart';
import 'package:houbago/houbago/models/earnings_item.dart';
import 'package:houbago/houbago/models/daily_earning.dart';
import 'package:houbago/houbago/models/support_request.dart';
import 'package:houbago/houbago/models/admin/pending_affiliate.dart';
import 'package:houbago/houbago/models/admin/pending_withdrawal.dart';
import 'package:houbago/houbago/models/user_account.dart';
import 'package:houbago/houbago/models/driver.dart';
import 'package:houbago/houbago/models/driver_detail.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:houbago/houbago/config/supabase_config.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseService {
  static late SupabaseClient _supabase;
  static HoubagoUser? _currentUser;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        authFlowType: AuthFlowType.implicit,
      );
      _supabase = Supabase.instance.client;
      print('Supabase initialisé avec succès');
      
      // Exécuter les migrations
      await runMigrations();
    } catch (e) {
      print('Erreur lors de l\'initialisation de Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get supabase => _supabase;

  static HoubagoUser? getCurrentUser() {
    return _currentUser;
  }

  static Future<String?> getCurrentUserId() async {
    print('=== getCurrentUserId ===');
    try {
      final session = _supabase.auth.currentSession;
      print('Session Supabase: ${session?.toJson()}');
      
      if (session == null) {
        print('Erreur: Pas de session active');
        return null;
      }

      final userId = session.user.id;
      print('UserId trouvé: $userId');
      return userId;
    } catch (e, stackTrace) {
      print('=== ERREUR dans getCurrentUserId ===');
      print('Message d\'erreur: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> setCurrentUser(HoubagoUser? user) async {
    print('=== setCurrentUser ===');
    print('User à définir: ${user?.toJson()}');
    _currentUser = user;
    print('_currentUser défini: ${_currentUser?.toJson()}');
  }

  static Future<void> createTestUserIfNeeded() async {
    // Ne rien faire, nous n'avons plus besoin d'utilisateur test
    return;
  }

  static Future<void> createAdminIfNeeded() async {
    try {
      print('\n=== Vérification/Création Admin ===');
      final admin = await _supabase
          .from('admins')
          .select()
          .eq('phone', '+225 0652262798')
          .maybeSingle();

      print('Admin existant: $admin');

      if (admin == null) {
        print('Création d\'un nouvel admin...');
        await _supabase.from('admins').insert({
          'first_name': 'Admin',
          'last_name': 'Houbago',
          'phone': '+225 0652262798',
          'pin': '0909',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Admin créé avec succès');
      }
    } catch (e) {
      print('Erreur lors de la création de l\'admin: $e');
    }
  }

  static Future<void> createDefaultUserIfNeeded() async {
    try {
      print('\n=== Vérification/Création Utilisateur par défaut ===');
      final user = await _supabase
          .from('users')
          .select()
          .eq('phone', '0757176576')
          .maybeSingle();

      print('Utilisateur existant: $user');

      if (user == null) {
        print('Création d\'un nouvel utilisateur...');
        await _supabase.from('users').insert({
          'first_name': 'Houbago',
          'last_name': 'User',
          'phone': '0757176576',
          'pin': '1111',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Utilisateur créé avec succès');
      }
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  static Future<void> checkUsers() async {
    try {
      await createAdminIfNeeded();
      await createDefaultUserIfNeeded();
      
      final users = await _supabase.from('users').select();
      print('Nombre d\'utilisateurs: ${users.length}');
    } catch (e) {
      print('Erreur lors de la vérification des utilisateurs: $e');
    }
  }

  static Future<HoubagoUser?> signInWithPhoneAndPin(String phone, String pin) async {
    try {
      print('\n=== Tentative de connexion ===');
      print('Téléphone: $phone');
      print('PIN: $pin');

      // Vérifier le contenu des tables
      print('\n=== Contenu des tables ===');
      final admins = await _supabase.from('admins').select();
      final users = await _supabase.from('users').select();
      print('Admins dans la base: $admins');
      print('Users dans la base: $users');

      // Essayer d'abord de se connecter en tant qu'admin
      try {
        print('\n=== Tentative connexion admin ===');
        final adminResponse = await _supabase
            .from('admins')
            .select()
            .eq('phone', phone)
            .eq('pin', pin)
            .maybeSingle();

        print('Réponse admin: $adminResponse');

        if (adminResponse != null) {
          print('Admin trouvé: $adminResponse');
          _currentUser = HoubagoUser(
            id: adminResponse['id'],
            firstname: adminResponse['first_name'] ?? 'Admin',
            lastname: adminResponse['last_name'] ?? 'Houbago',
            phone: phone,
            balance: 0,
          );
          return _currentUser;
        }
      } catch (e) {
        print('Erreur connexion admin: $e');
      }

      // Si ce n'est pas un admin, essayer en tant qu'utilisateur
      try {
        print('\n=== Tentative connexion utilisateur ===');
        final userResponse = await _supabase
            .from('users')
            .select()
            .eq('phone', phone)
            .eq('pin', pin)
            .maybeSingle();

        print('Réponse utilisateur: $userResponse');

        if (userResponse != null) {
          print('Utilisateur trouvé: $userResponse');
          _currentUser = HoubagoUser(
            id: userResponse['id'],
            firstname: userResponse['first_name'] ?? '',
            lastname: userResponse['last_name'] ?? '',
            phone: phone,
            balance: 0,
          );
          return _currentUser;
        }
      } catch (e) {
        print('Erreur connexion utilisateur: $e');
      }

      // Si on arrive ici, ni admin ni utilisateur trouvé
      print('Aucun compte trouvé avec ces identifiants');
      return null;

    } catch (e, stackTrace) {
      print('Erreur lors de la connexion:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<void> signOut() async {
    _currentUser = null;
  }

  static Future<void> checkTableStructure() async {
    try {
      print('\n=== Vérification de la structure des tables ===');
      await _supabase.from('users').select().limit(1);
      await _supabase.from('earnings').select().limit(1);
      await _supabase.from('course_partners').select().limit(1);
      await _supabase.from('moto_partners').select().limit(1);
      print('Structure des tables vérifiée avec succès');
    } catch (e, stackTrace) {
      print('=== ERREUR lors de la vérification de la structure ===');
      print('Message d\'erreur: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static Future<void> checkTableContents() async {
    try {
      final users = await _supabase.from('users').select();
      final earnings = await _supabase.from('earnings').select();
      final partners = await _supabase.from('moto_partners').select();

      print('Contenu des tables:');
      print('Users: ${users.length}');
      print('Earnings: ${earnings.length}');
      print('Partners: ${partners.length}');
    } catch (e) {
      print('Erreur lors de la vérification du contenu: $e');
    }
  }

  static Future<List<Map<String, String>>> getCourses() async {
    try {
      print('\n=== Récupération des partenaires course ===');
      final response = await _supabase
          .from('course_partners')
          .select()
          .order('created_at', ascending: false);

      print('Réponse: $response');

      return (response as List).map((item) => {
        'id': item['id'].toString(),
        'name': item['name'].toString(),
      }).toList();
    } catch (e, stackTrace) {
      print('=== ERREUR lors de la récupération des partenaires course ===');
      print('Message d\'erreur: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final response = await _supabase
          .from('drivers')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des chauffeurs: $e');
      return [];
    }
  }

  static Future<List<Map<String, String>>> getMotoPartners() async {
    try {
      print('\n=== Récupération des partenaires moto ===');
      final response = await _supabase
          .from('moto_partners')
          .select()
          .order('created_at', ascending: false);

      print('Réponse: $response');

      return (response as List).map((item) => {
        'id': item['id'].toString(),
        'name': item['name'].toString(),
      }).toList();
    } catch (e, stackTrace) {
      print('=== ERREUR lors de la récupération des partenaires moto ===');
      print('Message d\'erreur: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<bool> registerUser({
    required String firstname,
    required String lastname,
    required String phone,
    required String pin,
  }) async {
    try {
      print('\n=== Inscription nouvel utilisateur ===');
      print('Prénom: $firstname');
      print('Nom: $lastname');
      print('Téléphone: $phone');

      // Vérifier si l'utilisateur existe déjà
      final existingUsers = await _supabase
          .from('users')
          .select()
          .eq('phone', phone);
      
      print('Utilisateurs existants avec ce numéro: ${existingUsers.length}');
      
      if (existingUsers.isNotEmpty) {
        print('Un utilisateur existe déjà avec ce numéro');
        return false;
      }

      final newUser = {
        'first_name': firstname,
        'last_name': lastname,
        'phone': phone,
        'pin': pin,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Données à insérer: $newUser');

      final response = await _supabase
          .from('users')
          .insert(newUser)
          .select()
          .single();

      print('Réponse inscription: $response');

      if (response != null) {
        _currentUser = HoubagoUser(
          id: response['id'],
          firstname: response['first_name'],
          lastname: response['last_name'],
          phone: phone,
          balance: 0,
        );

        print('Utilisateur créé: ${_currentUser?.toJson()}');
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      print('=== ERREUR lors de l\'inscription ===');
      print('Message d\'erreur: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<UserAccount?> getCurrentUserAccount() async {
    try {
      final user = _currentUser;
      if (user == null) return null;

      // Pour les admins, créer un compte factice
      final isAdmin = await checkIsAdmin();
      if (isAdmin) {
        return UserAccount(
          id: user.id,
          userId: user.id,
          balance: 0,
          referralCode: '',
          createdAt: DateTime.now(),
        );
      }

      // Pour les utilisateurs normaux, récupérer depuis la base
      final response = await _supabase
          .from('user_accounts')
          .select()
          .eq('user_id', user.id)
          .single();

      if (response == null) return null;

      return UserAccount.fromJson(response);
    } catch (e) {
      print('Erreur lors de la récupération du compte: $e');
      return null;
    }
  }

  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    final code = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return code;
  }

  static Future<List<NotificationModel>> getNotifications({bool unreadOnly = false}) async {
    try {
      final userId = _currentUser?.id;
      print('getNotifications - userId: $userId');
      if (userId == null) return [];

      var query = _supabase
          .from('notifications')
          .select();

      if (unreadOnly) {
        query = query.match({'read': false});
      }

      final response = await query
          .match({'user_id': userId})
          .order('created_at', ascending: false);

      print('getNotifications - response: $response');

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des notifications: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getDailyEarnings() async {
    try {
      final userId = _currentUser?.id;
      print('getDailyEarnings - userId: $userId');
      if (userId == null) return [];

      // Récupérer les gains des 7 derniers jours
      final response = await _supabase
          .from('earnings')
          .select('amount, created_at')
          .eq('user_id', userId)
          .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('created_at', ascending: true);

      print('getDailyEarnings - response: $response');

      // Grouper les gains par jour
      final Map<String, double> dailyTotals = {};
      for (var earning in response) {
        final date = DateTime.parse(earning['created_at']).toLocal();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + (earning['amount'] as num).toDouble();
      }

      print('getDailyEarnings - dailyTotals: $dailyTotals');

      // Créer la liste des 7 derniers jours avec les gains
      final List<Map<String, dynamic>> result = [];
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        result.add({
          'date': date.toIso8601String(),
          'amount': dailyTotals[dateKey] ?? 0.0,
        });
      }

      print('getDailyEarnings - result: $result');
      return result;
    } catch (e) {
      print('Erreur lors de la récupération des gains: $e');
      return [];
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('Erreur lors du marquage de la notification: $e');
    }
  }

  static Future<void> insertTestData() async {
    try {
      print('insertTestData - début');
      // Insérer un utilisateur de test s'il n'existe pas déjà
      final testUser = await _supabase
          .from('users')
          .select()
          .eq('phone', '+225 0123456789')
          .maybeSingle();

      print('insertTestData - testUser: $testUser');

      String userId;
      if (testUser == null) {
        final response = await _supabase
            .from('users')
            .insert({
              'firstname': 'John',
              'lastname': 'Doe',
              'phone': '+225 0123456789',
              'pin': '1234',
              'balance': 0.0,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        userId = response['id'];
        print('insertTestData - nouvel utilisateur créé avec id: $userId');
      } else {
        userId = testUser['id'];
        print('insertTestData - utilisateur existant avec id: $userId');
      }

      // Insérer des gains de test pour les 7 derniers jours
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final amount = (15000 + (math.Random().nextDouble() * 20000));
        await _supabase.from('earnings').insert({
          'user_id': userId,
          'amount': amount,
          'created_at': date.toIso8601String(),
        });
        print('insertTestData - gain inséré: $amount FCFA pour le ${date.toIso8601String()}');
      }

      // Insérer des notifications de test
      await _supabase.from('notifications').insert([
        {
          'user_id': userId,
          'title': 'Nouveau gain',
          'message': 'Vous avez reçu 25000 FCFA',
          'type': 'earning',
          'read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'user_id': userId,
          'title': 'Nouvelle affiliation',
          'message': 'Un nouveau chauffeur vous a rejoint',
          'type': 'affiliation',
          'read': false,
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);

      print('insertTestData - notifications insérées');
      print('Données de test insérées avec succès');
    } catch (e) {
      print('Erreur lors de l\'insertion des données de test: $e');
    }
  }

  static Future<void> logout() async {
    _currentUser = null;
    await supabase.auth.signOut();
  }

  static Stream<List<Affiliate>> getAffiliates(String userId) {
    print('=== getAffiliates pour userId: $userId ===');
    return _supabase
        .from('affiliates')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
      print('Données reçues de Supabase: $data');
      return data.map<Affiliate>((json) {
        print('Conversion de JSON en Affiliate: $json');
        return Affiliate.fromJson(json);
      }).toList();
    });
  }

  static Future<Affiliate> addAffiliate({
    required String firstname,
    required String lastname,
    required String phone,
    required String driverType,
    required String photoIdentityUrl,
    required String photoLicenseUrl,
  }) async {
    try {
      print('\n=== DÉBUT addAffiliate ===');
      print('Paramètres reçus:');
      print('- firstname: $firstname');
      print('- lastname: $lastname');
      print('- phone: $phone');
      print('- driverType: $driverType');
      print('- photoIdentityUrl: $photoIdentityUrl');
      print('- photoLicenseUrl: $photoLicenseUrl');

      // 1. Vérifier l'utilisateur
      final userId = await getCurrentUserId();
      print('\n=== Vérification de l\'utilisateur ===');
      print('userId obtenu: $userId');
      
      if (userId == null) {
        print('❌ Erreur: Utilisateur non connecté');
        throw Exception('Utilisateur non connecté');
      }
      print('✓ Utilisateur connecté');

      // 2. Préparer les données
      print('\n=== Préparation des données ===');
      final data = {
        'user_id': userId,
        'first_name': firstname,
        'last_name': lastname,
        'phone': phone,
        'driver_type': driverType,
        'photo_identity_url': photoIdentityUrl,
        'photo_license_url': photoLicenseUrl,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('Données préparées: $data');

      // 3. Insérer dans Supabase
      print('\n=== Insertion dans Supabase ===');
      print('Envoi de la requête...');
      final response = await _supabase
          .from('affiliates')
          .insert(data)
          .select()
          .single();
      print('Réponse de Supabase: $response');

      // 4. Vérifier la réponse
      print('\n=== Vérification de la réponse ===');
      if (response == null) {
        print('❌ Erreur: Réponse null de Supabase');
        throw Exception('Erreur lors de l\'ajout du chauffeur');
      }
      print('✓ Réponse reçue');

      // 5. Vérifier l'insertion
      print('\n=== Vérification de l\'insertion ===');
      final inserted = await _supabase
          .from('affiliates')
          .select()
          .eq('id', response['id'])
          .single();
      
      if (inserted == null) {
        print('❌ Erreur: Impossible de trouver l\'affilié inséré');
        throw Exception('Erreur: Les données n\'ont pas été sauvegardées');
      }
      print('✓ Données trouvées dans la base');

      // 6. Créer l'objet Affiliate
      print('\n=== Création de l\'objet Affiliate ===');
      final affiliate = Affiliate.fromJson(response);
      print('Affiliate créé: ${affiliate.toJson()}');
      print('=== FIN addAffiliate (succès) ===\n');

      return affiliate;
    } catch (e, stackTrace) {
      print('\n=== ERREUR dans addAffiliate ===');
      print('Message d\'erreur: $e');
      print('Stack trace: $stackTrace');

      if (e.toString().contains('auth') || e.toString().contains('JWT')) {
        print('❌ Erreur d\'authentification');
        throw Exception('Erreur d\'authentification. Veuillez vous reconnecter.');
      }
      
      if (e.toString().contains('violates foreign key constraint')) {
        print('❌ Erreur de clé étrangère');
        throw Exception('Erreur: L\'utilisateur n\'existe pas dans la base de données.');
      }

      if (e.toString().contains('policy')) {
        print('❌ Erreur de politique RLS');
        throw Exception('Erreur: Vous n\'avez pas les permissions nécessaires.');
      }

      print('=== FIN addAffiliate (échec) ===\n');
      rethrow;
    }
  }

  static Future<void> updateAffiliateStatus({
    required String affiliateId,
    required String status,
  }) async {
    try {
      final response = await _supabase
          .from('affiliates')
          .update({'status': status})
          .eq('id', affiliateId)
          .select();
      
      print('Update affiliate status response: $response');
      
      // Récupérer les détails de l'affilié
      final affiliate = await _supabase
          .from('affiliates')
          .select()
          .eq('id', affiliateId)
          .single();
      
      // Créer une notification pour l'utilisateur
      await _supabase.from('notifications').insert({
        'user_id': affiliate['user_id'],
        'title': 'Statut mis à jour',
        'message': 'Le statut de votre chauffeur a été mis à jour à $status',
        'type': 'affiliate_status_update',
        'data': {'status': status},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      print('Error updating affiliate status: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Affiliate>> getPendingAffiliates() async {
    try {
      final stream = _supabase
          .from('affiliates')
          .stream(primaryKey: ['id'])
          .eq('status', 'pending')
          .map((data) {
        print('Received pending affiliates data: $data');
        return data
            .map<Affiliate>((json) => Affiliate.fromJson(json))
            .toList();
      });

      return stream.first;
    } catch (e, stackTrace) {
      print('Error getting pending affiliates: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAdminAffiliates() async {
    final currentAdmin = _currentUser;
    if (currentAdmin == null) {
      throw Exception('Admin non connecté');
    }

    final response = await _supabase
        .from('affiliates')
        .select('''
          *,
          sponsor:user_id (
            firstname,
            lastname,
            phone
          )
        ''')
        .order('created_at', ascending: false);

    return response;
  }

  static Stream<List<PendingAffiliate>> getPendingAffiliatesAdmin() {
    try {
      return _supabase
          .from('affiliates')
          .stream(primaryKey: ['id'])
          .eq('status', 'pending')
          .map((list) {
        print('Received affiliates data: $list'); // Debug
        return list
            .map((data) => PendingAffiliate(
                  id: data['id'] as String,
                  userId: data['user_id'] as String,
                  firstname: data['firstname'] as String,
                  lastname: data['lastname'] as String,
                  phone: data['phone'] as String,
                  status: data['status'] as String,
                  createdAt: DateTime.parse(data['created_at'] as String),
                ))
            .toList();
      });
    } catch (e, stackTrace) {
      print('Error getting pending affiliates: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Stream<List<PendingWithdrawal>> getPendingWithdrawals() {
    return _supabase
        .from('withdrawals')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at')
        .map((data) => data
            .map((json) => PendingWithdrawal.fromJson(json))
            .toList());
  }

  static Future<void> updateAffiliateStatusAdmin({
    required String affiliateId,
    required String status,
  }) async {
    final currentAdmin = _currentUser;
    if (currentAdmin == null) {
      throw Exception('Admin non connecté');
    }

    await _supabase.from('affiliates').update({
      'status': status,
      'admin_id': currentAdmin.id,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', affiliateId);

    // Récupérer les informations de l'affilié
    final affiliate = await _supabase
        .from('affiliates')
        .select('*, sponsor:user_id(*)')
        .eq('id', affiliateId)
        .single();

    // Créer une notification pour le parrain
    await _supabase.from('notifications').insert({
      'user_id': affiliate['sponsor_id'],
      'title': 'Statut du chauffeur mis à jour',
      'message': '''
Le statut de votre chauffeur ${affiliate['firstname']} ${affiliate['lastname']} a été mis à jour à "${status == 'active' ? 'Actif' : 'Refusé'}"
''',
      'type': 'driver_status_update',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateWithdrawalStatus(String id, String status) async {
    await _supabase
        .from('withdrawals')
        .update({
          'status': status,
          'admin_id': _currentUser?.id,
          'processed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  static Future<void> createSupportRequest({
    required String subject,
    required String message,
    String? audioUrl,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final supportRequest = await _supabase
        .from('support_requests')
        .insert({
          'user_id': user.id,
          'subject': subject,
          'message': message,
          'audio_url': audioUrl,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    // Créer une notification pour l'administrateur
    await _createAdminNotification(
      title: 'Nouvelle demande de support',
      message: '''De: ${user.phone}
Sujet: $subject''',
      type: 'new_support_request',
    );
  }

  static Stream<List<SupportRequest>> getSupportRequests() {
    return _supabase
        .from('support_requests')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data
            .map((json) => SupportRequest.fromJson(json))
            .toList());
  }

  static Future<void> updateSupportRequest(
    String id, {
    String? status,
    String? adminResponse,
  }) async {
    final updates = <String, dynamic>{
      if (status != null) 'status': status,
      if (adminResponse != null) 'admin_response': adminResponse,
      'admin_id': _currentUser?.id,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase
        .from('support_requests')
        .update(updates)
        .eq('id', id);
  }

  static Future<bool> requestPayment({required double amount}) async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return false;

      // Vérifier que le montant ne dépasse pas le solde
      if (amount > (_currentUser?.balance ?? 0)) {
        return false;
      }

      // Créer la demande de paiement
      await _supabase.from('payment_requests').insert({
        'user_id': userId,
        'amount': amount,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Créer une notification
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'Demande de paiement',
        'message': 'Votre demande de paiement de ${amount.toStringAsFixed(2)} FCFA a été envoyée. Nous la traiterons dans les plus brefs délais.',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Erreur lors de la demande de paiement: $e');
      return false;
    }
  }

  static Future<bool> requestWithdrawal({required double amount}) async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return false;

      // Vérifier que le montant ne dépasse pas le solde
      if (amount > (_currentUser?.balance ?? 0)) {
        return false;
      }

      // Créer la demande de retrait
      await _supabase.from('withdrawals').insert({
        'user_id': userId,
        'amount': amount,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Créer une notification
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': 'Demande de retrait',
        'message': 'Votre demande de retrait de ${amount.toStringAsFixed(2)} FCFA a été envoyée. Nous la traiterons dans les plus brefs délais.',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Erreur lors de la demande de retrait: $e');
      return false;
    }
  }

  static Future<bool> signInAsAdmin({
    required String phone,
    required String pin,
  }) async {
    try {
      print('\n=== Tentative de connexion admin ===');
      print('Téléphone: $phone');
      print('PIN: $pin');

      // Vérifier d'abord la structure de la table
      print('\n=== Vérification de la structure de la table admins ===');
      final tableData = await _supabase
          .from('admins')
          .select()
          .limit(1);
      print('Structure de la table: $tableData');

      // Faire la requête de connexion
      print('\n=== Requête de connexion admin ===');
      final response = await _supabase
          .from('admins')
          .select()
          .eq('phone', phone)
          .eq('pin', pin)
          .single();

      print('Response data: $response');

      if (response == null) {
        print('Aucun admin trouvé avec ces identifiants');
        return false;
      }

      // Stocker les informations de l'admin
      print('Données admin trouvées: $response');
      
      _currentUser = HoubagoUser(
        id: response['id'],
        firstname: response['first_name'],
        lastname: response['last_name'],
        phone: phone,
        balance: 0,
      );
      
      print('Admin connecté avec succès:');
      print('- Admin: ${_currentUser?.toJson()}');
      
      return true;
    } catch (e, stackTrace) {
      print('Erreur lors de la connexion admin: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<bool> checkIsAdmin() async {
    try {
      final admin = await _supabase
          .from('admins')
          .select()
          .eq('phone', '+225 0652262798')
          .eq('pin', '0909')
          .maybeSingle();

      return admin != null;
    } catch (e) {
      print('Erreur lors de la vérification admin: $e');
      return false;
    }
  }

  static Future<bool> isCurrentUserAdmin() async {
    try {
      if (_currentUser == null) return false;

      final admin = await _supabase
          .from('admins')
          .select()
          .eq('phone', _currentUser?.phone)
          .eq('pin', '0909')
          .maybeSingle();

      return admin != null;
    } catch (e) {
      print('Erreur lors de la vérification admin: $e');
      return false;
    }
  }

  static Future<bool> isCurrentUserSponsor() async {
    // Tout le monde est sponsor
    return true;
  }

  static Future<void> setCurrentUserAsSponsor() async {
    // Ne rien faire, tout le monde est sponsor
    return;
  }

  static Future<void> debugCheckTableStructure() async {
    try {
      print('\n=== Vérification de la structure de la table ===');
      final result = await supabase.rpc('get_table_info', params: {'table_name': 'affiliates'});
      print('Colonnes de la table affiliates:');
      for (var column in result) {
        print('${column['column_name']}: ${column['data_type']}');
      }
    } catch (e) {
      print('Erreur lors de la vérification de la structure: $e');
    }
  }

  static Future<bool> registerAffiliate({
    required String firstname,
    required String lastname,
    required String phone,
    required String photoUrl,
    required String idCardUrl,
  }) async {
    try {
      print('\n=== Enregistrement d\'un affilié ===');
      print('Prénom: $firstname');
      print('Nom: $lastname');
      print('Téléphone: $phone');
      print('Photo URL: $photoUrl');
      print('ID Card URL: $idCardUrl');

      // Vérifier la structure de la table avant l'insertion
      await debugCheckTableStructure();

      final response = await supabase.from('affiliates').insert({
        'first_name': firstname,
        'last_name': lastname,
        'phone': phone,
        'photo_identity_url': photoUrl,
        'photo_license_url': idCardUrl,
        'status': 'pending',
        'driver_type': 'moto', // ou 'car' selon le type
      }).select();

      print('Réponse: $response');
      return true;
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'affilié: $e');
      rethrow;
    }
  }

  static Future<void> debugCheckPendingAffiliates() async {
    try {
      final response = await _supabase
          .from('affiliates')
          .select()
          .eq('status', 'pending');
      
      print('Pending affiliates:');
      print(response);
      
      // Vérifier aussi la table users pour les détails
      if (response.isNotEmpty) {
        for (var affiliate in response) {
          final userId = affiliate['user_id'];
          final user = await _supabase
              .from('users')
              .select()
              .eq('id', userId)
              .single();
          print('User details for affiliate ${affiliate['id']}:');
          print(user);
        }
      }
    } catch (e, stackTrace) {
      print('Error checking pending affiliates: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static Future<void> runMigrations() async {
    try {
      print('Running migrations...');
      
      // Exécuter les migrations
      await _supabase.rpc('handle_migrations');
      
      print('Migrations completed successfully');
    } catch (e, stackTrace) {
      print('Error running migrations: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> _createAdminNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final admins = await _supabase.from('admins').select('id');
    
    for (final admin in admins) {
      await _supabase.from('admin_notifications').insert({
        'admin_id': admin['id'],
        'title': title,
        'message': message,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getAdminNotifications({
    bool unreadOnly = false,
  }) async {
    final currentAdmin = _currentUser;
    if (currentAdmin == null) {
      throw Exception('Admin non connecté');
    }

    var query = _supabase
        .from('admin_notifications')
        .select();

    if (unreadOnly) {
      query = query.match({'read': false});
    }

    final response = await query
        .match({'admin_id': currentAdmin.id})
        .order('created_at', ascending: false);

    return response;
  }

  static Future<void> markAdminNotificationAsRead(String notificationId) async {
    final currentAdmin = _currentUser;
    if (currentAdmin == null) {
      throw Exception('Admin non connecté');
    }

    await _supabase
        .from('admin_notifications')
        .update({'read': true})
        .eq('id', notificationId)
        .eq('admin_id', currentAdmin.id);
  }

  static Future<String> uploadAudioFile(File file) async {
    try {
      final user = _currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final fileName = 'audio_messages/${user.id}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final bytes = await file.readAsBytes();
      
      // Upload du fichier
      await _supabase
          .storage
          .from('support_files')
          .uploadBinary(fileName, bytes);

      // Récupération de l'URL publique
      final String audioUrl = _supabase
          .storage
          .from('support_files')
          .getPublicUrl(fileName);

      return audioUrl;
    } catch (e, stackTrace) {
      print('Error uploading audio file: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String> uploadImage(XFile file, String bucket) async {
    try {
      print('\n=== Upload de l\'image ===');
      print('Bucket: $bucket');
      print('Fichier: ${file.path}');

      // Lire le contenu du fichier
      final bytes = await file.readAsBytes();
      
      // Générer un nom unique
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Nom du fichier: $fileName');
      print('Taille: ${bytes.length} bytes');

      // Upload le fichier
      await supabase.storage.from(bucket).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
        ),
      );

      // Obtenir l'URL publique
      final url = supabase.storage.from(bucket).getPublicUrl(fileName);
      print('URL: $url');
      
      return url;
    } catch (e, stackTrace) {
      print('Erreur lors de l\'upload:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // Vérifie si c'est l'admin avec le PIN 0909
      final userId = await getCurrentUserId();
      if (userId == null) return [];

      final adminCheck = await _supabase
          .from('admins')
          .select()
          .eq('id', userId)
          .eq('pin', '0909')
          .maybeSingle();

      if (adminCheck == null) {
        print('Accès non autorisé: utilisateur non admin ou mauvais PIN');
        return [];
      }

      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      return [];
    }
  }

  static Future<bool> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId != userId) {
        print('Accès non autorisé: impossible de modifier un autre utilisateur');
        return false;
      }

      final updates = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  static Future<bool> isMainAdmin() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return false;

      final adminCheck = await _supabase
          .from('admins')
          .select()
          .eq('id', userId)
          .eq('pin', '0909')
          .maybeSingle();

      return adminCheck != null;
    } catch (e) {
      print('Erreur lors de la vérification admin: $e');
      return false;
    }
  }

  static Future<bool> isRegularUser() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return false;

      final userCheck = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .eq('pin', '1111')
          .maybeSingle();

      return userCheck != null;
    } catch (e) {
      print('Erreur lors de la vérification utilisateur: $e');
      return false;
    }
  }
}
