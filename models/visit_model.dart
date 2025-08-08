import 'package:flutter/material.dart';

class Visit {
  final String id;
  final String visitorName;
  final String? visitorEmail;
  final String? visitorPhone;
  final String? visitorAddress;
  final VisitorType visitorType;
  final String churchLocation;
  final String country;
  final DateTime visitDate;
  final String? referredBy;
  final List<String> interests;
  final VisitStatus status;
  final String? notes;
  final String registeredBy;
  final String registeredByName;
  final DateTime createdAt;
  final List<FollowUp> followUps;
  final bool isFirstTime;
  final String? ageGroup;
  final FamilyStatus? familyStatus;
  final List<String> prayerRequests;
  final bool wantsFollowUp;
  final String? preferredContact;

  Visit({
    required this.id,
    required this.visitorName,
    this.visitorEmail,
    this.visitorPhone,
    this.visitorAddress,
    required this.visitorType,
    required this.churchLocation,
    this.country = 'Suecia',
    required this.visitDate,
    this.referredBy,
    this.interests = const [],
    this.status = VisitStatus.newVisit,
    this.notes,
    required this.registeredBy,
    required this.registeredByName,
    required this.createdAt,
    this.followUps = const [],
    this.isFirstTime = true,
    this.ageGroup,
    this.familyStatus,
    this.prayerRequests = const [],
    this.wantsFollowUp = true,
    this.preferredContact,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone,
      'visitorAddress': visitorAddress,
      'visitorType': visitorType.name,
      'churchLocation': churchLocation,
      'country': country,
      'visitDate': visitDate.toIso8601String(),
      'referredBy': referredBy,
      'interests': interests,
      'status': status.name,
      'notes': notes,
      'registeredBy': registeredBy,
      'registeredByName': registeredByName,
      'createdAt': createdAt.toIso8601String(),
      'followUps': followUps.map((f) => f.toJson()).toList(),
      'isFirstTime': isFirstTime,
      'ageGroup': ageGroup,
      'familyStatus': familyStatus?.name,
      'prayerRequests': prayerRequests,
      'wantsFollowUp': wantsFollowUp,
      'preferredContact': preferredContact,
    };
  }

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      visitorName: json['visitorName'],
      visitorEmail: json['visitorEmail'],
      visitorPhone: json['visitorPhone'],
      visitorAddress: json['visitorAddress'],
      visitorType: VisitorType.values.firstWhere(
        (e) => e.name == json['visitorType'],
        orElse: () => VisitorType.visitor,
      ),
      churchLocation: json['churchLocation'],
      country: json['country'] ?? 'Suecia',
      visitDate: DateTime.parse(json['visitDate']),
      referredBy: json['referredBy'],
      interests: List<String>.from(json['interests'] ?? []),
      status: VisitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VisitStatus.newVisit,
      ),
      notes: json['notes'],
      registeredBy: json['registeredBy'],
      registeredByName: json['registeredByName'],
      createdAt: DateTime.parse(json['createdAt']),
      followUps: (json['followUps'] as List?)
          ?.map((f) => FollowUp.fromJson(f))
          .toList() ?? [],
      isFirstTime: json['isFirstTime'] ?? true,
      ageGroup: json['ageGroup'],
      familyStatus: json['familyStatus'] != null
          ? FamilyStatus.values.firstWhere(
              (e) => e.name == json['familyStatus'],
              orElse: () => FamilyStatus.single,
            )
          : null,
      prayerRequests: List<String>.from(json['prayerRequests'] ?? []),
      wantsFollowUp: json['wantsFollowUp'] ?? true,
      preferredContact: json['preferredContact'],
    );
  }

  Visit copyWith({
    String? visitorName,
    String? visitorEmail,
    String? visitorPhone,
    String? visitorAddress,
    VisitorType? visitorType,
    String? churchLocation,
    String? country,
    DateTime? visitDate,
    String? referredBy,
    List<String>? interests,
    VisitStatus? status,
    String? notes,
    List<FollowUp>? followUps,
    bool? isFirstTime,
    String? ageGroup,
    FamilyStatus? familyStatus,
    List<String>? prayerRequests,
    bool? wantsFollowUp,
    String? preferredContact,
  }) {
    return Visit(
      id: id,
      visitorName: visitorName ?? this.visitorName,
      visitorEmail: visitorEmail ?? this.visitorEmail,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      visitorAddress: visitorAddress ?? this.visitorAddress,
      visitorType: visitorType ?? this.visitorType,
      churchLocation: churchLocation ?? this.churchLocation,
      country: country ?? this.country,
      visitDate: visitDate ?? this.visitDate,
      referredBy: referredBy ?? this.referredBy,
      interests: interests ?? this.interests,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      registeredBy: registeredBy,
      registeredByName: registeredByName,
      createdAt: createdAt,
      followUps: followUps ?? this.followUps,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      ageGroup: ageGroup ?? this.ageGroup,
      familyStatus: familyStatus ?? this.familyStatus,
      prayerRequests: prayerRequests ?? this.prayerRequests,
      wantsFollowUp: wantsFollowUp ?? this.wantsFollowUp,
      preferredContact: preferredContact ?? this.preferredContact,
    );
  }
}

class FollowUp {
  final String id;
  final String visitId;
  final FollowUpType type;
  final String content;
  final String performedBy;
  final String performedByName;
  final DateTime performedAt;
  final FollowUpResult result;
  final String? nextActionDate;
  final String? nextActionNotes;

  FollowUp({
    required this.id,
    required this.visitId,
    required this.type,
    required this.content,
    required this.performedBy,
    required this.performedByName,
    required this.performedAt,
    this.result = FollowUpResult.pending,
    this.nextActionDate,
    this.nextActionNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitId': visitId,
      'type': type.name,
      'content': content,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'performedAt': performedAt.toIso8601String(),
      'result': result.name,
      'nextActionDate': nextActionDate,
      'nextActionNotes': nextActionNotes,
    };
  }

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'],
      visitId: json['visitId'],
      type: FollowUpType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FollowUpType.call,
      ),
      content: json['content'],
      performedBy: json['performedBy'],
      performedByName: json['performedByName'],
      performedAt: DateTime.parse(json['performedAt']),
      result: FollowUpResult.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => FollowUpResult.pending,
      ),
      nextActionDate: json['nextActionDate'],
      nextActionNotes: json['nextActionNotes'],
    );
  }
}

enum VisitorType {
  visitor,
  returnVisitor,
  newMember,
  transferMember,
  guest,
}

enum VisitStatus {
  newVisit,
  contacted,
  scheduled,
  followedUp,
  integrated,
  inactive,
}

enum FamilyStatus {
  single,
  married,
  divorced,
  widowed,
  family,
}

enum FollowUpType {
  call,
  email,
  visit,
  whatsapp,
  letter,
  invitation,
}

enum FollowUpResult {
  pending,
  successful,
  noResponse,
  requestedSpace,
  notInterested,
  wrongContact,
}

// Extensions para enums
extension VisitorTypeExtension on VisitorType {
  String get displayName {
    switch (this) {
      case VisitorType.visitor:
        return 'Visitante';
      case VisitorType.returnVisitor:
        return 'Visitante Recurrente';
      case VisitorType.newMember:
        return 'Nuevo Miembro';
      case VisitorType.transferMember:
        return 'Miembro Transferido';
      case VisitorType.guest:
        return 'Invitado Especial';
    }
  }

  IconData get icon {
    switch (this) {
      case VisitorType.visitor:
        return Icons.person_add;
      case VisitorType.returnVisitor:
        return Icons.repeat;
      case VisitorType.newMember:
        return Icons.group_add;
      case VisitorType.transferMember:
        return Icons.swap_horiz;
      case VisitorType.guest:
        return Icons.star;
    }
  }

  Color get color {
    switch (this) {
      case VisitorType.visitor:
        return const Color(0xFF3498db);
      case VisitorType.returnVisitor:
        return const Color(0xFF2ecc71);
      case VisitorType.newMember:
        return const Color(0xFF9b59b6);
      case VisitorType.transferMember:
        return const Color(0xFFe67e22);
      case VisitorType.guest:
        return const Color(0xFFf39c12);
    }
  }
}

extension VisitStatusExtension on VisitStatus {
  String get displayName {
    switch (this) {
      case VisitStatus.newVisit:
        return 'Nueva Visita';
      case VisitStatus.contacted:
        return 'Contactado';
      case VisitStatus.scheduled:
        return 'Programado';
      case VisitStatus.followedUp:
        return 'Con Seguimiento';
      case VisitStatus.integrated:
        return 'Integrado';
      case VisitStatus.inactive:
        return 'Inactivo';
    }
  }

  IconData get icon {
    switch (this) {
      case VisitStatus.newVisit:
        return Icons.new_label;
      case VisitStatus.contacted:
        return Icons.contact_phone;
      case VisitStatus.scheduled:
        return Icons.schedule;
      case VisitStatus.followedUp:
        return Icons.follow_the_signs;
      case VisitStatus.integrated:
        return Icons.check_circle;
      case VisitStatus.inactive:
        return Icons.pause_circle;
    }
  }

  Color get color {
    switch (this) {
      case VisitStatus.newVisit:
        return Colors.blue;
      case VisitStatus.contacted:
        return Colors.orange;
      case VisitStatus.scheduled:
        return Colors.purple;
      case VisitStatus.followedUp:
        return Colors.teal;
      case VisitStatus.integrated:
        return Colors.green;
      case VisitStatus.inactive:
        return Colors.grey;
    }
  }
}

extension FamilyStatusExtension on FamilyStatus {
  String get displayName {
    switch (this) {
      case FamilyStatus.single:
        return 'Soltero/a';
      case FamilyStatus.married:
        return 'Casado/a';
      case FamilyStatus.divorced:
        return 'Divorciado/a';
      case FamilyStatus.widowed:
        return 'Viudo/a';
      case FamilyStatus.family:
        return 'Familia';
    }
  }

  IconData get icon {
    switch (this) {
      case FamilyStatus.single:
        return Icons.person;
      case FamilyStatus.married:
        return Icons.favorite;
      case FamilyStatus.divorced:
        return Icons.heart_broken;
      case FamilyStatus.widowed:
        return Icons.person_outline;
      case FamilyStatus.family:
        return Icons.family_restroom;
    }
  }
}

extension FollowUpTypeExtension on FollowUpType {
  String get displayName {
    switch (this) {
      case FollowUpType.call:
        return 'Llamada';
      case FollowUpType.email:
        return 'Email';
      case FollowUpType.visit:
        return 'Visita';
      case FollowUpType.whatsapp:
        return 'WhatsApp';
      case FollowUpType.letter:
        return 'Carta';
      case FollowUpType.invitation:
        return 'Invitación';
    }
  }

  IconData get icon {
    switch (this) {
      case FollowUpType.call:
        return Icons.phone;
      case FollowUpType.email:
        return Icons.email;
      case FollowUpType.visit:
        return Icons.home;
      case FollowUpType.whatsapp:
        return Icons.chat;
      case FollowUpType.letter:
        return Icons.mail;
      case FollowUpType.invitation:
        return Icons.event;
    }
  }

  Color get color {
    switch (this) {
      case FollowUpType.call:
        return Colors.green;
      case FollowUpType.email:
        return Colors.blue;
      case FollowUpType.visit:
        return Colors.orange;
      case FollowUpType.whatsapp:
        return Colors.teal;
      case FollowUpType.letter:
        return Colors.purple;
      case FollowUpType.invitation:
        return Colors.pink;
    }
  }
}

extension FollowUpResultExtension on FollowUpResult {
  String get displayName {
    switch (this) {
      case FollowUpResult.pending:
        return 'Pendiente';
      case FollowUpResult.successful:
        return 'Exitoso';
      case FollowUpResult.noResponse:
        return 'Sin Respuesta';
      case FollowUpResult.requestedSpace:
        return 'Pidió Espacio';
      case FollowUpResult.notInterested:
        return 'No Interesado';
      case FollowUpResult.wrongContact:
        return 'Contacto Incorrecto';
    }
  }

  Color get color {
    switch (this) {
      case FollowUpResult.pending:
        return Colors.orange;
      case FollowUpResult.successful:
        return Colors.green;
      case FollowUpResult.noResponse:
        return Colors.grey;
      case FollowUpResult.requestedSpace:
        return Colors.blue;
      case FollowUpResult.notInterested:
        return Colors.red;
      case FollowUpResult.wrongContact:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case FollowUpResult.pending:
        return Icons.schedule;
      case FollowUpResult.successful:
        return Icons.check_circle;
      case FollowUpResult.noResponse:
        return Icons.radio_button_unchecked;
      case FollowUpResult.requestedSpace:
        return Icons.pause;
      case FollowUpResult.notInterested:
        return Icons.cancel;
      case FollowUpResult.wrongContact:
        return Icons.error;
    }
  }
}