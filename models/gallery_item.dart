class GalleryItem {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final DateTime date;
  final int likes;
  final bool isNew;
  final bool isFavorite;
  final String? description;
  final String? author;
  final List<String> tags;

  const GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.date,
    this.likes = 0,
    this.isNew = false,
    this.isFavorite = false,
    this.description,
    this.author,
    this.tags = const [],
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      likes: json['likes'] as int? ?? 0,
      isNew: json['isNew'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      description: json['description'] as String?,
      author: json['author'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
      'likes': likes,
      'isNew': isNew,
      'isFavorite': isFavorite,
      'description': description,
      'author': author,
      'tags': tags,
    };
  }

  GalleryItem copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? category,
    DateTime? date,
    int? likes,
    bool? isNew,
    bool? isFavorite,
    String? description,
    String? author,
    List<String>? tags,
  }) {
    return GalleryItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      isNew: isNew ?? this.isNew,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      author: author ?? this.author,
      tags: tags ?? this.tags,
    );
  }
}