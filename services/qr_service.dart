import 'dart:convert';
import 'dart:math';

class QRService {
  static final QRService _instance = QRService._internal();
  factory QRService() => _instance;
  QRService._internal();

  final Map<String, Map<String, dynamic>> _qrDatabase = {};

  /// Genera un código QR único para un asistente de evento
  Future<String> generateQRCode(String eventId, String attendeeId) async {
    try {
      // Generar código único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(999999);
      final uniqueCode = 'VMF${timestamp.toString().substring(8)}${random.toString().padLeft(6, '0')}';

      // Crear datos del QR
      final qrData = {
        'eventId': eventId,
        'attendeeId': attendeeId,
        'code': uniqueCode,
        'generatedAt': DateTime.now().toIso8601String(),
        'isValid': true,
        'usedAt': null,
      };

      // Almacenar en base de datos local (en producción sería una DB real)
      _qrDatabase[uniqueCode] = qrData;

      // En producción, aquí se generaría la imagen QR real
      // Por ahora retornamos el código único
      return uniqueCode;
      
    } catch (e) {
      throw Exception('Error al generar código QR: $e');
    }
  }

  /// Valida un código QR escaneado
  Future<Map<String, dynamic>> validateQRCode(String qrCode) async {
    try {
      // Buscar en base de datos
      if (!_qrDatabase.containsKey(qrCode)) {
        return {
          'isValid': false,
          'error': 'Código QR no encontrado',
        };
      }

      final qrData = _qrDatabase[qrCode]!;

      // Verificar si ya fue usado
      if (qrData['usedAt'] != null) {
        return {
          'isValid': false,
          'error': 'Código QR ya utilizado',
          'usedAt': qrData['usedAt'],
        };
      }

      // Verificar si está activo
      if (!qrData['isValid']) {
        return {
          'isValid': false,
          'error': 'Código QR inválido o desactivado',
        };
      }

      // Verificar expiración (opcional - 24 horas)
      final generatedAt = DateTime.parse(qrData['generatedAt']);
      final now = DateTime.now();
      final hoursDifference = now.difference(generatedAt).inHours;

      if (hoursDifference > 24) {
        return {
          'isValid': false,
          'error': 'Código QR expirado',
        };
      }

      return {
        'isValid': true,
        'eventId': qrData['eventId'],
        'attendeeId': qrData['attendeeId'],
        'generatedAt': qrData['generatedAt'],
      };
      
    } catch (e) {
      return {
        'isValid': false,
        'error': 'Error al validar código QR: $e',
      };
    }
  }

  /// Marca un código QR como usado
  Future<bool> markQRAsUsed(String qrCode) async {
    try {
      if (!_qrDatabase.containsKey(qrCode)) {
        return false;
      }

      _qrDatabase[qrCode]!['usedAt'] = DateTime.now().toIso8601String();
      return true;
      
    } catch (e) {
      return false;
    }
  }

  /// Desactiva un código QR
  Future<bool> deactivateQRCode(String qrCode) async {
    try {
      if (!_qrDatabase.containsKey(qrCode)) {
        return false;
      }

      _qrDatabase[qrCode]!['isValid'] = false;
      return true;
      
    } catch (e) {
      return false;
    }
  }

  /// Obtiene estadísticas de códigos QR para un evento
  Future<Map<String, dynamic>> getQRStats(String eventId) async {
    try {
      final eventQRs = _qrDatabase.values.where((qr) => qr['eventId'] == eventId).toList();
      
      final total = eventQRs.length;
      final used = eventQRs.where((qr) => qr['usedAt'] != null).length;
      final active = eventQRs.where((qr) => qr['isValid'] == true).length;
      final expired = eventQRs.where((qr) {
        final generatedAt = DateTime.parse(qr['generatedAt']);
        final hoursDifference = DateTime.now().difference(generatedAt).inHours;
        return hoursDifference > 24;
      }).length;

      return {
        'total': total,
        'used': used,
        'active': active,
        'expired': expired,
        'usageRate': total > 0 ? (used / total * 100).round() : 0,
      };
      
    } catch (e) {
      return {
        'total': 0,
        'used': 0,
        'active': 0,
        'expired': 0,
        'usageRate': 0,
      };
    }
  }

  /// Genera múltiples códigos QR para un evento
  Future<List<String>> generateBulkQRCodes(String eventId, List<String> attendeeIds) async {
    final List<String> qrCodes = [];
    
    for (final attendeeId in attendeeIds) {
      try {
        final qrCode = await generateQRCode(eventId, attendeeId);
        qrCodes.add(qrCode);
      } catch (e) {
        // Continuar con el siguiente si hay error
        continue;
      }
    }
    
    return qrCodes;
  }

  /// Limpia códigos QR expirados
  Future<int> cleanupExpiredQRCodes() async {
    try {
      final now = DateTime.now();
      final keysToRemove = <String>[];
      
      for (final entry in _qrDatabase.entries) {
        final generatedAt = DateTime.parse(entry.value['generatedAt']);
        final daysDifference = now.difference(generatedAt).inDays;
        
        // Eliminar códigos de más de 7 días
        if (daysDifference > 7) {
          keysToRemove.add(entry.key);
        }
      }
      
      for (final key in keysToRemove) {
        _qrDatabase.remove(key);
      }
      
      return keysToRemove.length;
      
    } catch (e) {
      return 0;
    }
  }

  /// Exporta datos de QR para backup
  Map<String, dynamic> exportQRData() {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCodes': _qrDatabase.length,
      'data': _qrDatabase,
    };
  }

  /// Importa datos de QR desde backup
  Future<bool> importQRData(Map<String, dynamic> backupData) async {
    try {
      if (backupData.containsKey('data')) {
        final data = backupData['data'] as Map<String, dynamic>;
        _qrDatabase.clear();
        // Convertir cada entrada al tipo correcto
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            _qrDatabase[key] = value;
          }
        });
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
