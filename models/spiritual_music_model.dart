import 'package:flutter/material.dart';

class SpiritualMusic {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final String? imageUrl;
  final Duration duration;
  final MusicCategory category;
  final MusicPurpose purpose;
  final List<String> tags;
  final String? lyrics;
  final String? description;
  final bool isInstrumental;
  final bool isForWorship;
  final bool isForTestimony;
  final bool isForPreaching;
  final bool isFavorite;
  final int playCount;
  final DateTime createdAt;
  final String? bibleVerse;
  final String? spiritualMessage;
  final MusicMood mood;
  final List<String> instruments;
  final String? copyright;
  final bool isOriginal;
  final String? composer;
  final String? arranger;

  SpiritualMusic({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.audioUrl,
    this.imageUrl,
    required this.duration,
    required this.category,
    required this.purpose,
    this.tags = const [],
    this.lyrics,
    this.description,
    this.isInstrumental = false,
    this.isForWorship = false,
    this.isForTestimony = false,
    this.isForPreaching = false,
    this.isFavorite = false,
    this.playCount = 0,
    required this.createdAt,
    this.bibleVerse,
    this.spiritualMessage,
    required this.mood,
    this.instruments = const [],
    this.copyright,
    this.isOriginal = false,
    this.composer,
    this.arranger,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'duration': duration.inMilliseconds,
      'category': category.name,
      'purpose': purpose.name,
      'tags': tags,
      'lyrics': lyrics,
      'description': description,
      'isInstrumental': isInstrumental,
      'isForWorship': isForWorship,
      'isForTestimony': isForTestimony,
      'isForPreaching': isForPreaching,
      'isFavorite': isFavorite,
      'playCount': playCount,
      'createdAt': createdAt.toIso8601String(),
      'bibleVerse': bibleVerse,
      'spiritualMessage': spiritualMessage,
      'mood': mood.name,
      'instruments': instruments,
      'copyright': copyright,
      'isOriginal': isOriginal,
      'composer': composer,
      'arranger': arranger,
    };
  }

  factory SpiritualMusic.fromJson(Map<String, dynamic> json) {
    return SpiritualMusic(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      duration: Duration(milliseconds: json['duration']),
      category: MusicCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MusicCategory.worship,
      ),
      purpose: MusicPurpose.values.firstWhere(
        (e) => e.name == json['purpose'],
        orElse: () => MusicPurpose.worship,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      lyrics: json['lyrics'],
      description: json['description'],
      isInstrumental: json['isInstrumental'] ?? false,
      isForWorship: json['isForWorship'] ?? false,
      isForTestimony: json['isForTestimony'] ?? false,
      isForPreaching: json['isForPreaching'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      playCount: json['playCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      bibleVerse: json['bibleVerse'],
      spiritualMessage: json['spiritualMessage'],
      mood: MusicMood.values.firstWhere(
        (e) => e.name == json['mood'],
        orElse: () => MusicMood.peaceful,
      ),
      instruments: List<String>.from(json['instruments'] ?? []),
      copyright: json['copyright'],
      isOriginal: json['isOriginal'] ?? false,
      composer: json['composer'],
      arranger: json['arranger'],
    );
  }

  SpiritualMusic copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? audioUrl,
    String? imageUrl,
    Duration? duration,
    MusicCategory? category,
    MusicPurpose? purpose,
    List<String>? tags,
    String? lyrics,
    String? description,
    bool? isInstrumental,
    bool? isForWorship,
    bool? isForTestimony,
    bool? isForPreaching,
    bool? isFavorite,
    int? playCount,
    DateTime? createdAt,
    String? bibleVerse,
    String? spiritualMessage,
    MusicMood? mood,
    List<String>? instruments,
    String? copyright,
    bool? isOriginal,
    String? composer,
    String? arranger,
  }) {
    return SpiritualMusic(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      purpose: purpose ?? this.purpose,
      tags: tags ?? this.tags,
      lyrics: lyrics ?? this.lyrics,
      description: description ?? this.description,
      isInstrumental: isInstrumental ?? this.isInstrumental,
      isForWorship: isForWorship ?? this.isForWorship,
      isForTestimony: isForTestimony ?? this.isForTestimony,
      isForPreaching: isForPreaching ?? this.isForPreaching,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      bibleVerse: bibleVerse ?? this.bibleVerse,
      spiritualMessage: spiritualMessage ?? this.spiritualMessage,
      mood: mood ?? this.mood,
      instruments: instruments ?? this.instruments,
      copyright: copyright ?? this.copyright,
      isOriginal: isOriginal ?? this.isOriginal,
      composer: composer ?? this.composer,
      arranger: arranger ?? this.arranger,
    );
  }
}

enum MusicCategory {
  worship,
  praise,
  testimony,
  preaching,
  instrumental,
  choir,
  youth,
  children,
  seasonal,
  hymns,
  contemporary,
  traditional,
}

enum MusicPurpose {
  worship,
  testimony,
  preaching,
  meditation,
  prayer,
  celebration,
  communion,
  baptism,
  wedding,
  funeral,
  evangelism,
  teaching,
}

enum MusicMood {
  peaceful,
  joyful,
  reverent,
  celebratory,
  contemplative,
  powerful,
  gentle,
  uplifting,
  solemn,
  hopeful,
  healing,
  victorious,
}

extension MusicCategoryExtension on MusicCategory {
  String get displayName {
    switch (this) {
      case MusicCategory.worship:
        return 'Adoración';
      case MusicCategory.praise:
        return 'Alabanza';
      case MusicCategory.testimony:
        return 'Testimonio';
      case MusicCategory.preaching:
        return 'Predicación';
      case MusicCategory.instrumental:
        return 'Instrumental';
      case MusicCategory.choir:
        return 'Coro';
      case MusicCategory.youth:
        return 'Juventud';
      case MusicCategory.children:
        return 'Niños';
      case MusicCategory.seasonal:
        return 'Estacional';
      case MusicCategory.hymns:
        return 'Himnos';
      case MusicCategory.contemporary:
        return 'Contemporáneo';
      case MusicCategory.traditional:
        return 'Tradicional';
    }
  }

  Color get color {
    switch (this) {
      case MusicCategory.worship:
        return Colors.purple;
      case MusicCategory.praise:
        return Colors.orange;
      case MusicCategory.testimony:
        return Colors.green;
      case MusicCategory.preaching:
        return Colors.blue;
      case MusicCategory.instrumental:
        return Colors.indigo;
      case MusicCategory.choir:
        return Colors.pink;
      case MusicCategory.youth:
        return Colors.cyan;
      case MusicCategory.children:
        return Colors.yellow;
      case MusicCategory.seasonal:
        return Colors.red;
      case MusicCategory.hymns:
        return Colors.brown;
      case MusicCategory.contemporary:
        return Colors.teal;
      case MusicCategory.traditional:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case MusicCategory.worship:
        return Icons.favorite;
      case MusicCategory.praise:
        return Icons.celebration;
      case MusicCategory.testimony:
        return Icons.record_voice_over;
      case MusicCategory.preaching:
        return Icons.menu_book;
      case MusicCategory.instrumental:
        return Icons.piano;
      case MusicCategory.choir:
        return Icons.group;
      case MusicCategory.youth:
        return Icons.people;
      case MusicCategory.children:
        return Icons.child_care;
      case MusicCategory.seasonal:
        return Icons.calendar_today;
      case MusicCategory.hymns:
        return Icons.library_music;
      case MusicCategory.contemporary:
        return Icons.trending_up;
      case MusicCategory.traditional:
        return Icons.history;
    }
  }
}

extension MusicPurposeExtension on MusicPurpose {
  String get displayName {
    switch (this) {
      case MusicPurpose.worship:
        return 'Adoración';
      case MusicPurpose.testimony:
        return 'Testimonio';
      case MusicPurpose.preaching:
        return 'Predicación';
      case MusicPurpose.meditation:
        return 'Meditación';
      case MusicPurpose.prayer:
        return 'Oración';
      case MusicPurpose.celebration:
        return 'Celebración';
      case MusicPurpose.communion:
        return 'Comunión';
      case MusicPurpose.baptism:
        return 'Bautismo';
      case MusicPurpose.wedding:
        return 'Boda';
      case MusicPurpose.funeral:
        return 'Funeral';
      case MusicPurpose.evangelism:
        return 'Evangelismo';
      case MusicPurpose.teaching:
        return 'Enseñanza';
    }
  }
}

extension MusicMoodExtension on MusicMood {
  String get displayName {
    switch (this) {
      case MusicMood.peaceful:
        return 'Pacífico';
      case MusicMood.joyful:
        return 'Gozoso';
      case MusicMood.reverent:
        return 'Reverente';
      case MusicMood.celebratory:
        return 'Celebratorio';
      case MusicMood.contemplative:
        return 'Contemplativo';
      case MusicMood.powerful:
        return 'Poderoso';
      case MusicMood.gentle:
        return 'Suave';
      case MusicMood.uplifting:
        return 'Edificante';
      case MusicMood.solemn:
        return 'Solemne';
      case MusicMood.hopeful:
        return 'Esperanzador';
      case MusicMood.healing:
        return 'Sanador';
      case MusicMood.victorious:
        return 'Victorioso';
    }
  }
}