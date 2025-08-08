import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/prayer_request_model.dart';

class PrayerRequestProvider with ChangeNotifier {
  List<PrayerRequest> _prayerRequests = [];
  PrayerFilter _currentFilter = PrayerFilter();
  bool _isLoading = false;
  String _error = '';
  String _currentUserId = 'user_current'; // Simulado

  List<PrayerRequest> get prayerRequests => _filteredRequests;
  List<PrayerRequest> get allPrayerRequests => _prayerRequests;
  PrayerFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentUserId => _currentUserId;

  List<PrayerRequest> get _filteredRequests {
    var filtered = List<PrayerRequest>.from(_prayerRequests);

    // Filtrar por categorías
    if (_currentFilter.categories.isNotEmpty) {
      filtered = filtered.where((request) => 
        _currentFilter.categories.contains(request.category)
      ).toList();
    }

    // Filtrar por urgencias
    if (_currentFilter.urgencies.isNotEmpty) {
      filtered = filtered.where((request) => 
        _currentFilter.urgencies.contains(request.urgency)
      ).toList();
    }

    // Filtrar por estados
    if (_currentFilter.statuses.isNotEmpty) {
      filtered = filtered.where((request) => 
        _currentFilter.statuses.contains(request.status)
      ).toList();
    }

    // Filtrar solo mis peticiones
    if (_currentFilter.showOnlyMine) {
      filtered = filtered.where((request) => 
        request.requesterId == _currentUserId
      ).toList();
    }

    // Filtrar peticiones anónimas
    if (!_currentFilter.showAnonymous) {
      filtered = filtered.where((request) => !request.isAnonymous).toList();
    }

    // Filtrar por rango de fechas
    if (_currentFilter.dateRange != null) {
      final dateRange = _currentFilter.dateRange!;
      if (dateRange.start != null) {
        filtered = filtered.where((request) => 
          request.createdAt.isAfter(dateRange.start!)
        ).toList();
      }
      if (dateRange.end != null) {
        filtered = filtered.where((request) => 
          request.createdAt.isBefore(dateRange.end!)
        ).toList();
      }
    }

    // Filtrar por búsqueda
    if (_currentFilter.searchQuery != null && _currentFilter.searchQuery!.isNotEmpty) {
      final query = _currentFilter.searchQuery!.toLowerCase();
      filtered = filtered.where((request) =>
        request.title.toLowerCase().contains(query) ||
        request.description.toLowerCase().contains(query) ||
        request.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    // Ordenar por fecha de creación (más recientes primero)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  PrayerRequestProvider() {
    _loadPrayerRequests();
    _generateMockData();
  }

  // Cargar peticiones de oración
  Future<void> _loadPrayerRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getStringList('prayer_requests') ?? [];
      
      _prayerRequests = requestsJson
          .map((json) => PrayerRequest.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar peticiones: $e';
      debugPrint(_error);
    }
  }

  // Guardar peticiones de oración
  Future<void> _savePrayerRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = _prayerRequests
          .map((request) => jsonEncode(request.toJson()))
          .toList();
      await prefs.setStringList('prayer_requests', requestsJson);
    } catch (e) {
      debugPrint('Error saving prayer requests: $e');
    }
  }

  // Crear nueva petición de oración
  Future<void> createPrayerRequest({
    required String title,
    required String description,
    required PrayerCategory category,
    required PrayerUrgency urgency,
    bool isAnonymous = false,
    bool isPublic = true,
    List<String> tags = const [],
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newRequest = PrayerRequest(
        id: 'prayer_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        requesterName: isAnonymous ? 'Usuario Anónimo' : 'Usuario Actual',
        requesterId: _currentUserId,
        requesterImageUrl: isAnonymous ? null : 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
        category: category,
        urgency: urgency,
        status: PrayerStatus.active,
        isAnonymous: isAnonymous,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        tags: tags,
      );

      _prayerRequests.insert(0, newRequest);
      await _savePrayerRequests();
      
    } catch (e) {
      _error = 'Error al crear petición: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Actualizar petición de oración
  Future<void> updatePrayerRequest(String requestId, {
    String? title,
    String? description,
    PrayerCategory? category,
    PrayerUrgency? urgency,
    PrayerStatus? status,
    List<String>? tags,
    String? testimonyAnswer,
  }) async {
    final index = _prayerRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final updatedRequest = _prayerRequests[index].copyWith(
      title: title,
      description: description,
      category: category,
      urgency: urgency,
      status: status,
      tags: tags,
      testimonyAnswer: testimonyAnswer,
      updatedAt: DateTime.now(),
      answeredAt: status == PrayerStatus.answered ? DateTime.now() : null,
    );

    _prayerRequests[index] = updatedRequest;
    await _savePrayerRequests();
    notifyListeners();
  }

  // Agregar actualización a petición
  Future<void> addPrayerUpdate(String requestId, {
    required String content,
    required PrayerUpdateType type,
  }) async {
    final index = _prayerRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final newUpdate = PrayerUpdate(
      id: 'update_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      authorName: 'Usuario Actual',
      authorId: _currentUserId,
      createdAt: DateTime.now(),
      type: type,
    );

    final updatedRequest = _prayerRequests[index].copyWith(
      updates: [..._prayerRequests[index].updates, newUpdate],
      updatedAt: DateTime.now(),
    );

    _prayerRequests[index] = updatedRequest;
    await _savePrayerRequests();
    notifyListeners();
  }

  // Orar por una petición
  Future<void> prayForRequest(String requestId) async {
    final index = _prayerRequests.indexWhere((r) => r.id == requestId);
    if (index == -1) return;

    final request = _prayerRequests[index];
    
    // Verificar si ya oró
    if (request.prayerPartners.contains(_currentUserId)) {
      return; // Ya oró por esta petición
    }

    final updatedRequest = request.copyWith(
      prayerCount: request.prayerCount + 1,
      prayerPartners: [...request.prayerPartners, _currentUserId],
    );

    _prayerRequests[index] = updatedRequest;
    await _savePrayerRequests();
    notifyListeners();
  }

  // Eliminar petición de oración
  Future<void> deletePrayerRequest(String requestId) async {
    _prayerRequests.removeWhere((r) => r.id == requestId);
    await _savePrayerRequests();
    notifyListeners();
  }

  // Aplicar filtros
  void applyFilter(PrayerFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _currentFilter = PrayerFilter();
    notifyListeners();
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    return {
      'total': _prayerRequests.length,
      'active': _prayerRequests.where((r) => r.status == PrayerStatus.active).length,
      'answered': _prayerRequests.where((r) => r.status == PrayerStatus.answered).length,
      'myRequests': _prayerRequests.where((r) => r.requesterId == _currentUserId).length,
      'prayedFor': _prayerRequests.where((r) => r.prayerPartners.contains(_currentUserId)).length,
    };
  }

  // Obtener peticiones por categoría
  Map<PrayerCategory, int> getRequestsByCategory() {
    final Map<PrayerCategory, int> categoryCount = {};
    
    for (final category in PrayerCategory.values) {
      categoryCount[category] = _prayerRequests
          .where((r) => r.category == category)
          .length;
    }
    
    return categoryCount;
  }

  // Obtener mis peticiones
  List<PrayerRequest> getMyRequests() {
    return _prayerRequests
        .where((r) => r.requesterId == _currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtener peticiones en las que he orado
  List<PrayerRequest> getPrayedForRequests() {
    return _prayerRequests
        .where((r) => r.prayerPartners.contains(_currentUserId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtener peticiones urgentes
  List<PrayerRequest> getUrgentRequests() {
    return _prayerRequests
        .where((r) => r.urgency == PrayerUrgency.urgent && r.status == PrayerStatus.active)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtener peticiones recientes
  List<PrayerRequest> getRecentRequests() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    return _prayerRequests
        .where((r) => r.createdAt.isAfter(yesterday))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Refrescar datos
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    await _loadPrayerRequests();
    
    _isLoading = false;
    notifyListeners();
  }

  void _generateMockData() {
    if (_prayerRequests.isNotEmpty) return;

    final mockRequests = [
      PrayerRequest(
        id: 'prayer_1',
        title: 'Sanidad para mi madre',
        description: 'Por favor oren por la sanidad de mi madre María, está en el hospital con problemas cardíacos. Creemos en el poder sanador de Jesús.',
        requesterName: 'Ana Petersson',
        requesterId: 'user_1',
        requesterImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
        category: PrayerCategory.health,
        urgency: PrayerUrgency.high,
        status: PrayerStatus.active,
        isAnonymous: false,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['sanidad', 'familia', 'hospital'],
        prayerCount: 12,
        prayerPartners: ['user_2', 'user_3', 'user_4'],
        updates: [
          PrayerUpdate(
            id: 'update_1',
            content: 'Gracias por sus oraciones. Los médicos dicen que está mejorando.',
            authorName: 'Ana Petersson',
            authorId: 'user_1',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            type: PrayerUpdateType.update,
          ),
        ],
      ),
      
      PrayerRequest(
        id: 'prayer_2',
        title: 'Dirección para mi futuro ministerio',
        description: 'Busco la dirección de Dios para saber si debo aceptar la invitación a pastorear en Gotemburgo. Necesito sabiduría divina.',
        requesterName: 'Pastor Erik Johansson',
        requesterId: 'user_2',
        requesterImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        category: PrayerCategory.guidance,
        urgency: PrayerUrgency.normal,
        status: PrayerStatus.active,
        isAnonymous: false,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['ministerio', 'dirección', 'sabiduría'],
        prayerCount: 18,
        prayerPartners: ['user_1', 'user_3', 'user_5'],
      ),
      
      PrayerRequest(
        id: 'prayer_3',
        title: 'Restauración matrimonial',
        description: 'Mi esposo y yo estamos pasando por una crisis. Oramos por restauración, perdón y el amor de Cristo en nuestro hogar.',
        requesterName: 'Usuario Anónimo',
        requesterId: 'user_3',
        category: PrayerCategory.relationships,
        urgency: PrayerUrgency.high,
        status: PrayerStatus.active,
        isAnonymous: true,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        tags: ['matrimonio', 'restauración', 'familia'],
        prayerCount: 8,
        prayerPartners: ['user_1', 'user_2'],
      ),
      
      PrayerRequest(
        id: 'prayer_4',
        title: 'Provisión financiera para misiones',
        description: 'Necesitamos 50,000 SEK para el proyecto misionero en África. Oramos por provisión sobrenatural y corazones generosos.',
        requesterName: 'Pastora Margareta Lindström',
        requesterId: 'user_4',
        requesterImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        category: PrayerCategory.missions,
        urgency: PrayerUrgency.urgent,
        status: PrayerStatus.active,
        isAnonymous: false,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        tags: ['misiones', 'áfrica', 'provisión', 'finanzas'],
        prayerCount: 25,
        prayerPartners: ['user_1', 'user_2', 'user_3', 'user_5'],
      ),
      
      PrayerRequest(
        id: 'prayer_5',
        title: 'Trabajo y estabilidad económica',
        description: 'Perdí mi trabajo la semana pasada y tengo familia que mantener. Oro por una nueva oportunidad laboral pronto.',
        requesterName: 'Carlos Andersson',
        requesterId: 'user_5',
        requesterImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
        category: PrayerCategory.work,
        urgency: PrayerUrgency.high,
        status: PrayerStatus.active,
        isAnonymous: false,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['trabajo', 'empleo', 'familia', 'provisión'],
        prayerCount: 15,
        prayerPartners: ['user_1', 'user_2', 'user_4'],
      ),
      
      PrayerRequest(
        id: 'prayer_6',
        title: '¡Dios contestó mi oración!',
        description: 'Hace un mes pedí oración por la visa de mi hermano. ¡Ayer la aprobaron! Gloria a Dios por su fidelidad.',
        requesterName: 'Lucía Eriksson',
        requesterId: 'user_6',
        requesterImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
        category: PrayerCategory.thanksgiving,
        urgency: PrayerUrgency.normal,
        status: PrayerStatus.answered,
        isAnonymous: false,
        isPublic: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        answeredAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['visa', 'testimonio', 'familia'],
        prayerCount: 22,
        prayerPartners: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
        testimonyAnswer: 'Dios fue fiel y la visa fue aprobada sin problemas. ¡Él siempre tiene el control!',
      ),
    ];

    _prayerRequests = mockRequests;
    _savePrayerRequests();
    notifyListeners();
  }
}