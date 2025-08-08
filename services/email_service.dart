import '../models/advanced_event_model.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  /// Envía email de confirmación de ticket
  Future<bool> sendTicketConfirmationEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
    TicketTier tier,
    String pdfPath,
  ) async {
    try {
      // En producción, aquí se integraría con un servicio de email real
      // como SendGrid, AWS SES, o similar
      
      final emailContent = _generateTicketConfirmationEmail(event, attendee, tier);
      
      // Simular envío de email
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Log del email enviado (en producción sería un log real)
      print('Email enviado a ${attendee.email}:');
      print(emailContent);
      print('Adjunto: $pdfPath');
      
      return true;
      
    } catch (e) {
      print('Error al enviar email de confirmación: $e');
      return false;
    }
  }

  /// Envía email de recordatorio de evento
  Future<bool> sendEventReminderEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
  ) async {
    try {
      final emailContent = _generateEventReminderEmail(event, attendee);
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('Email de recordatorio enviado a ${attendee.email}:');
      print(emailContent);
      
      return true;
      
    } catch (e) {
      print('Error al enviar email de recordatorio: $e');
      return false;
    }
  }

  /// Envía email de cancelación de evento
  Future<bool> sendEventCancellationEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
  ) async {
    try {
      final emailContent = _generateEventCancellationEmail(event, attendee);
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('Email de cancelación enviado a ${attendee.email}:');
      print(emailContent);
      
      return true;
      
    } catch (e) {
      print('Error al enviar email de cancelación: $e');
      return false;
    }
  }

  /// Envía email de confirmación de creación de evento
  Future<bool> sendEventCreatedEmail(AdvancedEventModel event) async {
    try {
      final emailContent = _generateEventCreatedEmail(event);
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('Email de evento creado enviado a ${event.organizerContact}:');
      print(emailContent);
      
      return true;
      
    } catch (e) {
      print('Error al enviar email de evento creado: $e');
      return false;
    }
  }

  /// Envía email de check-in exitoso
  Future<bool> sendCheckInConfirmationEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
  ) async {
    try {
      final emailContent = _generateCheckInConfirmationEmail(event, attendee);
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('Email de check-in enviado a ${attendee.email}:');
      print(emailContent);
      
      return true;
      
    } catch (e) {
      print('Error al enviar email de check-in: $e');
      return false;
    }
  }

  /// Envía emails masivos a todos los asistentes
  Future<Map<String, dynamic>> sendBulkEmails(
    AdvancedEventModel event,
    String subject,
    String message,
  ) async {
    int sent = 0;
    int failed = 0;
    
    for (final attendee in event.attendees) {
      try {
        final emailContent = _generateBulkEmail(event, attendee, subject, message);
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        print('Email masivo enviado a ${attendee.email}');
        sent++;
        
      } catch (e) {
        failed++;
      }
    }
    
    return {
      'sent': sent,
      'failed': failed,
      'total': event.attendees.length,
    };
  }

  /// Genera contenido del email de confirmación de ticket
  String _generateTicketConfirmationEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
    TicketTier tier,
  ) {
    return '''
Asunto: ✅ Confirmación de Ticket - ${event.title}

Hola ${attendee.name},

¡Gracias por tu compra! Tu ticket para ${event.title} ha sido confirmado.

DETALLES DEL EVENTO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Fecha: ${_formatDate(event.startDate)}
🕐 Hora: ${_formatTime(event.startDate)}
📍 Ubicación: ${event.location}
🏢 Dirección: ${event.address}

DETALLES DE TU TICKET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎫 Tipo: ${tier.name}
💰 Precio: ${tier.price.toStringAsFixed(2)} SEK
🔢 Código QR: ${attendee.qrCode}

BENEFICIOS INCLUIDOS:
${tier.benefits.map((benefit) => '✓ $benefit').join('\n')}

INSTRUCCIONES IMPORTANTES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Presenta tu ticket (adjunto en PDF) al llegar al evento
• Llega 30 minutos antes del inicio para el check-in
• Tu código QR será escaneado para el registro
• Guarda este email y el PDF adjunto

¿NECESITAS AYUDA?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📧 Email: ${event.organizerContact}
🌐 Web: www.vmfsweden.se

¡Esperamos verte pronto!

Con bendiciones,
Equipo VMF Sweden

---
Este email fue enviado automáticamente. Por favor no respondas a este mensaje.
ID de compra: ${attendee.id}
Fecha de compra: ${_formatDateTime(attendee.purchaseDate)}
''';
  }

  /// Genera contenido del email de recordatorio
  String _generateEventReminderEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
  ) {
    final daysUntilEvent = event.startDate.difference(DateTime.now()).inDays;
    
    return '''
Asunto: 🔔 Recordatorio - ${event.title} en ${daysUntilEvent} días

Hola ${attendee.name},

¡No olvides que ${event.title} se acerca!

RECORDATORIO DEL EVENTO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Fecha: ${_formatDate(event.startDate)}
🕐 Hora: ${_formatTime(event.startDate)}
📍 Ubicación: ${event.location}
🏢 Dirección: ${event.address}

PREPARATIVOS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Ten tu ticket listo (código QR: ${attendee.qrCode})
✓ Llega 30 minutos antes
✓ Revisa la ubicación y planifica tu transporte
✓ Trae una actitud de expectativa y fe

${event.agenda.isNotEmpty ? '''
AGENDA DEL EVENTO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${event.agenda.map((item) => 
  '${_formatTime(item.startTime)} - ${item.title} (${item.speaker})'
).join('\n')}
''' : ''}

¡Nos vemos pronto!

Bendiciones,
Equipo VMF Sweden

---
¿Necesitas cambiar algo? Contacta: ${event.organizerContact}
''';
  }

  /// Genera contenido del email de cancelación
  String _generateEventCancellationEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
  ) {
    return '''
Asunto: ❌ CANCELACIÓN - ${event.title}

Hola ${attendee.name},

Lamentamos informarte que ${event.title} ha sido cancelado.

DETALLES DEL EVENTO CANCELADO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Fecha original: ${_formatDate(event.startDate)}
📍 Ubicación: ${event.location}
🎫 Tu ticket: ${attendee.qrCode}

REEMBOLSO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 Se procesará automáticamente el reembolso completo
⏰ Tiempo estimado: 3-5 días hábiles
💳 Se acreditará al método de pago original

PRÓXIMOS EVENTOS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 Visita www.vmfsweden.se para ver otros eventos
📧 Te notificaremos sobre eventos similares

Pedimos disculpas por cualquier inconveniente causado.

Con bendiciones,
Equipo VMF Sweden

---
Para consultas sobre reembolsos: ${event.organizerContact}
ID de compra: ${attendee.id}
''';
  }

  /// Genera contenido del email de evento creado
  String _generateEventCreatedEmail(AdvancedEventModel event) {
    return '''
Asunto: ✅ Evento Creado Exitosamente - ${event.title}

Hola ${event.organizer},

Tu evento ha sido creado exitosamente en la plataforma VMF Sweden.

DETALLES DEL EVENTO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 Título: ${event.title}
📅 Fecha: ${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}
📍 Ubicación: ${event.location}
👥 Capacidad máxima: ${event.maxAttendees}

TIPOS DE TICKET CONFIGURADOS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${event.ticketTiers.map((tier) => 
  '🎫 ${tier.name}: ${tier.price.toStringAsFixed(2)} SEK (${tier.totalQuantity} disponibles)'
).join('\n')}

PRÓXIMOS PASOS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Tu evento ya está visible para los usuarios
✓ Puedes monitorear las ventas en tiempo real
✓ Recibirás notificaciones de cada compra
✓ Los reportes están disponibles en tu panel

HERRAMIENTAS DISPONIBLES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Analytics en tiempo real
📱 Check-in con códigos QR
📧 Comunicación masiva con asistentes
📄 Generación de reportes PDF
🎫 Gestión de tickets y reembolsos

¡Que Dios bendiga tu evento!

Equipo VMF Sweden

---
ID del evento: ${event.id}
Creado el: ${_formatDateTime(event.createdAt)}
''';
  }

  /// Genera contenido del email de check-in
  String _generateCheckInConfirmationEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
  ) {
    return '''
Asunto: ✅ Check-in Confirmado - ${event.title}

Hola ${attendee.name},

¡Tu check-in para ${event.title} ha sido confirmado exitosamente!

CONFIRMACIÓN DE REGISTRO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Registrado el: ${_formatDateTime(attendee.checkInTime!)}
🎫 Código QR: ${attendee.qrCode}
📍 Evento: ${event.title}
📅 Fecha: ${_formatDate(event.startDate)}

¡Disfruta del evento!

Bendiciones,
Equipo VMF Sweden

---
Este email confirma tu asistencia al evento.
''';
  }

  /// Genera contenido del email masivo
  String _generateBulkEmail(
    AdvancedEventModel event,
    AttendeeInfo attendee,
    String subject,
    String message,
  ) {
    return '''
Asunto: $subject

Hola ${attendee.name},

$message

DETALLES DEL EVENTO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 ${event.title}
📅 ${_formatDate(event.startDate)}
📍 ${event.location}

Con bendiciones,
${event.organizer}

---
Tu código QR: ${attendee.qrCode}
Para consultas: ${event.organizerContact}
''';
  }

  /// Formatea una fecha
  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Formatea una hora
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea fecha y hora
  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} a las ${_formatTime(date)}';
  }

  /// Programa recordatorios automáticos
  Future<void> scheduleEventReminders(AdvancedEventModel event) async {
    // En producción, esto se integraría con un sistema de colas/jobs
    // como Firebase Functions, AWS Lambda, o similar
    
    for (final attendee in event.attendees) {
      // Recordatorio 7 días antes
      final reminder7Days = event.startDate.subtract(const Duration(days: 7));
      if (reminder7Days.isAfter(DateTime.now())) {
        print('Recordatorio programado para ${attendee.email} el ${_formatDateTime(reminder7Days)}');
      }
      
      // Recordatorio 1 día antes
      final reminder1Day = event.startDate.subtract(const Duration(days: 1));
      if (reminder1Day.isAfter(DateTime.now())) {
        print('Recordatorio programado para ${attendee.email} el ${_formatDateTime(reminder1Day)}');
      }
      
      // Recordatorio 2 horas antes
      final reminder2Hours = event.startDate.subtract(const Duration(hours: 2));
      if (reminder2Hours.isAfter(DateTime.now())) {
        print('Recordatorio programado para ${attendee.email} el ${_formatDateTime(reminder2Hours)}');
      }
    }
  }

  /// Obtiene estadísticas de emails
  Future<Map<String, dynamic>> getEmailStats(String eventId) async {
    // En producción, esto consultaría una base de datos real
    return {
      'confirmationsSent': 0,
      'remindersSent': 0,
      'cancellationsSent': 0,
      'checkInsSent': 0,
      'bulkEmailsSent': 0,
      'deliveryRate': 98.5,
      'openRate': 75.2,
      'clickRate': 12.8,
    };
  }
}
