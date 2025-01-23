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
      
      // Vérifier les utilisateurs
      await checkUsers();
      
      print('Initialisation terminée avec succès');
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
          .eq('phone', '0652262798')
          .maybeSingle();

      print('Admin existant: $admin');

      if (admin == null) {
        print('Création d\'un nouvel admin...');
        await _supabase.from('admins').insert({
          'first_name': 'Admin',
          'last_name': 'Houbago',
          'phone': '0652262798',
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

  static Future<bool> signInWithPhone(String phone, String pin) async {
    try {
      print('\n=== Tentative de connexion ===');
      print('Téléphone: $phone');
      print('PIN: $pin');

      // Normaliser le numéro de téléphone
      final normalizedPhone = _normalizePhoneNumber(phone);
      print('Numéro normalisé: $normalizedPhone');

      // Vérifier si l'utilisateur existe dans auth.users
      final authUser = await _supabase.auth.signInWithPassword(
        email: '$normalizedPhone@houbago.com',
        password: pin,
      );

      if (authUser.user == null) {
        print('Échec de l\'authentification');
        return false;
      }

      print('Utilisateur authentifié: ${authUser.user!.id}');

      // Vérifier si l'utilisateur existe dans la table users
      final userData = await _supabase
          .from('users')
          .select()
          .eq('phone', normalizedPhone)
          .single();

      if (userData == null) {
        print('Création de l\'utilisateur dans la table users');
        // Créer l'utilisateur dans la table users avec le même ID que auth.users
        await _supabase.from('users').insert({
          'id': authUser.user!.id,
          'phone': normalizedPhone,
          'first_name': 'Utilisateur',
          'last_name': normalizedPhone,
          'pin': pin,
          'balance': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Récupérer les données de l'utilisateur créé
        final newUserData = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.user!.id)
          .single();
        
        _currentUser = HoubagoUser(
          id: newUserData['id'],
          firstName: newUserData['first_name'],
          lastName: newUserData['last_name'],
          phone: normalizedPhone,
          balance: newUserData['balance'] ?? 0,
          createdAt: DateTime.parse(newUserData['created_at']),
        );
      } else {
        _currentUser = HoubagoUser(
          id: userData['id'],
          firstName: userData['first_name'],
          lastName: userData['last_name'],
          phone: normalizedPhone,
          balance: userData['balance'] ?? 0,
          createdAt: DateTime.parse(userData['created_at']),
        );
      }

      print('Utilisateur connecté avec succès: ${_currentUser?.id}');
      return true;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
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
      print('\n=== Inscription d\'un nouvel utilisateur ===');
      print('Prénom: $firstname');
      print('Nom: $lastname');
      print('Téléphone: $phone');

      final normalizedPhone = _normalizePhoneNumber(phone);
      print('Téléphone normalisé: $normalizedPhone');

      // Créer l'utilisateur dans auth.users
      final authResponse = await _supabase.auth.signUp(
        email: '$normalizedPhone@houbago.com',
        password: pin,
        phone: normalizedPhone,
      );

      if (authResponse.user == null) {
        print('Échec de la création du compte auth');
        return false;
      }

      print('Compte auth créé: ${authResponse.user!.id}');

      // Créer l'utilisateur dans la table users avec le même ID
      await _supabase.from('users').insert({
        'id': authResponse.user!.id,
        'first_name': firstname,
        'last_name': lastname,
        'phone': normalizedPhone,
        'pin': pin,
        'balance': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('Utilisateur créé avec succès');
      return true;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
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
          .eq('phone', '0123456789')
          .maybeSingle();

      print('insertTestData - testUser: $testUser');

      String userId;
      if (testUser == null) {
        final response = await _supabase
            .from('users')
            .insert({
              'first_name': 'John',
              'last_name': 'Doe',
              'phone': '0123456789',
              'pin': '1234',
              'balance': 0.0,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
              'is_anonymous': false,
              'raw_user_meta_data': {},
              'raw_app_meta_data': {},
            })
            .select()
            .single();
        userId = response['id'];
        print('insertTestData - nouvel utilisateur créé avec id: $userId');
      } else {
        userId = testUser['id'];
        print('insertTestData - utilisateur existant avec id: $userId');
      }

      // Insérer des affiliés de test
      final existingAffiliates = await _supabase
          .from('affiliates')
          .select()
          .eq('referrer_id', userId);

      if (existingAffiliates.isEmpty) {
        print('insertTestData - création des affiliés de test');
        final now = DateTime.now();
        final affiliatesData = [
          {
            'referrer_id': userId,
            'first_name': 'Pierre',
            'last_name': 'Martin',
            'phone': '0601020304',
            'status': 'active',
            'driver_type': 'moto',
            'created_at': now.subtract(const Duration(days: 30)).toIso8601String(),
            'updated_at': now.toIso8601String(),
            'last_ride_date': now.subtract(const Duration(days: 2)).toIso8601String(),
            'total_earnings': 1500.0,
          },
          {
            'referrer_id': userId,
            'first_name': 'Marie',
            'last_name': 'Dubois',
            'phone': '0602030405',
            'status': 'pending',
            'driver_type': 'moto',
            'created_at': now.subtract(const Duration(days: 15)).toIso8601String(),
            'updated_at': now.toIso8601String(),
            'total_earnings': 0.0,
          },
          {
            'referrer_id': userId,
            'first_name': 'Jean',
            'last_name': 'Dupont',
            'phone': '0603040506',
            'status': 'inactive',
            'driver_type': 'moto',
            'created_at': now.subtract(const Duration(days: 60)).toIso8601String(),
            'updated_at': now.toIso8601String(),
            'last_ride_date': now.subtract(const Duration(days: 45)).toIso8601String(),
            'total_earnings': 750.0,
          },
        ];

        await _supabase.from('affiliates').insert(affiliatesData);
        print('insertTestData - affiliés de test créés');
      } else {
        print('insertTestData - les affiliés de test existent déjà');
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

  static Stream<List<PendingWithdrawal>> getPendingWithdrawals() {
    try {
      return _supabase
          .from('withdrawals')
          .stream(primaryKey: ['id'])
          .eq('status', 'pending')
          .map((data) {
            print('Données de retrait reçues: $data');
            return data.map((json) => PendingWithdrawal.fromJson(json)).toList();
          });
    } catch (e) {
      print('Erreur lors de la récupération des retraits en attente: $e');
      return Stream.value([]);
    }
  }

  static Future<void> updateWithdrawalStatus(String withdrawalId, String status) async {
    try {
      // Récupérer les détails du retrait
      final withdrawal = await _supabase
          .from('withdrawals')
          .select('*, users!inner(*)')
          .eq('id', withdrawalId)
          .single();

      // Mettre à jour le statut
      await _supabase
          .from('withdrawals')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', withdrawalId);

      // Si le retrait est effectué, notifier l'utilisateur
      if (status == 'completed') {
        // Débiter le compte de l'utilisateur
        final userId = withdrawal['user_id'];
        final amount = withdrawal['amount'];
        
        await _supabase.rpc('debit_user_balance', params: {
          'user_id': userId,
          'amount': amount,
        });

        // Envoyer une notification à l'utilisateur
        await _supabase.from('notifications').insert({
          'user_id': userId,
          'title': 'Retrait effectué',
          'message': 'Votre retrait de ${amount.toStringAsFixed(2)} € a été effectué.',
          'type': 'withdrawal_completed',
          'data': {
            'withdrawal_id': withdrawalId,
            'amount': amount,
          },
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut du retrait: $e');
      rethrow;
    }
  }

  static Future<void> createWithdrawalRequest(double amount) async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Récupérer les informations de l'utilisateur
      final userInfo = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      // Créer la demande de retrait
      final withdrawalId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();
      
      await _supabase.from('withdrawals').insert({
        'id': withdrawalId,
        'user_id': userId,
        'amount': amount,
        'status': 'pending',
        'created_at': now,
      });

      // Envoyer une notification à tous les admins
      final admins = await _supabase.from('admins').select('id');
      for (final admin in admins) {
        await _supabase.from('admin_notifications').insert({
          'user_id': admin['id'],
          'title': 'Nouvelle demande de retrait',
          'message': 'Demande de retrait de ${userInfo['first_name']} ${userInfo['last_name']} pour un montant de ${amount.toStringAsFixed(2)} €',
          'type': 'withdrawal_request',
          'data': {
            'withdrawal_id': withdrawalId,
            'user_id': userId,
            'user_name': '${userInfo['first_name']} ${userInfo['last_name']}',
            'amount': amount,
            'created_at': now,
          },
          'created_at': now,
        });
      }
    } catch (e) {
      print('Erreur lors de la création de la demande de retrait: $e');
      rethrow;
    }
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
    String requestId, {
    String? status,
    String? adminResponse,
  }) async {
    try {
      final updates = {
        if (status != null) 'status': status,
        if (adminResponse != null) 'admin_response': adminResponse,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('support_requests')
          .update(updates)
          .eq('id', requestId);
    } catch (e) {
      print('Erreur lors de la mise à jour de la demande: $e');
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

  static Future<void> runMigrations() async {
    try {
      print('Running migrations...');
      
      // Créer la fonction SQL si elle n'existe pas
      await _createSQLFunction();
      
      // Vérifier si la table admins existe
      try {
        await _supabase.from('admins').select().limit(1);
        print('Table admins existe déjà');
      } catch (e) {
        print('Création de la table admins...');
        // Créer la table admins si elle n'existe pas
        await _supabase.rpc('create_admins_table', params: {
          'sql': '''
            CREATE TABLE IF NOT EXISTS admins (
              id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
              first_name TEXT NOT NULL,
              last_name TEXT NOT NULL,
              phone TEXT UNIQUE NOT NULL,
              pin TEXT NOT NULL,
              created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
              updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
            );
          '''
        });
        print('Table admins créée avec succès');
      }
      
      // Créer l'admin par défaut
      await createAdminIfNeeded();
      
      print('Migrations completed successfully');
    } catch (e, stackTrace) {
      print('Error running migrations: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> _createSQLFunction() async {
    try {
      print('Création de la fonction SQL create_admins_table...');
      await _supabase.rpc('create_sql_function', params: {
        'function_name': 'create_admins_table',
        'sql': '''
          CREATE OR REPLACE FUNCTION create_admins_table(sql text)
          RETURNS void
          LANGUAGE plpgsql
          SECURITY DEFINER
          AS \$\$
          BEGIN
            EXECUTE sql;
          END;
          \$\$;
        '''
      });
      print('Fonction SQL créée avec succès');
    } catch (e) {
      print('Erreur lors de la création de la fonction SQL: $e');
      // On ignore l'erreur si la fonction existe déjà
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

  static Future<List<Map<String, dynamic>?>?> getAdminNotifications({
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

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final bytes = await file.readAsBytes();
      
      await _supabase
          .storage
          .from('audio_files')
          .uploadBinary(
            'user_${user.id}/$fileName',
            bytes,
            fileOptions: const FileOptions(
              contentType: 'audio/m4a',
            ),
          );

      final url = _supabase
          .storage
          .from('audio_files')
          .getPublicUrl('user_${user.id}/$fileName');

      return url;
    } catch (e) {
      print('Erreur lors de l\'upload du fichier audio: $e');
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
    } catch (e) {
      print('Erreur lors de l\'upload:');
      print('Error: $e');
      rethrow;
    }
  }

  static String _normalizePhoneNumber(String phone) {
    // Retirer les espaces et le préfixe +225 s'il existe
    return phone.replaceAll('+225 ', '').replaceAll(' ', '');
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

      // Normaliser le numéro de téléphone
      final normalizedPhone = _normalizePhoneNumber(phone);
      
      print('\n=== Requête de connexion admin ===');
      print('Numéro normalisé: $normalizedPhone');
      
      final response = await _supabase
          .from('admins')
          .select()
          .eq('phone', normalizedPhone)
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
        firstName: response['first_name'],
        lastName: response['last_name'],
        phone: phone,
        balance: 0,
        createdAt: DateTime.parse(response['created_at']),
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
          .eq('phone', '0652262798')
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
      
      final user = _currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('Vérification de l\'utilisateur actuel:');
      print('ID: ${user.id}');
      print('Nom: ${user.firstName} ${user.lastName}');
      print('Téléphone: ${user.phone}');

      // Vérifier que l'utilisateur existe dans la base de données
      final userExists = await _supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .single();

      if (userExists == null) {
        print('L\'utilisateur n\'existe pas dans la base de données');
        throw Exception('Utilisateur introuvable dans la base de données');
      }

      print('Utilisateur trouvé dans la base de données');
      print('Prénom: $firstname');
      print('Nom: $lastname');
      print('Téléphone: $phone');
      print('Photo URL: $photoUrl');
      print('ID Card URL: $idCardUrl');
      print('Référent ID: ${user.id}');

      // Vérifier la structure de la table avant l'insertion
      await debugCheckTableStructure();

      final response = await _supabase.from('affiliates').insert({
        'first_name': firstname,
        'last_name': lastname,
        'phone': phone,
        'photo_identity_url': photoUrl,
        'photo_license_url': idCardUrl,
        'status': 'pending',
        'driver_type': 'moto',
        'referrer_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'total_earnings': 0,
      }).select();

      print('Affilié enregistré avec succès');
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

  static Stream<List<PendingAffiliate>> getAllAffiliatesAdmin() {
    print('Récupération de tous les affiliés...');
    return _supabase
        .from('affiliates')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
      print('Données reçues: ${data.length} affiliés');
      return data.map((json) => PendingAffiliate.fromJson(json)).toList();
    });
  }

  static Future<void> updateAffiliateStatusAdmin({
    required String affiliateId,
    required String status,
  }) async {
    try {
      print('Début de updateAffiliateStatusAdmin - affiliateId: $affiliateId, status: $status');
      
      final currentAdmin = _currentUser;
      if (currentAdmin == null) {
        throw Exception('Admin non connecté');
      }
      print('Admin connecté: ${currentAdmin.id}');

      // Vérifier que l'utilisateur est bien un admin
      final isAdmin = await isCurrentUserAdmin();
      print('Est admin: $isAdmin');
      if (!isAdmin) {
        throw Exception('Permissions insuffisantes : seuls les admins peuvent modifier le statut des affiliés');
      }

      // Mise à jour directe pour le moment
      print('Mise à jour du statut...');
      await _supabase
          .from('affiliates')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', affiliateId);
      print('Statut mis à jour avec succès');

      // Récupérer les détails de l'affilié
      print('Récupération des détails de l\'affilié...');
      final affiliateData = await _supabase
          .from('affiliates')
          .select('*, users!affiliates_user_id_fkey(*)')
          .eq('id', affiliateId)
          .single();
      print('Détails de l\'affilié récupérés: ${affiliateData['user_id']}');

      // Créer une notification pour l'utilisateur
      print('Création de la notification...');
      await _supabase.from('notifications').insert({
        'id': const Uuid().v4(),
        'user_id': affiliateData['user_id'],
        'title': 'Mise à jour de votre demande d\'affiliation',
        'message': status == 'approved' 
          ? 'Votre demande d\'affiliation a été approuvée !'
          : status == 'rejected'
            ? 'Votre demande d\'affiliation a été rejetée.'
            : 'Votre demande d\'affiliation a été remise en attente.',
        'type': 'affiliate_status',
        'created_at': DateTime.now().toIso8601String(),
      });
      print('Notification créée avec succès');

    } catch (e, stackTrace) {
      print('Erreur lors de la mise à jour du statut: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Stream<List<PendingAffiliate>> getPendingAffiliatesAdmin() {
    try {
      return Stream.fromFuture(_supabase
          .from('affiliates')
          .select()
          .eq('status', 'pending')
          .then((data) {
            print('\n=== Données des affiliés reçues ===');
            for (var json in data) {
              print('\nAffilié:');
              print('id: ${json['id']}');
              print('user_id: ${json['user_id']}');
              print('first_name: ${json['first_name']}');
              print('last_name: ${json['last_name']}');
              print('phone: ${json['phone']}');
              print('status: ${json['status']}');
              print('created_at: ${json['created_at']}');
            }
            return (data as List).map((json) => PendingAffiliate.fromJson(json)).toList();
          }));
    } catch (e) {
      print('Erreur lors de la récupération des affiliés en attente: $e');
      return Stream.value([]);
    }
  }

  static Future<void> createSupportRequest({
    required String subject,
    required String message,
    File? audioFile,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final requestId = const Uuid().v4();
      String? audioUrl;
      final now = DateTime.now().toIso8601String();

      if (audioFile != null) {
        final bytes = await audioFile.readAsBytes();
        final storageResponse = await _supabase
            .storage
            .from('support_audio')
            .uploadBinary(
              '$requestId.m4a',
              bytes,
              fileOptions: const FileOptions(
                contentType: 'audio/m4a',
              ),
            );
        audioUrl = _supabase.storage
            .from('support_audio')
            .getPublicUrl('$requestId.m4a');
      }

      // Combine firstName et lastName seulement s'ils ne sont pas null
      String? senderName;
      if (firstName != null || lastName != null) {
        senderName = [
          if (firstName != null) firstName,
          if (lastName != null) lastName,
        ].join(' ').trim();
        if (senderName.isEmpty) senderName = null;
      }

      await _supabase.from('support_requests').insert({
        'id': requestId,
        'sender_name': senderName,
        'sender_phone': phone,
        'subject': subject,
        'message': message,
        'status': 'pending',
        'audio_url': audioUrl,
        'created_at': now,
        'updated_at': now,
      });

    } catch (e) {
      print('Erreur lors de la création de la demande de support: $e');
      rethrow;
    }
  }

  static Future<List<SupportRequest>> getUserSupportRequests() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) throw Exception('Utilisateur non connecté');

      final response = await _supabase
          .from('support_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<SupportRequest>((json) => SupportRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des demandes de support: $e');
      rethrow;
    }
  }

  static Future<List<Affiliate>> getMyAffiliates() async {
    try {
      print('Récupération des affiliés...');
      final user = _currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      print('User ID: ${user.id}');
      final response = await _supabase
          .from('affiliates')
          .select('*')
          .eq('referrer_id', user.id)
          .order('created_at', ascending: false);

      print('Réponse brute: $response');
      print('Affiliés récupérés: ${response.length}');
      
      final affiliates = (response as List<dynamic>)
          .map<Affiliate>((json) => Affiliate.fromJson(json))
          .toList();
      print('Affiliés convertis: ${affiliates.length}');
      return affiliates;
    } catch (e) {
      print('Erreur lors de la récupération des affiliés: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
