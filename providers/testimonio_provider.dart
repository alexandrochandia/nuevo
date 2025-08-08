import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/testimonio_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestimonioProvider extends ChangeNotifier {
  List<TestimonioModel> _testimonios = [];
  List<TestimonioModel> _misTestimonios = [];
  List<String> _favoritosIds = [];
  bool _isLoading = false;
  String? _error;
  TestimonioTipo? _filtroTipo;

  List<TestimonioModel> get testimonios => _testimonios;
  List<TestimonioModel> get misTestimonios => _misTestimonios;
  List<String> get favoritosIds => _favoritosIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TestimonioTipo? get filtroTipo => _filtroTipo;

  List<TestimonioModel> get testimoniosFiltrados {
    if (_filtroTipo == null) return _testimonios;
    return _testimonios.where((t) => t.tipo == _filtroTipo).toList();
  }

  TestimonioProvider() {
    _loadFavoritos();
    cargarTestimonios();
  }

  Future<void> _loadFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoritosIds = prefs.getStringList('testimonios_favoritos') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favoritos: $e');
    }
  }

  Future<void> _saveFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('testimonios_favoritos', _favoritosIds);
    } catch (e) {
      debugPrint('Error saving favoritos: $e');
    }
  }

  Future<void> cargarTestimonios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Intentar cargar desde Supabase
      final response = await Supabase.instance.client
          .from('testimonios')
          .select()
          .order('fecha_creacion', ascending: false);

      if (response.isNotEmpty) {
        _testimonios = response
            .map((json) => TestimonioModel.fromJson(json))
            .toList();
      } else {
        // Fallback a datos de muestra
        _testimonios = TestimoniosData.testimoniosMuestra;
      }
    } catch (e) {
      debugPrint('Error loading testimonios from Supabase: $e');
      // Usar datos de muestra como fallback
      _testimonios = TestimoniosData.testimoniosMuestra;
    }

    // Actualizar favoritos
    for (var testimonio in _testimonios) {
      testimonio.esFavorito = _favoritosIds.contains(testimonio.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cargarMisTestimonios(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('testimonios')
          .select()
          .eq('user_id', userId)
          .order('fecha_creacion', ascending: false);

      _misTestimonios = response
          .map((json) => TestimonioModel.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mis testimonios: $e');
      _misTestimonios = [];
      notifyListeners();
    }
  }

  Future<bool> crearTestimonio(TestimonioModel testimonio) async {
    try {
      final response = await Supabase.instance.client
          .from('testimonios')
          .insert(testimonio.toJson())
          .select()
          .single();

      final nuevoTestimonio = TestimonioModel.fromJson(response);
      _testimonios.insert(0, nuevoTestimonio);
      _misTestimonios.insert(0, nuevoTestimonio);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating testimonio: $e');
      _error = 'Error al crear el testimonio';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorito(String testimonioId) async {
    if (_favoritosIds.contains(testimonioId)) {
      _favoritosIds.remove(testimonioId);
    } else {
      _favoritosIds.add(testimonioId);
    }

    // Actualizar en la lista local
    final testimonio = _testimonios.firstWhere(
      (t) => t.id == testimonioId,
      orElse: () => TestimonioModel(),
    );

    if (testimonio.id != null) {
      testimonio.esFavorito = _favoritosIds.contains(testimonioId);
    }

    await _saveFavoritos();
    notifyListeners();
  }

  Future<void> incrementarVistas(String testimonioId) async {
    try {
      // Actualizar en Supabase
      await Supabase.instance.client
          .from('testimonios')
          .update({'vistas': (testimonios.firstWhere((t) => t.id == testimonioId).vistas ?? 0) + 1})
          .eq('id', testimonioId);

      // Actualizar localmente
      final testimonio = _testimonios.firstWhere(
        (t) => t.id == testimonioId,
        orElse: () => TestimonioModel(),
      );

      if (testimonio.id != null) {
        testimonio.vistas = (testimonio.vistas ?? 0) + 1;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  Future<void> darLike(String testimonioId) async {
    try {
      final testimonio = _testimonios.firstWhere(
        (t) => t.id == testimonioId,
        orElse: () => TestimonioModel(),
      );

      if (testimonio.id != null) {
        testimonio.likes = (testimonio.likes ?? 0) + 1;

        // Actualizar en Supabase
        await Supabase.instance.client
            .from('testimonios')
            .update({'likes': testimonio.likes})
            .eq('id', testimonioId);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error giving like: $e');
    }
  }

  void setFiltroTipo(TestimonioTipo? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}