import 'package:flutter/material.dart';

class SpiritualProfile {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String spiritualBio;
  final String testimony;
  final DateTime conversionDate;
  final DateTime memberSince;
  final BaptismStatus baptismStatus;
  final DateTime? baptismDate;
  final String? baptismLocation;
  final List<String> ministries;
  final List<String> spiritualGifts;
  final List<String> favoriteVerses;
  final String currentChurch;
  final String? pastorName;
  final SpiritualMaturity maturityLevel;
  final List<ParticipationRecord> participationHistory;
  final Map<String, int> participationStats;
  final List<Achievement> achievements;
  final List<PrayerRequest> prayerRequests;
  final PreferenceSettings preferences;
  final ContactInfo contactInfo;
  final EmergencyContact? emergencyContact;
  final bool isPublicProfile;
  final bool allowDirectMessages;
  final DateTime lastActive;
  final DateTime updatedAt;

  SpiritualProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.birthDate,
    this.profileImageUrl,
    this.coverImageUrl,
    required this.spiritualBio,
    required this.testimony,
    required this.conversionDate,
    required this.memberSince,
    required this.baptismStatus,
    this.baptismDate,
    this.baptismLocation,
    this.ministries = const [],
    this.spiritualGifts = const [],
    this.favoriteVerses = const [],
    required this.currentChurch,
    this.pastorName,
    required this.maturityLevel,
    this.participationHistory = const [],
    this.participationStats = const {},
    this.achievements = const [],
    this.prayerRequests = const [],
    required this.preferences,
    required this.contactInfo,
    this.emergencyContact,
    this.isPublicProfile = true,
    this.allowDirectMessages = true,
    required this.lastActive,
    required this.updatedAt,
  });

  SpiritualProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
    String? profileImageUrl,
    String? coverImageUrl,
    String? spiritualBio,
    String? testimony,
    DateTime? conversionDate,
    DateTime? memberSince,
    BaptismStatus? baptismStatus,
    DateTime? baptismDate,
    String? baptismLocation,
    List<String>? ministries,
    List<String>? spiritualGifts,
    List<String>? favoriteVerses,
    String? currentChurch,
    String? pastorName,
    SpiritualMaturity? maturityLevel,
    List<ParticipationRecord>? participationHistory,
    Map<String, int>? participationStats,
    List<Achievement>? achievements,
    List<PrayerRequest>? prayerRequests,
    PreferenceSettings? preferences,
    ContactInfo? contactInfo,
    EmergencyContact? emergencyContact,
    bool? isPublicProfile,
    bool? allowDirectMessages,
    DateTime? lastActive,
    DateTime? updatedAt,
  }) {
    return SpiritualProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      spiritualBio: spiritualBio ?? this.spiritualBio,
      testimony: testimony ?? this.testimony,
      conversionDate: conversionDate ?? this.conversionDate,
      memberSince: memberSince ?? this.memberSince,
      baptismStatus: baptismStatus ?? this.baptismStatus,
      baptismDate: baptismDate ?? this.baptismDate,
      baptismLocation: baptismLocation ?? this.baptismLocation,
      ministries: ministries ?? this.ministries,
      spiritualGifts: spiritualGifts ?? this.spiritualGifts,
      favoriteVerses: favoriteVerses ?? this.favoriteVerses,
      currentChurch: currentChurch ?? this.currentChurch,
      pastorName: pastorName ?? this.pastorName,
      maturityLevel: maturityLevel ?? this.maturityLevel,
      participationHistory: participationHistory ?? this.participationHistory,
      participationStats: participationStats ?? this.participationStats,
      achievements: achievements ?? this.achievements,
      prayerRequests: prayerRequests ?? this.prayerRequests,
      preferences: preferences ?? this.preferences,
      contactInfo: contactInfo ?? this.contactInfo,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isPublicProfile: isPublicProfile ?? this.isPublicProfile,
      allowDirectMessages: allowDirectMessages ?? this.allowDirectMessages,
      lastActive: lastActive ?? this.lastActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'spiritualBio': spiritualBio,
      'testimony': testimony,
      'conversionDate': conversionDate.toIso8601String(),
      'memberSince': memberSince.toIso8601String(),
      'baptismStatus': baptismStatus.name,
      'baptismDate': baptismDate?.toIso8601String(),
      'baptismLocation': baptismLocation,
      'ministries': ministries,
      'spiritualGifts': spiritualGifts,
      'favoriteVerses': favoriteVerses,
      'currentChurch': currentChurch,
      'pastorName': pastorName,
      'maturityLevel': maturityLevel.name,
      'participationHistory': participationHistory.map((p) => p.toJson()).toList(),
      'participationStats': participationStats,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'prayerRequests': prayerRequests.map((p) => p.toJson()).toList(),
      'preferences': preferences.toJson(),
      'contactInfo': contactInfo.toJson(),
      'emergencyContact': emergencyContact?.toJson(),
      'isPublicProfile': isPublicProfile,
      'allowDirectMessages': allowDirectMessages,
      'lastActive': lastActive.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SpiritualProfile.fromJson(Map<String, dynamic> json) {
    return SpiritualProfile(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      profileImageUrl: json['profileImageUrl'],
      coverImageUrl: json['coverImageUrl'],
      spiritualBio: json['spiritualBio'],
      testimony: json['testimony'],
      conversionDate: DateTime.parse(json['conversionDate']),
      memberSince: DateTime.parse(json['memberSince']),
      baptismStatus: BaptismStatus.values.firstWhere(
        (e) => e.name == json['baptismStatus'],
        orElse: () => BaptismStatus.notBaptized,
      ),
      baptismDate: json['baptismDate'] != null ? DateTime.parse(json['baptismDate']) : null,
      baptismLocation: json['baptismLocation'],
      ministries: List<String>.from(json['ministries'] ?? []),
      spiritualGifts: List<String>.from(json['spiritualGifts'] ?? []),
      favoriteVerses: List<String>.from(json['favoriteVerses'] ?? []),
      currentChurch: json['currentChurch'],
      pastorName: json['pastorName'],
      maturityLevel: SpiritualMaturity.values.firstWhere(
        (e) => e.name == json['maturityLevel'],
        orElse: () => SpiritualMaturity.newBeliever,
      ),
      participationHistory: (json['participationHistory'] as List?)
          ?.map((p) => ParticipationRecord.fromJson(p))
          .toList() ?? [],
      participationStats: Map<String, int>.from(json['participationStats'] ?? {}),
      achievements: (json['achievements'] as List?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      prayerRequests: (json['prayerRequests'] as List?)
          ?.map((p) => PrayerRequest.fromJson(p))
          .toList() ?? [],
      preferences: PreferenceSettings.fromJson(json['preferences'] ?? {}),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      emergencyContact: json['emergencyContact'] != null 
          ? EmergencyContact.fromJson(json['emergencyContact'])
          : null,
      isPublicProfile: json['isPublicProfile'] ?? true,
      allowDirectMessages: json['allowDirectMessages'] ?? true,
      lastActive: DateTime.parse(json['lastActive']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum BaptismStatus {
  notBaptized,
  baptized,
  pending,
  scheduled,
}

enum SpiritualMaturity {
  newBeliever,
  growing,
  mature,
  leader,
  elder,
}

class ParticipationRecord {
  final String id;
  final String activityType;
  final String activityName;
  final DateTime date;
  final String location;
  final bool attended;
  final String? role;
  final String? notes;

  ParticipationRecord({
    required this.id,
    required this.activityType,
    required this.activityName,
    required this.date,
    required this.location,
    required this.attended,
    this.role,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityType': activityType,
      'activityName': activityName,
      'date': date.toIso8601String(),
      'location': location,
      'attended': attended,
      'role': role,
      'notes': notes,
    };
  }

  factory ParticipationRecord.fromJson(Map<String, dynamic> json) {
    return ParticipationRecord(
      id: json['id'],
      activityType: json['activityType'],
      activityName: json['activityName'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      attended: json['attended'],
      role: json['role'],
      notes: json['notes'],
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final DateTime earnedDate;
  final String category;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earnedDate,
    required this.category,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color.value,
      'earnedDate': earnedDate.toIso8601String(),
      'category': category,
      'points': points,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: Color(json['color']),
      earnedDate: DateTime.parse(json['earnedDate']),
      category: json['category'],
      points: json['points'],
    );
  }
}

class PrayerRequest {
  final String id;
  final String title;
  final String description;
  final PrayerCategory category;
  final PrayerStatus status;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final String? answerDescription;

  PrayerRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.isPublic,
    required this.createdAt,
    this.answeredAt,
    this.answerDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
      'answerDescription': answerDescription,
    };
  }

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: PrayerCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PrayerCategory.personal,
      ),
      status: PrayerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrayerStatus.active,
      ),
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
      answerDescription: json['answerDescription'],
    );
  }
}

enum PrayerCategory {
  personal,
  family,
  health,
  work,
  ministry,
  church,
  world,
  thanksgiving,
}

enum PrayerStatus {
  active,
  answered,
  ongoing,
  closed,
}

class PreferenceSettings {
  final bool allowProfileViews;
  final bool allowDirectMessages;
  final bool showParticipationStats;
  final bool showAchievements;
  final bool receiveEventNotifications;
  final bool receivePrayerNotifications;
  final String preferredLanguage;
  final String timezone;

  PreferenceSettings({
    this.allowProfileViews = true,
    this.allowDirectMessages = true,
    this.showParticipationStats = true,
    this.showAchievements = true,
    this.receiveEventNotifications = true,
    this.receivePrayerNotifications = true,
    this.preferredLanguage = 'es',
    this.timezone = 'Europe/Stockholm',
  });

  Map<String, dynamic> toJson() {
    return {
      'allowProfileViews': allowProfileViews,
      'allowDirectMessages': allowDirectMessages,
      'showParticipationStats': showParticipationStats,
      'showAchievements': showAchievements,
      'receiveEventNotifications': receiveEventNotifications,
      'receivePrayerNotifications': receivePrayerNotifications,
      'preferredLanguage': preferredLanguage,
      'timezone': timezone,
    };
  }

  factory PreferenceSettings.fromJson(Map<String, dynamic> json) {
    return PreferenceSettings(
      allowProfileViews: json['allowProfileViews'] ?? true,
      allowDirectMessages: json['allowDirectMessages'] ?? true,
      showParticipationStats: json['showParticipationStats'] ?? true,
      showAchievements: json['showAchievements'] ?? true,
      receiveEventNotifications: json['receiveEventNotifications'] ?? true,
      receivePrayerNotifications: json['receivePrayerNotifications'] ?? true,
      preferredLanguage: json['preferredLanguage'] ?? 'es',
      timezone: json['timezone'] ?? 'Europe/Stockholm',
    );
  }
}

class ContactInfo {
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? homePhone;
  final String? workPhone;
  final String? whatsapp;
  final String? telegram;
  final Map<String, String> socialMedia;

  ContactInfo({
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.homePhone,
    this.workPhone,
    this.whatsapp,
    this.telegram,
    this.socialMedia = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'homePhone': homePhone,
      'workPhone': workPhone,
      'whatsapp': whatsapp,
      'telegram': telegram,
      'socialMedia': socialMedia,
    };
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      homePhone: json['homePhone'],
      workPhone: json['workPhone'],
      whatsapp: json['whatsapp'],
      telegram: json['telegram'],
      socialMedia: Map<String, String>.from(json['socialMedia'] ?? {}),
    );
  }
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final String? email;
  final String? address;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      relationship: json['relationship'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }
}

// Extensiones para enums
extension BaptismStatusExtension on BaptismStatus {
  String get displayName {
    switch (this) {
      case BaptismStatus.notBaptized:
        return 'No Bautizado';
      case BaptismStatus.baptized:
        return 'Bautizado';
      case BaptismStatus.pending:
        return 'Pendiente';
      case BaptismStatus.scheduled:
        return 'Programado';
    }
  }

  Color get color {
    switch (this) {
      case BaptismStatus.notBaptized:
        return const Color(0xFF6c757d);
      case BaptismStatus.baptized:
        return const Color(0xFF28a745);
      case BaptismStatus.pending:
        return const Color(0xFFffc107);
      case BaptismStatus.scheduled:
        return const Color(0xFF17a2b8);
    }
  }
}

extension SpiritualMaturityExtension on SpiritualMaturity {
  String get displayName {
    switch (this) {
      case SpiritualMaturity.newBeliever:
        return 'Nuevo Creyente';
      case SpiritualMaturity.growing:
        return 'En Crecimiento';
      case SpiritualMaturity.mature:
        return 'Maduro';
      case SpiritualMaturity.leader:
        return 'Líder';
      case SpiritualMaturity.elder:
        return 'Anciano';
    }
  }

  Color get color {
    switch (this) {
      case SpiritualMaturity.newBeliever:
        return const Color(0xFF81c784);
      case SpiritualMaturity.growing:
        return const Color(0xFF64b5f6);
      case SpiritualMaturity.mature:
        return const Color(0xFFba68c8);
      case SpiritualMaturity.leader:
        return const Color(0xFFff8a65);
      case SpiritualMaturity.elder:
        return const Color(0xFFffd54f);
    }
  }

  IconData get icon {
    switch (this) {
      case SpiritualMaturity.newBeliever:
        return Icons.child_care;
      case SpiritualMaturity.growing:
        return Icons.trending_up;
      case SpiritualMaturity.mature:
        return Icons.psychology;
      case SpiritualMaturity.leader:
        return Icons.group;
      case SpiritualMaturity.elder:
        return Icons.account_balance;
    }
  }
}

extension PrayerCategoryExtension on PrayerCategory {
  String get displayName {
    switch (this) {
      case PrayerCategory.personal:
        return 'Personal';
      case PrayerCategory.family:
        return 'Familia';
      case PrayerCategory.health:
        return 'Salud';
      case PrayerCategory.work:
        return 'Trabajo';
      case PrayerCategory.ministry:
        return 'Ministerio';
      case PrayerCategory.church:
        return 'Iglesia';
      case PrayerCategory.world:
        return 'Mundial';
      case PrayerCategory.thanksgiving:
        return 'Agradecimiento';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerCategory.personal:
        return Icons.person;
      case PrayerCategory.family:
        return Icons.family_restroom;
      case PrayerCategory.health:
        return Icons.local_hospital;
      case PrayerCategory.work:
        return Icons.work;
      case PrayerCategory.ministry:
        return Icons.church;
      case PrayerCategory.church:
        return Icons.account_balance;
      case PrayerCategory.world:
        return Icons.public;
      case PrayerCategory.thanksgiving:
        return Icons.favorite;
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
      case PrayerStatus.ongoing:
        return 'En Progreso';
      case PrayerStatus.closed:
        return 'Cerrada';
    }
  }

  Color get color {
    switch (this) {
      case PrayerStatus.active:
        return const Color(0xFF17a2b8);
      case PrayerStatus.answered:
        return const Color(0xFF28a745);
      case PrayerStatus.ongoing:
        return const Color(0xFFffc107);
      case PrayerStatus.closed:
        return const Color(0xFF6c757d);
    }
  }
}