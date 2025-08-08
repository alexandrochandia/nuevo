
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class UserService {
  static SupabaseClient? get _client => SupabaseConfig.client;

  // Guardar datos del perfil de usuario
  static Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String gender,
    required DateTime birthday,
    bool notifications = false,
    String? profilePhotoUrl,
    List<String>? additionalPhotos,
  }) async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    await _client!.from('user_profiles').upsert({
      'id': userId,
      'name': name,
      'gender': gender,
      'birthday': birthday.toIso8601String(),
      'notifications_enabled': notifications,
      'profile_photo_url': profilePhotoUrl,
      'additional_photos': additionalPhotos,
      'status': 'pending', // pending, approved, rejected
      'activation_date': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Activar usuario
  static Future<void> activateUser(String userId) async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    await _client!.from('user_profiles').update({
      'status': 'approved',
      'activation_date': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Verificar si usuario está activado
  static Future<bool> isUserActivated(String userId) async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    final response = await _client!
        .from('user_profiles')
        .select('status')
        .eq('id', userId)
        .single();
    
    return response['status'] == 'approved';
  }

  // Obtener perfil de usuario
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    final response = await _client!
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .single();
    
    return response;
  }

  // Registrar visita al perfil
  static Future<void> registerProfileVisit(String profileOwnerId, String visitorId) async {
    if (profileOwnerId == visitorId) return; // No registrar autovisitas
    
    try {
      if (_client == null) {
        throw Exception('Supabase not initialized');
      }
      await _client!.from('profile_visitors').upsert({
        'profile_owner_id': profileOwnerId,
        'visitor_id': visitorId,
        'visited_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error registering profile visit: $e');
    }
  }

  // Obtener número de visitantes únicos
  static Future<int> getVisitorCount(String profileOwnerId) async {
    try {
      if (_client == null) {
        throw Exception('Supabase not initialized');
      }
      final response = await _client!
          .from('profile_visitors')
          .select('visitor_id')
          .eq('profile_owner_id', profileOwnerId);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting visitor count: $e');
      return 0;
    }
  }

  // Obtener lista de visitantes recientes
  static Future<List<Map<String, dynamic>>> getRecentVisitors(String profileOwnerId, {int limit = 10}) async {
    try {
      if (_client == null) {
        throw Exception('Supabase not initialized');
      }
      final response = await _client!
          .from('profile_visitors')
          .select('''
            visited_at,
            visitor:visitor_id (
              name,
              profile_photo_url
            )
          ''')
          .eq('profile_owner_id', profileOwnerId)
          .order('visited_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting recent visitors: $e');
      return [];
    }
  }

  // Subir foto de perfil
  static Future<String?> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final fileName = 'profile_$userId.jpg';
      if (_client == null) {
        throw Exception('Supabase not initialized');
      }
      await _client!.storage
          .from('profile_photos')
          .upload(fileName, File(filePath));
      
      final publicUrl = _client!.storage
          .from('profile_photos')
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }
}
