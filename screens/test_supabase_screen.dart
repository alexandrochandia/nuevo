import 'package:flutter/material.dart';
import '../config/supabase_config.dart';
import '../services/auth_service.dart';

class TestSupabaseScreen extends StatefulWidget {
  const TestSupabaseScreen({super.key});

  @override
  State<TestSupabaseScreen> createState() => _TestSupabaseScreenState();
}

class _TestSupabaseScreenState extends State<TestSupabaseScreen> {
  String _status = 'Verificando conexión...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // Verificar si Supabase está inicializado
      final client = SupabaseConfig.client;
      
      if (client == null) {
        throw Exception('Supabase not initialized');
      }

      // Hacer una consulta simple para verificar conexión
      final response = await client
          .from('user_profiles')
          .select('count')
          .count()
          .timeout(const Duration(seconds: 10));

      setState(() {
        _status = '''✅ Supabase conectado correctamente!

🔗 Base de datos: Activa
📊 Tabla user_profiles: Accesible
⏱️ Latencia: < 10s
🎯 Ready para usar!''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Test Supabase'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  color: Color(0xFF667eea),
                ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _testConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                ),
                child: const Text(
                  'Verificar de nuevo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}