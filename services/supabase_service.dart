import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get supabase => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  // Auth helpers
  static User? get currentUser => supabase.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Storage helpers
  static String getPublicUrl(String bucket, String path) {
    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> bytes,
  }) async {
    final response = await supabase.storage
        .from(bucket)
        .uploadBinary(path, Uint8List.fromList(bytes));

    if (response.isNotEmpty) {
      return getPublicUrl(bucket, path);
    }
    throw Exception('Error uploading file');
  }

  // User management methods
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Dating/Swipe methods
  static Future<void> createSwipeAction({
    required String userId,
    required String targetUserId,
    required String action, // 'like' or 'pass'
  }) async {
    try {
      await supabase.from('dating_swipes').insert({
        'user_id': userId,
        'target_user_id': targetUserId,
        'action': action,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating swipe action: $e');
      throw Exception('Error creating swipe action');
    }
  }

  static Future<bool> checkMatch(String userId, String targetUserId) async {
    try {
      final response = await supabase
          .from('dating_matches')
          .select('*')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .or('user1_id.eq.$targetUserId,user2_id.eq.$targetUserId')
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      print('Error checking match: $e');
      return false;
    }
  }

  // User preferences
  static Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await supabase
          .from('dating_preferences')
          .upsert({
            'user_id': userId,
            ...preferences,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating user preferences: $e');
      throw Exception('Error updating user preferences');
    }
  }
}