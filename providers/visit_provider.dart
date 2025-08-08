import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/visit_model.dart';

class VisitProvider with ChangeNotifier {
  List<Visit> _visits = [];
  List<VisitorType> _selectedTypes = [];
  List<VisitStatus> _selectedStatuses = [];
  String _searchQuery = '';
  String _selectedChurch = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showOnlyPendingFollowUp = false;
  bool _isLoading = false;
  String _error = '';
  String _currentUserId = 'user_pastor'; // Simulado - Pastor/Líder

  List<Visit> get visits => _filteredVisits;
  List<Visit> get allVisits => _visits;
  List<VisitorType> get selectedTypes => _selectedTypes;
  List<VisitStatus> get selectedStatuses => _selectedStatuses;
  String get searchQuery => _searchQuery;
  String get selectedChurch => _selectedChurch;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get showOnlyPendingFollowUp => _showOnlyPendingFollowUp;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentUserId => _currentUserId;

  List<Visit> get _filteredVisits {
    var filtered = List<Visit>.from(_visits);

    // Filtrar por tipos de visitante
    if (_selectedTypes.isNotEmpty) {
      filtered = filtered.where((visit) => 
        _selectedTypes.contains(visit.visitorType)
      ).toList();
    }

    // Filtrar por estados
    if (_selectedStatuses.isNotEmpty) {
      filtered = filtered.where((visit) => 
        _selectedStatuses.contains(visit.status)
      ).toList();
    }

    // Filtrar por iglesia
    if (_selectedChurch.isNotEmpty) {
      filtered = filtered.where((visit) => 
        visit.churchLocation.toLowerCase().contains(_selectedChurch.toLowerCase())
      ).toList();
    }

    // Filtrar por rango de fechas
    if (_startDate != null) {
      filtered = filtered.where((visit) => 
        visit.visitDate.isAfter(_startDate!) || 
        visit.visitDate.isAtSameMomentAs(_startDate!)
      ).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((visit) => 
        visit.visitDate.isBefore(_endDate!.add(const Duration(days: 1)))
      ).toList();
    }

    // Filtrar solo seguimientos pendientes
    if (_showOnlyPendingFollowUp) {
      filtered = filtered.where((visit) => 
        visit.wantsFollowUp && 
        (visit.status == VisitStatus.newVisit || visit.status == VisitStatus.contacted)
      ).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((visit) =>
        visit.visitorName.toLowerCase().contains(query) ||
        (visit.visitorEmail?.toLowerCase().contains(query) ?? false) ||
        (visit.visitorPhone?.contains(query) ?? false) ||
        visit.churchLocation.toLowerCase().contains(query) ||
        (visit.referredBy?.toLowerCase().contains(query) ?? false) ||
        visit.interests.any((interest) => interest.toLowerCase().contains(query))
      ).toList();
    }

    // Ordenar por fecha de visita (más recientes primero)
    filtered.sort((a, b) => b.visitDate.compareTo(a.visitDate));

    return filtered;
  }

  VisitProvider() {
    _loadVisits();
    _generateMockData();
  }

  // Cargar visitas
  Future<void> _loadVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = prefs.getStringList('visits') ?? [];
      
      _visits = visitsJson
          .map((json) => Visit.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar visitas: $e';
      debugPrint(_error);
    }
  }

  // Guardar visitas
  Future<void> _saveVisits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitsJson = _visits
          .map((visit) => jsonEncode(visit.toJson()))
          .toList();
      await prefs.setStringList('visits', visitsJson);
    } catch (e) {
      debugPrint('Error saving visits: $e');
    }
  }

  // Aplicar filtros
  void applyFilters({
    List<VisitorType>? types,
    List<VisitStatus>? statuses,
    String? searchQuery,
    String? selectedChurch,
    DateTime? startDate,
    DateTime? endDate,
    bool? showOnlyPendingFollowUp,
  }) {
    _selectedTypes = types ?? _selectedTypes;
    _selectedStatuses = statuses ?? _selectedStatuses;
    _searchQuery = searchQuery ?? _searchQuery;
    _selectedChurch = selectedChurch ?? _selectedChurch;
    _startDate = startDate ?? _startDate;
    _endDate = endDate ?? _endDate;
    _showOnlyPendingFollowUp = showOnlyPendingFollowUp ?? _showOnlyPendingFollowUp;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedTypes = [];
    _selectedStatuses = [];
    _searchQuery = '';
    _selectedChurch = '';
    _startDate = null;
    _endDate = null;
    _showOnlyPendingFollowUp = false;
    notifyListeners();
  }

  // Agregar nueva visita
  Future<void> addVisit(Visit visit) async {
    _visits.add(visit);
    await _saveVisits();
    notifyListeners();
  }

  // Actualizar visita
  Future<void> updateVisit(Visit updatedVisit) async {
    final index = _visits.indexWhere((v) => v.id == updatedVisit.id);
    if (index != -1) {
      _visits[index] = updatedVisit;
      await _saveVisits();
      notifyListeners();
    }
  }

  // Actualizar estado de visita
  Future<void> updateVisitStatus(String visitId, VisitStatus newStatus) async {
    final index = _visits.indexWhere((v) => v.id == visitId);
    if (index != -1) {
      _visits[index] = _visits[index].copyWith(status: newStatus);
      await _saveVisits();
      notifyListeners();
    }
  }

  // Agregar seguimiento
  Future<void> addFollowUp(String visitId, FollowUp followUp) async {
    final index = _visits.indexWhere((v) => v.id == visitId);
    if (index != -1) {
      final updatedFollowUps = [..._visits[index].followUps, followUp];
      _visits[index] = _visits[index].copyWith(followUps: updatedFollowUps);
      await _saveVisits();
      notifyListeners();
    }
  }

  // Obtener visitas por estado
  Map<VisitStatus, int> getVisitsByStatus() {
    final Map<VisitStatus, int> statusCount = {};
    
    for (final status in VisitStatus.values) {
      statusCount[status] = _visits.where((v) => v.status == status).length;
    }
    
    return statusCount;
  }

  // Obtener visitas por tipo
  Map<VisitorType, int> getVisitsByType() {
    final Map<VisitorType, int> typeCount = {};
    
    for (final type in VisitorType.values) {
      typeCount[type] = _visits.where((v) => v.visitorType == type).length;
    }
    
    return typeCount;
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return {
      'total': _visits.length,
      'thisMonth': _visits.where((v) => v.visitDate.isAfter(thisMonth)).length,
      'thisWeek': _visits.where((v) => v.visitDate.isAfter(thisWeek)).length,
      'newVisitors': _visits.where((v) => v.isFirstTime).length,
      'pendingFollowUp': _visits.where((v) => 
        v.wantsFollowUp && 
        (v.status == VisitStatus.newVisit || v.status == VisitStatus.contacted)
      ).length,
      'integrated': _visits.where((v) => v.status == VisitStatus.integrated).length,
    };
  }

  // Obtener visitas recientes
  List<Visit> getRecentVisits({int limit = 10}) {
    final recent = List<Visit>.from(_visits);
    recent.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return recent.take(limit).toList();
  }

  // Obtener seguimientos pendientes
  List<Visit> getPendingFollowUps() {
    return _visits.where((v) => 
      v.wantsFollowUp && 
      (v.status == VisitStatus.newVisit || v.status == VisitStatus.contacted)
    ).toList();
  }

  // Obtener visitantes regulares
  List<Visit> getRegularVisitors() {
    return _visits.where((v) => 
      v.visitorType == VisitorType.returnVisitor ||
      v.status == VisitStatus.followedUp
    ).toList();
  }

  // Obtener estadísticas de crecimiento
  Map<String, List<int>> getGrowthStatistics() {
    final now = DateTime.now();
    final last6Months = <int>[];
    
    for (int i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      
      final monthVisits = _visits.where((v) => 
        v.visitDate.isAfter(monthStart) && 
        v.visitDate.isBefore(monthEnd.add(const Duration(days: 1)))
      ).length;
      
      last6Months.add(monthVisits);
    }
    
    return {
      'visits': last6Months,
      'integration': last6Months.map((month) => (month * 0.3).round()).toList(),
    };
  }

  // Obtener iglesias con más visitas
  List<Map<String, dynamic>> getTopChurches() {
    final churchCount = <String, int>{};
    
    for (final visit in _visits) {
      churchCount[visit.churchLocation] = (churchCount[visit.churchLocation] ?? 0) + 1;
    }
    
    final sortedChurches = churchCount.entries.toList();
    sortedChurches.sort((a, b) => b.value.compareTo(a.value));
    
    return sortedChurches.take(5).map((entry) => {
      'name': entry.key,
      'visits': entry.value,
    }).toList();
  }

  // Refrescar datos
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    await _loadVisits();
    
    _isLoading = false;
    notifyListeners();
  }

  void _generateMockData() {
    if (_visits.isNotEmpty) return;

    final mockVisits = [
      Visit(
        id: 'visit_1',
        visitorName: 'Maria Andersson',
        visitorEmail: 'maria.andersson@email.com',
        visitorPhone: '+46 70 123 4567',
        visitorAddress: 'Storgatan 12, 11122 Stockholm',
        visitorType: VisitorType.visitor,
        churchLocation: 'VMF Sweden - Estocolmo',
        country: 'Suecia',
        visitDate: DateTime.now().subtract(const Duration(days: 3)),
        referredBy: 'Erik Johansson',
        interests: ['Juventud', 'Música', 'Estudio Bíblico'],
        status: VisitStatus.newVisit,
        notes: 'Primera vez en la iglesia. Mostró mucho interés en los programas juveniles. Viene de una familia cristiana en Colombia.',
        registeredBy: 'pastor_1',
        registeredByName: 'Pastor Anders Eriksson',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isFirstTime: true,
        ageGroup: '25-35',
        familyStatus: FamilyStatus.single,
        prayerRequests: ['Por trabajo estable', 'Por integración en Suecia'],
        wantsFollowUp: true,
        preferredContact: 'WhatsApp',
        followUps: [],
      ),

      Visit(
        id: 'visit_2',
        visitorName: 'Carlos y Ana Jiménez',
        visitorEmail: 'carlos.jimenez@email.com',
        visitorPhone: '+46 70 234 5678',
        visitorAddress: 'Drottninggatan 45, 11151 Stockholm',
        visitorType: VisitorType.returnVisitor,
        churchLocation: 'VMF Sweden - Estocolmo',
        country: 'Suecia',
        visitDate: DateTime.now().subtract(const Duration(days: 7)),
        referredBy: 'Margareta Lindström',
        interests: ['Matrimonio', 'Familia', 'Oración'],
        status: VisitStatus.contacted,
        notes: 'Pareja recién llegada de Colombia. Han asistido tres veces. Muy comprometidos y buscan integración.',
        registeredBy: 'pastor_2',
        registeredByName: 'Pastora Margareta Lindström',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        isFirstTime: false,
        ageGroup: '35-45',
        familyStatus: FamilyStatus.married,
        prayerRequests: ['Por sus hijos en Colombia', 'Por estabilidad económica'],
        wantsFollowUp: true,
        preferredContact: 'Llamada',
        followUps: [
          FollowUp(
            id: 'followup_1',
            visitId: 'visit_2',
            type: FollowUpType.call,
            content: 'Llamada de seguimiento. Muy contentos con la iglesia, planean venir regularmente.',
            performedBy: 'pastor_2',
            performedByName: 'Pastora Margareta',
            performedAt: DateTime.now().subtract(const Duration(days: 5)),
            result: FollowUpResult.successful,
            nextActionDate: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            nextActionNotes: 'Invitar a grupo de matrimonios',
          ),
        ],
      ),

      Visit(
        id: 'visit_3',
        visitorName: 'Sebastian Larsson',
        visitorEmail: 'sebastian.larsson@email.com',
        visitorPhone: '+46 70 345 6789',
        visitorType: VisitorType.newMember,
        churchLocation: 'VMF Sweden - Gotemburgo',
        country: 'Suecia',
        visitDate: DateTime.now().subtract(const Duration(days: 14)),
        referredBy: 'Sitio web VMF',
        interests: ['Ministerio Juvenil', 'Tecnología', 'Multimedia'],
        status: VisitStatus.integrated,
        notes: 'Joven sueco convertido hace 6 meses. Ya está sirviendo en el equipo técnico. Muy comprometido.',
        registeredBy: 'leader_1',
        registeredByName: 'Líder Lars Andersson',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        isFirstTime: true,
        ageGroup: '18-25',
        familyStatus: FamilyStatus.single,
        prayerRequests: ['Por crecimiento espiritual', 'Por testimonio en universidad'],
        wantsFollowUp: false, // Ya integrado
        preferredContact: 'Email',
        followUps: [
          FollowUp(
            id: 'followup_2',
            visitId: 'visit_3',
            type: FollowUpType.visit,
            content: 'Visita pastoral. Confirmó su compromiso con la iglesia y deseo de bautizarse.',
            performedBy: 'leader_1',
            performedByName: 'Líder Lars',
            performedAt: DateTime.now().subtract(const Duration(days: 10)),
            result: FollowUpResult.successful,
          ),
        ],
      ),

      Visit(
        id: 'visit_4',
        visitorName: 'Rosa Martinez',
        visitorEmail: 'rosa.martinez@email.com',
        visitorPhone: '+46 70 456 7890',
        visitorAddress: 'Kungsgatan 78, 41119 Göteborg',
        visitorType: VisitorType.visitor,
        churchLocation: 'VMF Sweden - Gotemburgo',
        country: 'Suecia',
        visitDate: DateTime.now().subtract(const Duration(days: 1)),
        referredBy: 'Ana Petersson',
        interests: ['Oración', 'Ministerio Femenino', 'Intercesión'],
        status: VisitStatus.newVisit,
        notes: 'Hermana con experiencia en intercesión. Viene de otra denominación. Busca iglesia que hable español.',
        registeredBy: 'pastor_3',
        registeredByName: 'Pastor Miguel Rodriguez',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isFirstTime: true,
        ageGroup: '45-55',
        familyStatus: FamilyStatus.widowed,
        prayerRequests: ['Por sanidad emocional', 'Por dirección de Dios'],
        wantsFollowUp: true,
        preferredContact: 'WhatsApp',
        followUps: [],
      ),

      Visit(
        id: 'visit_5',
        visitorName: 'Familia Gonzalez',
        visitorEmail: 'pedro.gonzalez@email.com',
        visitorPhone: '+46 70 567 8901',
        visitorAddress: 'Vasagatan 23, 75320 Uppsala',
        visitorType: VisitorType.transferMember,
        churchLocation: 'VMF Sweden - Uppsala',
        country: 'Suecia',
        visitDate: DateTime.now().subtract(const Duration(days: 21)),
        referredBy: 'Pastor VMF España',
        interests: ['Familia', 'Niños', 'Misiones'],
        status: VisitStatus.followedUp,
        notes: 'Familia misionera que se muda a Suecia. Padres con 3 niños. Experiencia en ministerio infantil.',
        registeredBy: 'pastor_4',
        registeredByName: 'Pastor Jonas Nilsson',
        createdAt: DateTime.now().subtract(const Duration(days: 21)),
        isFirstTime: false, // Miembros transferidos
        ageGroup: '35-45',
        familyStatus: FamilyStatus.family,
        prayerRequests: ['Por adaptación cultural', 'Por ministerio en Suecia'],
        wantsFollowUp: true,
        preferredContact: 'Email',
        followUps: [
          FollowUp(
            id: 'followup_3',
            visitId: 'visit_5',
            type: FollowUpType.email,
            content: 'Email de bienvenida con información sobre ministerios familiares y programa infantil.',
            performedBy: 'pastor_4',
            performedByName: 'Pastor Jonas',
            performedAt: DateTime.now().subtract(const Duration(days: 18)),
            result: FollowUpResult.successful,
            nextActionDate: DateTime.now().add(const Duration(days: 3)).toIso8601String(),
            nextActionNotes: 'Reunión para integración en ministerio infantil',
          ),
        ],
      ),

      Visit(
        id: 'visit_6',
        visitorName: 'David Eriksson',
        visitorEmail: 'david.erik@email.com',
        visitorPhone: '+46 70 678 9012',
        visitorType: VisitorType.guest,
        churchLocation: 'VMF Sweden - Estocolmo',
        country: 'Suecia',
        visitDate: DateTime.now().subtract(const Duration(days: 30)),
        referredBy: 'Evento especial - Conferencia',
        interests: ['Liderazgo', 'Enseñanza', 'Pastoral'],
        status: VisitStatus.inactive,
        notes: 'Pastor visitante de otra denominación. Vino a conferencia especial. No mostró interés en integrarse.',
        registeredBy: 'pastor_1',
        registeredByName: 'Pastor Anders Eriksson',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isFirstTime: true,
        ageGroup: '55+',
        familyStatus: FamilyStatus.married,
        prayerRequests: [],
        wantsFollowUp: false,
        preferredContact: 'Email',
        followUps: [
          FollowUp(
            id: 'followup_4',
            visitId: 'visit_6',
            type: FollowUpType.email,
            content: 'Email de agradecimiento por su visita y materiales de la conferencia.',
            performedBy: 'pastor_1',
            performedByName: 'Pastor Anders',
            performedAt: DateTime.now().subtract(const Duration(days: 28)),
            result: FollowUpResult.noResponse,
          ),
        ],
      ),
    ];

    _visits = mockVisits;
    _saveVisits();
    notifyListeners();
  }

  // Getters adicionales para estadísticas
  int get totalVisits => _visits.length;
  int get activeVisits => _visits.where((v) => v.status == VisitStatus.newVisit || v.status == VisitStatus.contacted).length;
  
  int get todayVisits {
    final today = DateTime.now();
    return _visits.where((visit) => 
      visit.visitDate.year == today.year &&
      visit.visitDate.month == today.month &&
      visit.visitDate.day == today.day
    ).length;
  }
  
  List<Map<String, dynamic>> get countryStats {
    final Map<String, int> stats = {};
    for (final visit in _visits) {
      stats[visit.country] = (stats[visit.country] ?? 0) + 1;
    }
    return stats.entries.map((entry) => {
      'country': entry.key,
      'count': entry.value,
    }).toList();
  }
  
  List<String> get recentActivitySummary {
    final recent = _visits.where((visit) => 
      DateTime.now().difference(visit.visitDate).inDays <= 7
    ).toList();
    
    return recent.map((visit) => 
      '${visit.visitorName} visitó ${visit.churchLocation} hace ${DateTime.now().difference(visit.visitDate).inDays} días'
    ).toList();
  }
}