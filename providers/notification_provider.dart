import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<VMFNotification> _notifications = [];
  List<VMFNotification> _filteredNotifications = [];
  bool _isLoading = false;
  String _searchQuery = '';
  NotificationType? _selectedType;
  NotificationCategory? _selectedCategory;
  bool _showOnlyUnread = false;

  List<VMFNotification> get notifications => _filteredNotifications;
  List<VMFNotification> get allNotifications => _notifications;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  NotificationType? get selectedType => _selectedType;
  NotificationCategory? get selectedCategory => _selectedCategory;
  bool get showOnlyUnread => _showOnlyUnread;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get totalCount => _notifications.length;

  NotificationProvider() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('vmf_notifications') ?? [];
      
      _notifications = notificationsJson
          .map((json) => VMFNotification.fromJson(jsonDecode(json)))
          .toList();

      // Si no hay notificaciones guardadas, cargar datos de prueba
      if (_notifications.isEmpty) {
        _notifications = _generateMockNotifications();
        await _saveNotifications();
      }

      // Ordenar por fecha (más recientes primero)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    } catch (e) {
      print('Error loading notifications: $e');
      _notifications = _generateMockNotifications();
    }

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      await prefs.setStringList('vmf_notifications', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  void _applyFilters() {
    _filteredNotifications = _notifications.where((notification) {
      // Filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!notification.title.toLowerCase().contains(query) &&
            !notification.body.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro por tipo
      if (_selectedType != null && notification.type != _selectedType) {
        return false;
      }

      // Filtro por categoría
      if (_selectedCategory != null && notification.category != _selectedCategory) {
        return false;
      }

      // Filtro solo no leídas
      if (_showOnlyUnread && notification.isRead) {
        return false;
      }

      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setTypeFilter(NotificationType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(NotificationCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setShowOnlyUnread(bool value) {
    _showOnlyUnread = value;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _selectedCategory = null;
    _showOnlyUnread = false;
    _applyFilters();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await _saveNotifications();
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    _applyFilters();
    notifyListeners();
  }

  Future<void> addNotification(VMFNotification notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
    _applyFilters();
    notifyListeners();
  }

  List<VMFNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  List<VMFNotification> getNotificationsByCategory(NotificationCategory category) {
    return _notifications.where((n) => n.category == category).toList();
  }

  List<VMFNotification> getRecentNotifications({int limit = 5}) {
    return _notifications.take(limit).toList();
  }

  List<VMFNotification> _generateMockNotifications() {
    final now = DateTime.now();
    
    return [
      VMFNotification(
        id: '1',
        title: 'Recordatorio de Oración Matutina',
        body: 'Es hora de tu tiempo devocional matutino. Que Dios bendiga este momento especial contigo.',
        subtitle: 'Devocional Diario',
        imageUrl: 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=500',
        createdAt: now.subtract(const Duration(minutes: 30)),
        type: NotificationType.prayer,
        category: NotificationCategory.spiritual,
        priority: NotificationPriority.normal,
        isPersistent: true,
        deepLink: '/devotional',
      ),
      VMFNotification(
        id: '2',
        title: 'Culto Dominical Comenzando',
        body: 'El culto dominical está a punto de comenzar. Únete a la transmisión en vivo ahora.',
        subtitle: 'Transmisión en Vivo',
        imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500',
        createdAt: now.subtract(const Duration(hours: 1)),
        type: NotificationType.livestream,
        category: NotificationCategory.spiritual,
        priority: NotificationPriority.high,
        actionUrl: '/livestream',
        deepLink: '/livestream/sunday-service',
      ),
      VMFNotification(
        id: '3',
        title: 'Mensaje Pastoral del Pastor Anders',
        body: 'Queridos hermanos, recordemos que "Todo lo puedo en Cristo que me fortalece". Mantengamos nuestra fe firme.',
        subtitle: 'Reflexión Semanal',
        imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=500',
        createdAt: now.subtract(const Duration(hours: 3)),
        type: NotificationType.pastoral,
        category: NotificationCategory.spiritual,
        priority: NotificationPriority.normal,
        isRead: false,
      ),
      VMFNotification(
        id: '4',
        title: 'Conferencia de Jóvenes - Inscripciones Abiertas',
        body: 'Ya están abiertas las inscripciones para la conferencia de jóvenes "Fuego Santo 2025". ¡No te quedes fuera!',
        subtitle: 'Evento Próximo',
        imageUrl: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=500',
        createdAt: now.subtract(const Duration(hours: 6)),
        scheduledFor: now.add(const Duration(days: 15)),
        type: NotificationType.event,
        category: NotificationCategory.social,
        priority: NotificationPriority.normal,
        isScheduled: true,
        actionUrl: '/events',
        deepLink: '/events/youth-conference-2025',
      ),
      VMFNotification(
        id: '5',
        title: 'Recordatorio de Ofrenda Misionera',
        body: 'Este mes estamos apoyando las misiones en África. Tu ofrenda puede cambiar vidas.',
        subtitle: 'Ofrenda Especial',
        imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=500',
        createdAt: now.subtract(const Duration(hours: 12)),
        type: NotificationType.offering,
        category: NotificationCategory.administrative,
        priority: NotificationPriority.normal,
        actionUrl: '/offerings',
        deepLink: '/offerings/missionary',
      ),
      VMFNotification(
        id: '6',
        title: 'Nuevo Devocional Disponible',
        body: '"La Fidelidad de Dios" - Un devocional sobre cómo Dios siempre cumple sus promesas.',
        subtitle: 'Crecimiento Espiritual',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.devotional,
        category: NotificationCategory.educational,
        priority: NotificationPriority.low,
        actionUrl: '/devotional',
        deepLink: '/devotional/gods-faithfulness',
      ),
      VMFNotification(
        id: '7',
        title: 'Reunión de Oración Grupal',
        body: 'Recordatorio: Esta noche tenemos reunión de oración grupal a las 19:00. Oremos juntos por nuestras necesidades.',
        subtitle: 'Comunidad VMF',
        imageUrl: 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=500',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        scheduledFor: now.add(const Duration(hours: 3)),
        type: NotificationType.community,
        category: NotificationCategory.social,
        priority: NotificationPriority.normal,
        isScheduled: true,
        actionUrl: '/chat',
        deepLink: '/chat/prayer-group',
      ),
      VMFNotification(
        id: '8',
        title: 'Cambio de Horario - Estudio Bíblico',
        body: 'Importante: El estudio bíblico de mañana se ha movido a las 18:30 debido a la conferencia especial.',
        subtitle: 'Actualización Importante',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.reminder,
        category: NotificationCategory.urgent,
        priority: NotificationPriority.high,
        isPersistent: true,
      ),
    ];
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}