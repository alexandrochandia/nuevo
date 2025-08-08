import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum LiveStreamStatus {
  live,
  scheduled,
  ended,
  upcoming
}

enum LiveStreamType {
  culto,
  estudio,
  evento,
  juventud,
  matrimonio,
  conferencia
}

extension LiveStreamStatusExtension on LiveStreamStatus {
  String get displayName {
    switch (this) {
      case LiveStreamStatus.live:
        return 'EN VIVO';
      case LiveStreamStatus.scheduled:
        return 'PROGRAMADO';
      case LiveStreamStatus.ended:
        return 'FINALIZADO';
      case LiveStreamStatus.upcoming:
        return 'PRÓXIMO';
    }
  }

  Color get color {
    switch (this) {
      case LiveStreamStatus.live:
        return Colors.red;
      case LiveStreamStatus.scheduled:
        return Colors.orange;
      case LiveStreamStatus.ended:
        return Colors.grey;
      case LiveStreamStatus.upcoming:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case LiveStreamStatus.live:
        return Icons.radio_button_checked;
      case LiveStreamStatus.scheduled:
        return Icons.schedule;
      case LiveStreamStatus.ended:
        return Icons.stop_circle;
      case LiveStreamStatus.upcoming:
        return Icons.upcoming;
    }
  }
}

extension LiveStreamTypeExtension on LiveStreamType {
  String get displayName {
    switch (this) {
      case LiveStreamType.culto:
        return 'Culto Dominical';
      case LiveStreamType.estudio:
        return 'Estudio Bíblico';
      case LiveStreamType.evento:
        return 'Evento Especial';
      case LiveStreamType.juventud:
        return 'Culto de Jóvenes';
      case LiveStreamType.matrimonio:
        return 'Encuentro Matrimonial';
      case LiveStreamType.conferencia:
        return 'Conferencia';
    }
  }

  Color get color {
    switch (this) {
      case LiveStreamType.culto:
        return const Color(0xFF6c5ce7);
      case LiveStreamType.estudio:
        return const Color(0xFF00b894);
      case LiveStreamType.evento:
        return const Color(0xFFfd79a8);
      case LiveStreamType.juventud:
        return const Color(0xFF74b9ff);
      case LiveStreamType.matrimonio:
        return const Color(0xFFe17055);
      case LiveStreamType.conferencia:
        return const Color(0xFF00cec9);
    }
  }

  String get emoji {
    switch (this) {
      case LiveStreamType.culto:
        return '⛪';
      case LiveStreamType.estudio:
        return '📖';
      case LiveStreamType.evento:
        return '🎉';
      case LiveStreamType.juventud:
        return '🎵';
      case LiveStreamType.matrimonio:
        return '💑';
      case LiveStreamType.conferencia:
        return '🎤';
    }
  }
}

class LiveStreamModel {
  final String id;
  final String title;
  final String description;
  final String hostName;
  final String channelName;
  final String status;
  final int viewersCount;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final String? streamerId;
  final String? streamerName;
  final String? pastor;
  final String? type;
  final int? viewerCount;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? thumbnailUrl;
  final String? streamUrl;
  final String? recordingUrl;
  final List<String>? tags;
  final bool? allowComments;
  final bool? allowDonations;
  final Map<String, dynamic>? metadata;
  final int? duration;

  // Computed properties
  bool get isLive => status == 'live';
  bool get isUpcoming => scheduledTime != null && scheduledTime!.isAfter(DateTime.now()) && status != 'live';
  bool get hasEnded => status == 'ended';


  LiveStreamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hostName,
    required this.channelName,
    required this.status,
    required this.viewersCount,
    required this.createdAt,
    this.endedAt,
    this.durationMinutes,
    this.streamerId,
    this.streamerName,
    this.pastor,
    this.type,
    this.viewerCount,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    this.thumbnailUrl,
    this.streamUrl,
    this.recordingUrl,
    this.tags,
    this.allowComments,
    this.allowDonations,
    this.metadata,
    this.duration,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hostName: json['host_name']?.toString() ?? '',
      channelName: json['channel_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'offline',
      viewersCount: json['viewers_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'].toString())
          : null,
      durationMinutes: json['duration_minutes'] as int?,
      streamerId: json['streamerId']?.toString(),
      streamerName: json['streamerName']?.toString(),
      pastor: json['pastor']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      viewerCount: json['viewerCount'] as int? ?? 0,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'].toString())
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'].toString())
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'].toString())
          : null,
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      streamUrl: json['streamUrl']?.toString(),
      recordingUrl: json['recordingUrl']?.toString(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      allowComments: json['allowComments'] as bool?,
      allowDonations: json['allowDonations'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'host_name': hostName,
      'channel_name': channelName,
      'status': status,
      'viewers_count': viewersCount,
      'created_at': createdAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'streamerId': streamerId,
      'streamerName': streamerName,
      'pastor': pastor,
      'type': type,
      'viewerCount': viewerCount,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'streamUrl': streamUrl,
      'recordingUrl': recordingUrl,
      'tags': tags,
      'allowComments': allowComments,
      'allowDonations': allowDonations,
      'metadata': metadata,
      'duration': duration,
    };
  }

  LiveStreamModel copyWith({
    String? id,
    String? title,
    String? description,
    String? hostName,
    String? channelName,
    String? status,
    int? viewersCount,
    DateTime? createdAt,
    DateTime? endedAt,
    int? durationMinutes,
    String? streamerId,
    String? streamerName,
    String? pastor,
    String? type,
    int? viewerCount,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? endTime,
    String? thumbnailUrl,
    String? streamUrl,
    String? recordingUrl,
    List<String>? tags,
    bool? allowComments,
    bool? allowDonations,
    Map<String, dynamic>? metadata,
    int? duration,
  }) {
    return LiveStreamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hostName: hostName ?? this.hostName,
      channelName: channelName ?? this.channelName,
      status: status ?? this.status,
      viewersCount: viewersCount ?? this.viewersCount,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      streamerId: streamerId ?? this.streamerId,
      streamerName: streamerName ?? this.streamerName,
      pastor: pastor ?? this.pastor,
      type: type ?? this.type,
      viewerCount: viewerCount ?? this.viewerCount,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      tags: tags ?? this.tags,
      allowComments: allowComments ?? this.allowComments,
      allowDonations: allowDonations ?? this.allowDonations,
      metadata: metadata ?? this.metadata,
      duration: duration ?? this.duration,
    );
  }
}

// Stream categories
class StreamCategory {
  static const String general = 'General';
  static const String music = 'Música';
  static const String gaming = 'Gaming';
  static const String education = 'Educación';
  static const String sports = 'Deportes';
  static const String cooking = 'Cocina';
  static const String art = 'Arte';
  static const String talk = 'Talk Show';
  static const String fitness = 'Fitness';
  static const String travel = 'Viajes';

  static List<String> get all => [
    general,
    music,
    gaming,
    education,
    sports,
    cooking,
    art,
    talk,
    fitness,
    travel,
  ];
}

class LiveStreamComment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String message;
  final DateTime timestamp;
  final bool isPinned;
  final bool isFromPastor;
  final int likes;
  final String? replyToId;

  LiveStreamComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.message,
    required this.timestamp,
    this.isPinned = false,
    this.isFromPastor = false,
    this.likes = 0,
    this.replyToId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isPinned': isPinned,
      'isFromPastor': isFromPastor,
      'likes': likes,
      'replyToId': replyToId,
    };
  }

  factory LiveStreamComment.fromJson(Map<String, dynamic> json) {
    return LiveStreamComment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      isFromPastor: json['isFromPastor'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      replyToId: json['replyToId'] as String?,
    );
  }
}

class LiveStreamDonation {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String currency;
  final String message;
  final DateTime timestamp;
  final bool isAnonymous;

  LiveStreamDonation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.currency,
    required this.message,
    required this.timestamp,
    this.isAnonymous = false,
  });

  String get formattedAmount {
    switch (currency) {
      case 'SEK':
        return '${amount.toStringAsFixed(0)} kr';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'currency': currency,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  factory LiveStreamDonation.fromJson(Map<String, dynamic> json) {
    return LiveStreamDonation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }
}