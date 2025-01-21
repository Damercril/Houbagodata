import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://opvgksxndayifwtpsyra.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wdmdrc3huZGF5aWZ3dHBzeXJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0MjAwNjMsImV4cCI6MjA1Mjk5NjA2M30.1sz9dgmC6Sc7iYcnpVLP1K5rjlvD3jyulPxNZlxx3Fc';

  static late final SupabaseClient client;

  static Future<SupabaseClient> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: true,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        }
      );
      
      client = Supabase.instance.client;
      
      // Essayer de se connecter anonymement
      try {
        if (client.auth.currentSession == null) {
          await client.auth.signInWithPassword(
            email: 'service@houbago.com',
            password: 'houbago2024',
          );
        }
      } catch (authError) {
        print('Erreur d\'authentification: $authError');
      }
      
      return client;
    } catch (e) {
      print('Erreur d\'initialisation Supabase: $e');
      rethrow;
    }
  }

  static SupabaseClient get supabase => client;
}
