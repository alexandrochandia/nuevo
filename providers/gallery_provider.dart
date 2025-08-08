import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gallery_item.dart';

class GalleryProvider with ChangeNotifier {
  List<GalleryItem> _galleryItems = [];
  List<String> _favoriteIds = [];
  String _selectedCategory = 'Todas';
  bool _isLoading = false;

  List<GalleryItem> get galleryItems => _galleryItems;
  List<String> get favoriteIds => _favoriteIds;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  final List<String> categories = [
    'Todas',
    'Eventos VMF',
    'Cultos',
    'Testimonios',
    'Jóvenes',
    'Casas Iglesias',
    'Alabanza',
    'Ofrendas',
    'Conferencias',
  ];

  // Datos de ejemplo premium para VMF Sweden
  final List<Map<String, dynamic>> _mockGalleryData = [
    {
      'id': '1',
      'imageUrl': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=500',
      'title': 'Conferencia VMF 2024',
      'category': 'Eventos VMF',
      'date': '2024-12-15T00:00:00.000Z',
      'likes': 150,
      'isNew': true,
      'description': 'Conferencia anual VMF Sweden con invitados internacionales',
      'author': 'Pastor VMF',
      'tags': ['conferencia', 'internacional', 'enseñanza'],
    },
    {
      'id': '2',
      'imageUrl': 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500',
      'title': 'Culto de Adoración',
      'category': 'Cultos',
      'date': '2024-12-10T00:00:00.000Z',
      'likes': 89,
      'isNew': true,
      'description': 'Momento especial de adoración en el culto dominical',
      'author': 'Equipo de Alabanza',
      'tags': ['alabanza', 'adoración', 'domingo'],
    },
    {
      'id': '3',
      'imageUrl': 'https://images.unsplash.com/photo-1529390079861-591de354faf5?w=500',
      'title': 'Testimonio de Sanidad',
      'category': 'Testimonios',
      'date': '2024-12-08T00:00:00.000Z',
      'likes': 245,
      'isNew': false,
      'description': 'Hermana María comparte su testimonio de sanidad divina',
      'author': 'Hermana María',
      'tags': ['testimonio', 'sanidad', 'milagro'],
    },
    {
      'id': '4',
      'imageUrl': 'https://images.unsplash.com/photo-1511988617509-a57c8a288659?w=500',
      'title': 'Reunión de Jóvenes',
      'category': 'Jóvenes',
      'date': '2024-12-05T00:00:00.000Z',
      'likes': 76,
      'isNew': false,
      'description': 'Noche de jóvenes con actividades y enseñanza bíblica',
      'author': 'Ministerio Juvenil',
      'tags': ['jóvenes', 'actividades', 'enseñanza'],
    },
    {
      'id': '5',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      'title': 'Casa Iglesia Stockholm',
      'category': 'Casas Iglesias',
      'date': '2024-12-03T00:00:00.000Z',
      'likes': 67,
      'isNew': false,
      'description': 'Reunión semanal en casa iglesia de Stockholm',
      'author': 'Casa Iglesia Stockholm',
      'tags': ['casa-iglesia', 'stockholm', 'comunión'],
    },
    {
      'id': '6',
      'imageUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500',
      'title': 'Coro de Alabanza',
      'category': 'Alabanza',
      'date': '2024-12-01T00:00:00.000Z',
      'likes': 134,
      'isNew': false,
      'description': 'Presentación especial del coro de alabanza',
      'author': 'Coro VMF',
      'tags': ['coro', 'música', 'presentación'],
    },
    {
      'id': '7',
      'imageUrl': 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=500',
      'title': 'Campaña de Ofrendas',
      'category': 'Ofrendas',
      'date': '2024-11-28T00:00:00.000Z',
      'likes': 89,
      'isNew': false,
      'description': 'Campaña especial para construcción del nuevo templo',
      'author': 'Administración VMF',
      'tags': ['ofrendas', 'construcción', 'templo'],
    },
    {
      'id': '8',
      'imageUrl': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500',
      'title': 'Conferencia Profética',
      'category': 'Conferencias',
      'date': '2024-11-25T00:00:00.000Z',
      'likes': 198,
      'isNew': false,
      'description': 'Conferencia profética con ministerio internacional',
      'author': 'Pastor Invitado',
      'tags': ['profético', 'conferencia', 'internacional'],
    },
    {
      'id': '9',
      'imageUrl': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500',
      'title': 'Bautismos en Agua',
      'category': 'Eventos VMF',
      'date': '2024-11-20T00:00:00.000Z',
      'likes': 167,
      'isNew': false,
      'description': 'Ceremonia de bautismos en agua - nuevos miembros',
      'author': 'Pastor VMF',
      'tags': ['bautismo', 'agua', 'nuevos-miembros'],
    },
    {
      'id': '10',
      'imageUrl': 'https://images.unsplash.com/photo-1544531586-fde5298cdd40?w=500',
      'title': 'Noche de Milagros',
      'category': 'Cultos',
      'date': '2024-11-18T00:00:00.000Z',
      'likes': 278,
      'isNew': false,
      'description': 'Culto especial con manifestaciones sobrenaturales',
      'author': 'Pastor VMF',
      'tags': ['milagros', 'sobrenatural', 'especial'],
    },
  ];

  GalleryProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _isLoading = true;
    notifyListeners();

    // Simular carga desde Supabase
    Future.delayed(const Duration(seconds: 1), () {
      _galleryItems = _mockGalleryData
          .map((item) => GalleryItem.fromJson(item))
          .toList();
      _isLoading = false;
      notifyListeners();
      
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('gallery_favorites');
      if (favoritesJson != null) {
        _favoriteIds = List<String>.from(json.decode(favoritesJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gallery_favorites', json.encode(_favoriteIds));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  void toggleFavorite(String itemId) {
    if (_favoriteIds.contains(itemId)) {
      _favoriteIds.remove(itemId);
    } else {
      _favoriteIds.add(itemId);
    }
    notifyListeners();
    _saveFavorites();
  }

  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<GalleryItem> getFilteredItems() {
    if (_selectedCategory == 'Todas') {
      return _galleryItems;
    }
    return _galleryItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  List<GalleryItem> getFavoriteItems() {
    return _galleryItems
        .where((item) => _favoriteIds.contains(item.id))
        .toList();
  }

  List<GalleryItem> getRecentItems({int limit = 6}) {
    final sortedItems = List<GalleryItem>.from(_galleryItems);
    sortedItems.sort((a, b) => b.date.compareTo(a.date));
    return sortedItems.take(limit).toList();
  }

  int getTotalLikes() {
    return _galleryItems.fold(0, (sum, item) => sum + item.likes);
  }

  int getNewItemsCount() {
    return _galleryItems.where((item) => item.isNew).length;
  }

  Future<void> refreshGallery() async {
    _isLoading = true;
    notifyListeners();

    // Simular actualización desde servidor
    await Future.delayed(const Duration(seconds: 2));
    
    _isLoading = false;
    notifyListeners();
  }

  void likeItem(String itemId) {
    final index = _galleryItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _galleryItems[index] = _galleryItems[index].copyWith(
        likes: _galleryItems[index].likes + 1,
      );
      notifyListeners();
    }
  }

  List<GalleryItem> searchItems(String query) {
    if (query.isEmpty) return getFilteredItems();
    
    final lowercaseQuery = query.toLowerCase();
    return _galleryItems.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
             item.description?.toLowerCase().contains(lowercaseQuery) == true ||
             item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}