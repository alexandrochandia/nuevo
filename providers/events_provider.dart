import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../config/supabase_config.dart';

class EventsProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;
  EventType? _selectedFilter;
  String _searchQuery = '';

  // Getters
  List<EventModel> get events => _filteredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  EventType? get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  // Mock data for testing while Supabase is not configured for events
  List<EventModel> get _mockEvents => [
    EventModel(
      id: '1',
      titulo: 'Culto Dominical',
      descripcion: 'Únete a nosotros en nuestro culto dominical lleno del Espíritu Santo. Experimentaremos la presencia de Dios a través de la adoración, la palabra y la comunión fraternal.',
      descripcionCorta: 'Culto dominical con adoración y predicación',
      fechaInicio: DateTime.now().add(const Duration(days: 7)),
      fechaFin: DateTime.now().add(const Duration(days: 7, hours: 2)),
      ubicacion: 'Iglesia VMF Sweden - Estocolmo',
      direccion: 'Gamla Stan 15, Stockholm, Sweden',
      imagenUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
      tipo: EventType.culto,
      estado: EventStatus.proximo,
      precio: 0.0,
      esPremium: false,
      requiresRegistration: true,
      capacidadMaxima: 200,
      registrados: 45,
      tags: ['adoración', 'predicación', 'comunión'],
      organizador: 'Pastor VMF Sweden',
      contactoInfo: 'info@vmfsweden.se',
    ),
    EventModel(
      id: '2',
      titulo: 'Conferencia Profética 2025',
      descripcion: 'Una conferencia especial con profetas reconocidos internacionalmente. Tres días de encuentro con Dios, revelación profética y ministerio de sanidad divina.',
      descripcionCorta: 'Conferencia con profetas internacionales',
      fechaInicio: DateTime.now().add(const Duration(days: 30)),
      fechaFin: DateTime.now().add(const Duration(days: 32)),
      ubicacion: 'Centro de Convenciones Stockholm',
      direccion: 'Stockholmsmässan, Älvsjö, Sweden',
      imagenUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&h=600&fit=crop',
      tipo: EventType.conferencia,
      estado: EventStatus.proximo,
      precio: 150.0,
      esPremium: true,
      requiresRegistration: true,
      capacidadMaxima: 1000,
      registrados: 234,
      tags: ['profético', 'sanidad', 'internacional'],
      organizador: 'VMF Sweden Internacional',
      contactoInfo: 'conferencias@vmfsweden.se',
    ),
    EventModel(
      id: '3',
      titulo: 'Retiro Juvenil de Verano',
      descripcion: 'Campamento de verano para jóvenes de 16-25 años. Actividades al aire libre, talleres de liderazgo, momentos de adoración y diversión asegurada.',
      descripcionCorta: 'Campamento de verano para jóvenes',
      fechaInicio: DateTime.now().add(const Duration(days: 60)),
      fechaFin: DateTime.now().add(const Duration(days: 63)),
      ubicacion: 'Campamento Skärgården',
      direccion: 'Archipelago Islands, Stockholm',
      imagenUrl: 'https://images.unsplash.com/photo-1519167758481-83f29c5cae15?w=800&h=600&fit=crop',
      tipo: EventType.juvenil,
      estado: EventStatus.proximo,
      precio: 200.0,
      esPremium: false,
      requiresRegistration: true,
      capacidadMaxima: 80,
      registrados: 23,
      tags: ['jóvenes', 'campamento', 'liderazgo'],
      organizador: 'Ministerio Juvenil VMF',
      contactoInfo: 'jovenes@vmfsweden.se',
    ),
    EventModel(
      id: '4',
      titulo: 'Seminario de Matrimonios',
      descripcion: 'Fortalece tu matrimonio con principios bíblicos. Talleres prácticos para parejas que desean crecer juntos en el amor de Cristo.',
      descripcionCorta: 'Talleres para fortalecer matrimonios',
      fechaInicio: DateTime.now().add(const Duration(days: 14)),
      fechaFin: DateTime.now().add(const Duration(days: 14, hours: 6)),
      ubicacion: 'Iglesia VMF Sweden - Salón Principal',
      direccion: 'Gamla Stan 15, Stockholm, Sweden',
      imagenUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800&h=600&fit=crop',
      tipo: EventType.seminario,
      estado: EventStatus.proximo,
      precio: 50.0,
      esPremium: false,
      requiresRegistration: true,
      capacidadMaxima: 40,
      registrados: 18,
      tags: ['matrimonio', 'familia', 'talleres'],
      organizador: 'Pastor de Parejas',
      contactoInfo: 'matrimonios@vmfsweden.se',
    ),
    EventModel(
      id: '5',
      titulo: 'Transmisión EN VIVO',
      descripcion: 'Culto especial transmitido en vivo para toda la comunidad mundial VMF. Únete desde cualquier lugar del mundo.',
      descripcionCorta: 'Culto en vivo por YouTube',
      fechaInicio: DateTime.now().subtract(const Duration(hours: 1)),
      fechaFin: DateTime.now().add(const Duration(hours: 1)),
      ubicacion: 'Online - YouTube Live',
      direccion: 'Transmisión mundial',
      imagenUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=800&h=600&fit=crop',
      tipo: EventType.especial,
      estado: EventStatus.enVivo,
      precio: 0.0,
      esPremium: false,
      requiresRegistration: false,
      capacidadMaxima: 0,
      registrados: 1247,
      tags: ['online', 'mundial', 'live'],
      linkTransmision: 'https://youtube.com/vmfsweden',
      organizador: 'VMF Sweden Media',
      contactoInfo: 'media@vmfsweden.se',
    ),
  ];

  EventsProvider() {
    loadEvents();
  }

  Future<void> loadEvents() async {
    _setLoading(true);
    _error = null;

    try {
      // Try to load from Supabase first
      if (SupabaseConfig.client != null) {
        await _loadFromSupabase();
      } else {
        // Use mock data as fallback
        _events = _mockEvents;
      }
      
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      // Use mock data as fallback on error
      _events = _mockEvents;
      _applyFilters();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadFromSupabase() async {
    try {
      final response = await SupabaseConfig.client!
          .from('events')
          .select()
          .order('fecha_inicio', ascending: true);

      _events = (response as List)
          .map((eventData) => EventModel.fromJson(eventData))
          .toList();

      if (_events.isEmpty) {
        // If no events in Supabase, use mock data
        _events = _mockEvents;
      }
    } catch (e) {
      // On error, use mock data
      _events = _mockEvents;
    }
  }

  void _applyFilters() {
    _filteredEvents = _events.where((event) {
      bool matchesFilter = true;
      bool matchesSearch = true;

      // Apply type filter
      if (_selectedFilter != null) {
        matchesFilter = event.tipo == _selectedFilter;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        matchesSearch = event.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      event.descripcion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      event.ubicacion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      event.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }

      return matchesFilter && matchesSearch;
    }).toList();

    // Sort by date (upcoming first, live events at top)
    _filteredEvents.sort((a, b) {
      if (a.estado == EventStatus.enVivo && b.estado != EventStatus.enVivo) return -1;
      if (b.estado == EventStatus.enVivo && a.estado != EventStatus.enVivo) return 1;
      return a.fechaInicio.compareTo(b.fechaInicio);
    });

    notifyListeners();
  }

  void setFilter(EventType? filter) {
    _selectedFilter = filter;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    _selectedFilter = null;
    _searchQuery = '';
    _applyFilters();
  }

  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EventModel> getUpcomingEvents() {
    return _events.where((event) => event.estado == EventStatus.proximo).toList()
      ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
  }

  List<EventModel> getLiveEvents() {
    return _events.where((event) => event.estado == EventStatus.enVivo).toList();
  }

  List<EventModel> getPremiumEvents() {
    return _events.where((event) => event.esPremium).toList();
  }

  Future<bool> registerForEvent(String eventId) async {
    try {
      final event = getEventById(eventId);
      if (event == null) return false;

      if (!event.hasAvailableSeats) return false;

      // TODO: Implement actual registration logic with Supabase
      // For now, just simulate registration
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local count (in real app, this would come from server)
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        // Note: This creates a new object since EventModel is immutable
        // In real implementation, this would be handled by the server
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}