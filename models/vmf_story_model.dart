class VMFStoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final VMFStoryType type;
  final String content;
  final String? thumbnail;
  final String? musicTitle;
  final String? musicArtist;
  final Duration duration;
  final List<String> viewByUserIds;
  final DateTime createdAt;
  final String? description;
  final List<String> hashtags;
  final VMFStoryCategory category;
  final bool isVerified;
  final int views;
  final int likes;
  final bool isLiked;

  VMFStoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.type,
    required this.content,
    this.thumbnail,
    this.musicTitle,
    this.musicArtist,
    required this.duration,
    required this.viewByUserIds,
    required this.createdAt,
    this.description,
    required this.hashtags,
    required this.category,
    this.isVerified = false,
    this.views = 0,
    this.likes = 0,
    this.isLiked = false,
  });

  factory VMFStoryModel.fromJson(Map<String, dynamic> json) {
    return VMFStoryModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userProfileImage: json['user_profile_image'] ?? '',
      type: VMFStoryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => VMFStoryType.video,
      ),
      content: json['content'],
      thumbnail: json['thumbnail'],
      musicTitle: json['music_title'],
      musicArtist: json['music_artist'],
      duration: Duration(seconds: json['duration'] ?? 0),
      viewByUserIds: List<String>.from(json['view_by_user_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      category: VMFStoryCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => VMFStoryCategory.testimonio,
      ),
      isVerified: json['is_verified'] ?? false,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_profile_image': userProfileImage,
      'type': type.toString().split('.').last,
      'content': content,
      'thumbnail': thumbnail,
      'music_title': musicTitle,
      'music_artist': musicArtist,
      'duration': duration.inSeconds,
      'view_by_user_ids': viewByUserIds,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'hashtags': hashtags,
      'category': category.toString().split('.').last,
      'is_verified': isVerified,
      'views': views,
      'likes': likes,
      'is_liked': isLiked,
    };
  }

  // Create copy with updated values
  VMFStoryModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    VMFStoryType? type,
    String? content,
    String? thumbnail,
    String? musicTitle,
    String? musicArtist,
    Duration? duration,
    List<String>? viewByUserIds,
    DateTime? createdAt,
    String? description,
    List<String>? hashtags,
    VMFStoryCategory? category,
    bool? isVerified,
    int? views,
    int? likes,
    bool? isLiked,
  }) {
    return VMFStoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      type: type ?? this.type,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      musicTitle: musicTitle ?? this.musicTitle,
      musicArtist: musicArtist ?? this.musicArtist,
      duration: duration ?? this.duration,
      viewByUserIds: viewByUserIds ?? this.viewByUserIds,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      hashtags: hashtags ?? this.hashtags,
      category: category ?? this.category,
      isVerified: isVerified ?? this.isVerified,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Mock data for VMF Sweden
  static List<VMFStoryModel> mockVMFStories() {
    return [
      VMFStoryModel(
        id: '1',
        userId: 'user1',
        userName: 'Pastor Carlos Annacondia',
        userProfileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        type: VMFStoryType.video,
        content: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        thumbnail: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        musicTitle: 'Al que es Digno',
        musicArtist: 'Hillsong United',
        duration: const Duration(seconds: 45),
        viewByUserIds: ['user2', 'user3', 'user4'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        description: 'Reflexión sobre la importancia de la oración en nuestras vidas',
        hashtags: ['#vmfsweden', '#oracion', '#fe', '#testimonio'],
        category: VMFStoryCategory.predicacion,
        isVerified: true,
        views: 234,
        likes: 89,
        isLiked: false,
      ),
      VMFStoryModel(
        id: '2',
        userId: 'user2',
        userName: 'María González',
        userProfileImage: 'https://images.unsplash.com/photo-1494790108755-2616b612b1a9?w=150',
        type: VMFStoryType.video,
        content: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        thumbnail: 'https://images.unsplash.com/photo-1494790108755-2616b612b1a9?w=300',
        musicTitle: 'Amazing Grace',
        musicArtist: 'Acapella Worship',
        duration: const Duration(seconds: 30),
        viewByUserIds: ['user1', 'user3'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        description: 'Mi testimonio de cómo Dios transformó mi vida completamente',
        hashtags: ['#testimonio', '#transformacion', '#milagro', '#vmf'],
        category: VMFStoryCategory.testimonio,
        isVerified: false,
        views: 156,
        likes: 67,
        isLiked: true,
      ),
      VMFStoryModel(
        id: '3',
        userId: 'user3',
        userName: 'David Andersson',
        userProfileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        type: VMFStoryType.video,
        content: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
        thumbnail: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
        musicTitle: 'Aquí Estoy',
        musicArtist: 'Jesús Adrián Romero',
        duration: const Duration(seconds: 60),
        viewByUserIds: ['user1', 'user2', 'user4', 'user5'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        description: 'Momentos de adoración desde Estocolmo, Suecia',
        hashtags: ['#adoracion', '#estocolmo', '#suecia', '#alabanza'],
        category: VMFStoryCategory.alabanza,
        isVerified: false,
        views: 312,
        likes: 145,
        isLiked: false,
      ),
      VMFStoryModel(
        id: '4',
        userId: 'user4',
        userName: 'Ana Persson',
        userProfileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        type: VMFStoryType.video,
        content: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        thumbnail: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300',
        musicTitle: 'Jóvenes Valientes',
        musicArtist: 'Generación 12',
        duration: const Duration(seconds: 25),
        viewByUserIds: ['user1', 'user3'],
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        description: 'Actividades de la juventud VMF - ¡Unidos en Cristo!',
        hashtags: ['#juventudvmf', '#unidos', '#jovenes', '#cristo'],
        category: VMFStoryCategory.juventud,
        isVerified: false,
        views: 89,
        likes: 34,
        isLiked: true,
      ),
      VMFStoryModel(
        id: '5',
        userId: 'user5',
        userName: 'Pastor Erik Lindqvist',
        userProfileImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        type: VMFStoryType.video,
        content: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        thumbnail: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
        musicTitle: 'Santo, Santo, Santo',
        musicArtist: 'Hillsong en Español',
        duration: const Duration(seconds: 40),
        viewByUserIds: ['user1', 'user2', 'user3'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Predica sobre el amor incondicional de Dios',
        hashtags: ['#amor', '#dios', '#predicacion', '#vmfsweden'],
        category: VMFStoryCategory.predicacion,
        isVerified: true,
        views: 445,
        likes: 203,
        isLiked: false,
      ),
    ];
  }
}

enum VMFStoryType {
  video,
  image,
  text,
}

enum VMFStoryCategory {
  testimonio,
  predicacion,
  alabanza,
  juventud,
  matrimonio,
  oracion,
  estudio,
  eventos,
}