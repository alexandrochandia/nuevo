import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuraProvider extends ChangeNotifier {
  Color _selectedAuraColor = const Color(0xFF00D4FF); // Azul neón por defecto
  double _auraIntensity = 0.5;
  bool _isAuraEnabled = true;
  List<Color> _favoriteColors = [];
  bool _isLoading = false;

  // Colores predefinidos VMF
  static const List<Color> predefinedColors = [
    Color(0xFF00D4FF), // Azul neón principal
    Color(0xFF0099FF), // Azul neón oscuro
    Color(0xFF33E0FF), // Azul neón claro
    Color(0xFF0080FF), // Azul eléctrico
    Color(0xFF007FFF), // Azul brillante
    Color(0xFF0066FF), // Azul profundo
    Color(0xFF4DA6FF), // Azul cielo
    Color(0xFF1A8FFF), // Azul medio
    Color(0xFF0073E6), // Azul corporativo
    Color(0xFF339FFF), // Azul suave
    Color(0xFF0059B3), // Azul oscuro
    Color(0xFF66B2FF), // Azul pastel
  ];

  Color get selectedAuraColor => _selectedAuraColor;
  Color get currentAuraColor => _selectedAuraColor;
  double get auraIntensity => _auraIntensity;
  bool get isAuraEnabled => _isAuraEnabled;
  List<Color> get favoriteColors => _favoriteColors;
  bool get isLoading => _isLoading;

  Future<void> setAuraColor(Color color) async {
    _selectedAuraColor = color;
    notifyListeners();
    await _saveAuraSettings();
  }

  Future<void> setAuraIntensity(double intensity) async {
    _auraIntensity = intensity;
    notifyListeners();
    await _saveAuraSettings();
  }

  void toggleAura() {
    _isAuraEnabled = !_isAuraEnabled;
    notifyListeners();
    _saveAuraSettings();
  }

  void addToFavorites(Color color) {
    if (!_favoriteColors.contains(color)) {
      _favoriteColors.add(color);
      notifyListeners();
      _saveAuraSettings();
    }
  }

  void removeFromFavorites(Color color) {
    _favoriteColors.remove(color);
    notifyListeners();
    _saveAuraSettings();
  }

  Future<void> _saveAuraSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('aura_color', _selectedAuraColor.value);
      await prefs.setDouble('aura_intensity', _auraIntensity);
      await prefs.setBool('aura_enabled', _isAuraEnabled);
      
      // Guardar colores favoritos
      List<String> favoriteColorStrings = _favoriteColors.map((color) => color.value.toString()).toList();
      await prefs.setStringList('favorite_colors', favoriteColorStrings);
    } catch (e) {
      print('Error saving aura settings: $e');
    }
  }

  Future<void> loadAuraSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final colorValue = prefs.getInt('aura_color');
      if (colorValue != null) {
        _selectedAuraColor = Color(colorValue);
      }
      
      _auraIntensity = prefs.getDouble('aura_intensity') ?? 0.5;
      _isAuraEnabled = prefs.getBool('aura_enabled') ?? true;
      
      // Cargar colores favoritos
      final favoriteColorStrings = prefs.getStringList('favorite_colors') ?? [];
      _favoriteColors = favoriteColorStrings.map((colorString) => Color(int.parse(colorString))).toList();
      
    } catch (e) {
      print('Error loading aura settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para obtener el estilo de glow del aura actual
  BoxShadow getAuraGlow({double? customIntensity}) {
    if (!_isAuraEnabled) return const BoxShadow(color: Colors.transparent);
    
    final intensity = customIntensity ?? _auraIntensity;
    return BoxShadow(
      color: _selectedAuraColor.withOpacity(intensity * 0.6),
      blurRadius: 20 * intensity,
      spreadRadius: 5 * intensity,
    );
  }

  // Método para obtener múltiples sombras para efecto más dramático
  List<BoxShadow> getMultipleAuraGlows({double? customIntensity}) {
    if (!_isAuraEnabled) return [];
    
    final intensity = customIntensity ?? _auraIntensity;
    return [
      BoxShadow(
        color: _selectedAuraColor.withOpacity(intensity * 0.3),
        blurRadius: 30 * intensity,
        spreadRadius: 8 * intensity,
      ),
      BoxShadow(
        color: _selectedAuraColor.withOpacity(intensity * 0.2),
        blurRadius: 60 * intensity,
        spreadRadius: 15 * intensity,
      ),
    ];
  }
}