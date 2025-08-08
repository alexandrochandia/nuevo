class SongModel {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String thumbnail;
  final String audioUrl;
  final String videoUrl;
  final String category;
  final bool isVideo;
  final bool isFavorite;
  final int plays;
  final DateTime createdAt;
  final List<String> tags;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.thumbnail,
    required this.audioUrl,
    this.videoUrl = '',
    required this.category,
    this.isVideo = false,
    this.isFavorite = false,
    this.plays = 0,
    required this.createdAt,
    this.tags = const [],
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      duration: json['duration'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      category: json['category'] ?? '',
      isVideo: json['isVideo'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      plays: json['plays'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'duration': duration,
      'thumbnail': thumbnail,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'category': category,
      'isVideo': isVideo,
      'isFavorite': isFavorite,
      'plays': plays,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? duration,
    String? thumbnail,
    String? audioUrl,
    String? videoUrl,
    String? category,
    bool? isVideo,
    bool? isFavorite,
    int? plays,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      isVideo: isVideo ?? this.isVideo,
      isFavorite: isFavorite ?? this.isFavorite,
      plays: plays ?? this.plays,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
}