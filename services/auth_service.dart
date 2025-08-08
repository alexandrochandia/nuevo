import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  static SupabaseClient? get _client => SupabaseConfig.client;

  // Registro de usuario
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return await _client!.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }

  // Inicio de sesión
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    return await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    if (_client == null) {
      throw Exception('Supabase not initialized');
    }
    await _client!.auth.signOut();
  }

  // Obtener usuario actual
  static User? get currentUser => _client?.auth.currentUser;

  // Stream del estado de autenticación
  static Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;
}