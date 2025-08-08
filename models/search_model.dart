import 'package:flutter/material.dart';

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final SearchResultType type;
  final DateTime? date;
  final String? location;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final double relevanceScore;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.type,
    this.date,
    this.location,
    this.tags = const [],
    this.metadata = const {},
    this.relevanceScore = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'date': date?.toIso8601String(),
      'location': location,
      'tags': tags,
      'metadata': metadata,
      'relevanceScore': relevanceScore,
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: SearchResultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SearchResultType.other,
      ),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      relevanceScore: (json['relevanceScore'] ?? 0.0).toDouble(),
    );
  }
}

enum SearchResultType {
  member,
  event,
  media,
  devotional,
  church,
  testimony,
  prayer,
  news,
  ministry,
  other,
}

class SearchFilter {
  final List<SearchResultType> types;
  final String? location;
  final List<String> tags;
  final DateRange? dateRange;
  final SortOption sortBy;
  final bool ascending;

  SearchFilter({
    this.types = const [],
    this.location,
    this.tags = const [],
    this.dateRange,
    this.sortBy = SortOption.relevance,
    this.ascending = false,
  });

  SearchFilter copyWith({
    List<SearchResultType>? types,
    String? location,
    List<String>? tags,
    DateRange? dateRange,
    SortOption? sortBy,
    bool? ascending,
  }) {
    return SearchFilter(
      types: types ?? this.types,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      dateRange: dateRange ?? this.dateRange,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'types': types.map((e) => e.name).toList(),
      'location': location,
      'tags': tags,
      'dateRange': dateRange?.toJson(),
      'sortBy': sortBy.name,
      'ascending': ascending,
    };
  }

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      types: (json['types'] as List?)
          ?.map((e) => SearchResultType.values.firstWhere(
                (type) => type.name == e,
                orElse: () => SearchResultType.other,
              ))
          .toList() ?? [],
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      dateRange: json['dateRange'] != null 
          ? DateRange.fromJson(json['dateRange'])
          : null,
      sortBy: SortOption.values.firstWhere(
        (e) => e.name == json['sortBy'],
        orElse: () => SortOption.relevance,
      ),
      ascending: json['ascending'] ?? false,
    );
  }
}

class DateRange {
  final DateTime? start;
  final DateTime? end;

  DateRange({this.start, this.end});

  Map<String, dynamic> toJson() {
    return {
      'start': start?.toIso8601String(),
      'end': end?.toIso8601String(),
    };
  }

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: json['start'] != null ? DateTime.parse(json['start']) : null,
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
    );
  }
}

enum SortOption {
  relevance,
  date,
  alphabetical,
  location,
  popularity,
}

class SearchHistory {
  final String id;
  final String query;
  final SearchFilter filter;
  final DateTime timestamp;
  final int resultCount;

  SearchHistory({
    required this.id,
    required this.query,
    required this.filter,
    required this.timestamp,
    required this.resultCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'filter': filter.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'],
      query: json['query'],
      filter: SearchFilter.fromJson(json['filter']),
      timestamp: DateTime.parse(json['timestamp']),
      resultCount: json['resultCount'],
    );
  }
}

class PopularSearch {
  final String query;
  final int frequency;
  final SearchResultType primaryType;

  PopularSearch({
    required this.query,
    required this.frequency,
    required this.primaryType,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'frequency': frequency,
      'primaryType': primaryType.name,
    };
  }

  factory PopularSearch.fromJson(Map<String, dynamic> json) {
    return PopularSearch(
      query: json['query'],
      frequency: json['frequency'],
      primaryType: SearchResultType.values.firstWhere(
        (e) => e.name == json['primaryType'],
        orElse: () => SearchResultType.other,
      ),
    );
  }
}

// Extensiones para enums
extension SearchResultTypeExtension on SearchResultType {
  String get displayName {
    switch (this) {
      case SearchResultType.member:
        return 'Hermanos';
      case SearchResultType.event:
        return 'Eventos';
      case SearchResultType.media:
        return 'Multimedia';
      case SearchResultType.devotional:
        return 'Devocionales';
      case SearchResultType.church:
        return 'Iglesias';
      case SearchResultType.testimony:
        return 'Testimonios';
      case SearchResultType.prayer:
        return 'Oración';
      case SearchResultType.news:
        return 'Noticias';
      case SearchResultType.ministry:
        return 'Ministerios';
      case SearchResultType.other:
        return 'Otros';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchResultType.member:
        return Icons.person;
      case SearchResultType.event:
        return Icons.event;
      case SearchResultType.media:
        return Icons.play_circle;
      case SearchResultType.devotional:
        return Icons.menu_book;
      case SearchResultType.church:
        return Icons.church;
      case SearchResultType.testimony:
        return Icons.auto_stories;
      case SearchResultType.prayer:
        return Icons.favorite;
      case SearchResultType.news:
        return Icons.article;
      case SearchResultType.ministry:
        return Icons.volunteer_activism;
      case SearchResultType.other:
        return Icons.search;
    }
  }

  Color get color {
    switch (this) {
      case SearchResultType.member:
        return const Color(0xFF9b59b6);
      case SearchResultType.event:
        return const Color(0xFF3498db);
      case SearchResultType.media:
        return const Color(0xFFe74c3c);
      case SearchResultType.devotional:
        return const Color(0xFF2ecc71);
      case SearchResultType.church:
        return const Color(0xFFf39c12);
      case SearchResultType.testimony:
        return const Color(0xFF1abc9c);
      case SearchResultType.prayer:
        return const Color(0xFFe91e63);
      case SearchResultType.news:
        return const Color(0xFF34495e);
      case SearchResultType.ministry:
        return const Color(0xFF9c27b0);
      case SearchResultType.other:
        return const Color(0xFF95a5a6);
    }
  }
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.relevance:
        return 'Relevancia';
      case SortOption.date:
        return 'Fecha';
      case SortOption.alphabetical:
        return 'Alfabético';
      case SortOption.location:
        return 'Ubicación';
      case SortOption.popularity:
        return 'Popularidad';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.relevance:
        return Icons.star;
      case SortOption.date:
        return Icons.calendar_today;
      case SortOption.alphabetical:
        return Icons.sort_by_alpha;
      case SortOption.location:
        return Icons.location_on;
      case SortOption.popularity:
        return Icons.trending_up;
    }
  }
}