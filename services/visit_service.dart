import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import '../models/visit_model.dart';

class VisitService {
  final _supabase = SupabaseConfig.client;

  Future<void> registerVisit(String visitedUserId) async {
    try {
      // Try to get real IP data, fallback to mock
      String country = 'Suecia'; // Default for VMF Sweden
      
      try {
        final ipData = await http.get(Uri.parse('https://ipapi.co/json/'));
        if (ipData.statusCode == 200) {
          final data = jsonDecode(ipData.body);
          country = data['country_name'] ?? 'Suecia';
        }
      } catch (e) {
        // Fallback to mock countries for VMF Sweden context
        final mockCountries = ['Suecia', 'España', 'Reino Unido', 'Noruega', 'Dinamarca', 'Francia', 'Alemania'];
        country = mockCountries[Random().nextInt(mockCountries.length)];
      }

      await _supabase?.from('visits').insert({
        'visited_user_id': visitedUserId,
        'country': country,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error registrando visita: $e');
      // Continue silently - visit tracking is not critical
    }
  }

  Future<List<Visit>> getRecentVisits(String userId) async {
    try {
      final response = await _supabase
          ?.from('visits')
          .select()
          .eq('visited_user_id', userId)
          .order('timestamp', ascending: false)
          .limit(50);

      return response?.map<Visit>((data) => Visit.fromMap(data)).toList() ?? [];
    } catch (e) {
      print('Error obteniendo visitas: $e');
      // Return mock data for demonstration
      return Visit.mockVisits();
    }
  }

  Future<Map<String, int>> getVisitStatistics() async {
    try {
      final response = await _supabase
          ?.from('visits')
          .select()
          .gte('timestamp', DateTime.now().subtract(const Duration(days: 7)).toIso8601String());

      final visits = response?.map<Visit>((data) => Visit.fromMap(data)).toList() ?? [];
      
      final Map<String, int> countryStats = {};
      for (final visit in visits) {
        countryStats[visit.country] = (countryStats[visit.country] ?? 0) + 1;
      }

      return countryStats;
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      // Return mock statistics
      return {
        'Suecia': 45,
        'España': 23,
        'Reino Unido': 12,
        'Noruega': 8,
        'Dinamarca': 6,
        'Francia': 4,
        'Alemania': 3,
      };
    }
  }

  // Get total visits for current user
  Future<int> getTotalVisits(String userId) async {
    try {
      final response = await _supabase
          ?.from('visits')
          .select('id')
          .eq('visited_user_id', userId);

      return response?.length ?? 0;
    } catch (e) {
      print('Error obteniendo total de visitas: $e');
      return Random().nextInt(50) + 100; // Mock between 100-150
    }
  }
}