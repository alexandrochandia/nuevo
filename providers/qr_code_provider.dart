import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/qr_code_model.dart';

class QRCodeProvider with ChangeNotifier {
  List<QRCodeData> _qrCodes = [];
  List<QRCodeType> _selectedTypes = [];
  String _searchQuery = '';
  bool _showOnlyActive = false;
  bool _showOnlyExpired = false;
  bool _isLoading = false;
  String _error = '';
  String _currentUserId = 'user_pastor';
  String _currentUserName = 'Pastor Anders Eriksson';

  List<QRCodeData> get qrCodes => _filteredQRCodes;
  List<QRCodeData> get allQRCodes => _qrCodes;
  List<QRCodeType> get selectedTypes => _selectedTypes;
  String get searchQuery => _searchQuery;
  bool get showOnlyActive => _showOnlyActive;
  bool get showOnlyExpired => _showOnlyExpired;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  List<QRCodeData> get _filteredQRCodes {
    var filtered = List<QRCodeData>.from(_qrCodes);

    // Filtrar por tipos
    if (_selectedTypes.isNotEmpty) {
      filtered = filtered.where((qr) => _selectedTypes.contains(qr.type)).toList();
    }

    // Filtrar por estado activo
    if (_showOnlyActive) {
      filtered = filtered.where((qr) => qr.isActive && !qr.isExpired).toList();
    }

    // Filtrar por expirados
    if (_showOnlyExpired) {
      filtered = filtered.where((qr) => qr.isExpired).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((qr) =>
        qr.title.toLowerCase().contains(query) ||
        qr.content.toLowerCase().contains(query) ||
        qr.createdByName.toLowerCase().contains(query) ||
        (qr.churchLocation?.toLowerCase().contains(query) ?? false) ||
        qr.type.displayName.toLowerCase().contains(query)
      ).toList();
    }

    // Ordenar por fecha de creación (más recientes primero)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  QRCodeProvider() {
    _loadQRCodes();
    _generateMockData();
  }

  // Cargar QR codes
  Future<void> _loadQRCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qrCodesJson = prefs.getStringList('qr_codes') ?? [];
      
      _qrCodes = qrCodesJson
          .map((json) => QRCodeData.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar códigos QR: $e';
      debugPrint(_error);
    }
  }

  // Guardar QR codes
  Future<void> _saveQRCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final qrCodesJson = _qrCodes
          .map((qr) => jsonEncode(qr.toJson()))
          .toList();
      await prefs.setStringList('qr_codes', qrCodesJson);
    } catch (e) {
      debugPrint('Error saving QR codes: $e');
    }
  }

  // Aplicar filtros
  void applyFilters({
    List<QRCodeType>? types,
    String? searchQuery,
    bool? showOnlyActive,
    bool? showOnlyExpired,
  }) {
    _selectedTypes = types ?? _selectedTypes;
    _searchQuery = searchQuery ?? _searchQuery;
    _showOnlyActive = showOnlyActive ?? _showOnlyActive;
    _showOnlyExpired = showOnlyExpired ?? _showOnlyExpired;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedTypes = [];
    _searchQuery = '';
    _showOnlyActive = false;
    _showOnlyExpired = false;
    notifyListeners();
  }

  // Crear nuevo QR code
  Future<String> createQRCode({
    required QRCodeType type,
    required String title,
    required Map<String, dynamic> data,
    DateTime? expiresAt,
    String? eventId,
    String? churchLocation,
    Color? customColor,
  }) async {
    final id = 'qr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    
    String content;
    switch (type) {
      case QRCodeType.event:
        content = QRCodeGenerator.generateEventQR(
          eventId: data['eventId'] ?? '',
          eventTitle: title,
          churchLocation: churchLocation ?? '',
          eventDate: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
        );
        break;
      case QRCodeType.contact:
        content = QRCodeGenerator.generateContactQR(
          name: data['name'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'],
          church: data['church'],
          ministry: data['ministry'],
        );
        break;
      case QRCodeType.checkin:
        content = QRCodeGenerator.generateCheckinQR(
          eventId: data['eventId'] ?? '',
          checkinId: id,
          eventTitle: title,
          location: data['location'] ?? '',
        );
        break;
      case QRCodeType.donation:
        content = QRCodeGenerator.generateDonationQR(
          amount: data['amount'] ?? '',
          currency: data['currency'] ?? 'SEK',
          purpose: data['purpose'] ?? '',
          church: data['church'],
        );
        break;
      case QRCodeType.ministry:
        content = QRCodeGenerator.generateMinistryQR(
          ministryId: data['ministryId'] ?? '',
          ministryName: title,
          description: data['description'] ?? '',
          leader: data['leader'] ?? '',
          church: data['church'],
        );
        break;
      case QRCodeType.wifi:
        content = QRCodeGenerator.generateWifiQR(
          ssid: data['ssid'] ?? '',
          password: data['password'] ?? '',
          security: data['security'] ?? 'WPA',
        );
        break;
      case QRCodeType.url:
        content = QRCodeGenerator.generateUrlQR(data['url'] ?? '');
        break;
      case QRCodeType.text:
        content = QRCodeGenerator.generateTextQR(data['text'] ?? '');
        break;
    }

    final qrCode = QRCodeData(
      id: id,
      type: type,
      title: title,
      content: content,
      data: data,
      createdBy: _currentUserId,
      createdByName: _currentUserName,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      eventId: eventId,
      churchLocation: churchLocation,
      customColor: customColor,
    );

    _qrCodes.add(qrCode);
    await _saveQRCodes();
    notifyListeners();
    
    return id;
  }

  // Registrar escaneo
  Future<void> registerScan({
    required String qrCodeId,
    required String scannedBy,
    required String scannedByName,
    String? deviceInfo,
    String? location,
    ScanResult result = ScanResult.success,
    Map<String, dynamic>? additionalData,
  }) async {
    final qrCodeIndex = _qrCodes.indexWhere((qr) => qr.id == qrCodeId);
    if (qrCodeIndex == -1) return;

    final scanId = 'scan_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    final scan = QRCodeScan(
      id: scanId,
      qrCodeId: qrCodeId,
      scannedBy: scannedBy,
      scannedByName: scannedByName,
      scannedAt: DateTime.now(),
      deviceInfo: deviceInfo,
      location: location,
      result: result,
      additionalData: additionalData,
    );

    final updatedScans = [..._qrCodes[qrCodeIndex].scans, scan];
    _qrCodes[qrCodeIndex] = _qrCodes[qrCodeIndex].copyWith(scans: updatedScans);
    
    await _saveQRCodes();
    notifyListeners();
  }

  // Actualizar QR code
  Future<void> updateQRCode(QRCodeData updatedQRCode) async {
    final index = _qrCodes.indexWhere((qr) => qr.id == updatedQRCode.id);
    if (index != -1) {
      _qrCodes[index] = updatedQRCode;
      await _saveQRCodes();
      notifyListeners();
    }
  }

  // Eliminar QR code
  Future<void> deleteQRCode(String qrCodeId) async {
    _qrCodes.removeWhere((qr) => qr.id == qrCodeId);
    await _saveQRCodes();
    notifyListeners();
  }

  // Alternar estado activo
  Future<void> toggleActiveStatus(String qrCodeId) async {
    final index = _qrCodes.indexWhere((qr) => qr.id == qrCodeId);
    if (index != -1) {
      _qrCodes[index] = _qrCodes[index].copyWith(isActive: !_qrCodes[index].isActive);
      await _saveQRCodes();
      notifyListeners();
    }
  }

  // Obtener QR code por ID
  QRCodeData? getQRCodeById(String id) {
    try {
      return _qrCodes.firstWhere((qr) => qr.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener estadísticas
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    final totalScans = _qrCodes.fold<int>(0, (sum, qr) => sum + qr.scanCount);
    final activeQRs = _qrCodes.where((qr) => qr.isActive && !qr.isExpired).length;
    final expiredQRs = _qrCodes.where((qr) => qr.isExpired).length;

    return {
      'totalQRs': _qrCodes.length,
      'activeQRs': activeQRs,
      'expiredQRs': expiredQRs,
      'totalScans': totalScans,
      'thisWeekScans': _qrCodes
          .expand((qr) => qr.scans)
          .where((scan) => scan.scannedAt.isAfter(thisWeek))
          .length,
      'thisMonthScans': _qrCodes
          .expand((qr) => qr.scans)
          .where((scan) => scan.scannedAt.isAfter(thisMonth))
          .length,
    };
  }

  // Obtener QRs por tipo
  Map<QRCodeType, int> getQRsByType() {
    final Map<QRCodeType, int> typeCount = {};
    
    for (final type in QRCodeType.values) {
      typeCount[type] = _qrCodes.where((qr) => qr.type == type).length;
    }
    
    return typeCount;
  }

  // Obtener QRs más escaneados
  List<QRCodeData> getMostScannedQRs({int limit = 10}) {
    final sorted = List<QRCodeData>.from(_qrCodes);
    sorted.sort((a, b) => b.scanCount.compareTo(a.scanCount));
    return sorted.take(limit).toList();
  }

  // Obtener QRs recientes
  List<QRCodeData> getRecentQRs({int limit = 10}) {
    final recent = List<QRCodeData>.from(_qrCodes);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(limit).toList();
  }

  // Obtener escaneos recientes
  List<QRCodeScan> getRecentScans({int limit = 20}) {
    final allScans = _qrCodes.expand((qr) => qr.scans).toList();
    allScans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return allScans.take(limit).toList();
  }

  // Refrescar datos
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    await _loadQRCodes();
    
    _isLoading = false;
    notifyListeners();
  }

  // Simular escaneo de QR externo
  Future<Map<String, dynamic>> simulateScanQR(String qrContent) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simular procesamiento del QR
    if (qrContent.startsWith('vmf://')) {
      final uri = Uri.parse(qrContent);
      final type = uri.host;
      
      return {
        'success': true,
        'type': type,
        'data': uri.queryParameters,
        'message': 'QR VMF escaneado exitosamente',
      };
    } else if (qrContent.startsWith('WIFI:')) {
      return {
        'success': true,
        'type': 'wifi',
        'data': {'content': qrContent},
        'message': 'Configuración WiFi detectada',
      };
    } else if (qrContent.startsWith('http')) {
      return {
        'success': true,
        'type': 'url',
        'data': {'url': qrContent},
        'message': 'Enlace web detectado',
      };
    } else {
      return {
        'success': true,
        'type': 'text',
        'data': {'text': qrContent},
        'message': 'Texto escaneado',
      };
    }
  }

  void _generateMockData() {
    if (_qrCodes.isNotEmpty) return;

    final mockQRs = [
      QRCodeData(
        id: 'qr_1',
        type: QRCodeType.event,
        title: 'Culto Dominical - Estocolmo',
        content: QRCodeGenerator.generateEventQR(
          eventId: 'event_1',
          eventTitle: 'Culto Dominical',
          churchLocation: 'VMF Sweden - Estocolmo',
          eventDate: DateTime.now().add(const Duration(days: 7)),
        ),
        data: {
          'eventId': 'event_1',
          'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'time': '10:00',
          'address': 'Storgatan 15, Stockholm',
        },
        createdBy: 'pastor_1',
        createdByName: 'Pastor Anders Eriksson',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        eventId: 'event_1',
        churchLocation: 'VMF Sweden - Estocolmo',
        customColor: const Color(0xFF3498db),
        scans: [
          QRCodeScan(
            id: 'scan_1',
            qrCodeId: 'qr_1',
            scannedBy: 'user_1',
            scannedByName: 'Maria Andersson',
            scannedAt: DateTime.now().subtract(const Duration(hours: 2)),
            result: ScanResult.success,
            location: 'Estocolmo',
          ),
          QRCodeScan(
            id: 'scan_2',
            qrCodeId: 'qr_1',
            scannedBy: 'user_2',
            scannedByName: 'Carlos Jiménez',
            scannedAt: DateTime.now().subtract(const Duration(hours: 1)),
            result: ScanResult.success,
            location: 'Estocolmo',
          ),
        ],
      ),

      QRCodeData(
        id: 'qr_2',
        type: QRCodeType.checkin,
        title: 'Check-in Conferencia VMF',
        content: QRCodeGenerator.generateCheckinQR(
          eventId: 'event_2',
          checkinId: 'checkin_1',
          eventTitle: 'Conferencia Anual VMF',
          location: 'Centro de Conferencias',
        ),
        data: {
          'eventId': 'event_2',
          'location': 'Centro de Conferencias',
          'date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        },
        createdBy: 'pastor_2',
        createdByName: 'Pastora Margareta Lindström',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        eventId: 'event_2',
        churchLocation: 'VMF Sweden - Nacional',
        customColor: const Color(0xFF9b59b6),
        scans: [
          QRCodeScan(
            id: 'scan_3',
            qrCodeId: 'qr_2',
            scannedBy: 'user_3',
            scannedByName: 'Erik Johansson',
            scannedAt: DateTime.now().subtract(const Duration(minutes: 30)),
            result: ScanResult.success,
          ),
        ],
      ),

      QRCodeData(
        id: 'qr_3',
        type: QRCodeType.contact,
        title: 'Pastor Anders Eriksson',
        content: QRCodeGenerator.generateContactQR(
          name: 'Pastor Anders Eriksson',
          phone: '+46 70 123 4567',
          email: 'anders@vmfsweden.se',
          church: 'VMF Sweden - Estocolmo',
          ministry: 'Pastor Principal',
        ),
        data: {
          'name': 'Pastor Anders Eriksson',
          'phone': '+46 70 123 4567',
          'email': 'anders@vmfsweden.se',
          'church': 'VMF Sweden - Estocolmo',
          'ministry': 'Pastor Principal',
        },
        createdBy: 'pastor_1',
        createdByName: 'Pastor Anders Eriksson',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        churchLocation: 'VMF Sweden - Estocolmo',
        customColor: const Color(0xFF2ecc71),
        scans: [
          QRCodeScan(
            id: 'scan_4',
            qrCodeId: 'qr_3',
            scannedBy: 'user_4',
            scannedByName: 'Anna Petersson',
            scannedAt: DateTime.now().subtract(const Duration(hours: 6)),
            result: ScanResult.success,
          ),
        ],
      ),

      QRCodeData(
        id: 'qr_4',
        type: QRCodeType.donation,
        title: 'Ofrenda VMF Sweden',
        content: QRCodeGenerator.generateDonationQR(
          amount: '100',
          currency: 'SEK',
          purpose: 'Ofrenda General',
          church: 'VMF Sweden',
        ),
        data: {
          'amount': '100',
          'currency': 'SEK',
          'purpose': 'Ofrenda General',
          'church': 'VMF Sweden',
          'account': 'SE89 3000 0000 0123 4567 8901',
        },
        createdBy: 'pastor_3',
        createdByName: 'Pastor Miguel Rodriguez',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        churchLocation: 'VMF Sweden - Nacional',
        customColor: const Color(0xFFe74c3c),
        scans: [
          QRCodeScan(
            id: 'scan_5',
            qrCodeId: 'qr_4',
            scannedBy: 'user_5',
            scannedByName: 'Sofia Lindqvist',
            scannedAt: DateTime.now().subtract(const Duration(minutes: 45)),
            result: ScanResult.success,
          ),
        ],
      ),

      QRCodeData(
        id: 'qr_5',
        type: QRCodeType.wifi,
        title: 'WiFi VMF Church',
        content: QRCodeGenerator.generateWifiQR(
          ssid: 'VMF_Church_Guest',
          password: 'Jesus2024!',
          security: 'WPA',
        ),
        data: {
          'ssid': 'VMF_Church_Guest',
          'password': 'Jesus2024!',
          'security': 'WPA',
        },
        createdBy: 'tech_1',
        createdByName: 'Líder Sebastian Larsson',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        churchLocation: 'VMF Sweden - Estocolmo',
        customColor: const Color(0xFF1abc9c),
        scans: [
          QRCodeScan(
            id: 'scan_6',
            qrCodeId: 'qr_5',
            scannedBy: 'user_6',
            scannedByName: 'Diego Morales',
            scannedAt: DateTime.now().subtract(const Duration(hours: 3)),
            result: ScanResult.success,
          ),
        ],
      ),

      QRCodeData(
        id: 'qr_6',
        type: QRCodeType.ministry,
        title: 'Ministerio Juvenil VMF',
        content: QRCodeGenerator.generateMinistryQR(
          ministryId: 'ministry_1',
          ministryName: 'Ministerio Juvenil',
          description: 'Jóvenes sirviendo a Dios con pasión',
          leader: 'Líder Sebastian Larsson',
          church: 'VMF Sweden - Estocolmo',
        ),
        data: {
          'ministryId': 'ministry_1',
          'description': 'Jóvenes sirviendo a Dios con pasión',
          'leader': 'Líder Sebastian Larsson',
          'church': 'VMF Sweden - Estocolmo',
          'meetingDay': 'Viernes',
          'meetingTime': '19:00',
        },
        createdBy: 'leader_1',
        createdByName: 'Líder Sebastian Larsson',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        churchLocation: 'VMF Sweden - Estocolmo',
        customColor: const Color(0xFFf39c12),
        scans: [],
      ),
    ];

    _qrCodes = mockQRs;
    _saveQRCodes();
    notifyListeners();
  }
}