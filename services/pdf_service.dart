import 'dart:io';
import 'dart:typed_data';
import '../models/advanced_event_model.dart';

class PDFService {
  static final PDFService _instance = PDFService._internal();
  factory PDFService() => _instance;
  PDFService._internal();

  /// Genera un PDF del ticket para un asistente
  Future<String> generateTicketPDF(AdvancedEventModel event, AttendeeInfo attendee, TicketTier tier) async {
    try {
      // En una implementación real, aquí usaríamos una librería como pdf
      // Por ahora simulamos la generación del PDF
      
      final fileName = 'ticket_${event.id}_${attendee.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await _getTicketsDirectory() + '/$fileName';
      
      // Simular creación del archivo PDF
      final pdfContent = _generateTicketContent(event, attendee, tier);
      
      // En producción, aquí se generaría el PDF real
      // final pdf = pw.Document();
      // pdf.addPage(...)
      // await File(filePath).writeAsBytes(await pdf.save());
      
      // Por ahora creamos un archivo de texto simulando el PDF
      await File(filePath).writeAsString(pdfContent);
      
      return filePath;
      
    } catch (e) {
      throw Exception('Error al generar PDF del ticket: $e');
    }
  }

  /// Genera un reporte PDF de un evento
  Future<String> generateEventReportPDF(AdvancedEventModel event, Map<String, dynamic> analytics) async {
    try {
      final fileName = 'reporte_${event.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await _getReportsDirectory() + '/$fileName';
      
      final reportContent = _generateEventReportContent(event, analytics);
      
      // En producción sería un PDF real con gráficos y tablas
      await File(filePath).writeAsString(reportContent);
      
      return filePath;
      
    } catch (e) {
      throw Exception('Error al generar reporte PDF: $e');
    }
  }

  /// Genera PDF con lista de asistentes
  Future<String> generateAttendeeListPDF(AdvancedEventModel event) async {
    try {
      final fileName = 'asistentes_${event.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await _getReportsDirectory() + '/$fileName';
      
      final attendeeListContent = _generateAttendeeListContent(event);
      
      await File(filePath).writeAsString(attendeeListContent);
      
      return filePath;
      
    } catch (e) {
      throw Exception('Error al generar lista de asistentes PDF: $e');
    }
  }

  /// Genera certificado de participación
  Future<String> generateCertificatePDF(AdvancedEventModel event, AttendeeInfo attendee) async {
    try {
      final fileName = 'certificado_${event.id}_${attendee.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await _getCertificatesDirectory() + '/$fileName';
      
      final certificateContent = _generateCertificateContent(event, attendee);
      
      await File(filePath).writeAsString(certificateContent);
      
      return filePath;
      
    } catch (e) {
      throw Exception('Error al generar certificado PDF: $e');
    }
  }

  /// Obtiene el directorio de tickets
  Future<String> _getTicketsDirectory() async {
    final directory = Directory('documents/vmf_tickets');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  /// Obtiene el directorio de reportes
  Future<String> _getReportsDirectory() async {
    final directory = Directory('documents/vmf_reports');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  /// Obtiene el directorio de certificados
  Future<String> _getCertificatesDirectory() async {
    final directory = Directory('documents/vmf_certificates');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  /// Genera el contenido del ticket
  String _generateTicketContent(AdvancedEventModel event, AttendeeInfo attendee, TicketTier tier) {
    return '''
╔══════════════════════════════════════════════════════════════╗
║                         VMF SWEDEN                           ║
║                      TICKET DE EVENTO                        ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  EVENTO: ${event.title.padRight(50)}║
║  FECHA:  ${_formatDate(event.startDate).padRight(50)}║
║  HORA:   ${_formatTime(event.startDate).padRight(50)}║
║  LUGAR:  ${event.location.padRight(50)}║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  ASISTENTE: ${attendee.name.padRight(45)}║
║  EMAIL:     ${attendee.email.padRight(45)}║
║  TELÉFONO:  ${attendee.phone.padRight(45)}║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  TIPO DE TICKET: ${tier.name.padRight(42)}║
║  PRECIO:         ${tier.price.toStringAsFixed(2)} SEK${' '.padRight(35)}║
║                                                              ║
║  BENEFICIOS:                                                 ║
${tier.benefits.map((b) => '║  • $b${' ' * (58 - b.length)}║').join('\n')}
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  CÓDIGO QR: ${attendee.qrCode.padRight(45)}║
║                                                              ║
║  [En una app real, aquí iría el código QR visual]           ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  INSTRUCCIONES:                                              ║
║  • Presenta este ticket al llegar al evento                 ║
║  • El código QR será escaneado para el check-in             ║
║  • Llega 30 minutos antes del inicio                        ║
║  • Para consultas: ${event.organizerContact.padRight(32)}║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Ticket generado el: ${DateTime.now().toString()}
ID de compra: ${attendee.id}
''';
  }

  /// Genera el contenido del reporte de evento
  String _generateEventReportContent(AdvancedEventModel event, Map<String, dynamic> analytics) {
    return '''
═══════════════════════════════════════════════════════════════
                        VMF SWEDEN
                   REPORTE DE EVENTO
═══════════════════════════════════════════════════════════════

INFORMACIÓN DEL EVENTO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Título: ${event.title}
Fecha: ${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}
Ubicación: ${event.location}
Organizador: ${event.organizer}
Categoría: ${event.category}

ESTADÍSTICAS DE VENTAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total de tickets vendidos: ${analytics['totalTicketsSold']}
Ingresos totales: ${analytics['totalRevenue'].toStringAsFixed(2)} SEK
Tasa de check-in: ${event.checkInPercentage.toStringAsFixed(1)}%
Asistentes registrados: ${event.checkedInCount}/${event.attendees.length}

VENTAS POR TIPO DE TICKET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${(analytics['salesByTier'] as List).map((tier) => 
  '${tier['name']}: ${tier['sold']} tickets - ${tier['revenue'].toStringAsFixed(2)} SEK'
).join('\n')}

CAPACIDAD Y OCUPACIÓN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Capacidad máxima: ${event.maxAttendees}
Tickets vendidos: ${event.totalSoldTickets}
Tickets disponibles: ${event.totalAvailableTickets}
Porcentaje de ocupación: ${((event.totalSoldTickets / event.maxAttendees) * 100).toStringAsFixed(1)}%

INFORMACIÓN ADICIONAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Estado del evento: ${event.isUpcoming ? 'Próximo' : event.isOngoing ? 'En curso' : 'Finalizado'}
Evento destacado: ${event.isFeatured ? 'Sí' : 'No'}
Lista de espera habilitada: ${event.allowWaitlist ? 'Sí' : 'No'}

Reporte generado el: ${DateTime.now().toString()}
''';
  }

  /// Genera el contenido de la lista de asistentes
  String _generateAttendeeListContent(AdvancedEventModel event) {
    return '''
═══════════════════════════════════════════════════════════════
                        VMF SWEDEN
                  LISTA DE ASISTENTES
═══════════════════════════════════════════════════════════════

EVENTO: ${event.title}
FECHA: ${_formatDate(event.startDate)}
TOTAL DE ASISTENTES: ${event.attendees.length}

LISTA COMPLETA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${event.attendees.asMap().entries.map((entry) {
  final index = entry.key + 1;
  final attendee = entry.value;
  final tier = event.ticketTiers.firstWhere((t) => t.id == attendee.ticketTierId);
  final status = attendee.isCheckedIn ? '✓ Registrado' : '○ Pendiente';
  
  return '''
${index.toString().padLeft(3)}. ${attendee.name}
     Email: ${attendee.email}
     Teléfono: ${attendee.phone}
     Tipo de ticket: ${tier.name}
     Estado: $status
     Código QR: ${attendee.qrCode}
     ${attendee.isCheckedIn ? 'Check-in: ${_formatDateTime(attendee.checkInTime!)}' : ''}
''';
}).join('\n')}

RESUMEN POR TIPO DE TICKET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${event.ticketTiers.map((tier) {
  final count = event.attendees.where((a) => a.ticketTierId == tier.id).length;
  final checkedIn = event.attendees.where((a) => a.ticketTierId == tier.id && a.isCheckedIn).length;
  return '${tier.name}: $count asistentes ($checkedIn registrados)';
}).join('\n')}

Lista generada el: ${DateTime.now().toString()}
''';
  }

  /// Genera el contenido del certificado
  String _generateCertificateContent(AdvancedEventModel event, AttendeeInfo attendee) {
    return '''
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                         VMF SWEDEN                           ║
║                                                              ║
║                    CERTIFICADO DE PARTICIPACIÓN             ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║                                                              ║
║              Por la presente se certifica que                ║
║                                                              ║
║                    ${attendee.name.toUpperCase().padLeft(30)}                    ║
║                                                              ║
║              ha participado exitosamente en el              ║
║                                                              ║
║                    ${event.title.toUpperCase()}                    ║
║                                                              ║
║              realizado el ${_formatDate(event.startDate)}              ║
║                                                              ║
║              en ${event.location}              ║
║                                                              ║
║                                                              ║
║              Organizado por: ${event.organizer}              ║
║                                                              ║
║                                                              ║
║              ________________________                        ║
║                   Firma Autorizada                          ║
║                                                              ║
║              Certificado emitido el:                        ║
║              ${DateTime.now().toString().substring(0, 10)}                        ║
║                                                              ║
║              ID de verificación: ${attendee.id}              ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
''';
  }

  /// Formatea una fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formatea una hora
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea fecha y hora
  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }

  /// Elimina archivos PDF antiguos
  Future<int> cleanupOldPDFs({int daysOld = 30}) async {
    int deletedCount = 0;
    
    try {
      final directories = [
        await _getTicketsDirectory(),
        await _getReportsDirectory(),
        await _getCertificatesDirectory(),
      ];
      
      for (final dirPath in directories) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          final files = await dir.list().toList();
          
          for (final file in files) {
            if (file is File) {
              final stat = await file.stat();
              final daysDifference = DateTime.now().difference(stat.modified).inDays;
              
              if (daysDifference > daysOld) {
                await file.delete();
                deletedCount++;
              }
            }
          }
        }
      }
      
      return deletedCount;
      
    } catch (e) {
      return 0;
    }
  }

  /// Obtiene el tamaño total de archivos PDF
  Future<int> getTotalPDFSize() async {
    int totalSize = 0;
    
    try {
      final directories = [
        await _getTicketsDirectory(),
        await _getReportsDirectory(),
        await _getCertificatesDirectory(),
      ];
      
      for (final dirPath in directories) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          final files = await dir.list().toList();
          
          for (final file in files) {
            if (file is File) {
              final stat = await file.stat();
              totalSize += stat.size;
            }
          }
        }
      }
      
      return totalSize;
      
    } catch (e) {
      return 0;
    }
  }
}
