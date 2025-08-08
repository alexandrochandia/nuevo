import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/ministry_model.dart';

class MinistryProvider with ChangeNotifier {
  List<Ministry> _ministries = [];
  List<MinistryCategory> _selectedCategories = [];
  List<MinistryStatus> _selectedStatuses = [];
  String _searchQuery = '';
  bool _showOnlyRecruiting = false;
  bool _isLoading = false;
  String _error = '';
  String _currentUserId = 'user_current'; // Simulado

  List<Ministry> get ministries => _filteredMinistries;
  List<Ministry> get allMinistries => _ministries;
  List<MinistryCategory> get selectedCategories => _selectedCategories;
  List<MinistryStatus> get selectedStatuses => _selectedStatuses;
  String get searchQuery => _searchQuery;
  bool get showOnlyRecruiting => _showOnlyRecruiting;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentUserId => _currentUserId;

  List<Ministry> get _filteredMinistries {
    var filtered = List<Ministry>.from(_ministries);

    // Filtrar por categorías
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((ministry) => 
        _selectedCategories.contains(ministry.category)
      ).toList();
    }

    // Filtrar por estados
    if (_selectedStatuses.isNotEmpty) {
      filtered = filtered.where((ministry) => 
        _selectedStatuses.contains(ministry.status)
      ).toList();
    }

    // Filtrar solo ministerios reclutando
    if (_showOnlyRecruiting) {
      filtered = filtered.where((ministry) => ministry.isRecruiting).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((ministry) =>
        ministry.name.toLowerCase().contains(query) ||
        ministry.description.toLowerCase().contains(query) ||
        ministry.leaderName.toLowerCase().contains(query) ||
        ministry.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    // Ordenar por estado (activos primero) y luego por nombre
    filtered.sort((a, b) {
      if (a.status != b.status) {
        if (a.status == MinistryStatus.active) return -1;
        if (b.status == MinistryStatus.active) return 1;
        if (a.status == MinistryStatus.recruiting) return -1;
        if (b.status == MinistryStatus.recruiting) return 1;
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  MinistryProvider() {
    _loadMinistries();
    _generateMockData();
  }

  // Cargar ministerios
  Future<void> _loadMinistries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ministriesJson = prefs.getStringList('ministries') ?? [];
      
      _ministries = ministriesJson
          .map((json) => Ministry.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar ministerios: $e';
      debugPrint(_error);
    }
  }

  // Guardar ministerios
  Future<void> _saveMinistries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ministriesJson = _ministries
          .map((ministry) => jsonEncode(ministry.toJson()))
          .toList();
      await prefs.setStringList('ministries', ministriesJson);
    } catch (e) {
      debugPrint('Error saving ministries: $e');
    }
  }

  // Aplicar filtros
  void applyFilters({
    List<MinistryCategory>? categories,
    List<MinistryStatus>? statuses,
    String? searchQuery,
    bool? showOnlyRecruiting,
  }) {
    _selectedCategories = categories ?? _selectedCategories;
    _selectedStatuses = statuses ?? _selectedStatuses;
    _searchQuery = searchQuery ?? _searchQuery;
    _showOnlyRecruiting = showOnlyRecruiting ?? _showOnlyRecruiting;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedCategories = [];
    _selectedStatuses = [];
    _searchQuery = '';
    _showOnlyRecruiting = false;
    notifyListeners();
  }

  // Unirse a ministerio
  Future<void> joinMinistry(String ministryId) async {
    final index = _ministries.indexWhere((m) => m.id == ministryId);
    if (index == -1) return;

    final ministry = _ministries[index];
    
    // Verificar si ya es miembro
    if (ministry.members.contains(_currentUserId)) {
      return; // Ya es miembro
    }

    // Verificar límite de miembros
    if (ministry.members.length >= ministry.maxMembers) {
      _error = 'El ministerio ha alcanzado su límite de miembros';
      notifyListeners();
      return;
    }

    final updatedMinistry = ministry.copyWith(
      members: [...ministry.members, _currentUserId],
    );

    _ministries[index] = updatedMinistry;
    await _saveMinistries();
    notifyListeners();
  }

  // Salir de ministerio
  Future<void> leaveMinistry(String ministryId) async {
    final index = _ministries.indexWhere((m) => m.id == ministryId);
    if (index == -1) return;

    final ministry = _ministries[index];
    final updatedMembers = ministry.members.where((id) => id != _currentUserId).toList();

    final updatedMinistry = ministry.copyWith(members: updatedMembers);

    _ministries[index] = updatedMinistry;
    await _saveMinistries();
    notifyListeners();
  }

  // Obtener ministerios del usuario
  List<Ministry> getUserMinistries() {
    return _ministries
        .where((m) => m.members.contains(_currentUserId) || m.leaderId == _currentUserId)
        .toList();
  }

  // Obtener ministerios que lidera
  List<Ministry> getLeadingMinistries() {
    return _ministries
        .where((m) => m.leaderId == _currentUserId)
        .toList();
  }

  // Obtener ministerios por categoría
  Map<MinistryCategory, int> getMinistriesByCategory() {
    final Map<MinistryCategory, int> categoryCount = {};
    
    for (final category in MinistryCategory.values) {
      categoryCount[category] = _ministries
          .where((m) => m.category == category)
          .length;
    }
    
    return categoryCount;
  }

  // Obtener estadísticas
  Map<String, int> getStatistics() {
    return {
      'total': _ministries.length,
      'active': _ministries.where((m) => m.status == MinistryStatus.active).length,
      'recruiting': _ministries.where((m) => m.isRecruiting).length,
      'myMinistries': getUserMinistries().length,
      'leading': getLeadingMinistries().length,
    };
  }

  // Obtener ministerios destacados (con más miembros)
  List<Ministry> getFeaturedMinistries() {
    final featured = List<Ministry>.from(_ministries);
    featured.sort((a, b) => b.members.length.compareTo(a.members.length));
    return featured.take(6).toList();
  }

  // Obtener próximos eventos
  List<MinistryEvent> getUpcomingEvents() {
    final allEvents = <MinistryEvent>[];
    final now = DateTime.now();
    
    for (final ministry in _ministries) {
      for (final event in ministry.events) {
        if (event.date.isAfter(now)) {
          allEvents.add(event);
        }
      }
    }
    
    allEvents.sort((a, b) => a.date.compareTo(b.date));
    return allEvents.take(10).toList();
  }

  // Obtener anuncios recientes
  List<MinistryAnnouncement> getRecentAnnouncements() {
    final allAnnouncements = <MinistryAnnouncement>[];
    
    for (final ministry in _ministries) {
      allAnnouncements.addAll(ministry.announcements);
    }
    
    allAnnouncements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allAnnouncements.take(20).toList();
  }

  // Refrescar datos
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    await _loadMinistries();
    
    _isLoading = false;
    notifyListeners();
  }

  void _generateMockData() {
    if (_ministries.isNotEmpty) return;

    final mockMinistries = [
      Ministry(
        id: 'ministry_1',
        name: 'Ministerio de Adoración',
        description: 'Dirigimos la alabanza y adoración durante los servicios dominicales y eventos especiales. Buscamos músicos, cantantes y técnicos de sonido comprometidos.',
        leaderName: 'Erik Johansson',
        leaderId: 'leader_1',
        leaderImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        category: MinistryCategory.worship,
        status: MinistryStatus.recruiting,
        members: ['member_1', 'member_2', 'member_3', 'member_4'],
        requirements: [
          'Experiencia musical (instrumento o vocal)',
          'Compromiso con ensayos semanales',
          'Corazón de adorador',
          'Disponibilidad domingos'
        ],
        activities: [
          'Ensayos semanales',
          'Servicios dominicales',
          'Eventos especiales',
          'Conferencias de adoración'
        ],
        tags: ['música', 'adoración', 'alabanza', 'ministerio'],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        nextMeeting: DateTime.now().add(const Duration(days: 3)),
        meetingLocation: 'Salón de música, VMF Estocolmo',
        maxMembers: 25,
        isRecruiting: true,
        events: [
          MinistryEvent(
            id: 'event_1',
            title: 'Ensayo General',
            description: 'Ensayo para el servicio dominical',
            date: DateTime.now().add(const Duration(days: 3)),
            location: 'Salón de música',
            type: EventType.meeting,
          ),
          MinistryEvent(
            id: 'event_2',
            title: 'Taller de Nuevas Canciones',
            description: 'Aprendiendo el nuevo repertorio',
            date: DateTime.now().add(const Duration(days: 10)),
            location: 'Salón principal',
            type: EventType.training,
          ),
        ],
        announcements: [
          MinistryAnnouncement(
            id: 'ann_1',
            title: 'Nuevo repertorio disponible',
            content: 'Las partituras del nuevo repertorio están disponibles en el grupo de WhatsApp.',
            authorName: 'Erik Johansson',
            authorId: 'leader_1',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            priority: AnnouncementPriority.normal,
          ),
        ],
      ),

      Ministry(
        id: 'ministry_2',
        name: 'Ministerio Juvenil',
        description: 'Enfocados en alcanzar y discipular a la nueva generación. Organizamos actividades, estudios bíblicos y eventos para jóvenes de 13-25 años.',
        leaderName: 'Pastora Margareta Lindström',
        leaderId: 'leader_2',
        leaderImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
        category: MinistryCategory.youth,
        status: MinistryStatus.active,
        members: ['member_5', 'member_6', 'member_7', 'member_8', 'member_9'],
        requirements: [
          'Corazón para los jóvenes',
          'Madurez espiritual',
          'Disponibilidad viernes y sábados',
          'Experiencia con jóvenes (deseable)'
        ],
        activities: [
          'Reuniones de jóvenes',
          'Estudios bíblicos',
          'Actividades recreativas',
          'Campamentos anuales'
        ],
        tags: ['juventud', 'discipulado', 'actividades', 'formación'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        nextMeeting: DateTime.now().add(const Duration(days: 2)),
        meetingLocation: 'Sala juvenil, VMF Estocolmo',
        maxMembers: 30,
        isRecruiting: false,
        events: [
          MinistryEvent(
            id: 'event_3',
            title: 'Noche de Jóvenes',
            description: 'Alabanza, mensaje y confraternidad',
            date: DateTime.now().add(const Duration(days: 2)),
            location: 'Sala juvenil',
            type: EventType.service,
          ),
        ],
        announcements: [
          MinistryAnnouncement(
            id: 'ann_2',
            title: 'Campamento de verano',
            content: 'Ya están abiertas las inscripciones para el campamento de verano 2025.',
            authorName: 'Pastora Margareta',
            authorId: 'leader_2',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            priority: AnnouncementPriority.high,
            isPinned: true,
          ),
        ],
      ),

      Ministry(
        id: 'ministry_3',
        name: 'Ministerio de Intercesión',
        description: 'Nos dedicamos a la oración intercesora por la iglesia, los pastores, las familias y las necesidades de la comunidad VMF.',
        leaderName: 'Ana Petersson',
        leaderId: 'leader_3',
        leaderImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        category: MinistryCategory.intercession,
        status: MinistryStatus.active,
        members: ['member_10', 'member_11', 'member_12'],
        requirements: [
          'Vida de oración establecida',
          'Discreción y confidencialidad',
          'Compromiso con reuniones semanales',
          'Corazón pastoral'
        ],
        activities: [
          'Reuniones de oración',
          'Intercesión pastoral',
          'Cadenas de oración',
          'Vigilias especiales'
        ],
        tags: ['oración', 'intercesión', 'guerra espiritual', 'pastoral'],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        nextMeeting: DateTime.now().add(const Duration(days: 1)),
        meetingLocation: 'Salón de oración, VMF Estocolmo',
        maxMembers: 15,
        isRecruiting: true,
        events: [
          MinistryEvent(
            id: 'event_4',
            title: 'Reunión de Intercesión',
            description: 'Oración por las necesidades de la iglesia',
            date: DateTime.now().add(const Duration(days: 1)),
            location: 'Salón de oración',
            type: EventType.meeting,
          ),
        ],
      ),

      Ministry(
        id: 'ministry_4',
        name: 'Ministerio de Misiones',
        description: 'Enfocados en apoyar misioneros y proyectos misioneros alrededor del mundo, especialmente en África y Latinoamérica.',
        leaderName: 'Pastor Anders Eriksson',
        leaderId: 'leader_4',
        leaderImageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200',
        category: MinistryCategory.missions,
        status: MinistryStatus.recruiting,
        members: ['member_13', 'member_14'],
        requirements: [
          'Visión misionera',
          'Capacidad de organización',
          'Compromiso financiero',
          'Disponibilidad para viajes (ocasional)'
        ],
        activities: [
          'Apoyo a misioneros',
          'Recaudación de fondos',
          'Viajes misioneros',
          'Conciencia misionera'
        ],
        tags: ['misiones', 'mundial', 'evangelismo', 'apoyo'],
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        nextMeeting: DateTime.now().add(const Duration(days: 7)),
        meetingLocation: 'Oficina pastoral, VMF Estocolmo',
        maxMembers: 20,
        isRecruiting: true,
        events: [
          MinistryEvent(
            id: 'event_5',
            title: 'Planificación Proyecto África',
            description: 'Organización del próximo viaje misionero',
            date: DateTime.now().add(const Duration(days: 7)),
            location: 'Oficina pastoral',
            type: EventType.meeting,
          ),
        ],
        announcements: [
          MinistryAnnouncement(
            id: 'ann_3',
            title: 'Meta de apoyo misionero',
            content: 'Necesitamos alcanzar 100,000 SEK para el proyecto de pozos de agua en África.',
            authorName: 'Pastor Anders',
            authorId: 'leader_4',
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
            priority: AnnouncementPriority.urgent,
            isPinned: true,
          ),
        ],
      ),

      Ministry(
        id: 'ministry_5',
        name: 'Ministerio de Niños',
        description: 'Dedicados a la enseñanza y cuidado de los niños durante los servicios, con programas educativos adaptados a cada edad.',
        leaderName: 'Lucía Eriksson',
        leaderId: 'leader_5',
        leaderImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
        category: MinistryCategory.children,
        status: MinistryStatus.recruiting,
        members: ['member_15', 'member_16', 'member_17'],
        requirements: [
          'Amor por los niños',
          'Paciencia y creatividad',
          'Certificado de antecedentes',
          'Disponibilidad dominical'
        ],
        activities: [
          'Escuela dominical',
          'Actividades recreativas',
          'Programas especiales',
          'Eventos familiares'
        ],
        tags: ['niños', 'educación', 'familia', 'creatividad'],
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        nextMeeting: DateTime.now().add(const Duration(days: 5)),
        meetingLocation: 'Aula infantil, VMF Estocolmo',
        maxMembers: 20,
        isRecruiting: true,
        events: [
          MinistryEvent(
            id: 'event_6',
            title: 'Planificación Programa Navidad',
            description: 'Preparación del programa navideño infantil',
            date: DateTime.now().add(const Duration(days: 5)),
            location: 'Aula infantil',
            type: EventType.meeting,
          ),
        ],
      ),

      Ministry(
        id: 'ministry_6',
        name: 'Ministerio de Hospitalidad',
        description: 'Nos encargamos de recibir a visitantes, servir café, organizar eventos sociales y crear un ambiente acogedor en la iglesia.',
        leaderName: 'Carlos Andersson',
        leaderId: 'leader_6',
        leaderImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
        category: MinistryCategory.hospitality,
        status: MinistryStatus.active,
        members: ['member_18', 'member_19', 'member_20', 'member_21'],
        requirements: [
          'Actitud servicial',
          'Amabilidad y carisma',
          'Puntualidad',
          'Capacidad para trabajar en equipo'
        ],
        activities: [
          'Recepción de visitantes',
          'Servicio de café',
          'Eventos sociales',
          'Decoración especial'
        ],
        tags: ['hospitalidad', 'servicio', 'recepción', 'eventos'],
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        nextMeeting: DateTime.now().add(const Duration(days: 4)),
        meetingLocation: 'Vestíbulo principal, VMF Estocolmo',
        maxMembers: 25,
        isRecruiting: false,
        events: [
          MinistryEvent(
            id: 'event_7',
            title: 'Evento de Confraternidad',
            description: 'Organización del almuerzo comunitario',
            date: DateTime.now().add(const Duration(days: 4)),
            location: 'Salón social',
            type: EventType.fellowship,
          ),
        ],
      ),
    ];

    _ministries = mockMinistries;
    _saveMinistries();
    notifyListeners();
  }
}