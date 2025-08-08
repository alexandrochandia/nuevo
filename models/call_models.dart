
class CallParticipant {
  final int uid;
  String name;
  String? avatar;
  bool isVideoEnabled;
  bool isAudioEnabled;
  bool isHost;
  bool isSpeaking;
  double audioLevel;
  
  CallParticipant({
    required this.uid,
    required this.name,
    this.avatar,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
    this.isHost = false,
    this.isSpeaking = false,
    this.audioLevel = 0.0,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'avatar': avatar,
      'isVideoEnabled': isVideoEnabled,
      'isAudioEnabled': isAudioEnabled,
      'isHost': isHost,
      'isSpeaking': isSpeaking,
      'audioLevel': audioLevel,
    };
  }
  
  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      uid: json['uid'],
      name: json['name'],
      avatar: json['avatar'],
      isVideoEnabled: json['isVideoEnabled'] ?? true,
      isAudioEnabled: json['isAudioEnabled'] ?? true,
      isHost: json['isHost'] ?? false,
      isSpeaking: json['isSpeaking'] ?? false,
      audioLevel: json['audioLevel']?.toDouble() ?? 0.0,
    );
  }
}

class CallHistoryItem {
  final String id;
  final String callType;
  final int duration;
  final DateTime timestamp;
  final List<String> participants;
  final String status;
  final String? thumbnailUrl;
  
  CallHistoryItem({
    required this.id,
    required this.callType,
    required this.duration,
    required this.timestamp,
    required this.participants,
    required this.status,
    this.thumbnailUrl,
  });
  
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  String get participantsText {
    if (participants.length <= 2) {
      return participants.join(', ');
    } else {
      return '${participants.take(2).join(', ')} y ${participants.length - 2} más';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_type': callType,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'participants': participants,
      'status': status,
      'thumbnail_url': thumbnailUrl,
    };
  }
  
  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      id: json['id'],
      callType: json['call_type'],
      duration: json['duration_seconds'] ?? 0,
      timestamp: DateTime.parse(json['created_at']),
      participants: List<String>.from(json['participants'] ?? []),
      status: json['status'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }
}

class IncomingCall {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String callType;
  final String channelName;
  final DateTime timestamp;
  
  IncomingCall({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.callType,
    required this.channelName,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'call_id': callId,
      'caller_id': callerId,
      'caller_name': callerName,
      'caller_avatar': callerAvatar,
      'call_type': callType,
      'channel_name': channelName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory IncomingCall.fromJson(Map<String, dynamic> json) {
    return IncomingCall(
      callId: json['call_id'],
      callerId: json['caller_id'],
      callerName: json['caller_name'],
      callerAvatar: json['caller_avatar'],
      callType: json['call_type'],
      channelName: json['channel_name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

enum CallState {
  idle,
  calling,
  ringing,
  connected,
  ended,
  busy,
  failed,
}

enum CallQuality {
  poor,
  fair,
  good,
  excellent,
}

class CallStatistics {
  final int duration;
  final CallQuality networkQuality;
  final int packetsLost;
  final double audioLevel;
  final int bitrate;
  final String resolution;
  final int frameRate;
  
  CallStatistics({
    required this.duration,
    required this.networkQuality,
    required this.packetsLost,
    required this.audioLevel,
    required this.bitrate,
    required this.resolution,
    required this.frameRate,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'network_quality': networkQuality.name,
      'packets_lost': packetsLost,
      'audio_level': audioLevel,
      'bitrate': bitrate,
      'resolution': resolution,
      'frame_rate': frameRate,
    };
  }
}
