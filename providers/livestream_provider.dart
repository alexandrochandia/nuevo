import 'package:flutter/material.dart';
import '../models/livestream_model.dart';

class LiveStreamProvider extends ChangeNotifier {
  List<LiveStreamModel> _streams = [];
  List<LiveStreamComment> _comments = [];
  List<LiveStreamDonation> _donations = [];
  bool _isLoading = false;
  LiveStreamModel? _currentStream;
  String _searchQuery = '';
  LiveStreamType? _selectedType;
  LiveStreamStatus? _selectedStatus;

  List<LiveStreamModel> get streams => _streams;
  List<LiveStreamComment> get comments => _comments;
  List<LiveStreamDonation> get donations => _donations;
  bool get isLoading => _isLoading;
  LiveStreamModel? get currentStream => _currentStream;
  String get searchQuery => _searchQuery;
  LiveStreamType? get selectedType => _selectedType;
  LiveStreamStatus? get selectedStatus => _selectedStatus;

  // Getters for filtered streams
  List<LiveStreamModel> get liveStreams =>
      _streams.where((stream) => stream.status == LiveStreamStatus.live).toList();

  List<LiveStreamModel> get upcomingStreams =>
      _streams.where((stream) => stream.isUpcoming).toList();

  List<LiveStreamModel> get pastStreams =>
      _streams.where((stream) => stream.hasEnded).toList();

  List<LiveStreamModel> get filteredStreams {
    var filtered = _streams.where((stream) {
      bool matchesSearch = _searchQuery.isEmpty ||
          stream.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          stream.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (stream.pastor?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());

      bool matchesType = _selectedType == null || stream.type == _selectedType;
      bool matchesStatus = _selectedStatus == null || stream.status == _selectedStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    // Sort by status priority and scheduled time
    filtered.sort((a, b) {
      if (a.isLive && !b.isLive) return -1;
      if (!a.isLive && b.isLive) return 1;
      if (a.isUpcoming && !b.isUpcoming) return -1;
      if (!a.isUpcoming && b.isUpcoming) return 1;
      return (a.scheduledTime ?? DateTime.now()).compareTo(b.scheduledTime ?? DateTime.now());
    });

    return filtered;
  }

  // Statistics
  int get totalViewers => liveStreams.fold(0, (sum, stream) => sum + (stream.viewerCount ?? 0));
  int get liveStreamCount => liveStreams.length;
  double get totalDonations => _donations.fold(0.0, (sum, donation) => sum + donation.amount);

  LiveStreamProvider() {
    _loadMockData();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Mock livestream data for VMF Sweden
    _streams = [
      LiveStreamModel(
        id: '1',
        streamerId: 'pastor_daniel_001',
        streamerName: 'Pastor Daniel Morales',
        title: 'Culto Dominical - "El Poder de la Oración"',
        description: 'Únete a nosotros en este poderoso culto dominical donde exploraremos el poder transformador de la oración en nuestras vidas. Pastor Daniel Morales nos guiará a través de las Escrituras.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=450&fit=crop',
        streamUrl: 'https://vmf-sweden.live/stream/culto-dominical',
        hostName: 'Pastor Daniel Morales',
        channelName: 'vmf_culto_dominical',
        status: LiveStreamStatus.live.toString().split('.').last,
        viewersCount: 1247,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        endedAt: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
        durationMinutes: 120,
        pastor: 'Pastor Daniel Morales',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        type: LiveStreamType.culto.toString().split('.').last,
        viewerCount: 1247,
        tags: ['oración', 'fe', 'dominical', 'vmf'],
        allowComments: true,
        allowDonations: true,
        metadata: {
          'church': 'VMF Sweden Stockholm',
          'language': 'español',
          'duration_estimate': 90,
        },
      ),
      LiveStreamModel(
        id: '2',
        streamerId: 'pastor_maria_002',
        streamerName: 'Pastora María González',
        title: 'Estudio Bíblico: Libro de Filipenses',
        description: 'Estudio profundo del libro de Filipenses, capítulo 2. Descubriremos la humildad de Cristo y cómo aplicarla en nuestras vidas diarias.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&h=450&fit=crop',
        streamUrl: 'https://vmf-sweden.live/stream/estudio-filipenses',
        hostName: 'Pastora María González',
        channelName: 'vmf_estudio_biblico',
        status: LiveStreamStatus.scheduled.toString().split('.').last,
        viewersCount: 0,
        createdAt: DateTime.now().add(const Duration(days: 2, hours: 19)),
        durationMinutes: 90,
        pastor: 'Pastora Ana Lindström',
        scheduledTime: DateTime.now().add(const Duration(days: 2, hours: 19)),
        startTime: DateTime.now().add(const Duration(days: 2, hours: 19)),
        type: LiveStreamType.estudio.toString().split('.').last,
        viewerCount: 0,
        tags: ['estudio', 'filipenses', 'biblia', 'martes'],
        allowComments: true,
        allowDonations: false,
        metadata: {
          'church': 'VMF Sweden Göteborg',
          'language': 'español',
          'duration_estimate': 60,
        },
      ),
      LiveStreamModel(
        id: '3',
        streamerId: 'pastor_carlos_003',
        streamerName: 'Pastor Carlos Hernández',
        title: 'Encuentro Juvenil - "Generación de Fuego"',
        description: 'Un encuentro especial para jóvenes lleno de alabanza, testimonios y una palabra poderosa. ¡Ven a experimentar el fuego de Dios!',
        thumbnailUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=450&fit=crop',
        streamUrl: 'https://vmf-sweden.live/stream/juventud-fuego',
        hostName: 'Pastor Carlos Hernández',
        channelName: 'vmf_juventud_fuego',
        status: LiveStreamStatus.upcoming.toString().split('.').last,
        viewersCount: 0,
        createdAt: DateTime.now().add(const Duration(days: 5, hours: 19, minutes: 30)),
        durationMinutes: 120,
        pastor: 'Pastor Carlos Hernández',
        scheduledTime: DateTime.now().add(const Duration(days: 5, hours: 19, minutes: 30)),
        startTime: DateTime.now().add(const Duration(days: 5, hours: 19, minutes: 30)),
        type: LiveStreamType.juventud.toString().split('.').last,
        viewerCount: 0,
        tags: ['juventud', 'alabanza', 'fuego', 'viernes'],
        allowComments: true,
        allowDonations: true,
        metadata: {
          'church': 'VMF Sweden Malmö',
          'language': 'español',
          'duration_estimate': 120,
          'target_age': '15-30',
        },
      ),
      LiveStreamModel(
        id: '4',
        title: 'Conferencia: "El Reino de Dios en Tiempos Modernos"',
        description: 'Conferencia especial con invitados internacionales sobre cómo vivir los principios del Reino de Dios en la sociedad actual.',
        hostName: 'Pastor Miguel Rodríguez & Invitados',
        channelName: 'vmf_conferencia_reino',
        status: 'ended',
        viewersCount: 1850,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        endedAt: DateTime.now().subtract(const Duration(days: 2, hours: -3)),
        durationMinutes: 180,
        streamerId: 'pastor_ana_004',
        streamerName: 'Pastora Ana López',
        pastor: 'Pastor Miguel Rodríguez & Invitados',
        type: 'conferencia',
        viewerCount: 1850,
        startTime: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['conferencia', 'reino', 'internacional', 'especial'],
        allowComments: false,
        allowDonations: true,
        recordingUrl: 'https://vmf-sweden.live/recordings/conferencia-reino-2025',
        metadata: {
          'church': 'VMF Sweden Central',
          'language': 'español',
          'duration_estimate': 180,
          'speakers': ['Pastor Miguel Rodríguez', 'Dr. Elena Martínez', 'Pastor Jorge Silva'],
        },
      ),
      LiveStreamModel(
        id: '5',
        title: 'Encuentro Matrimonial - "Amor que Transforma"',
        description: 'Encuentro especial para matrimonios sobre fortalecer los vínculos matrimoniales basados en principios bíblicos.',
        hostName: 'Pastores David y María Sánchez',
        channelName: 'vmf_encuentro_matrimonial',
        status: 'scheduled',
        viewersCount: 0,
        createdAt: DateTime.now().add(const Duration(days: 7, hours: 18)),
        durationMinutes: 150,
        streamerId: 'pastores_david_maria_005',
        streamerName: 'Pastores David y María Sánchez',
        pastor: 'Pastores David y María Sánchez',
        type: 'matrimonio',
        viewerCount: 0,
        startTime: DateTime.now().add(const Duration(days: 7, hours: 18)),
        tags: ['matrimonio', 'amor', 'parejas', 'familia'],
        allowComments: true,
        allowDonations: false,
        metadata: {
          'church': 'VMF Sweden Uppsala',
          'language': 'español',
          'duration_estimate': 90,
          'target_audience': 'matrimonios',
        },
      ),
      LiveStreamModel(
        id: '6',
        streamerId: 'ministerio_intercesion_006',
        streamerName: 'Ministerio de Intercesión VMF',
        title: 'Vigilia de Oración - "Busquemos Su Rostro"',
        description: 'Una noche especial de oración e intercesión por Suecia, las familias y el avivamiento espiritual.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&h=450&fit=crop',
        streamUrl: 'https://vmf-sweden.live/stream/vigilia-oracion',
        hostName: 'Ministerio de Intercesión VMF',
        channelName: 'vmf_vigilia_oracion',
        pastor: 'Ministerio de Intercesión VMF',
        scheduledTime: DateTime.now().add(const Duration(days: 14, hours: 21)),
        startTime: DateTime.now().add(const Duration(days: 14, hours: 21)),
        status: LiveStreamStatus.scheduled.toString().split('.').last,
        type: LiveStreamType.evento.toString().split('.').last,
        viewerCount: 0,
        viewersCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        tags: ['vigilia', 'oración', 'intercesión', 'avivamiento'],
        allowComments: true,
        allowDonations: true,
        metadata: {
          'church': 'VMF Sweden National',
          'language': 'español',
          'duration_estimate': 240,
          'special_event': true,
        },
      ),
    ];

    // Mock comments for live stream
    if (_streams.isNotEmpty && _streams.first.isLive) {
      _comments = [
        LiveStreamComment(
          id: '1',
          userId: '101',
          userName: 'María González',
          userAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=100&h=100&fit=crop',
          message: '¡Gloria a Dios! Bendecido mensaje pastor',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          likes: 12,
          isFromPastor: false,
        ),
        LiveStreamComment(
          id: '2',
          userId: '102',
          userName: 'Pastor Daniel Morales',
          userAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
          message: 'Oremos juntos por el avivamiento en Suecia 🙏',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          likes: 28,
          isFromPastor: true,
          isPinned: true,
        ),
        LiveStreamComment(
          id: '3',
          userId: '103',
          userName: 'Carlos Ruiz',
          userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
          message: 'Amén! Dios siga bendiciendo VMF Sweden',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          likes: 7,
          isFromPastor: false,
        ),
        LiveStreamComment(
          id: '4',
          userId: '104',
          userName: 'Elena Lindström',
          userAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
          message: 'Conectando desde Göteborg! Bendiciones familia',
          timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
          likes: 15,
          isFromPastor: false,
        ),
      ];
    }

    // Mock donations
    _donations = [
      LiveStreamDonation(
        id: '1',
        userId: '201',
        userName: 'Familia Hernández',
        amount: 500.0,
        currency: 'SEK',
        message: 'Para la obra de Dios en Suecia',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isAnonymous: false,
      ),
      LiveStreamDonation(
        id: '2',
        userId: '202',
        userName: 'Anónimo',
        amount: 200.0,
        currency: 'SEK',
        message: 'Dios los bendiga abundantemente',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isAnonymous: true,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Search and filter functions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(LiveStreamType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setStatusFilter(LiveStreamStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedStatus = null;
    notifyListeners();
  }

  // Stream management
  void setCurrentStream(LiveStreamModel stream) {
    _currentStream = stream;
    _loadCommentsForStream(stream.id);
    notifyListeners();
  }

  void _loadCommentsForStream(String streamId) {
    // Simulate loading comments for specific stream
    // In real implementation, this would fetch from backend
    if (streamId == '1') {
      // Keep current comments for live stream
    } else {
      _comments = [];
    }
  }

  // Comment functions
  Future<void> addComment(String message) async {
    if (_currentStream == null || message.trim().isEmpty) return;

    final comment = LiveStreamComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      userName: 'Usuario Actual',
      userAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
      message: message.trim(),
      timestamp: DateTime.now(),
      isFromPastor: false,
    );

    _comments.add(comment);
    notifyListeners();
  }

  void likeComment(String commentId) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final comment = _comments[index];
      _comments[index] = LiveStreamComment(
        id: comment.id,
        userId: comment.userId,
        userName: comment.userName,
        userAvatar: comment.userAvatar,
        message: comment.message,
        timestamp: comment.timestamp,
        isPinned: comment.isPinned,
        isFromPastor: comment.isFromPastor,
        likes: comment.likes + 1,
        replyToId: comment.replyToId,
      );
      notifyListeners();
    }
  }

  // Donation functions
  Future<void> makeDonation(double amount, String currency, String message, {bool anonymous = false}) async {
    final donation = LiveStreamDonation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      userName: anonymous ? 'Anónimo' : 'Usuario Actual',
      amount: amount,
      currency: currency,
      message: message,
      timestamp: DateTime.now(),
      isAnonymous: anonymous,
    );

    _donations.add(donation);
    notifyListeners();
  }

  // Utility functions
  void refreshStreams() {
    _loadMockData();
  }

  void updateViewerCount(String streamId, int count) {
    final index = _streams.indexWhere((s) => s.id == streamId);
    if (index != -1) {
      _streams[index] = _streams[index].copyWith(viewerCount: count);
      notifyListeners();
    }
  }

  Future<void> updateStreamStatus(String streamId, LiveStreamStatus status) async {
    final streamIndex = liveStreams.indexWhere((stream) => stream.id == streamId);
    if (streamIndex != -1) {
      final updatedStream = liveStreams[streamIndex].copyWith(
        status: status.toString().split('.').last,
        endTime: status == LiveStreamStatus.ended ? DateTime.now() : null,
      );

      liveStreams[streamIndex] = updatedStream;
      notifyListeners();
    }
  }

  void toggleStreamStatus(String streamId) {
    final index = _streams.indexWhere((s) => s.id == streamId);
    if (index != -1) {
      final stream = _streams[index];
      LiveStreamStatus newStatus = LiveStreamStatus.scheduled; // Default value
      DateTime? newStartTime;

      switch (stream.status) {
        case LiveStreamStatus.scheduled:
        case LiveStreamStatus.upcoming:
          newStatus = LiveStreamStatus.live;
          newStartTime = DateTime.now();
          break;
        case LiveStreamStatus.live:
          newStatus = LiveStreamStatus.ended;
          break;
        case LiveStreamStatus.ended:
          newStatus = LiveStreamStatus.scheduled;
          newStartTime = null;
          break;
      }

      _streams[index] = stream.copyWith(
        status: newStatus.toString().split('.').last,
        startTime: newStartTime,
        endTime: newStatus == LiveStreamStatus.ended ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }
}