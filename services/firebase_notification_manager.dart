import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class FirebaseNotificationManager {
  static final FirebaseNotificationManager _instance = FirebaseNotificationManager._internal();
  factory FirebaseNotificationManager() => _instance;
  FirebaseNotificationManager._internal();

  // Simulamos Firebase Messaging para este demo
  // En producción, aquí integrarías Firebase Cloud Messaging (FCM)
  
  final List<Function(VMFNotification)> _listeners = [];
  List<VMFNotification> _scheduledNotifications = [];
  
  // Configuración de notificaciones por tipo
  final Map<NotificationType, bool> _typeSettings = {
    NotificationType.general: true,
    NotificationType.prayer: true,
    NotificationType.event: true,
    NotificationType.pastoral: true,
    NotificationType.devotional: true,
    NotificationType.offering: true,
    NotificationType.livestream: true,
    NotificationType.community: true,
    NotificationType.reminder: true,
    NotificationType.emergency: true,
  };

  // Configuración de horarios para recordatorios automáticos
  final Map<String, TimeOfDay> _reminderTimes = {
    'morning_prayer': const TimeOfDay(hour: 7, minute: 0),
    'evening_prayer': const TimeOfDay(hour: 19, minute: 0),
    'devotional': const TimeOfDay(hour: 8, minute: 30),
  };

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    await _loadSettings();
    await _loadScheduledNotifications();
    _startBackgroundService();
    
    debugPrint('✅ Firebase Notification Manager initialized');
  }

  /// Agrega un listener para nuevas notificaciones
  void addListener(Function(VMFNotification) listener) {
    _listeners.add(listener);
  }

  /// Remueve un listener
  void removeListener(Function(VMFNotification) listener) {
    _listeners.remove(listener);
  }

  /// Envía una notificación inmediata
  Future<void> sendNotification(VMFNotification notification) async {
    // Verificar si el tipo está habilitado
    if (!(_typeSettings[notification.type] ?? true)) {
      debugPrint('⚠️ Notification type ${notification.type.name} is disabled');
      return;
    }

    // Simular envío de push notification
    await _simulateNetworkDelay();
    
    // Notificar a los listeners
    for (final listener in _listeners) {
      try {
        listener(notification);
      } catch (e) {
        debugPrint('❌ Error in notification listener: $e');
      }
    }

    debugPrint('📱 Notification sent: ${notification.title}');
  }

  /// Programa una notificación para el futuro
  Future<void> scheduleNotification(VMFNotification notification) async {
    if (notification.scheduledFor == null) {
      throw ArgumentError('scheduledFor must be provided for scheduled notifications');
    }

    _scheduledNotifications.add(notification);
    await _saveScheduledNotifications();
    
    debugPrint('⏰ Notification scheduled for ${notification.scheduledFor}: ${notification.title}');
  }

  /// Cancela una notificación programada
  Future<void> cancelScheduledNotification(String notificationId) async {
    _scheduledNotifications.removeWhere((n) => n.id == notificationId);
    await _saveScheduledNotifications();
    
    debugPrint('❌ Cancelled scheduled notification: $notificationId');
  }

  /// Obtiene todas las notificaciones programadas
  List<VMFNotification> getScheduledNotifications() {
    return List.from(_scheduledNotifications);
  }

  /// Configura si un tipo de notificación está habilitado
  Future<void> setNotificationTypeEnabled(NotificationType type, bool enabled) async {
    _typeSettings[type] = enabled;
    await _saveSettings();
    
    debugPrint('⚙️ Notification type ${type.name} ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Verifica si un tipo de notificación está habilitado
  bool isNotificationTypeEnabled(NotificationType type) {
    return _typeSettings[type] ?? true;
  }

  /// Configura los horarios de recordatorios automáticos
  Future<void> setReminderTime(String reminderId, TimeOfDay time) async {
    _reminderTimes[reminderId] = time;
    await _saveSettings();
    
    debugPrint('⏰ Reminder time set: $reminderId at ${time.hour}:${time.minute}');
  }

  /// Obtiene un horario de recordatorio
  TimeOfDay? getReminderTime(String reminderId) {
    return _reminderTimes[reminderId];
  }

  /// Crea recordatorios automáticos de oración
  Future<void> scheduleDailyPrayerReminders() async {
    final now = DateTime.now();
    final morningTime = _reminderTimes['morning_prayer']!;
    final eveningTime = _reminderTimes['evening_prayer']!;
    
    // Recordatorio matutino
    final morningReminder = DateTime(
      now.year,
      now.month,
      now.day + 1, // Para mañana
      morningTime.hour,
      morningTime.minute,
    );
    
    await scheduleNotification(VMFNotification(
      id: 'morning_prayer_${now.millisecondsSinceEpoch}',
      title: '🌅 Tiempo de Oración Matutina',
      body: 'Buenos días! Es hora de conectar con Dios en oración. Que tengas un día bendecido.',
      createdAt: now,
      scheduledFor: morningReminder,
      type: NotificationType.prayer,
      category: NotificationCategory.spiritual,
      priority: NotificationPriority.normal,
      isPersistent: true,
      isScheduled: true,
      deepLink: '/devotional',
    ));

    // Recordatorio vespertino
    final eveningReminder = DateTime(
      now.year,
      now.month,
      now.day + 1, // Para mañana
      eveningTime.hour,
      eveningTime.minute,
    );
    
    await scheduleNotification(VMFNotification(
      id: 'evening_prayer_${now.millisecondsSinceEpoch}',
      title: '🌙 Tiempo de Oración Vespertina',
      body: 'Termina tu día agradeciendo a Dios por sus bendiciones. Un momento especial para reflexionar.',
      createdAt: now,
      scheduledFor: eveningReminder,
      type: NotificationType.prayer,
      category: NotificationCategory.spiritual,
      priority: NotificationPriority.normal,
      isPersistent: true,
      isScheduled: true,
      deepLink: '/devotional',
    ));
  }

  /// Crea recordatorios de eventos próximos
  Future<void> scheduleEventReminders(List<Map<String, dynamic>> events) async {
    for (final event in events) {
      final eventDate = DateTime.parse(event['date']);
      
      // Recordatorio 1 día antes
      final oneDayBefore = eventDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(DateTime.now())) {
        await scheduleNotification(VMFNotification(
          id: 'event_reminder_1d_${event['id']}',
          title: '📅 Evento Mañana: ${event['title']}',
          body: 'Recordatorio: ${event['title']} es mañana a las ${event['time']}. ¡No te lo pierdas!',
          imageUrl: event['imageUrl'],
          createdAt: DateTime.now(),
          scheduledFor: oneDayBefore,
          type: NotificationType.event,
          category: NotificationCategory.social,
          priority: NotificationPriority.normal,
          isScheduled: true,
          actionUrl: '/events',
          deepLink: '/events/${event['id']}',
        ));
      }

      // Recordatorio 1 hora antes
      final oneHourBefore = eventDate.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(DateTime.now())) {
        await scheduleNotification(VMFNotification(
          id: 'event_reminder_1h_${event['id']}',
          title: '⏰ Evento en 1 Hora: ${event['title']}',
          body: '${event['title']} comienza en 1 hora. Prepárate para este momento especial.',
          imageUrl: event['imageUrl'],
          createdAt: DateTime.now(),
          scheduledFor: oneHourBefore,
          type: NotificationType.reminder,
          category: NotificationCategory.urgent,
          priority: NotificationPriority.high,
          isScheduled: true,
          actionUrl: '/events',
          deepLink: '/events/${event['id']}',
        ));
      }
    }
  }

  /// Envía mensaje pastoral aleatorio
  Future<void> sendRandomPastoralMessage() async {
    final messages = [
      {
        'title': 'Palabra de Esperanza',
        'body': '"Porque yo sé los pensamientos que tengo acerca de vosotros, dice Jehová, pensamientos de paz, y no de mal, para daros el fin que esperáis." - Jeremías 29:11',
        'author': 'Pastor Anders Eriksson',
      },
      {
        'title': 'Reflexión Diaria',
        'body': 'En los momentos difíciles, recordemos que Dios tiene un propósito para cada situación. Confiemos en Su plan perfecto.',
        'author': 'Pastora Margareta Lindström',
      },
      {
        'title': 'Bendición VMF',
        'body': 'Que la paz de Cristo reine en tu corazón hoy y siempre. Eres amado y valioso para Dios.',
        'author': 'Pastor Erik Johansson',
      },
      {
        'title': 'Fortaleza Espiritual',
        'body': '"Todo lo puedo en Cristo que me fortalece." - Filipenses 4:13. No importa lo que enfrentes hoy, Él está contigo.',
        'author': 'Pastor Lars Andersson',
      },
    ];

    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    await sendNotification(VMFNotification(
      id: 'pastoral_${DateTime.now().millisecondsSinceEpoch}',
      title: message['title']!,
      body: message['body']!,
      subtitle: 'Mensaje de ${message['author']}',
      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
      createdAt: DateTime.now(),
      type: NotificationType.pastoral,
      category: NotificationCategory.spiritual,
      priority: NotificationPriority.normal,
    ));
  }

  /// Simula el servicio en segundo plano que verifica notificaciones programadas
  void _startBackgroundService() {
    // En producción, esto sería manejado por Firebase Functions o un worker
    // Timer.periodic(const Duration(minutes: 1), (timer) {
    //   _checkScheduledNotifications();
    // });
    
    // Simular llegada de notificaciones aleatorias cada 30 minutos
    // Timer.periodic(const Duration(minutes: 30), (timer) {
    //   if (Random().nextBool()) {
    //     sendRandomPastoralMessage();
    //   }
    // });
    
    // Por ahora solo verificamos notificaciones al inicializar
    _checkScheduledNotifications();
  }

  /// Verifica y envía notificaciones programadas que han llegado su hora
  void _checkScheduledNotifications() {
    final now = DateTime.now();
    final toSend = <VMFNotification>[];
    
    _scheduledNotifications.removeWhere((notification) {
      if (notification.scheduledFor != null && 
          notification.scheduledFor!.isBefore(now)) {
        toSend.add(notification.copyWith(
          isScheduled: false,
          createdAt: now,
        ));
        return true;
      }
      return false;
    });

    for (final notification in toSend) {
      sendNotification(notification);
    }

    if (toSend.isNotEmpty) {
      _saveScheduledNotifications();
    }
  }

  /// Simula retraso de red
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 100));
  }

  /// Carga configuraciones guardadas
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar configuración de tipos
      for (final type in NotificationType.values) {
        final key = 'notification_${type.name}_enabled';
        _typeSettings[type] = prefs.getBool(key) ?? true;
      }

      // Cargar horarios de recordatorios
      final morningHour = prefs.getInt('morning_prayer_hour') ?? 7;
      final morningMinute = prefs.getInt('morning_prayer_minute') ?? 0;
      _reminderTimes['morning_prayer'] = TimeOfDay(hour: morningHour, minute: morningMinute);

      final eveningHour = prefs.getInt('evening_prayer_hour') ?? 19;
      final eveningMinute = prefs.getInt('evening_prayer_minute') ?? 0;
      _reminderTimes['evening_prayer'] = TimeOfDay(hour: eveningHour, minute: eveningMinute);

      final devotionalHour = prefs.getInt('devotional_hour') ?? 8;
      final devotionalMinute = prefs.getInt('devotional_minute') ?? 30;
      _reminderTimes['devotional'] = TimeOfDay(hour: devotionalHour, minute: devotionalMinute);
      
    } catch (e) {
      debugPrint('❌ Error loading notification settings: $e');
    }
  }

  /// Guarda configuraciones
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar configuración de tipos
      for (final entry in _typeSettings.entries) {
        final key = 'notification_${entry.key.name}_enabled';
        await prefs.setBool(key, entry.value);
      }

      // Guardar horarios de recordatorios
      final morningTime = _reminderTimes['morning_prayer']!;
      await prefs.setInt('morning_prayer_hour', morningTime.hour);
      await prefs.setInt('morning_prayer_minute', morningTime.minute);

      final eveningTime = _reminderTimes['evening_prayer']!;
      await prefs.setInt('evening_prayer_hour', eveningTime.hour);
      await prefs.setInt('evening_prayer_minute', eveningTime.minute);

      final devotionalTime = _reminderTimes['devotional']!;
      await prefs.setInt('devotional_hour', devotionalTime.hour);
      await prefs.setInt('devotional_minute', devotionalTime.minute);
      
    } catch (e) {
      debugPrint('❌ Error saving notification settings: $e');
    }
  }

  /// Carga notificaciones programadas
  Future<void> _loadScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson = prefs.getStringList('scheduled_notifications') ?? [];
      
      _scheduledNotifications = scheduledJson
          .map((json) => VMFNotification.fromJson(jsonDecode(json)))
          .where((notification) => 
              notification.scheduledFor != null && 
              notification.scheduledFor!.isAfter(DateTime.now()))
          .toList();
      
    } catch (e) {
      debugPrint('❌ Error loading scheduled notifications: $e');
      _scheduledNotifications = [];
    }
  }

  /// Guarda notificaciones programadas
  Future<void> _saveScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson = _scheduledNotifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      await prefs.setStringList('scheduled_notifications', scheduledJson);
    } catch (e) {
      debugPrint('❌ Error saving scheduled notifications: $e');
    }
  }
}

// Clase auxiliar para manejo de tiempo
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}