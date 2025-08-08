import 'package:flutter/material.dart';

class TicketTier {
  final String id;
  final String name;
  final String description;
  final double price;
  final int totalQuantity;
  final int soldQuantity;
  final int availableQuantity;
  final Color color;
  final List<String> benefits;
  final bool isActive;

  TicketTier({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.totalQuantity,
    required this.soldQuantity,
    required this.color,
    required this.benefits,
    this.isActive = true,
  }) : availableQuantity = totalQuantity - soldQuantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'totalQuantity': totalQuantity,
      'soldQuantity': soldQuantity,
      'color': color.value,
      'benefits': benefits,
      'isActive': isActive,
    };
  }

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    return TicketTier(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      totalQuantity: json['totalQuantity'],
      soldQuantity: json['soldQuantity'],
      color: Color(json['color']),
      benefits: List<String>.from(json['benefits']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class AttendeeInfo {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String ticketTierId;
  final String qrCode;
  final DateTime purchaseDate;
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final Map<String, dynamic> additionalInfo;

  AttendeeInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.ticketTierId,
    required this.qrCode,
    required this.purchaseDate,
    this.isCheckedIn = false,
    this.checkInTime,
    this.additionalInfo = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'ticketTierId': ticketTierId,
      'qrCode': qrCode,
      'purchaseDate': purchaseDate.toIso8601String(),
      'isCheckedIn': isCheckedIn,
      'checkInTime': checkInTime?.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }

  factory AttendeeInfo.fromJson(Map<String, dynamic> json) {
    return AttendeeInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      ticketTierId: json['ticketTierId'],
      qrCode: json['qrCode'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      isCheckedIn: json['isCheckedIn'] ?? false,
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }
}

class EventAgendaItem {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String speaker;
  final String location;
  final IconData icon;

  EventAgendaItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.speaker,
    required this.location,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'speaker': speaker,
      'location': location,
      'icon': icon.codePoint,
    };
  }

  factory EventAgendaItem.fromJson(Map<String, dynamic> json) {
    return EventAgendaItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      speaker: json['speaker'],
      location: json['location'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    );
  }
}

class AdvancedEventModel {
  final String id;
  final String title;
  final String description;
  final String longDescription;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final List<String> galleryImages;
  final String category;
  final String organizer;
  final String organizerContact;
  final List<TicketTier> ticketTiers;
  final List<AttendeeInfo> attendees;
  final List<EventAgendaItem> agenda;
  final bool isActive;
  final bool isFeatured;
  final bool allowWaitlist;
  final int maxAttendees;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  AdvancedEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.longDescription,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.galleryImages,
    required this.category,
    required this.organizer,
    required this.organizerContact,
    required this.ticketTiers,
    required this.attendees,
    required this.agenda,
    this.isActive = true,
    this.isFeatured = false,
    this.allowWaitlist = true,
    required this.maxAttendees,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  // Getters calculados
  int get totalSoldTickets => ticketTiers.fold(0, (sum, tier) => sum + tier.soldQuantity);
  int get totalAvailableTickets => ticketTiers.fold(0, (sum, tier) => sum + tier.availableQuantity);
  double get lowestPrice => ticketTiers.where((tier) => tier.isActive).map((tier) => tier.price).reduce((a, b) => a < b ? a : b);
  double get highestPrice => ticketTiers.where((tier) => tier.isActive).map((tier) => tier.price).reduce((a, b) => a > b ? a : b);
  bool get isSoldOut => totalAvailableTickets == 0;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get isPast => endDate.isBefore(DateTime.now());
  int get checkedInCount => attendees.where((attendee) => attendee.isCheckedIn).length;
  double get checkInPercentage => attendees.isEmpty ? 0 : (checkedInCount / attendees.length) * 100;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'longDescription': longDescription,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'galleryImages': galleryImages,
      'category': category,
      'organizer': organizer,
      'organizerContact': organizerContact,
      'ticketTiers': ticketTiers.map((tier) => tier.toJson()).toList(),
      'attendees': attendees.map((attendee) => attendee.toJson()).toList(),
      'agenda': agenda.map((item) => item.toJson()).toList(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'allowWaitlist': allowWaitlist,
      'maxAttendees': maxAttendees,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AdvancedEventModel.fromJson(Map<String, dynamic> json) {
    return AdvancedEventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      longDescription: json['longDescription'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      location: json['location'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imageUrl: json['imageUrl'],
      galleryImages: List<String>.from(json['galleryImages']),
      category: json['category'],
      organizer: json['organizer'],
      organizerContact: json['organizerContact'],
      ticketTiers: (json['ticketTiers'] as List).map((tier) => TicketTier.fromJson(tier)).toList(),
      attendees: (json['attendees'] as List).map((attendee) => AttendeeInfo.fromJson(attendee)).toList(),
      agenda: (json['agenda'] as List).map((item) => EventAgendaItem.fromJson(item)).toList(),
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      allowWaitlist: json['allowWaitlist'] ?? true,
      maxAttendees: json['maxAttendees'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'] ?? {},
    );
  }

  AdvancedEventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? longDescription,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? galleryImages,
    String? category,
    String? organizer,
    String? organizerContact,
    List<TicketTier>? ticketTiers,
    List<AttendeeInfo>? attendees,
    List<EventAgendaItem>? agenda,
    bool? isActive,
    bool? isFeatured,
    bool? allowWaitlist,
    int? maxAttendees,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AdvancedEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      category: category ?? this.category,
      organizer: organizer ?? this.organizer,
      organizerContact: organizerContact ?? this.organizerContact,
      ticketTiers: ticketTiers ?? this.ticketTiers,
      attendees: attendees ?? this.attendees,
      agenda: agenda ?? this.agenda,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      allowWaitlist: allowWaitlist ?? this.allowWaitlist,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
