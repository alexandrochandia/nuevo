import 'package:flutter/material.dart';

class QRCodeData {
  final String id;
  final QRCodeType type;
  final String title;
  final String content;
  final Map<String, dynamic> data;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final List<QRCodeScan> scans;
  final String? eventId;
  final String? churchLocation;
  final Color? customColor;
  final String? logoUrl;

  QRCodeData({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.data,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.scans = const [],
    this.eventId,
    this.churchLocation,
    this.customColor,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'content': content,
      'data': data,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'scans': scans.map((s) => s.toJson()).toList(),
      'eventId': eventId,
      'churchLocation': churchLocation,
      'customColor': customColor?.value,
      'logoUrl': logoUrl,
    };
  }

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    return QRCodeData(
      id: json['id'],
      type: QRCodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QRCodeType.event,
      ),
      title: json['title'],
      content: json['content'],
      data: Map<String, dynamic>.from(json['data']),
      createdBy: json['createdBy'],
      createdByName: json['createdByName'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isActive: json['isActive'] ?? true,
      scans: (json['scans'] as List?)
          ?.map((s) => QRCodeScan.fromJson(s))
          .toList() ?? [],
      eventId: json['eventId'],
      churchLocation: json['churchLocation'],
      customColor: json['customColor'] != null ? Color(json['customColor']) : null,
      logoUrl: json['logoUrl'],
    );
  }

  QRCodeData copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? data,
    DateTime? expiresAt,
    bool? isActive,
    List<QRCodeScan>? scans,
    String? eventId,
    String? churchLocation,
    Color? customColor,
    String? logoUrl,
  }) {
    return QRCodeData(
      id: id,
      type: type,
      title: title ?? this.title,
      content: content ?? this.content,
      data: data ?? this.data,
      createdBy: createdBy,
      createdByName: createdByName,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      scans: scans ?? this.scans,
      eventId: eventId ?? this.eventId,
      churchLocation: churchLocation ?? this.churchLocation,
      customColor: customColor ?? this.customColor,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  int get scanCount => scans.length;
  
  List<QRCodeScan> getRecentScans({int limit = 10}) {
    final recent = List<QRCodeScan>.from(scans);
    recent.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return recent.take(limit).toList();
  }
}

class QRCodeScan {
  final String id;
  final String qrCodeId;
  final String scannedBy;
  final String scannedByName;
  final DateTime scannedAt;
  final String? deviceInfo;
  final String? location;
  final ScanResult result;
  final Map<String, dynamic>? additionalData;

  QRCodeScan({
    required this.id,
    required this.qrCodeId,
    required this.scannedBy,
    required this.scannedByName,
    required this.scannedAt,
    this.deviceInfo,
    this.location,
    this.result = ScanResult.success,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCodeId': qrCodeId,
      'scannedBy': scannedBy,
      'scannedByName': scannedByName,
      'scannedAt': scannedAt.toIso8601String(),
      'deviceInfo': deviceInfo,
      'location': location,
      'result': result.name,
      'additionalData': additionalData,
    };
  }

  factory QRCodeScan.fromJson(Map<String, dynamic> json) {
    return QRCodeScan(
      id: json['id'],
      qrCodeId: json['qrCodeId'],
      scannedBy: json['scannedBy'],
      scannedByName: json['scannedByName'],
      scannedAt: DateTime.parse(json['scannedAt']),
      deviceInfo: json['deviceInfo'],
      location: json['location'],
      result: ScanResult.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => ScanResult.success,
      ),
      additionalData: json['additionalData'] != null 
          ? Map<String, dynamic>.from(json['additionalData'])
          : null,
    );
  }
}

enum QRCodeType {
  event,
  contact,
  checkin,
  url,
  text,
  wifi,
  donation,
  ministry,
}

enum ScanResult {
  success,
  expired,
  inactive,
  unauthorized,
  error,
}

// Extensions para enums
extension QRCodeTypeExtension on QRCodeType {
  String get displayName {
    switch (this) {
      case QRCodeType.event:
        return 'Evento VMF';
      case QRCodeType.contact:
        return 'Contacto';
      case QRCodeType.checkin:
        return 'Check-in';
      case QRCodeType.url:
        return 'Enlace Web';
      case QRCodeType.text:
        return 'Texto';
      case QRCodeType.wifi:
        return 'WiFi';
      case QRCodeType.donation:
        return 'Donación';
      case QRCodeType.ministry:
        return 'Ministerio';
    }
  }

  String get description {
    switch (this) {
      case QRCodeType.event:
        return 'QR para acceso rápido a eventos VMF';
      case QRCodeType.contact:
        return 'Compartir información de contacto';
      case QRCodeType.checkin:
        return 'Check-in automático en eventos';
      case QRCodeType.url:
        return 'Acceso directo a sitio web';
      case QRCodeType.text:
        return 'Mostrar texto personalizado';
      case QRCodeType.wifi:
        return 'Conexión automática a WiFi';
      case QRCodeType.donation:
        return 'Donación rápida VMF';
      case QRCodeType.ministry:
        return 'Información de ministerio';
    }
  }

  IconData get icon {
    switch (this) {
      case QRCodeType.event:
        return Icons.event;
      case QRCodeType.contact:
        return Icons.contact_page;
      case QRCodeType.checkin:
        return Icons.check_circle;
      case QRCodeType.url:
        return Icons.link;
      case QRCodeType.text:
        return Icons.text_fields;
      case QRCodeType.wifi:
        return Icons.wifi;
      case QRCodeType.donation:
        return Icons.volunteer_activism;
      case QRCodeType.ministry:
        return Icons.groups;
    }
  }

  Color get color {
    switch (this) {
      case QRCodeType.event:
        return const Color(0xFF3498db);
      case QRCodeType.contact:
        return const Color(0xFF2ecc71);
      case QRCodeType.checkin:
        return const Color(0xFF9b59b6);
      case QRCodeType.url:
        return const Color(0xFFe67e22);
      case QRCodeType.text:
        return const Color(0xFF34495e);
      case QRCodeType.wifi:
        return const Color(0xFF1abc9c);
      case QRCodeType.donation:
        return const Color(0xFFe74c3c);
      case QRCodeType.ministry:
        return const Color(0xFFf39c12);
    }
  }
}

extension ScanResultExtension on ScanResult {
  String get displayName {
    switch (this) {
      case ScanResult.success:
        return 'Exitoso';
      case ScanResult.expired:
        return 'Expirado';
      case ScanResult.inactive:
        return 'Inactivo';
      case ScanResult.unauthorized:
        return 'No Autorizado';
      case ScanResult.error:
        return 'Error';
    }
  }

  Color get color {
    switch (this) {
      case ScanResult.success:
        return Colors.green;
      case ScanResult.expired:
        return Colors.orange;
      case ScanResult.inactive:
        return Colors.grey;
      case ScanResult.unauthorized:
        return Colors.red;
      case ScanResult.error:
        return Colors.deepOrange;
    }
  }

  IconData get icon {
    switch (this) {
      case ScanResult.success:
        return Icons.check_circle;
      case ScanResult.expired:
        return Icons.schedule;
      case ScanResult.inactive:
        return Icons.pause_circle;
      case ScanResult.unauthorized:
        return Icons.block;
      case ScanResult.error:
        return Icons.error;
    }
  }
}

// Clase para generar diferentes tipos de QR
class QRCodeGenerator {
  static String generateEventQR({
    required String eventId,
    required String eventTitle,
    required String churchLocation,
    required DateTime eventDate,
  }) {
    final data = {
      'type': 'event',
      'eventId': eventId,
      'title': eventTitle,
      'church': churchLocation,
      'date': eventDate.toIso8601String(),
      'app': 'VMF_Sweden',
    };
    return 'vmf://event?data=${Uri.encodeComponent(data.toString())}';
  }

  static String generateContactQR({
    required String name,
    required String phone,
    String? email,
    String? church,
    String? ministry,
  }) {
    final data = {
      'type': 'contact',
      'name': name,
      'phone': phone,
      'email': email,
      'church': church,
      'ministry': ministry,
      'app': 'VMF_Sweden',
    };
    return 'vmf://contact?data=${Uri.encodeComponent(data.toString())}';
  }

  static String generateCheckinQR({
    required String eventId,
    required String checkinId,
    required String eventTitle,
    required String location,
  }) {
    final data = {
      'type': 'checkin',
      'eventId': eventId,
      'checkinId': checkinId,
      'title': eventTitle,
      'location': location,
      'app': 'VMF_Sweden',
    };
    return 'vmf://checkin?data=${Uri.encodeComponent(data.toString())}';
  }

  static String generateDonationQR({
    required String amount,
    required String currency,
    required String purpose,
    String? church,
  }) {
    final data = {
      'type': 'donation',
      'amount': amount,
      'currency': currency,
      'purpose': purpose,
      'church': church,
      'app': 'VMF_Sweden',
    };
    return 'vmf://donation?data=${Uri.encodeComponent(data.toString())}';
  }

  static String generateMinistryQR({
    required String ministryId,
    required String ministryName,
    required String description,
    required String leader,
    String? church,
  }) {
    final data = {
      'type': 'ministry',
      'ministryId': ministryId,
      'name': ministryName,
      'description': description,
      'leader': leader,
      'church': church,
      'app': 'VMF_Sweden',
    };
    return 'vmf://ministry?data=${Uri.encodeComponent(data.toString())}';
  }

  static String generateWifiQR({
    required String ssid,
    required String password,
    required String security,
  }) {
    return 'WIFI:T:$security;S:$ssid;P:$password;H:false;;';
  }

  static String generateUrlQR(String url) {
    return url;
  }

  static String generateTextQR(String text) {
    return text;
  }
}