import 'package:flutter/material.dart';

class PrayerRequest {
  final String id;
  final String title;
  final String description;
  final String requesterName;
  final String requesterId;
  final String? requesterImageUrl;
  final PrayerCategory category;
  final PrayerUrgency urgency;
  final PrayerStatus status;
  final bool isAnonymous;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? answeredAt;
  final List<String> tags;
  final List<PrayerUpdate> updates;
  final int prayerCount;
  final List<String> prayerPartners;
  final String? testimonyAnswer;

  PrayerRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.requesterName,
    required this.requesterId,
    this.requesterImageUrl,
    required this.category,
    required this.urgency,
    required this.status,
    this.isAnonymous = false,
    this.isPublic = true,
    required this.createdAt,
    this.updatedAt,
    this.answeredAt,
    this.tags = const [],
    this.updates = const [],
    this.prayerCount = 0,
    this.prayerPartners = const [],
    this.testimonyAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requesterName': requesterName,
      'requesterId': requesterId,
      'requesterImageUrl': requesterImageUrl,
      'category': category.name,
      'urgency': urgency.name,
      'status': status.name,
      'isAnonymous': isAnonymous,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
      'tags': tags,
      'updates': updates.map((u) => u.toJson()).toList(),
      'prayerCount': prayerCount,
      'prayerPartners': prayerPartners,
      'testimonyAnswer': testimonyAnswer,
    };
  }

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      requesterName: json['requesterName'],
      requesterId: json['requesterId'],
      requesterImageUrl: json['requesterImageUrl'],
      category: PrayerCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PrayerCategory.general,
      ),
      urgency: PrayerUrgency.values.firstWhere(
        (e) => e.name == json['urgency'],
        orElse: () => PrayerUrgency.normal,
      ),
      status: PrayerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrayerStatus.active,
      ),
      isAnonymous: json['isAnonymous'] ?? false,
      isPublic: json['isPublic'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      updates: (json['updates'] as List?)
          ?.map((u) => PrayerUpdate.fromJson(u))
          .toList() ?? [],
      prayerCount: json['prayerCount'] ?? 0,
      prayerPartners: List<String>.from(json['prayerPartners'] ?? []),
      testimonyAnswer: json['testimonyAnswer'],
    );
  }

  PrayerRequest copyWith({
    String? title,
    String? description,
    PrayerCategory? category,
    PrayerUrgency? urgency,
    PrayerStatus? status,
    bool? isAnonymous,
    bool? isPublic,
    DateTime? updatedAt,
    DateTime? answeredAt,
    List<String>? tags,
    List<PrayerUpdate>? updates,
    int? prayerCount,
    List<String>? prayerPartners,
    String? testimonyAnswer,
  }) {
    return PrayerRequest(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      requesterName: requesterName,
      requesterId: requesterId,
      requesterImageUrl: requesterImageUrl,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      tags: tags ?? this.tags,
      updates: updates ?? this.updates,
      prayerCount: prayerCount ?? this.prayerCount,
      prayerPartners: prayerPartners ?? this.prayerPartners,
      testimonyAnswer: testimonyAnswer ?? this.testimonyAnswer,
    );
  }
}

class PrayerUpdate {
  final String id;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final PrayerUpdateType type;

  PrayerUpdate({
    required this.id,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
    };
  }

  factory PrayerUpdate.fromJson(Map<String, dynamic> json) {
    return PrayerUpdate(
      id: json['id'],
      content: json['content'],
      authorName: json['authorName'],
      authorId: json['authorId'],
      createdAt: DateTime.parse(json['createdAt']),
      type: PrayerUpdateType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PrayerUpdateType.update,
      ),
    );
  }
}

enum PrayerCategory {
  general,
  health,
  family,
  work,
  spiritual,
  financial,
  ministry,
  missions,
  relationships,
  guidance,
  protection,
  thanksgiving,
}

enum PrayerUrgency {
  low,
  normal,
  high,
  urgent,
}

enum PrayerStatus {
  active,
  answered,
  closed,
  archived,
}

enum PrayerUpdateType {
  update,
  prayer,
  testimony,
  encouragement,
}

class PrayerFilter {
  final List<PrayerCategory> categories;
  final List<PrayerUrgency> urgencies;
  final List<PrayerStatus> statuses;
  final bool showOnlyMine;
  final bool showAnonymous;
  final DateRange? dateRange;
  final String? searchQuery;

  PrayerFilter({
    this.categories = const [],
    this.urgencies = const [],
    this.statuses = const [],
    this.showOnlyMine = false,
    this.showAnonymous = true,
    this.dateRange,
    this.searchQuery,
  });

  PrayerFilter copyWith({
    List<PrayerCategory>? categories,
    List<PrayerUrgency>? urgencies,
    List<PrayerStatus>? statuses,
    bool? showOnlyMine,
    bool? showAnonymous,
    DateRange? dateRange,
    String? searchQuery,
  }) {
    return PrayerFilter(
      categories: categories ?? this.categories,
      urgencies: urgencies ?? this.urgencies,
      statuses: statuses ?? this.statuses,
      showOnlyMine: showOnlyMine ?? this.showOnlyMine,
      showAnonymous: showAnonymous ?? this.showAnonymous,
      dateRange: dateRange ?? this.dateRange,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DateRange {
  final DateTime? start;
  final DateTime? end;

  DateRange({this.start, this.end});
}

// Extensions para enums
extension PrayerCategoryExtension on PrayerCategory {
  String get displayName {
    switch (this) {
      case PrayerCategory.general:
        return 'General';
      case PrayerCategory.health:
        return 'Salud';
      case PrayerCategory.family:
        return 'Familia';
      case PrayerCategory.work:
        return 'Trabajo';
      case PrayerCategory.spiritual:
        return 'Espiritual';
      case PrayerCategory.financial:
        return 'Financiero';
      case PrayerCategory.ministry:
        return 'Ministerio';
      case PrayerCategory.missions:
        return 'Misiones';
      case PrayerCategory.relationships:
        return 'Relaciones';
      case PrayerCategory.guidance:
        return 'Dirección';
      case PrayerCategory.protection:
        return 'Protección';
      case PrayerCategory.thanksgiving:
        return 'Gratitud';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerCategory.general:
        return Icons.forum;
      case PrayerCategory.health:
        return Icons.healing;
      case PrayerCategory.family:
        return Icons.family_restroom;
      case PrayerCategory.work:
        return Icons.work;
      case PrayerCategory.spiritual:
        return Icons.auto_awesome;
      case PrayerCategory.financial:
        return Icons.attach_money;
      case PrayerCategory.ministry:
        return Icons.volunteer_activism;
      case PrayerCategory.missions:
        return Icons.public;
      case PrayerCategory.relationships:
        return Icons.favorite;
      case PrayerCategory.guidance:
        return Icons.explore;
      case PrayerCategory.protection:
        return Icons.security;
      case PrayerCategory.thanksgiving:
        return Icons.celebration;
    }
  }

  Color get color {
    switch (this) {
      case PrayerCategory.general:
        return const Color(0xFF95a5a6);
      case PrayerCategory.health:
        return const Color(0xFF27ae60);
      case PrayerCategory.family:
        return const Color(0xFFe74c3c);
      case PrayerCategory.work:
        return const Color(0xFF3498db);
      case PrayerCategory.spiritual:
        return const Color(0xFF9b59b6);
      case PrayerCategory.financial:
        return const Color(0xFFf39c12);
      case PrayerCategory.ministry:
        return const Color(0xFF1abc9c);
      case PrayerCategory.missions:
        return const Color(0xFF34495e);
      case PrayerCategory.relationships:
        return const Color(0xFFe91e63);
      case PrayerCategory.guidance:
        return const Color(0xFF2ecc71);
      case PrayerCategory.protection:
        return const Color(0xFF8e44ad);
      case PrayerCategory.thanksgiving:
        return const Color(0xFFffd700);
    }
  }
}

extension PrayerUrgencyExtension on PrayerUrgency {
  String get displayName {
    switch (this) {
      case PrayerUrgency.low:
        return 'Baja';
      case PrayerUrgency.normal:
        return 'Normal';
      case PrayerUrgency.high:
        return 'Alta';
      case PrayerUrgency.urgent:
        return 'Urgente';
    }
  }

  Color get color {
    switch (this) {
      case PrayerUrgency.low:
        return Colors.blue;
      case PrayerUrgency.normal:
        return Colors.green;
      case PrayerUrgency.high:
        return Colors.orange;
      case PrayerUrgency.urgent:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerUrgency.low:
        return Icons.schedule;
      case PrayerUrgency.normal:
        return Icons.access_time;
      case PrayerUrgency.high:
        return Icons.priority_high;
      case PrayerUrgency.urgent:
        return Icons.emergency;
    }
  }
}

extension PrayerStatusExtension on PrayerStatus {
  String get displayName {
    switch (this) {
      case PrayerStatus.active:
        return 'Activa';
      case PrayerStatus.answered:
        return 'Respondida';
      case PrayerStatus.closed:
        return 'Cerrada';
      case PrayerStatus.archived:
        return 'Archivada';
    }
  }

  Color get color {
    switch (this) {
      case PrayerStatus.active:
        return Colors.blue;
      case PrayerStatus.answered:
        return Colors.green;
      case PrayerStatus.closed:
        return Colors.grey;
      case PrayerStatus.archived:
        return Colors.brown;
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerStatus.active:
        return Icons.radio_button_checked;
      case PrayerStatus.answered:
        return Icons.check_circle;
      case PrayerStatus.closed:
        return Icons.cancel;
      case PrayerStatus.archived:
        return Icons.archive;
    }
  }
}

extension PrayerUpdateTypeExtension on PrayerUpdateType {
  String get displayName {
    switch (this) {
      case PrayerUpdateType.update:
        return 'Actualización';
      case PrayerUpdateType.prayer:
        return 'Oración';
      case PrayerUpdateType.testimony:
        return 'Testimonio';
      case PrayerUpdateType.encouragement:
        return 'Ánimo';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerUpdateType.update:
        return Icons.update;
      case PrayerUpdateType.prayer:
        return Icons.favorite;
      case PrayerUpdateType.testimony:
        return Icons.auto_stories;
      case PrayerUpdateType.encouragement:
        return Icons.thumb_up;
    }
  }

  Color get color {
    switch (this) {
      case PrayerUpdateType.update:
        return Colors.blue;
      case PrayerUpdateType.prayer:
        return Colors.red;
      case PrayerUpdateType.testimony:
        return Colors.green;
      case PrayerUpdateType.encouragement:
        return Colors.orange;
    }
  }
}