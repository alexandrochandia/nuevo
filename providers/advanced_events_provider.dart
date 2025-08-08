import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/advanced_event_model.dart';
import '../services/qr_service.dart';
import '../services/pdf_service.dart';
import '../services/email_service.dart';

class AdvancedEventsProvider with ChangeNotifier {
  List<AdvancedEventModel> _events = [];
  List<AdvancedEventModel> _filteredEvents = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  String _selectedStatus = 'Todos';
  String _sortBy = 'fecha';
  String _currentFilter = 'Todos';

  final QRService _qrService = QRService();
  final PDFService _pdfService = PDFService();
  final EmailService _emailService = EmailService();

  // Getters
  List<AdvancedEventModel> get events => _filteredEvents;
  List<AdvancedEventModel> get allEvents => _events;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get sortBy => _sortBy;
  String get currentFilter => _currentFilter;

  // ✅ Nuevo método Supabase
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('events') // ← Asegúrate que esta tabla exista en Supabase
          .select()
          .order('date', ascending: true);

      final List<AdvancedEventModel> loaded = response.map<AdvancedEventModel>((data) {
        return AdvancedEventModel.fromJson(data); // ← Cambiado a fromJson
      }).toList();

      _events = loaded;
      _filteredEvents = loaded;
    } catch (e) {
      debugPrint('❌ Error al cargar eventos desde Supabase: $e');
      // Si hay error, cargar datos de ejemplo
      _loadSampleEvents();
      return;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Categorías disponibles
  List<String> get categories => [
    'Todos',
    'Conferencia',
    'Taller',
    'Seminario',
    'Retiro',
    'Concierto',
    'Oración',
    'Estudio Bíblico',
    'Juventud',
    'Niños',
    'Familias'
  ];

  // Estados disponibles
  List<String> get statuses => [
    'Todos',
    'Próximos',
    'En curso',
    'Finalizados',
    'Cancelados'
  ];

  // Opciones de ordenamiento
  List<String> get sortOptions => [
    'fecha',
    'nombre',
    'popularidad',
    'precio'
  ];

  // Estadísticas
  int get totalEvents => _events.length;
  int get upcomingEvents => _events.where((e) => e.isUpcoming).length;
  int get ongoingEvents => _events.where((e) => e.isOngoing).length;
  int get pastEvents => _events.where((e) => e.isPast).length;
  int get totalAttendees => _events.fold(0, (sum, e) => sum + e.attendees.length);
  double get averageAttendance => _events.isEmpty ? 0 : totalAttendees / _events.length;

  AdvancedEventsProvider() {
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    _isLoading = true;
    notifyListeners();

    // Datos de ejemplo
    _events = [
      AdvancedEventModel(
        id: '1',
        title: 'Conferencia VMF 2024',
        description: 'Gran conferencia anual de VMF Sweden con invitados internacionales',
        longDescription: 'Únete a nosotros en la conferencia más importante del año. Tendremos oradores de renombre mundial, talleres especializados y momentos de adoración únicos.',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 32)),
        location: 'Centro de Convenciones Stockholm',
        address: 'Stockholmsmässan, Mässvägen 1, 125 80 Älvsjö',
        latitude: 59.2639,
        longitude: 17.9957,
        imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
        galleryImages: [
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
          'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
          'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800',
        ],
        category: 'Conferencia',
        organizer: 'VMF Sweden',
        organizerContact: 'eventos@vmfsweden.se',
        ticketTiers: [
          TicketTier(
            id: 't1',
            name: 'Entrada General',
            description: 'Acceso a todas las sesiones principales',
            price: 299.0,
            totalQuantity: 500,
            soldQuantity: 150,
            color: Colors.blue,
            benefits: ['Acceso a sesiones principales', 'Material del evento', 'Refrigerios'],
          ),
          TicketTier(
            id: 't2',
            name: 'VIP',
            description: 'Acceso completo + meet & greet',
            price: 599.0,
            totalQuantity: 100,
            soldQuantity: 45,
            color: Colors.amber,
            benefits: ['Todo lo anterior', 'Meet & greet con oradores', 'Cena especial', 'Asientos preferenciales'],
          ),
        ],
        attendees: [],
        agenda: [
          EventAgendaItem(
            id: 'a1',
            title: 'Apertura y Adoración',
            description: 'Momento de adoración y bienvenida',
            startTime: DateTime.now().add(const Duration(days: 30, hours: 9)),
            endTime: DateTime.now().add(const Duration(days: 30, hours: 10)),
            speaker: 'Equipo de Adoración VMF',
            location: 'Auditorio Principal',
            icon: Icons.music_note,
          ),
          EventAgendaItem(
            id: 'a2',
            title: 'Conferencia Magistral',
            description: 'Mensaje principal del evento',
            startTime: DateTime.now().add(const Duration(days: 30, hours: 10, minutes: 30)),
            endTime: DateTime.now().add(const Duration(days: 30, hours: 12)),
            speaker: 'Pastor John Smith',
            location: 'Auditorio Principal',
            icon: Icons.mic,
          ),
        ],
        maxAttendees: 600,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        isFeatured: true,
      ),
      AdvancedEventModel(
        id: '2',
        title: 'Retiro de Jóvenes',
        description: 'Fin de semana especial para jóvenes de 16-25 años',
        longDescription: 'Un fin de semana transformador diseñado especialmente para jóvenes. Incluye actividades al aire libre, talleres de liderazgo y momentos de reflexión espiritual.',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 17)),
        location: 'Camp Lejondal',
        address: 'Lejondalsvägen 1, 645 92 Strängnäs',
        latitude: 59.3774,
        longitude: 17.0280,
        imageUrl: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=800',
        galleryImages: [
          'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=800',
          'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?w=800',
        ],
        category: 'Juventud',
        organizer: 'Ministerio de Jóvenes VMF',
        organizerContact: 'jovenes@vmfsweden.se',
        ticketTiers: [
          TicketTier(
            id: 't3',
            name: 'Participante',
            description: 'Incluye alojamiento y todas las comidas',
            price: 450.0,
            totalQuantity: 80,
            soldQuantity: 65,
            color: Colors.green,
            benefits: ['Alojamiento 2 noches', 'Todas las comidas', 'Actividades', 'Material del retiro'],
          ),
        ],
        attendees: [],
        agenda: [],
        maxAttendees: 80,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        isFeatured: false,
      ),
    ];

    _filteredEvents = List.from(_events);
    _isLoading = false;
    notifyListeners();
  }

  // Búsqueda y filtros
  void searchEvents(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    _currentFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void sortEvents(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredEvents = List.from(_events);

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      _filteredEvents = _filteredEvents.where((event) =>
      event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Aplicar filtro de categoría
    if (_selectedCategory != 'Todos') {
      _filteredEvents = _filteredEvents.where((event) => event.category == _selectedCategory).toList();
    }

    // Aplicar filtro de estado
    if (_selectedStatus != 'Todos') {
      switch (_selectedStatus) {
        case 'Próximos':
          _filteredEvents = _filteredEvents.where((event) => event.isUpcoming).toList();
          break;
        case 'En curso':
          _filteredEvents = _filteredEvents.where((event) => event.isOngoing).toList();
          break;
        case 'Finalizados':
          _filteredEvents = _filteredEvents.where((event) => event.isPast).toList();
          break;
      }
    }

    // Aplicar ordenamiento
    switch (_sortBy) {
      case 'fecha':
        _filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case 'nombre':
        _filteredEvents.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'popularidad':
        _filteredEvents.sort((a, b) => b.totalSoldTickets.compareTo(a.totalSoldTickets));
        break;
      case 'precio':
        _filteredEvents.sort((a, b) => a.lowestPrice.compareTo(b.lowestPrice));
        break;
    }

    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'Todos';
    _selectedStatus = 'Todos';
    _currentFilter = 'Todos';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // CRUD Operations
  Future<void> createEvent(AdvancedEventModel event) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular API call
      await Future.delayed(const Duration(seconds: 1));

      _events.add(event);
      _applyFilters();

      // Enviar email de confirmación al organizador
      await _emailService.sendEventCreatedEmail(event);

    } catch (e) {
      throw Exception('Error al crear evento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEvent(AdvancedEventModel event) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event.copyWith(updatedAt: DateTime.now());
        _applyFilters();
      }

    } catch (e) {
      throw Exception('Error al actualizar evento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _events.removeWhere((event) => event.id == eventId);
      _applyFilters();

    } catch (e) {
      throw Exception('Error al eliminar evento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gestión de tickets
  Future<String> purchaseTicket(String eventId, String ticketTierId, AttendeeInfo attendee) async {
    try {
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex == -1) throw Exception('Evento no encontrado');

      final event = _events[eventIndex];
      final tierIndex = event.ticketTiers.indexWhere((t) => t.id == ticketTierId);
      if (tierIndex == -1) throw Exception('Tipo de ticket no encontrado');

      final tier = event.ticketTiers[tierIndex];
      if (tier.availableQuantity <= 0) throw Exception('Tickets agotados');

      // Generar QR code único
      final qrCode = await _qrService.generateQRCode(eventId, attendee.id);

      // Crear attendee con QR
      final attendeeWithQR = AttendeeInfo(
        id: attendee.id,
        name: attendee.name,
        email: attendee.email,
        phone: attendee.phone,
        ticketTierId: ticketTierId,
        qrCode: qrCode,
        purchaseDate: DateTime.now(),
        isCheckedIn: false,
        checkInTime: null,
        additionalInfo: attendee.additionalInfo,
      );

      // Actualizar tier (incrementar vendidos)
      final updatedTier = TicketTier(
        id: tier.id,
        name: tier.name,
        description: tier.description,
        price: tier.price,
        totalQuantity: tier.totalQuantity,
        soldQuantity: tier.soldQuantity + 1,
        color: tier.color,
        benefits: tier.benefits,
        isActive: tier.isActive,
      );

      // Actualizar evento
      final updatedTiers = List<TicketTier>.from(event.ticketTiers);
      updatedTiers[tierIndex] = updatedTier;

      final updatedAttendees = List<AttendeeInfo>.from(event.attendees);
      updatedAttendees.add(attendeeWithQR);

      final updatedEvent = event.copyWith(
        ticketTiers: updatedTiers,
        attendees: updatedAttendees,
        updatedAt: DateTime.now(),
      );

      _events[eventIndex] = updatedEvent;
      _applyFilters();

      // Generar PDF del ticket
      final pdfPath = await _pdfService.generateTicketPDF(updatedEvent, attendeeWithQR, updatedTier);

      // Enviar email con ticket
      await _emailService.sendTicketConfirmationEmail(updatedEvent, attendeeWithQR, updatedTier, pdfPath);

      return qrCode;

    } catch (e) {
      throw Exception('Error al comprar ticket: $e');
    }
  }

  // Check-in con QR
  Future<bool> checkInAttendee(String qrCode) async {
    try {
      final validation = await _qrService.validateQRCode(qrCode);
      if (!validation['isValid']) return false;

      final eventId = validation['eventId'];
      final attendeeId = validation['attendeeId'];

      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex == -1) return false;

      final event = _events[eventIndex];
      final attendeeIndex = event.attendees.indexWhere((a) => a.id == attendeeId);
      if (attendeeIndex == -1) return false;

      if (event.attendees[attendeeIndex].isCheckedIn) return false; // Ya registrado

      // Actualizar check-in
      final updatedAttendees = List<AttendeeInfo>.from(event.attendees);
      updatedAttendees[attendeeIndex] = AttendeeInfo(
        id: event.attendees[attendeeIndex].id,
        name: event.attendees[attendeeIndex].name,
        email: event.attendees[attendeeIndex].email,
        phone: event.attendees[attendeeIndex].phone,
        ticketTierId: event.attendees[attendeeIndex].ticketTierId,
        qrCode: event.attendees[attendeeIndex].qrCode,
        purchaseDate: event.attendees[attendeeIndex].purchaseDate,
        isCheckedIn: true,
        checkInTime: DateTime.now(),
        additionalInfo: event.attendees[attendeeIndex].additionalInfo,
      );

      _events[eventIndex] = event.copyWith(
        attendees: updatedAttendees,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;

    } catch (e) {
      return false;
    }
  }

  // Analytics
  Map<String, dynamic> getEventAnalytics(String eventId) {
    final event = _events.firstWhere((e) => e.id == eventId);

    return {
      'totalTicketsSold': event.totalSoldTickets,
      'totalRevenue': event.ticketTiers.fold(0.0, (sum, tier) => sum + (tier.soldQuantity * tier.price)),
      'checkInRate': event.checkInPercentage,
      'salesByTier': event.ticketTiers.map((tier) => {
        'name': tier.name,
        'sold': tier.soldQuantity,
        'revenue': tier.soldQuantity * tier.price,
      }).toList(),
      'attendeesByDay': _getAttendeesByDay(event),
    };
  }

  Map<String, int> _getAttendeesByDay(AdvancedEventModel event) {
    final Map<String, int> attendeesByDay = {};

    for (final attendee in event.attendees) {
      final day = attendee.purchaseDate.toString().split(' ')[0];
      attendeesByDay[day] = (attendeesByDay[day] ?? 0) + 1;
    }

    return attendeesByDay;
  }

  // Obtener evento por ID
  AdvancedEventModel? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Eventos destacados
  List<AdvancedEventModel> get featuredEvents => _events.where((event) => event.isFeatured).toList();

  // Próximos eventos
  List<AdvancedEventModel> get upcomingEventsList => _events.where((event) => event.isUpcoming).toList();
}
