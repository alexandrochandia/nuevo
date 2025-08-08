import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/church_model.dart';
import '../config/supabase_config.dart';

class ChurchProvider with ChangeNotifier {
  List<ChurchModel> _churches = [];
  List<ChurchModel> _filteredChurches = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedLanguage = 'all';
  String _searchQuery = '';

  List<ChurchModel> get churches => _filteredChurches;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedLanguage => _selectedLanguage;
  String get searchQuery => _searchQuery;

  Future<void> loadChurches() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Intentar cargar desde Supabase
      if (SupabaseConfig.url.isNotEmpty && 
          SupabaseConfig.anonKey.isNotEmpty &&
          SupabaseConfig.client != null) {
        final response = await SupabaseConfig.client!
            .from('churches')
            .select()
            .eq('is_active', true)
            .order('name');

        _churches = response.map<ChurchModel>((json) => ChurchModel.fromJson(json)).toList();
      } else {
        // Fallback a datos de prueba
        _churches = ChurchModel.getMockChurches();
      }

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error al cargar iglesias: ${e.toString()}';
      // Fallback a datos de prueba en caso de error
      _churches = ChurchModel.getMockChurches();
      _applyFilters();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setLanguageFilter(String language) {
    _selectedLanguage = language;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredChurches = _churches.where((church) {
      bool matchesLanguage = _selectedLanguage == 'all' || church.language == _selectedLanguage;
      bool matchesSearch = _searchQuery.isEmpty ||
          church.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          church.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          church.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesLanguage && matchesSearch;
    }).toList();
  }

  ChurchModel? getChurchById(String id) {
    try {
      return _churches.firstWhere((church) => church.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ChurchModel> getChurchesByCity(String city) {
    return _churches.where((church) => 
        church.city.toLowerCase() == city.toLowerCase()).toList();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Fórmula de Haversine para calcular distancia entre dos puntos
    const double earthRadius = 6371; // Radio de la Tierra en kilómetros

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  List<ChurchModel> getNearbyChurches(double userLat, double userLon, {double radiusKm = 50.0}) {
    return _churches.where((church) {
      double distance = calculateDistance(userLat, userLon, church.latitude, church.longitude);
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        double distanceA = calculateDistance(userLat, userLon, a.latitude, a.longitude);
        double distanceB = calculateDistance(userLat, userLon, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });
  }

  void refreshChurches() {
    loadChurches();
  }
}