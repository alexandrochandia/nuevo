import 'package:flutter/material.dart';

class VideoCallService {
  static final VideoCallService _instance = VideoCallService._internal();
  factory VideoCallService() => _instance;
  VideoCallService._internal();

  // Lista de usuarios disponibles para videollamada (demo)
  static const List<Map<String, dynamic>> availableContacts = [
    {
      'id': 'pastor_vmf',
      'name': 'Pastor VMF',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'isOnline': true,
      'lastSeen': 'Ahora',
    },
    {
      'id': 'hermana_maria',
      'name': 'Hermana María',
      'imageUrl': 'https://images.unsplash.com/photo-1494790108755-2616b6d95e5e?w=150',
      'isOnline': true,
      'lastSeen': 'Hace 2 min',
    },
    {
      'id': 'hermano_juan',
      'name': 'Hermano Juan',
      'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'isOnline': false,
      'lastSeen': 'Hace 1 hora',
    },
    {
      'id': 'hermana_ana',
      'name': 'Hermana Ana',
      'imageUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      'isOnline': true,
      'lastSeen': 'Ahora',
    },
    {
      'id': 'hermano_pedro',
      'name': 'Hermano Pedro',
      'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'isOnline': false,
      'lastSeen': 'Hace 30 min',
    },
  ];

  // Simular inicio de llamada
  Future<bool> initiateCall({
    required String contactId,
    required String contactName,
    required BuildContext context,
  }) async {
    try {
      // Aquí se integraría con un servicio real como Agora, WebRTC, etc.
      debugPrint('Iniciando videollamada con: $contactName ($contactId)');
      
      // Simular proceso de conexión
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      debugPrint('Error al iniciar videollamada: $e');
      return false;
    }
  }

  // Simular llamada entrante
  Future<void> simulateIncomingCall({
    required String fromContactId,
    required String fromContactName,
    required BuildContext context,
  }) async {
    // Aquí se mostraría una notificación o overlay de llamada entrante
    debugPrint('Llamada entrante de: $fromContactName ($fromContactId)');
  }

  // Obtener lista de contactos disponibles
  List<Map<String, dynamic>> getAvailableContacts() {
    return availableContacts;
  }

  // Obtener contactos en línea
  List<Map<String, dynamic>> getOnlineContacts() {
    return availableContacts.where((contact) => contact['isOnline'] == true).toList();
  }

  // Buscar contacto por ID
  Map<String, dynamic>? getContactById(String contactId) {
    try {
      return availableContacts.firstWhere((contact) => contact['id'] == contactId);
    } catch (e) {
      return null;
    }
  }

  // Simular historial de llamadas
  static const List<Map<String, dynamic>> callHistory = [
    {
      'contactId': 'pastor_vmf',
      'contactName': 'Pastor VMF',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'type': 'outgoing', // outgoing, incoming, missed
      'duration': '05:32',
      'timestamp': '2025-01-08 14:30:00',
      'isVideoCall': true,
    },
    {
      'contactId': 'hermana_maria',
      'contactName': 'Hermana María',
      'imageUrl': 'https://images.unsplash.com/photo-1494790108755-2616b6d95e5e?w=150',
      'type': 'incoming',
      'duration': '12:45',
      'timestamp': '2025-01-08 10:15:00',
      'isVideoCall': true,
    },
    {
      'contactId': 'hermano_juan',
      'contactName': 'Hermano Juan',
      'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'type': 'missed',
      'duration': '00:00',
      'timestamp': '2025-01-07 18:45:00',
      'isVideoCall': false,
    },
  ];

  // Obtener historial de llamadas
  List<Map<String, dynamic>> getCallHistory() {
    return callHistory;
  }

  // Agregar llamada al historial
  Future<void> addToCallHistory({
    required String contactId,
    required String contactName,
    required String type,
    required String duration,
    bool isVideoCall = true,
  }) async {
    // Aquí se guardaría en la base de datos real
    debugPrint('Agregando llamada al historial: $contactName - $duration');
  }

  // Validar permisos de cámara y micrófono
  Future<bool> checkPermissions() async {
    // Aquí se verificarían los permisos reales del dispositivo
    return true;
  }

  // Configurar calidad de video
  void setVideoQuality(String quality) {
    // low, medium, high
    debugPrint('Configurando calidad de video: $quality');
  }

  // Obtener estado de conexión
  String getConnectionStatus() {
    // connected, connecting, disconnected, failed
    return 'connected';
  }
}