import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:houbago/houbago/config/supabase_config.dart';
import 'package:houbago/houbago/models/user.dart' as houbago;
import 'package:houbago/houbago/models/notification.dart';
import 'package:houbago/houbago/models/user_account.dart';
import 'package:houbago/houbago/models/driver.dart';
import 'package:houbago/houbago/models/driver_detail.dart';
import 'package:houbago/houbago/models/daily_earning.dart';
import 'package:houbago/houbago/models/earnings.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  static late SupabaseClient _supabase;
  static houbago.HoubagoUser? _currentUser;

  static Future<void> initialize() async {
    try {
      _supabase = await SupabaseConfig.initialize();
      print('Supabase initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation de Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get supabase => _supabase;

  static houbago.HoubagoUser? getCurrentUser() {
    return _currentUser;
  }

  static void setCurrentUser(houbago.HoubagoUser? user) {
    _currentUser = user;
  }

  static Future<String?> getCurrentUserId() async {
    return _currentUser?.id;
  }

  static Future<void> createTestUserIfNeeded() async {
    try {
      final testUser = await _supabase
          .from('users')
          .select()
          .eq('phone', '+33123456789')
          .maybeSingle();

      if (testUser == null) {
        await _supabase.from('users').insert({
          'phone': '+33123456789',
          'first_name': 'Test',
          'last_name': 'User',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur test: $e');
    }
  }

  static Future<void> checkUsers() async {
    try {
      final users = await _supabase.from('users').select();
      print('Nombre d\'utilisateurs: ${users.length}');
    } catch (e) {
      print('Erreur lors de la vérification des utilisateurs: $e');
    }
  }

  static Future<bool> signInWithPhone({
    required String phone,
    required String pin,
  }) async {
    try {
      // Récupérer l'utilisateur
      final user = await _supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .eq('pin', pin)
          .maybeSingle();

      if (user != null) {
        // Calculer le solde total à partir des gains
        final earnings = await _supabase
            .from('earnings')
            .select('amount')
            .eq('user_id', user['id']);
        
        double totalBalance = 0.0;
        if (earnings != null) {
          for (var earning in earnings) {
            totalBalance += (earning['amount'] as num).toDouble();
          }
        }

        // Créer l'utilisateur avec le solde calculé
        _currentUser = houbago.HoubagoUser.fromJson({
          ...user,
          'balance': totalBalance,
        });
        
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    }
  }

  static Future<void> checkTableStructure() async {
    try {
      await _supabase.from('users').select().limit(1);
      await _supabase.from('earnings').select().limit(1);
      await _supabase.from('moto_partners').select().limit(1);
      print('Structure des tables vérifiée avec succès');
    } catch (e) {
      print('Erreur lors de la vérification de la structure: $e');
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
      final response = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((item) => {
        'id': item['id'].toString(),
        'name': item['name'].toString(),
        'description': item['description']?.toString() ?? '',
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des courses: $e');
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
      final response = await _supabase
          .from('moto_partners')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((item) => {
        'id': item['id'].toString(),
        'name': item['name'].toString(),
        'code': item['code'].toString(),
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des partenaires: $e');
      return [];
    }
  }

  static Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String pin,
    required String courseId,
    String? motoPartnerId,
  }) async {
    try {
      final newUser = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'pin': pin,
        'course_id': courseId,
        'moto_partner_id': motoPartnerId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('users')
          .insert(newUser)
          .select()
          .single();

      _currentUser = houbago.HoubagoUser.fromJson(response);
      return true;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      return false;
    }
  }

  static Future<UserAccount?> getCurrentUserAccount() async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response == null) return null;

      // Convertir la réponse en UserAccount
      return UserAccount(
        id: response['id'],
        userId: response['id'],
        balance: (response['balance'] ?? 0.0).toDouble(),
        referralCode: '', // Plus utilisé
        createdAt: DateTime.parse(response['created_at']),
      );
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
          .select()
          .eq('user_id', userId);

      if (unreadOnly) {
        query = query.eq('read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(50);

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
              'first_name': 'John',
              'last_name': 'Doe',
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
}
