import 'package:flutter/material.dart';

class VMFNotification {
  final String id;
  final String title;
  final String body;
  final String? subtitle;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final NotificationType type;
  final NotificationCategory category;
  final NotificationPriority priority;
  final bool isRead;
  final bool isScheduled;
  final bool isPersistent;
  final Map<String, dynamic>? payload;
  final String? actionUrl;
  final String? deepLink;

  VMFNotification({
    required this.id,
    required this.title,
    required this.body,
    this.subtitle,
    this.imageUrl,
    required this.createdAt,
    this.scheduledFor,
    required this.type,
    required this.category,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.isScheduled = false,
    this.isPersistent = false,
    this.payload,
    this.actionUrl,
    this.deepLink,
  });

  VMFNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? subtitle,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? scheduledFor,
    NotificationType? type,
    NotificationCategory? category,
    NotificationPriority? priority,
    bool? isRead,
    bool? isScheduled,
    bool? isPersistent,
    Map<String, dynamic>? payload,
    String? actionUrl,
    String? deepLink,
  }) {
    return VMFNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      isScheduled: isScheduled ?? this.isScheduled,
      isPersistent: isPersistent ?? this.isPersistent,
      payload: payload ?? this.payload,
      actionUrl: actionUrl ?? this.actionUrl,
      deepLink: deepLink ?? this.deepLink,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'type': type.name,
      'category': category.name,
      'priority': priority.name,
      'isRead': isRead,
      'isScheduled': isScheduled,
      'isPersistent': isPersistent,
      'payload': payload,
      'actionUrl': actionUrl,
      'deepLink': deepLink,
    };
  }

  factory VMFNotification.fromJson(Map<String, dynamic> json) {
    return VMFNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      scheduledFor: json['scheduledFor'] != null 
          ? DateTime.parse(json['scheduledFor'])
          : null,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NotificationCategory.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      isRead: json['isRead'] ?? false,
      isScheduled: json['isScheduled'] ?? false,
      isPersistent: json['isPersistent'] ?? false,
      payload: json['payload'],
      actionUrl: json['actionUrl'],
      deepLink: json['deepLink'],
    );
  }
}

enum NotificationType {
  general,
  prayer,
  event,
  pastoral,
  devotional,
  offering,
  livestream,
  community,
  reminder,
  emergency,
}

enum NotificationCategory {
  general,
  spiritual,
  administrative,
  social,
  educational,
  urgent,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.prayer:
        return 'Oración';
      case NotificationType.event:
        return 'Evento';
      case NotificationType.pastoral:
        return 'Pastoral';
      case NotificationType.devotional:
        return 'Devocional';
      case NotificationType.offering:
        return 'Ofrenda';
      case NotificationType.livestream:
        return 'Transmisión';
      case NotificationType.community:
        return 'Comunidad';
      case NotificationType.reminder:
        return 'Recordatorio';
      case NotificationType.emergency:
        return 'Emergencia';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.prayer:
        return Icons.favorite;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.pastoral:
        return Icons.person;
      case NotificationType.devotional:
        return Icons.book;
      case NotificationType.offering:
        return Icons.volunteer_activism;
      case NotificationType.livestream:
        return Icons.live_tv;
      case NotificationType.community:
        return Icons.group;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.emergency:
        return Icons.warning;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.general:
        return const Color(0xFF6c757d);
      case NotificationType.prayer:
        return const Color(0xFFe91e63);
      case NotificationType.event:
        return const Color(0xFF3498db);
      case NotificationType.pastoral:
        return const Color(0xFF9b59b6);
      case NotificationType.devotional:
        return const Color(0xFF2ecc71);
      case NotificationType.offering:
        return const Color(0xFFf1c40f);
      case NotificationType.livestream:
        return const Color(0xFFe74c3c);
      case NotificationType.community:
        return const Color(0xFF17a2b8);
      case NotificationType.reminder:
        return const Color(0xFFfd7e14);
      case NotificationType.emergency:
        return const Color(0xFFdc3545);
    }
  }
}

extension NotificationCategoryExtension on NotificationCategory {
  String get displayName {
    switch (this) {
      case NotificationCategory.general:
        return 'General';
      case NotificationCategory.spiritual:
        return 'Espiritual';
      case NotificationCategory.administrative:
        return 'Administrativo';
      case NotificationCategory.social:
        return 'Social';
      case NotificationCategory.educational:
        return 'Educativo';
      case NotificationCategory.urgent:
        return 'Urgente';
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.general:
        return const Color(0xFF6c757d);
      case NotificationCategory.spiritual:
        return const Color(0xFFf1c40f);
      case NotificationCategory.administrative:
        return const Color(0xFF3498db);
      case NotificationCategory.social:
        return const Color(0xFF2ecc71);
      case NotificationCategory.educational:
        return const Color(0xFF9b59b6);
      case NotificationCategory.urgent:
        return const Color(0xFFe74c3c);
    }
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Baja';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'Alta';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return const Color(0xFF6c757d);
      case NotificationPriority.normal:
        return const Color(0xFF17a2b8);
      case NotificationPriority.high:
        return const Color(0xFFfd7e14);
      case NotificationPriority.urgent:
        return const Color(0xFFdc3545);
    }
  }
}