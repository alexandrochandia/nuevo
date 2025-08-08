import 'package:cloud_firestore/cloud_firestore.dart';

class VMFPostModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final VMFPostType type;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final DateTime createdAt;
  final bool isApproved;
  final String? musicUrl;
  final String? musicTitle;

  VMFPostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.type,
    required this.hashtags,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    required this.createdAt,
    required this.isApproved,
    this.musicUrl,
    this.musicTitle,
  });

  // Crear desde Firestore
  factory VMFPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VMFPostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      type: VMFPostType.values.firstWhere(
        (e) => e.toString() == 'VMFPostType.${data['type']}',
        orElse: () => VMFPostType.testimonio,
      ),
      hashtags: List<String>.from(data['hashtags'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      sharesCount: data['sharesCount'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isApproved: data['isApproved'] ?? false,
      musicUrl: data['musicUrl'],
      musicTitle: data['musicTitle'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'type': type.toString().split('.').last,
      'hashtags': hashtags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': FieldValue.serverTimestamp(),
      'isApproved': isApproved,
      'musicUrl': musicUrl,
      'musicTitle': musicTitle,
    };
  }

  // Crear copia con cambios
  VMFPostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    VMFPostType? type,
    List<String>? hashtags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    DateTime? createdAt,
    bool? isApproved,
    String? musicUrl,
    String? musicTitle,
  }) {
    return VMFPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      hashtags: hashtags ?? this.hashtags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      musicUrl: musicUrl ?? this.musicUrl,
      musicTitle: musicTitle ?? this.musicTitle,
    );
  }
}

// Enum para tipos de contenido VMF
enum VMFPostType {
  testimonio,    // Testimonios de fe
  predicacion,   // Predicaciones cortas
  alabanza,      // Música y alabanzas
  reflexion,     // Reflexiones bíblicas
  oracion,       // Momentos de oración
  evento,        // Eventos de la iglesia
  comedia,       // Comedia cristiana
}

// Extensión para obtener información del tipo
extension VMFPostTypeExtension on VMFPostType {
  String get displayName {
    switch (this) {
      case VMFPostType.testimonio:
        return 'Testimonio';
      case VMFPostType.predicacion:
        return 'Predicación';
      case VMFPostType.alabanza:
        return 'Alabanza';
      case VMFPostType.reflexion:
        return 'Reflexión';
      case VMFPostType.oracion:
        return 'Oración';
      case VMFPostType.evento:
        return 'Evento';
      case VMFPostType.comedia:
        return 'Comedia';
    }
  }

  String get icon {
    switch (this) {
      case VMFPostType.testimonio:
        return '🙏';
      case VMFPostType.predicacion:
        return '✝️';
      case VMFPostType.alabanza:
        return '🎵';
      case VMFPostType.reflexion:
        return '💭';
      case VMFPostType.oracion:
        return '🕊️';
      case VMFPostType.evento:
        return '🏛️';
      case VMFPostType.comedia:
        return '😊';
    }
  }

  String get color {
    switch (this) {
      case VMFPostType.testimonio:
        return '#D4AF37'; // Dorado
      case VMFPostType.predicacion:
        return '#8B4513'; // Marrón
      case VMFPostType.alabanza:
        return '#FFD700'; // Oro
      case VMFPostType.reflexion:
        return '#4682B4'; // Azul acero
      case VMFPostType.oracion:
        return '#9370DB'; // Violeta
      case VMFPostType.evento:
        return '#DC143C'; // Rojo carmesí
      case VMFPostType.comedia:
        return '#32CD32'; // Verde lima
    }
  }
}
