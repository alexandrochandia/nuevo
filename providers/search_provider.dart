import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/search_model.dart';
import '../models/spiritual_profile_model.dart';
import '../models/event_model.dart';
import '../models/media_model.dart';
import '../models/church_model.dart';
import '../models/devotional_model.dart';

class SearchProvider with ChangeNotifier {
  List<SearchResult> _searchResults = [];
  List<SearchHistory> _searchHistory = [];
  List<PopularSearch> _popularSearches = [];
  SearchFilter _currentFilter = SearchFilter();
  String _currentQuery = '';
  bool _isSearching = false;
  String _error = '';

  List<SearchResult> get searchResults => _searchResults;
  List<SearchHistory> get searchHistory => _searchHistory;
  List<PopularSearch> get popularSearches => _popularSearches;
  SearchFilter get currentFilter => _currentFilter;
  String get currentQuery => _currentQuery;
  bool get isSearching => _isSearching;
  String get error => _error;

  SearchProvider() {
    _loadSearchHistory();
    _loadPopularSearches();
    _generateMockData();
  }

  // Buscar contenido
  Future<void> search(String query, {SearchFilter? filter}) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _currentQuery = query.trim();
    _currentFilter = filter ?? SearchFilter();
    _error = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simular búsqueda

      final allResults = await _performSearch(query, _currentFilter);
      _searchResults = _sortResults(allResults, _currentFilter.sortBy, _currentFilter.ascending);

      // Guardar en historial
      await _addToHistory(query, _currentFilter, _searchResults.length);

      // Actualizar búsquedas populares
      await _updatePopularSearches(query);

    } catch (e) {
      _error = 'Error en la búsqueda: $e';
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  // Realizar búsqueda en diferentes fuentes
  Future<List<SearchResult>> _performSearch(String query, SearchFilter filter) async {
    final results = <SearchResult>[];
    final queryLower = query.toLowerCase();

    // Buscar en miembros
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.member)) {
      results.addAll(_searchMembers(queryLower, filter));
    }

    // Buscar en eventos
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.event)) {
      results.addAll(_searchEvents(queryLower, filter));
    }

    // Buscar en multimedia
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.media)) {
      results.addAll(_searchMedia(queryLower, filter));
    }

    // Buscar en iglesias
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.church)) {
      results.addAll(_searchChurches(queryLower, filter));
    }

    // Buscar en devocionales
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.devotional)) {
      results.addAll(_searchDevotionals(queryLower, filter));
    }

    // Buscar en testimonios
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.testimony)) {
      results.addAll(_searchTestimonies(queryLower, filter));
    }

    // Buscar en noticias
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.news)) {
      results.addAll(_searchNews(queryLower, filter));
    }

    // Buscar en ministerios
    if (filter.types.isEmpty || filter.types.contains(SearchResultType.ministry)) {
      results.addAll(_searchMinistries(queryLower, filter));
    }

    return results;
  }

  List<SearchResult> _searchMembers(String query, SearchFilter filter) {
    final members = _getMockMembers();
    final results = <SearchResult>[];

    for (final member in members) {
      double score = 0.0;
      
      if (member['name'].toLowerCase().contains(query)) score += 1.0;
      if (member['church'].toLowerCase().contains(query)) score += 0.8;
      if (member['ministries'].any((m) => m.toLowerCase().contains(query))) score += 0.9;
      if (member['location'].toLowerCase().contains(query)) score += 0.7;
      if (member['bio'].toLowerCase().contains(query)) score += 0.5;

      if (score > 0) {
        // Aplicar filtros
        if (filter.location != null && 
            !member['location'].toLowerCase().contains(filter.location!.toLowerCase())) {
          continue;
        }

        if (filter.tags.isNotEmpty &&
            !filter.tags.any((tag) => member['ministries'].contains(tag))) {
          continue;
        }

        results.add(SearchResult(
          id: member['id'],
          title: member['name'],
          subtitle: member['church'],
          description: member['bio'],
          imageUrl: member['imageUrl'],
          type: SearchResultType.member,
          location: member['location'],
          tags: List<String>.from(member['ministries']),
          relevanceScore: score,
          metadata: {
            'maturity': member['maturity'],
            'baptized': member['baptized'],
            'joinDate': member['joinDate'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchEvents(String query, SearchFilter filter) {
    final events = _getMockEvents();
    final results = <SearchResult>[];

    for (final event in events) {
      double score = 0.0;
      
      if (event['title'].toLowerCase().contains(query)) score += 1.0;
      if (event['description'].toLowerCase().contains(query)) score += 0.8;
      if (event['location'].toLowerCase().contains(query)) score += 0.7;
      if (event['category'].toLowerCase().contains(query)) score += 0.9;

      if (score > 0) {
        final eventDate = DateTime.parse(event['date']);
        
        // Aplicar filtros de fecha
        if (filter.dateRange != null) {
          if (filter.dateRange!.start != null && eventDate.isBefore(filter.dateRange!.start!)) {
            continue;
          }
          if (filter.dateRange!.end != null && eventDate.isAfter(filter.dateRange!.end!)) {
            continue;
          }
        }

        // Aplicar filtros de ubicación
        if (filter.location != null && 
            !event['location'].toLowerCase().contains(filter.location!.toLowerCase())) {
          continue;
        }

        results.add(SearchResult(
          id: event['id'],
          title: event['title'],
          subtitle: event['category'],
          description: event['description'],
          imageUrl: event['imageUrl'],
          type: SearchResultType.event,
          date: eventDate,
          location: event['location'],
          tags: [event['category']],
          relevanceScore: score,
          metadata: {
            'price': event['price'],
            'capacity': event['capacity'],
            'registered': event['registered'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchMedia(String query, SearchFilter filter) {
    final media = _getMockMedia();
    final results = <SearchResult>[];

    for (final item in media) {
      double score = 0.0;
      
      if (item['title'].toLowerCase().contains(query)) score += 1.0;
      if (item['description'].toLowerCase().contains(query)) score += 0.8;
      if (item['category'].toLowerCase().contains(query)) score += 0.9;
      if (item['artist'].toLowerCase().contains(query)) score += 0.7;

      if (score > 0) {
        results.add(SearchResult(
          id: item['id'],
          title: item['title'],
          subtitle: item['artist'],
          description: item['description'],
          imageUrl: item['imageUrl'],
          type: SearchResultType.media,
          tags: [item['category'], item['type']],
          relevanceScore: score,
          metadata: {
            'duration': item['duration'],
            'plays': item['plays'],
            'rating': item['rating'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchChurches(String query, SearchFilter filter) {
    final churches = _getMockChurches();
    final results = <SearchResult>[];

    for (final church in churches) {
      double score = 0.0;
      
      if (church['name'].toLowerCase().contains(query)) score += 1.0;
      if (church['city'].toLowerCase().contains(query)) score += 0.8;
      if (church['description'].toLowerCase().contains(query)) score += 0.6;
      if (church['pastor'].toLowerCase().contains(query)) score += 0.7;

      if (score > 0) {
        // Aplicar filtros de ubicación
        if (filter.location != null && 
            !church['city'].toLowerCase().contains(filter.location!.toLowerCase())) {
          continue;
        }

        results.add(SearchResult(
          id: church['id'],
          title: church['name'],
          subtitle: church['city'],
          description: church['description'],
          imageUrl: church['imageUrl'],
          type: SearchResultType.church,
          location: church['city'],
          tags: church['languages'],
          relevanceScore: score,
          metadata: {
            'pastor': church['pastor'],
            'phone': church['phone'],
            'members': church['members'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchDevotionals(String query, SearchFilter filter) {
    final devotionals = _getMockDevotionals();
    final results = <SearchResult>[];

    for (final devotional in devotionals) {
      double score = 0.0;
      
      if (devotional['title'].toLowerCase().contains(query)) score += 1.0;
      if (devotional['content'].toLowerCase().contains(query)) score += 0.8;
      if (devotional['verse'].toLowerCase().contains(query)) score += 0.9;
      if (devotional['category'].toLowerCase().contains(query)) score += 0.7;

      if (score > 0) {
        results.add(SearchResult(
          id: devotional['id'],
          title: devotional['title'],
          subtitle: devotional['verse'],
          description: devotional['content'],
          imageUrl: devotional['imageUrl'],
          type: SearchResultType.devotional,
          date: DateTime.parse(devotional['date']),
          tags: [devotional['category']],
          relevanceScore: score,
          metadata: {
            'author': devotional['author'],
            'readTime': devotional['readTime'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchTestimonies(String query, SearchFilter filter) {
    // Datos de testimonios simulados
    final testimonies = [
      {
        'id': 'testimony_1',
        'title': 'Dios me sanó completamente',
        'author': 'Maria Andersson',
        'content': 'Después de años de enfermedad, Dios me sanó milagrosamente durante una oración en la iglesia...',
        'category': 'Sanidad',
        'imageUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300',
        'date': '2025-01-05',
      },
      {
        'id': 'testimony_2',
        'title': 'Mi familia encontró la paz',
        'author': 'Carlos Eriksson',
        'content': 'Después de años de conflictos familiares, Dios restauró nuestra familia cuando comenzamos a orar juntos...',
        'category': 'Familia',
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        'date': '2024-12-20',
      },
      {
        'id': 'testimony_3',
        'title': 'Liberado de las adicciones',
        'author': 'Johan Lindqvist',
        'content': 'Era esclavo de las drogas y el alcohol, pero Jesús me liberó completamente y ahora ayudo a otros...',
        'category': 'Liberación',
        'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
        'date': '2024-11-10',
      },
    ];

    final results = <SearchResult>[];

    for (final testimony in testimonies) {
      double score = 0.0;
      
      if (testimony['title']!.toLowerCase().contains(query)) score += 1.0;
      if (testimony['content']!.toLowerCase().contains(query)) score += 0.8;
      if (testimony['author']!.toLowerCase().contains(query)) score += 0.9;
      if (testimony['category']!.toLowerCase().contains(query)) score += 0.7;

      if (score > 0) {
        results.add(SearchResult(
          id: testimony['id']!,
          title: testimony['title']!,
          subtitle: 'Por ${testimony['author']}',
          description: testimony['content']!,
          imageUrl: testimony['imageUrl']!,
          type: SearchResultType.testimony,
          date: DateTime.parse(testimony['date']!),
          tags: [testimony['category']!],
          relevanceScore: score,
          metadata: {
            'author': testimony['author'],
            'category': testimony['category'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchNews(String query, SearchFilter filter) {
    // Datos de noticias simulados
    final news = [
      {
        'id': 'news_1',
        'title': 'Nueva iglesia VMF abre en Malmö',
        'content': 'Estamos emocionados de anunciar la apertura de nuestra nueva sede en Malmö, que servirá a la comunidad latina...',
        'category': 'Anuncios',
        'imageUrl': 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=300',
        'date': '2025-01-08',
        'author': 'Pastor Anders Eriksson',
      },
      {
        'id': 'news_2',
        'title': 'Conferencia de Juventud 2025',
        'content': 'Se acerca nuestra conferencia anual de juventud con invitados internacionales y actividades especiales...',
        'category': 'Eventos',
        'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=300',
        'date': '2025-01-03',
        'author': 'Pastor Erik Johansson',
      },
      {
        'id': 'news_3',
        'title': 'Campaña de oración por Suecia',
        'content': 'Únete a nuestra campaña de 30 días de oración por el avivamiento en Suecia y la transformación del país...',
        'category': 'Oración',
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        'date': '2024-12-28',
        'author': 'Pastora Margareta Lindström',
      },
    ];

    final results = <SearchResult>[];

    for (final article in news) {
      double score = 0.0;
      
      if (article['title']!.toLowerCase().contains(query)) score += 1.0;
      if (article['content']!.toLowerCase().contains(query)) score += 0.8;
      if (article['category']!.toLowerCase().contains(query)) score += 0.9;
      if (article['author']!.toLowerCase().contains(query)) score += 0.7;

      if (score > 0) {
        results.add(SearchResult(
          id: article['id']!,
          title: article['title']!,
          subtitle: article['category']!,
          description: article['content']!,
          imageUrl: article['imageUrl']!,
          type: SearchResultType.news,
          date: DateTime.parse(article['date']!),
          tags: [article['category']!],
          relevanceScore: score,
          metadata: {
            'author': article['author'],
            'category': article['category'],
          },
        ));
      }
    }

    return results;
  }

  List<SearchResult> _searchMinistries(String query, SearchFilter filter) {
    // Datos de ministerios simulados
    final ministries = [
      {
        'id': 'ministry_1',
        'name': 'Ministerio Juvenil',
        'description': 'Dedicado a formar la próxima generación de líderes cristianos a través de actividades, discipulado y eventos especiales',
        'leader': 'Pastor Erik Johansson',
        'members': 45,
        'activities': ['Cultos juveniles', 'Retiros', 'Evangelismo'],
        'imageUrl': 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=300',
      },
      {
        'id': 'ministry_2',
        'name': 'Ministerio de Música',
        'description': 'Adoración y alabanza que lleva a las personas a la presencia de Dios a través de la música cristiana contemporánea',
        'leader': 'Lisa Johansson',
        'members': 25,
        'activities': ['Ensayos', 'Grabaciones', 'Conciertos'],
        'imageUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      },
      {
        'id': 'ministry_3',
        'name': 'Ministerio de Intercesión',
        'description': 'Dedicado a la oración intercesora por la iglesia, la ciudad, el país y las misiones mundiales',
        'leader': 'Pastora Margareta Lindström',
        'members': 35,
        'activities': ['Vigilias de oración', 'Cadenas de oración', 'Retiros de oración'],
        'imageUrl': 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=300',
      },
    ];

    final results = <SearchResult>[];

    for (final ministry in ministries) {
      double score = 0.0;
      
      final name = ministry['name'] as String;
      final description = ministry['description'] as String;
      final leader = ministry['leader'] as String;
      final activities = ministry['activities'] as List<dynamic>;
      
      if (name.toLowerCase().contains(query)) score += 1.0;
      if (description.toLowerCase().contains(query)) score += 0.8;
      if (leader.toLowerCase().contains(query)) score += 0.9;
      if (activities.any((a) => a.toString().toLowerCase().contains(query))) score += 0.7;

      if (score > 0) {
        results.add(SearchResult(
          id: ministry['id'] as String,
          title: name,
          subtitle: 'Líder: $leader',
          description: description,
          imageUrl: ministry['imageUrl'] as String,
          type: SearchResultType.ministry,
          tags: activities.cast<String>(),
          relevanceScore: score,
          metadata: {
            'leader': leader,
            'members': ministry['members'],
            'activities': activities,
          },
        ));
      }
    }

    return results;
  }

  // Ordenar resultados
  List<SearchResult> _sortResults(List<SearchResult> results, SortOption sortBy, bool ascending) {
    final sorted = List<SearchResult>.from(results);

    switch (sortBy) {
      case SortOption.relevance:
        sorted.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case SortOption.date:
        sorted.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
        break;
      case SortOption.alphabetical:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.location:
        sorted.sort((a, b) {
          final locA = a.location ?? '';
          final locB = b.location ?? '';
          return locA.compareTo(locB);
        });
        break;
      case SortOption.popularity:
        sorted.sort((a, b) {
          final popA = a.metadata['plays'] ?? a.metadata['members'] ?? 0;
          final popB = b.metadata['plays'] ?? b.metadata['members'] ?? 0;
          return popB.compareTo(popA);
        });
        break;
    }

    if (ascending && sortBy != SortOption.relevance) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  // Aplicar filtro
  void applyFilter(SearchFilter filter) {
    _currentFilter = filter;
    if (_currentQuery.isNotEmpty) {
      search(_currentQuery, filter: filter);
    }
  }

  // Limpiar búsqueda
  void clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    _currentFilter = SearchFilter();
    notifyListeners();
  }

  // Cargar historial de búsqueda
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('search_history') ?? [];
      
      _searchHistory = historyJson
          .map((json) => SearchHistory.fromJson(jsonDecode(json)))
          .toList();
      
      // Ordenar por fecha más reciente
      _searchHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Mantener solo los últimos 50
      if (_searchHistory.length > 50) {
        _searchHistory = _searchHistory.take(50).toList();
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  // Guardar historial de búsqueda
  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _searchHistory
          .map((history) => jsonEncode(history.toJson()))
          .toList();
      await prefs.setStringList('search_history', historyJson);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  // Agregar al historial
  Future<void> _addToHistory(String query, SearchFilter filter, int resultCount) async {
    final history = SearchHistory(
      id: 'search_${DateTime.now().millisecondsSinceEpoch}',
      query: query,
      filter: filter,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    );

    // Remover búsquedas duplicadas
    _searchHistory.removeWhere((h) => h.query.toLowerCase() == query.toLowerCase());
    
    // Agregar al inicio
    _searchHistory.insert(0, history);
    
    // Mantener solo las últimas 50
    if (_searchHistory.length > 50) {
      _searchHistory = _searchHistory.take(50).toList();
    }

    await _saveSearchHistory();
  }

  // Cargar búsquedas populares
  Future<void> _loadPopularSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final popularJson = prefs.getStringList('popular_searches') ?? [];
      
      if (popularJson.isEmpty) {
        _popularSearches = _generateDefaultPopularSearches();
        await _savePopularSearches();
      } else {
        _popularSearches = popularJson
            .map((json) => PopularSearch.fromJson(jsonDecode(json)))
            .toList();
      }
      
      // Ordenar por frecuencia
      _popularSearches.sort((a, b) => b.frequency.compareTo(a.frequency));
      
    } catch (e) {
      _popularSearches = _generateDefaultPopularSearches();
    }
  }

  // Guardar búsquedas populares
  Future<void> _savePopularSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final popularJson = _popularSearches
          .map((search) => jsonEncode(search.toJson()))
          .toList();
      await prefs.setStringList('popular_searches', popularJson);
    } catch (e) {
      debugPrint('Error saving popular searches: $e');
    }
  }

  // Actualizar búsquedas populares
  Future<void> _updatePopularSearches(String query) async {
    final existingIndex = _popularSearches.indexWhere(
      (search) => search.query.toLowerCase() == query.toLowerCase()
    );

    if (existingIndex != -1) {
      // Incrementar frecuencia
      final existing = _popularSearches[existingIndex];
      _popularSearches[existingIndex] = PopularSearch(
        query: existing.query,
        frequency: existing.frequency + 1,
        primaryType: existing.primaryType,
      );
    } else {
      // Agregar nueva búsqueda
      _popularSearches.add(PopularSearch(
        query: query,
        frequency: 1,
        primaryType: _getMostRelevantType(),
      ));
    }

    // Ordenar y mantener solo las top 20
    _popularSearches.sort((a, b) => b.frequency.compareTo(a.frequency));
    if (_popularSearches.length > 20) {
      _popularSearches = _popularSearches.take(20).toList();
    }

    await _savePopularSearches();
  }

  SearchResultType _getMostRelevantType() {
    if (_searchResults.isEmpty) return SearchResultType.other;
    
    // Retornar el tipo más común en los resultados
    final typeCounts = <SearchResultType, int>{};
    for (final result in _searchResults) {
      typeCounts[result.type] = (typeCounts[result.type] ?? 0) + 1;
    }
    
    return typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  List<PopularSearch> _generateDefaultPopularSearches() {
    return [
      PopularSearch(query: 'pastor', frequency: 45, primaryType: SearchResultType.member),
      PopularSearch(query: 'juventud', frequency: 38, primaryType: SearchResultType.event),
      PopularSearch(query: 'música', frequency: 32, primaryType: SearchResultType.media),
      PopularSearch(query: 'oración', frequency: 29, primaryType: SearchResultType.prayer),
      PopularSearch(query: 'estocolmo', frequency: 25, primaryType: SearchResultType.church),
      PopularSearch(query: 'conferencia', frequency: 22, primaryType: SearchResultType.event),
      PopularSearch(query: 'testimonio', frequency: 18, primaryType: SearchResultType.testimony),
      PopularSearch(query: 'adoración', frequency: 15, primaryType: SearchResultType.media),
    ];
  }

  // Borrar historial
  Future<void> clearHistory() async {
    _searchHistory = [];
    await _saveSearchHistory();
    notifyListeners();
  }

  // Obtener sugerencias de búsqueda
  List<String> getSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    
    final suggestions = <String>[];
    final queryLower = query.toLowerCase();
    
    // Sugerencias predefinidas
    final predefined = [
      'pastor', 'juventud', 'música', 'oración', 'conferencia',
      'testimonio', 'adoración', 'estudio bíblico', 'misiones',
      'matrimonio', 'familia', 'sanidad', 'liberación'
    ];
    
    for (final term in predefined) {
      if (term.contains(queryLower) && !suggestions.contains(term)) {
        suggestions.add(term);
      }
    }
    
    return suggestions.take(8).toList();
  }

  void _generateMockData() {
    // Datos simulados generados dinámicamente
  }

  // Funciones auxiliares para obtener datos simulados
  List<Map<String, dynamic>> _getMockMembers() {
    return [
      {
        'id': 'member_1',
        'name': 'Anders Eriksson',
        'church': 'VMF Sweden - Estocolmo',
        'location': 'Estocolmo, Suecia',
        'bio': 'Pastor principal con 25 años de experiencia en el ministerio',
        'ministries': ['Pastoral', 'Predicación', 'Consejería'],
        'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200',
        'maturity': 'Anciano',
        'baptized': true,
        'joinDate': '2005-01-10',
      },
      {
        'id': 'member_2',
        'name': 'Margareta Lindström',
        'church': 'VMF Sweden - Estocolmo',
        'location': 'Estocolmo, Suecia',
        'bio': 'Pastora asociada y líder del ministerio de mujeres',
        'ministries': ['Pastoral', 'Ministerio Femenino', 'Oración'],
        'imageUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=200',
        'maturity': 'Líder',
        'baptized': true,
        'joinDate': '2008-09-15',
      },
      {
        'id': 'member_3',
        'name': 'Erik Johansson',
        'church': 'VMF Sweden - Estocolmo',
        'location': 'Estocolmo, Suecia',
        'bio': 'Líder de jóvenes con corazón para la nueva generación',
        'ministries': ['Ministerio Juvenil', 'Música', 'Adoración'],
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        'maturity': 'En Crecimiento',
        'baptized': true,
        'joinDate': '2016-06-10',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockEvents() {
    return [
      {
        'id': 'event_1',
        'title': 'Conferencia de Juventud 2025',
        'description': 'Una conferencia especial para jóvenes con invitados internacionales',
        'category': 'Juventud',
        'location': 'Centro de Conferencias, Estocolmo',
        'date': '2025-03-15T10:00:00.000Z',
        'price': 150.0,
        'capacity': 500,
        'registered': 234,
        'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=300',
      },
      {
        'id': 'event_2',
        'title': 'Retiro de Matrimonios',
        'description': 'Un fin de semana especial para fortalecer los matrimonios',
        'category': 'Matrimonio',
        'location': 'Casa de Retiros, Gotemburgo',
        'date': '2025-04-20T09:00:00.000Z',
        'price': 800.0,
        'capacity': 50,
        'registered': 38,
        'imageUrl': 'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?w=300',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockMedia() {
    return [
      {
        'id': 'media_1',
        'title': 'Rompiste las Cadenas',
        'artist': 'Miel San Marcos',
        'description': 'Una poderosa canción de liberación y victoria',
        'category': 'Adoración',
        'type': 'Audio',
        'duration': '4:32',
        'plays': 1250,
        'rating': 4.8,
        'imageUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
      },
      {
        'id': 'media_2',
        'title': 'Predicación: La Fe que Mueve Montañas',
        'artist': 'Pastor Anders Eriksson',
        'description': 'Una enseñanza poderosa sobre la fe y los milagros',
        'category': 'Enseñanza',
        'type': 'Video',
        'duration': '45:20',
        'plays': 890,
        'rating': 4.9,
        'imageUrl': 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=300',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockChurches() {
    return [
      {
        'id': 'church_1',
        'name': 'VMF Sweden - Estocolmo',
        'city': 'Estocolmo',
        'description': 'Iglesia principal VMF',
        'pastor': 'Pastor Anders',
        'members': 450,
        'imageUrl': 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=300',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockDevotionals() {
    return [
      {
        'id': 'devotional_1',
        'title': 'La Provisión de Dios',
        'content': 'Devocional VMF',
        'category': 'Fe',
        'author': 'Pastor VMF',
        'imageUrl': 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=300',
      },
    ];
  }
}