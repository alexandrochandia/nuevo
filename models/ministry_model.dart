import 'package:flutter/material.dart';

class Ministry {
  final String id;
  final String name;
  final String description;
  final String leaderName;
  final String leaderId;
  final String? leaderImageUrl;
  final MinistryCategory category;
  final MinistryStatus status;
  final List<String> members;
  final List<String> requirements;
  final List<String> activities;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? nextMeeting;
  final String? meetingLocation;
  final int maxMembers;
  final bool isRecruiting;
  final List<MinistryEvent> events;
  final List<MinistryAnnouncement> announcements;

  Ministry({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderName,
    required this.leaderId,
    this.leaderImageUrl,
    required this.category,
    required this.status,
    this.members = const [],
    this.requirements = const [],
    this.activities = const [],
    this.tags = const [],
    required this.createdAt,
    this.nextMeeting,
    this.meetingLocation,
    this.maxMembers = 50,
    this.isRecruiting = true,
    this.events = const [],
    this.announcements = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderName': leaderName,
      'leaderId': leaderId,
      'leaderImageUrl': leaderImageUrl,
      'category': category.name,
      'status': status.name,
      'members': members,
      'requirements': requirements,
      'activities': activities,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'nextMeeting': nextMeeting?.toIso8601String(),
      'meetingLocation': meetingLocation,
      'maxMembers': maxMembers,
      'isRecruiting': isRecruiting,
      'events': events.map((e) => e.toJson()).toList(),
      'announcements': announcements.map((a) => a.toJson()).toList(),
    };
  }

  factory Ministry.fromJson(Map<String, dynamic> json) {
    return Ministry(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderName: json['leaderName'],
      leaderId: json['leaderId'],
      leaderImageUrl: json['leaderImageUrl'],
      category: MinistryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MinistryCategory.general,
      ),
      status: MinistryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MinistryStatus.active,
      ),
      members: List<String>.from(json['members'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      nextMeeting: json['nextMeeting'] != null ? DateTime.parse(json['nextMeeting']) : null,
      meetingLocation: json['meetingLocation'],
      maxMembers: json['maxMembers'] ?? 50,
      isRecruiting: json['isRecruiting'] ?? true,
      events: (json['events'] as List?)
          ?.map((e) => MinistryEvent.fromJson(e))
          .toList() ?? [],
      announcements: (json['announcements'] as List?)
          ?.map((a) => MinistryAnnouncement.fromJson(a))
          .toList() ?? [],
    );
  }

  Ministry copyWith({
    String? name,
    String? description,
    MinistryCategory? category,
    MinistryStatus? status,
    List<String>? members,
    List<String>? requirements,
    List<String>? activities,
    List<String>? tags,
    DateTime? nextMeeting,
    String? meetingLocation,
    int? maxMembers,
    bool? isRecruiting,
    List<MinistryEvent>? events,
    List<MinistryAnnouncement>? announcements,
  }) {
    return Ministry(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      leaderName: leaderName,
      leaderId: leaderId,
      leaderImageUrl: leaderImageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      members: members ?? this.members,
      requirements: requirements ?? this.requirements,
      activities: activities ?? this.activities,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      nextMeeting: nextMeeting ?? this.nextMeeting,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      maxMembers: maxMembers ?? this.maxMembers,
      isRecruiting: isRecruiting ?? this.isRecruiting,
      events: events ?? this.events,
      announcements: announcements ?? this.announcements,
    );
  }
}

class MinistryEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final EventType type;
  final bool isPublic;

  MinistryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.type,
    this.isPublic = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'type': type.name,
      'isPublic': isPublic,
    };
  }

  factory MinistryEvent.fromJson(Map<String, dynamic> json) {
    return MinistryEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.meeting,
      ),
      isPublic: json['isPublic'] ?? true,
    );
  }
}

class MinistryAnnouncement {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final AnnouncementPriority priority;
  final bool isPinned;

  MinistryAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    this.priority = AnnouncementPriority.normal,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.name,
      'isPinned': isPinned,
    };
  }

  factory MinistryAnnouncement.fromJson(Map<String, dynamic> json) {
    return MinistryAnnouncement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorName: json['authorName'],
      authorId: json['authorId'],
      createdAt: DateTime.parse(json['createdAt']),
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AnnouncementPriority.normal,
      ),
      isPinned: json['isPinned'] ?? false,
    );
  }
}

enum MinistryCategory {
  general,
  worship,
  youth,
  children,
  women,
  men,
  missions,
  intercession,
  evangelism,
  discipleship,
  marriage,
  administration,
  technology,
  media,
  hospitality,
}

enum MinistryStatus {
  active,
  recruiting,
  paused,
  inactive,
}

enum EventType {
  meeting,
  training,
  outreach,
  service,
  fellowship,
  conference,
}

enum AnnouncementPriority {
  low,
  normal,
  high,
  urgent,
}

// Extensions para enums
extension MinistryCategoryExtension on MinistryCategory {
  String get displayName {
    switch (this) {
      case MinistryCategory.general:
        return 'General';
      case MinistryCategory.worship:
        return 'Adoración';
      case MinistryCategory.youth:
        return 'Juventud';
      case MinistryCategory.children:
        return 'Niños';
      case MinistryCategory.women:
        return 'Mujeres';
      case MinistryCategory.men:
        return 'Hombres';
      case MinistryCategory.missions:
        return 'Misiones';
      case MinistryCategory.intercession:
        return 'Intercesión';
      case MinistryCategory.evangelism:
        return 'Evangelismo';
      case MinistryCategory.discipleship:
        return 'Discipulado';
      case MinistryCategory.marriage:
        return 'Matrimonio';
      case MinistryCategory.administration:
        return 'Administración';
      case MinistryCategory.technology:
        return 'Tecnología';
      case MinistryCategory.media:
        return 'Medios';
      case MinistryCategory.hospitality:
        return 'Hospitalidad';
    }
  }

  IconData get icon {
    switch (this) {
      case MinistryCategory.general:
        return Icons.group;
      case MinistryCategory.worship:
        return Icons.music_note;
      case MinistryCategory.youth:
        return Icons.groups;
      case MinistryCategory.children:
        return Icons.child_care;
      case MinistryCategory.women:
        return Icons.woman;
      case MinistryCategory.men:
        return Icons.man;
      case MinistryCategory.missions:
        return Icons.public;
      case MinistryCategory.intercession:
        return Icons.favorite;
      case MinistryCategory.evangelism:
        return Icons.campaign;
      case MinistryCategory.discipleship:
        return Icons.school;
      case MinistryCategory.marriage:
        return Icons.favorite_border;
      case MinistryCategory.administration:
        return Icons.business;
      case MinistryCategory.technology:
        return Icons.computer;
      case MinistryCategory.media:
        return Icons.videocam;
      case MinistryCategory.hospitality:
        return Icons.restaurant;
    }
  }

  Color get color {
    switch (this) {
      case MinistryCategory.general:
        return const Color(0xFF95a5a6);
      case MinistryCategory.worship:
        return const Color(0xFF9b59b6);
      case MinistryCategory.youth:
        return const Color(0xFF3498db);
      case MinistryCategory.children:
        return const Color(0xFFe74c3c);
      case MinistryCategory.women:
        return const Color(0xFFe91e63);
      case MinistryCategory.men:
        return const Color(0xFF34495e);
      case MinistryCategory.missions:
        return const Color(0xFF27ae60);
      case MinistryCategory.intercession:
        return const Color(0xFFf39c12);
      case MinistryCategory.evangelism:
        return const Color(0xFF1abc9c);
      case MinistryCategory.discipleship:
        return const Color(0xFF8e44ad);
      case MinistryCategory.marriage:
        return const Color(0xFFe74c3c);
      case MinistryCategory.administration:
        return const Color(0xFF2ecc71);
      case MinistryCategory.technology:
        return const Color(0xFF3498db);
      case MinistryCategory.media:
        return const Color(0xFFf39c12);
      case MinistryCategory.hospitality:
        return const Color(0xFFe67e22);
    }
  }
}

extension MinistryStatusExtension on MinistryStatus {
  String get displayName {
    switch (this) {
      case MinistryStatus.active:
        return 'Activo';
      case MinistryStatus.recruiting:
        return 'Reclutando';
      case MinistryStatus.paused:
        return 'Pausado';
      case MinistryStatus.inactive:
        return 'Inactivo';
    }
  }

  Color get color {
    switch (this) {
      case MinistryStatus.active:
        return Colors.green;
      case MinistryStatus.recruiting:
        return Colors.blue;
      case MinistryStatus.paused:
        return Colors.orange;
      case MinistryStatus.inactive:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case MinistryStatus.active:
        return Icons.check_circle;
      case MinistryStatus.recruiting:
        return Icons.person_add;
      case MinistryStatus.paused:
        return Icons.pause_circle;
      case MinistryStatus.inactive:
        return Icons.remove_circle;
    }
  }
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.meeting:
        return 'Reunión';
      case EventType.training:
        return 'Entrenamiento';
      case EventType.outreach:
        return 'Alcance';
      case EventType.service:
        return 'Servicio';
      case EventType.fellowship:
        return 'Confraternidad';
      case EventType.conference:
        return 'Conferencia';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.meeting:
        return Icons.meeting_room;
      case EventType.training:
        return Icons.school;
      case EventType.outreach:
        return Icons.public;
      case EventType.service:
        return Icons.volunteer_activism;
      case EventType.fellowship:
        return Icons.groups;
      case EventType.conference:
        return Icons.event;
    }
  }

  Color get color {
    switch (this) {
      case EventType.meeting:
        return Colors.blue;
      case EventType.training:
        return Colors.green;
      case EventType.outreach:
        return Colors.orange;
      case EventType.service:
        return Colors.purple;
      case EventType.fellowship:
        return Colors.pink;
      case EventType.conference:
        return Colors.red;
    }
  }
}

extension AnnouncementPriorityExtension on AnnouncementPriority {
  String get displayName {
    switch (this) {
      case AnnouncementPriority.low:
        return 'Baja';
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.high:
        return 'Alta';
      case AnnouncementPriority.urgent:
        return 'Urgente';
    }
  }

  Color get color {
    switch (this) {
      case AnnouncementPriority.low:
        return Colors.blue;
      case AnnouncementPriority.normal:
        return Colors.green;
      case AnnouncementPriority.high:
        return Colors.orange;
      case AnnouncementPriority.urgent:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case AnnouncementPriority.low:
        return Icons.info;
      case AnnouncementPriority.normal:
        return Icons.notifications;
      case AnnouncementPriority.high:
        return Icons.priority_high;
      case AnnouncementPriority.urgent:
        return Icons.emergency;
    }
  }
}