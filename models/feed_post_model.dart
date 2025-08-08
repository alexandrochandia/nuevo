import 'package:flutter/material.dart';

class FeedPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorRole;
  final String authorImage;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  final FeedPostType type;
  final FeedPostCategory category;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isPinned;
  final bool isHighlighted;
  final List<String> tags;

  FeedPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorRole,
    required this.authorImage,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    required this.type,
    required this.category,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    this.isHighlighted = false,
    this.tags = const [],
  });

  FeedPost copyWith({
    String? id,
    String? title,
    String? content,
    String? authorName,
    String? authorRole,
    String? authorImage,
    String? imageUrl,
    String? videoUrl,
    DateTime? createdAt,
    FeedPostType? type,
    FeedPostCategory? category,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isPinned,
    bool? isHighlighted,
    List<String>? tags,
  }) {
    return FeedPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorImage: authorImage ?? this.authorImage,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      tags: tags ?? this.tags,
    );
  }
}

enum FeedPostType {
  announcement,
  reflection,
  news,
  event,
  prayer,
  testimony,
  teaching,
  verse,
}

enum FeedPostCategory {
  general,
  worship,
  youth,
  missions,
  community,
  prayer,
  study,
  family,
}

class FeedComment {
  final String id;
  final String postId;
  final String content;
  final String authorName;
  final String authorImage;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final List<FeedComment> replies;

  FeedComment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorName,
    required this.authorImage,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  FeedComment copyWith({
    String? id,
    String? postId,
    String? content,
    String? authorName,
    String? authorImage,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    List<FeedComment>? replies,
  }) {
    return FeedComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}

// Extensiones para obtener información de display
extension FeedPostTypeExtension on FeedPostType {
  String get displayName {
    switch (this) {
      case FeedPostType.announcement:
        return 'Anuncio';
      case FeedPostType.reflection:
        return 'Reflexión';
      case FeedPostType.news:
        return 'Noticia';
      case FeedPostType.event:
        return 'Evento';
      case FeedPostType.prayer:
        return 'Oración';
      case FeedPostType.testimony:
        return 'Testimonio';
      case FeedPostType.teaching:
        return 'Enseñanza';
      case FeedPostType.verse:
        return 'Versículo';
    }
  }

  String get emoji {
    switch (this) {
      case FeedPostType.announcement:
        return '📢';
      case FeedPostType.reflection:
        return '💭';
      case FeedPostType.news:
        return '📰';
      case FeedPostType.event:
        return '📅';
      case FeedPostType.prayer:
        return '🙏';
      case FeedPostType.testimony:
        return '✨';
      case FeedPostType.teaching:
        return '📖';
      case FeedPostType.verse:
        return '📜';
    }
  }

  Color get color {
    switch (this) {
      case FeedPostType.announcement:
        return const Color(0xFFe74c3c);
      case FeedPostType.reflection:
        return const Color(0xFF9b59b6);
      case FeedPostType.news:
        return const Color(0xFF3498db);
      case FeedPostType.event:
        return const Color(0xFFe67e22);
      case FeedPostType.prayer:
        return const Color(0xFF2ecc71);
      case FeedPostType.testimony:
        return const Color(0xFFf1c40f);
      case FeedPostType.teaching:
        return const Color(0xFF34495e);
      case FeedPostType.verse:
        return const Color(0xFFe91e63);
    }
  }
}

extension FeedPostCategoryExtension on FeedPostCategory {
  String get displayName {
    switch (this) {
      case FeedPostCategory.general:
        return 'General';
      case FeedPostCategory.worship:
        return 'Alabanza';
      case FeedPostCategory.youth:
        return 'Juventud';
      case FeedPostCategory.missions:
        return 'Misiones';
      case FeedPostCategory.community:
        return 'Comunidad';
      case FeedPostCategory.prayer:
        return 'Oración';
      case FeedPostCategory.study:
        return 'Estudio';
      case FeedPostCategory.family:
        return 'Familia';
    }
  }
}