class DevotionalModel {
  final String id;
  final String title;
  final String subtitle;
  final String mainVerse;
  final String verseReference;
  final String reflection;
  final String prayer;
  final String imageUrl;
  final DevotionalCategory category;
  final DateTime date;
  final int readTime; // minutos estimados
  final List<String> tags;
  final String author;
  final bool isFeatured;
  final bool isFavorite;
  final int views;
  final double rating;

  DevotionalModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mainVerse,
    required this.verseReference,
    required this.reflection,
    required this.prayer,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.readTime,
    required this.tags,
    required this.author,
    this.isFeatured = false,
    this.isFavorite = false,
    this.views = 0,
    this.rating = 5.0,
  });

  DevotionalModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? mainVerse,
    String? verseReference,
    String? reflection,
    String? prayer,
    String? imageUrl,
    DevotionalCategory? category,
    DateTime? date,
    int? readTime,
    List<String>? tags,
    String? author,
    bool? isFeatured,
    bool? isFavorite,
    int? views,
    double? rating,
  }) {
    return DevotionalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      mainVerse: mainVerse ?? this.mainVerse,
      verseReference: verseReference ?? this.verseReference,
      reflection: reflection ?? this.reflection,
      prayer: prayer ?? this.prayer,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      date: date ?? this.date,
      readTime: readTime ?? this.readTime,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      views: views ?? this.views,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'mainVerse': mainVerse,
      'verseReference': verseReference,
      'reflection': reflection,
      'prayer': prayer,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last,
      'date': date.toIso8601String(),
      'readTime': readTime,
      'tags': tags,
      'author': author,
      'isFeatured': isFeatured,
      'isFavorite': isFavorite,
      'views': views,
      'rating': rating,
    };
  }

  static DevotionalModel fromJson(Map<String, dynamic> json) {
    return DevotionalModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      mainVerse: json['mainVerse'],
      verseReference: json['verseReference'],
      reflection: json['reflection'],
      prayer: json['prayer'],
      imageUrl: json['imageUrl'],
      category: DevotionalCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => DevotionalCategory.daily,
      ),
      date: DateTime.parse(json['date']),
      readTime: json['readTime'],
      tags: List<String>.from(json['tags']),
      author: json['author'],
      isFeatured: json['isFeatured'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      views: json['views'] ?? 0,
      rating: json['rating']?.toDouble() ?? 5.0,
    );
  }
}

enum DevotionalCategory {
  daily('Diario', '📅'),
  prayer('Oración', '🙏'),
  fasting('Ayuno', '⭐'),
  bible('Estudio Bíblico', '📖'),
  faith('Fe', '✨'),
  hope('Esperanza', '🕊️'),
  love('Amor', '❤️'),
  family('Familia', '👨‍👩‍👧‍👦'),
  youth('Juventud', '🔥'),
  leadership('Liderazgo', '👑'),
  testimonies('Testimonios', '🎤'),
  worship('Adoración', '🎵');

  const DevotionalCategory(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

class VerseModel {
  final String text;
  final String reference;
  final String version;

  VerseModel({
    required this.text,
    required this.reference,
    this.version = 'RVR1960',
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'reference': reference,
      'version': version,
    };
  }

  static VerseModel fromJson(Map<String, dynamic> json) {
    return VerseModel(
      text: json['text'],
      reference: json['reference'],
      version: json['version'] ?? 'RVR1960',
    );
  }
}

class ReflectionModel {
  final String id;
  final String devotionalId;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final List<String> keyPoints;

  ReflectionModel({
    required this.id,
    required this.devotionalId,
    required this.content,
    required this.authorName,
    required this.createdAt,
    required this.keyPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'devotionalId': devotionalId,
      'content': content,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'keyPoints': keyPoints,
    };
  }

  static ReflectionModel fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'],
      devotionalId: json['devotionalId'],
      content: json['content'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
      keyPoints: List<String>.from(json['keyPoints']),
    );
  }
}