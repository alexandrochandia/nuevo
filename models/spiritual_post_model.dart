
class SpiritualPostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final String postType; // 'verse', 'prayer', 'testimony', 'reflection', 'announcement'
  final List<String> mediaUrls;
  final String? bibleVerse;
  final String? bibleReference;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final bool isVerified;
  final String? eventId;
  final Map<String, dynamic>? metadata;

  SpiritualPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.postType = 'reflection',
    this.mediaUrls = const [],
    this.bibleVerse,
    this.bibleReference,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.isVerified = false,
    this.eventId,
    this.metadata,
  });

  factory SpiritualPostModel.fromJson(Map<String, dynamic> json) {
    return SpiritualPostModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      content: json['content'] ?? '',
      postType: json['post_type'] ?? 'reflection',
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      bibleVerse: json['bible_verse'],
      bibleReference: json['bible_reference'],
      tags: List<String>.from(json['tags'] ?? []),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      location: json['location'],
      isVerified: json['is_verified'] ?? false,
      eventId: json['event_id'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'post_type': postType,
      'media_urls': mediaUrls,
      'bible_verse': bibleVerse,
      'bible_reference': bibleReference,
      'tags': tags,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_liked': isLiked,
      'is_bookmarked': isBookmarked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'location': location,
      'is_verified': isVerified,
      'event_id': eventId,
      'metadata': metadata,
    };
  }

  SpiritualPostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? postType,
    List<String>? mediaUrls,
    String? bibleVerse,
    String? bibleReference,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    bool? isVerified,
    String? eventId,
    Map<String, dynamic>? metadata,
  }) {
    return SpiritualPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      bibleVerse: bibleVerse ?? this.bibleVerse,
      bibleReference: bibleReference ?? this.bibleReference,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      eventId: eventId ?? this.eventId,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum PostType {
  verse,
  prayer,
  testimony,
  reflection,
  announcement,
  devotional,
  music,
  event
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.verse:
        return 'Versículo';
      case PostType.prayer:
        return 'Oración';
      case PostType.testimony:
        return 'Testimonio';
      case PostType.reflection:
        return 'Reflexión';
      case PostType.announcement:
        return 'Anuncio';
      case PostType.devotional:
        return 'Devocional';
      case PostType.music:
        return 'Música';
      case PostType.event:
        return 'Evento';
    }
  }

  String get emoji {
    switch (this) {
      case PostType.verse:
        return '📖';
      case PostType.prayer:
        return '🙏';
      case PostType.testimony:
        return '✨';
      case PostType.reflection:
        return '💭';
      case PostType.announcement:
        return '📢';
      case PostType.devotional:
        return '🕊️';
      case PostType.music:
        return '🎵';
      case PostType.event:
        return '🎉';
    }
  }
}
