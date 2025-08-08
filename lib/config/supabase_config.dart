import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Agregar tus credenciales de Supabase aquí
  static const String url = 'https://kwfsjknrpwqqkdyopabm.supabase.co';  // Ejemplo: 'https://tu-proyecto.supabase.co'
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3ZnNqa25ycHdxcWtkeW9wYWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxODk5MTUsImV4cCI6MjA2Mjc2NTkxNX0.WYuduX4XuNNMmybDMy5VgudtnPsWZwqZLkVBGSvSjio';  // Tu clave anónima de Supabase
  
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    _client ??= SupabaseClient(url, anonKey);
    return _client!;
  }
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }
  
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
