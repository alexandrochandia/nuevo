import 'package:flutter/material.dart';

enum MediaType {
  video,
  audio,
  playlist,
  live,
  sermon,
  worship
}

enum MediaCategory {
  alabanza,
  sermones,
  podcasts,
  transmisiones,
  devocionales,
  testimonios
}

class MediaModel {
  final String id;
  final String title;
  final String description;
  final String shortDescription;
  final String thumbnailUrl;
  final String mediaUrl;
  final MediaType type;
  final MediaCategory category;
  final String artist;
  final String duration;
  final DateTime uploadDate;
  final bool isPremium;
  final bool isLive;
  final bool isFeatured;
  final List<String> tags;
  final String? youtubeId;
  final String? spotifyUrl;
  final String? soundcloudUrl;
  final int views;
  final int likes;
  final double rating;

  const MediaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.thumbnailUrl,
    required this.mediaUrl,
    required this.type,
    required this.category,
    required this.artist,
    required this.duration,
    required this.uploadDate,
    this.isPremium = false,
    this.isLive = false,
    this.isFeatured = false,
    this.tags = const [],
    this.youtubeId,
    this.spotifyUrl,
    this.soundcloudUrl,
    this.views = 0,
    this.likes = 0,
    this.rating = 0.0,
  });

  // Getters for UI display
  Color get categoryColor {
    switch (category) {
      case MediaCategory.alabanza:
        return const Color(0xFFFFD700); // Gold
      case MediaCategory.sermones:
        return const Color(0xFF4285F4); // Blue
      case MediaCategory.podcasts:
        return const Color(0xFF34A853); // Green
      case MediaCategory.transmisiones:
        return const Color(0xFFEA4335); // Red
      case MediaCategory.devocionales:
        return const Color(0xFF9C27B0); // Purple
      case MediaCategory.testimonios:
        return const Color(0xFFFF9800); // Orange
    }
  }

  String get categoryText {
    switch (category) {
      case MediaCategory.alabanza:
        return 'Alabanza';
      case MediaCategory.sermones:
        return 'Sermones';
      case MediaCategory.podcasts:
        return 'Podcasts';
      case MediaCategory.transmisiones:
        return 'En Vivo';
      case MediaCategory.devocionales:
        return 'Devocionales';
      case MediaCategory.testimonios:
        return 'Testimonios';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case MediaType.video:
        return Icons.play_circle_fill_rounded;
      case MediaType.audio:
        return Icons.music_note_rounded;
      case MediaType.playlist:
        return Icons.playlist_play_rounded;
      case MediaType.live:
        return Icons.live_tv_rounded;
      case MediaType.sermon:
        return Icons.church_rounded;
      case MediaType.worship:
        return Icons.favorite_rounded;
    }
  }

  String get typeText {
    switch (type) {
      case MediaType.video:
        return 'Video';
      case MediaType.audio:
        return 'Audio';
      case MediaType.playlist:
        return 'Playlist';
      case MediaType.live:
        return 'En Vivo';
      case MediaType.sermon:
        return 'Sermón';
      case MediaType.worship:
        return 'Adoración';
    }
  }

  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String get formattedUploadDate {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mes${difference.inDays > 60 ? 'es' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace poco';
    }
  }

  MediaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    String? thumbnailUrl,
    String? mediaUrl,
    MediaType? type,
    MediaCategory? category,
    String? artist,
    String? duration,
    DateTime? uploadDate,
    bool? isPremium,
    bool? isLive,
    bool? isFeatured,
    List<String>? tags,
    String? youtubeId,
    String? spotifyUrl,
    String? soundcloudUrl,
    int? views,
    int? likes,
    double? rating,
  }) {
    return MediaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      category: category ?? this.category,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      uploadDate: uploadDate ?? this.uploadDate,
      isPremium: isPremium ?? this.isPremium,
      isLive: isLive ?? this.isLive,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      youtubeId: youtubeId ?? this.youtubeId,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      soundcloudUrl: soundcloudUrl ?? this.soundcloudUrl,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'thumbnailUrl': thumbnailUrl,
      'mediaUrl': mediaUrl,
      'type': type.name,
      'category': category.name,
      'artist': artist,
      'duration': duration,
      'uploadDate': uploadDate.toIso8601String(),
      'isPremium': isPremium,
      'isLive': isLive,
      'isFeatured': isFeatured,
      'tags': tags,
      'youtubeId': youtubeId,
      'spotifyUrl': spotifyUrl,
      'soundcloudUrl': soundcloudUrl,
      'views': views,
      'likes': likes,
      'rating': rating,
    };
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      shortDescription: json['shortDescription'],
      thumbnailUrl: json['thumbnailUrl'],
      mediaUrl: json['mediaUrl'],
      type: MediaType.values.firstWhere((e) => e.name == json['type']),
      category: MediaCategory.values.firstWhere((e) => e.name == json['category']),
      artist: json['artist'],
      duration: json['duration'],
      uploadDate: DateTime.parse(json['uploadDate']),
      isPremium: json['isPremium'] ?? false,
      isLive: json['isLive'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      youtubeId: json['youtubeId'],
      spotifyUrl: json['spotifyUrl'],
      soundcloudUrl: json['soundcloudUrl'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }
}