import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../config/supabase_config.dart';

class MediaProvider extends ChangeNotifier {
  List<MediaModel> _allMedia = [];
  List<MediaModel> _filteredMedia = [];
  MediaModel? _currentPlaying;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _error;
  MediaCategory? _selectedCategory;
  MediaType? _selectedType;
  String _searchQuery = '';
  bool _showFeaturedOnly = false;

  // Getters
  List<MediaModel> get media => _filteredMedia;
  List<MediaModel> get featuredMedia => _allMedia.where((m) => m.isFeatured).toList();
  List<MediaModel> get liveMedia => _allMedia.where((m) => m.isLive).toList();
  MediaModel? get currentPlaying => _currentPlaying;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String? get error => _error;
  MediaCategory? get selectedCategory => _selectedCategory;
  MediaType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  bool get showFeaturedOnly => _showFeaturedOnly;

  // Mock data for VMF Sweden Media
  List<MediaModel> get _mockMedia => [
    MediaModel(
      id: '1',
      title: 'Como Zaqueo',
      description: 'Una poderosa alabanza que nos recuerda el amor transformador de Jesús. Como Zaqueo subió al árbol, nosotros también podemos acercarnos a Cristo desde donde estemos.',
      shortDescription: 'Alabanza sobre el encuentro transformador con Jesús',
      thumbnailUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/watch?v=abc123',
      type: MediaType.audio,
      category: MediaCategory.alabanza,
      artist: 'Miel San Marcos',
      duration: '4:23',
      uploadDate: DateTime.now().subtract(const Duration(days: 7)),
      isFeatured: true,
      tags: ['adoración', 'transformación', 'encuentro'],
      youtubeId: 'abc123',
      views: 125000,
      likes: 8500,
      rating: 4.9,
    ),
    MediaModel(
      id: '2',
      title: 'Reckless Love',
      description: 'Un himno moderno sobre el amor desenfrenado de Dios. Esta canción ha tocado millones de corazones en todo el mundo, recordándonos que no hay altura ni profundidad que el amor de Dios no pueda alcanzar.',
      shortDescription: 'Himno sobre el amor incondicional de Dios',
      thumbnailUrl: 'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/watch?v=def456',
      type: MediaType.video,
      category: MediaCategory.alabanza,
      artist: 'Cory Asbury',
      duration: '5:42',
      uploadDate: DateTime.now().subtract(const Duration(days: 14)),
      isFeatured: true,
      tags: ['amor', 'gracia', 'adoración'],
      youtubeId: 'def456',
      views: 98000,
      likes: 7200,
      rating: 4.8,
    ),
    MediaModel(
      id: '3',
      title: 'Sermón: El Poder de la Fe',
      description: 'Pastor VMF Sweden nos enseña sobre cómo la fe puede mover montañas. Un mensaje inspirador basado en Mateo 17:20 que fortalecerá tu caminar espiritual.',
      shortDescription: 'Enseñanza sobre el poder transformador de la fe',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/watch?v=ghi789',
      type: MediaType.video,
      category: MediaCategory.sermones,
      artist: 'Pastor VMF Sweden',
      duration: '45:30',
      uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      isFeatured: true,
      tags: ['fe', 'enseñanza', 'crecimiento'],
      youtubeId: 'ghi789',
      views: 45000,
      likes: 3200,
      rating: 4.9,
    ),
    MediaModel(
      id: '4',
      title: 'Way Maker',
      description: 'Una declaración profética sobre el carácter de Dios. Esta canción proclama que Dios es hacedor de caminos, obrando milagros y cumpliendo promesas.',
      shortDescription: 'Declaración sobre el carácter milagroso de Dios',
      thumbnailUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/watch?v=jkl012',
      type: MediaType.audio,
      category: MediaCategory.alabanza,
      artist: 'Sinach',
      duration: '3:56',
      uploadDate: DateTime.now().subtract(const Duration(days: 21)),
      tags: ['milagros', 'promesas', 'adoración'],
      youtubeId: 'jkl012',
      views: 156000,
      likes: 12500,
      rating: 5.0,
    ),
    MediaModel(
      id: '5',
      title: 'Podcast VMF: Viviendo en Victoria',
      description: 'Serie de enseñanzas sobre cómo vivir una vida victoriosa en Cristo. Episodio 15: "Superando los obstáculos con fe".',
      shortDescription: 'Enseñanzas sobre vida victoriosa en Cristo',
      thumbnailUrl: 'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=800&h=600&fit=crop',
      mediaUrl: 'https://anchor.fm/vmfsweden/episodes/ep15',
      type: MediaType.audio,
      category: MediaCategory.podcasts,
      artist: 'Equipo VMF Sweden',
      duration: '28:45',
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['victoria', 'fe', 'enseñanza'],
      views: 8900,
      likes: 650,
      rating: 4.7,
    ),
    MediaModel(
      id: '6',
      title: 'Goodness of God',
      description: 'Un cántico de gratitud que celebra la bondad constante de Dios a través de todas las estaciones de la vida.',
      shortDescription: 'Celebración de la bondad constante de Dios',
      thumbnailUrl: 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/watch?v=mno345',
      type: MediaType.video,
      category: MediaCategory.alabanza,
      artist: 'Bethel Music',
      duration: '4:18',
      uploadDate: DateTime.now().subtract(const Duration(days: 12)),
      tags: ['gratitud', 'bondad', 'adoración'],
      youtubeId: 'mno345',
      views: 89000,
      likes: 6800,
      rating: 4.8,
    ),
    MediaModel(
      id: '7',
      title: 'Culto Dominical en Vivo',
      description: 'Únete a nosotros cada domingo para un tiempo de adoración, comunión y enseñanza de la Palabra.',
      shortDescription: 'Servicio dominical en vivo desde VMF Sweden',
      thumbnailUrl: 'https://images.unsplash.com/photo-1519638831568-d9897f573d11?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/live/pqr678',
      type: MediaType.live,
      category: MediaCategory.transmisiones,
      artist: 'VMF Sweden',
      duration: 'En vivo',
      uploadDate: DateTime.now(),
      isLive: true,
      isFeatured: true,
      tags: ['culto', 'en-vivo', 'comunidad'],
      youtubeId: 'pqr678',
      views: 2500,
      likes: 450,
      rating: 4.9,
    ),
    MediaModel(
      id: '8',
      title: 'Grande es Tu Fidelidad',
      description: 'Un himno clásico que ha consolado generaciones con la verdad de la fidelidad inquebrantable de Dios.',
      shortDescription: 'Himno clásico sobre la fidelidad de Dios',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&h=600&fit=crop',
      mediaUrl: 'https://www.youtube.com/watch?v=stu901',
      type: MediaType.audio,
      category: MediaCategory.alabanza,
      artist: 'Marco Barrientos',
      duration: '6:12',
      uploadDate: DateTime.now().subtract(const Duration(days: 30)),
      tags: ['fidelidad', 'himno', 'esperanza'],
      youtubeId: 'stu901',
      views: 67000,
      likes: 4900,
      rating: 4.9,
    ),
  ];

  MediaProvider() {
    loadMedia();
  }

  Future<void> loadMedia() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from Supabase first
      if (SupabaseConfig.client != null) {
        await _loadFromSupabase();
      } else {
        // Fallback to mock data
        _allMedia = _mockMedia;
      }
      
      _applyFilters();
    } catch (e) {
      _error = 'Error cargando contenido multimedia: ${e.toString()}';
      _allMedia = _mockMedia; // Fallback to mock data
      _applyFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromSupabase() async {
    // Implementation for loading from Supabase when configured
    // For now, use mock data
    _allMedia = _mockMedia;
  }

  void setCategory(MediaCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setType(MediaType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleFeaturedOnly() {
    _showFeaturedOnly = !_showFeaturedOnly;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMedia = _allMedia.where((media) {
      // Category filter
      if (_selectedCategory != null && media.category != _selectedCategory) {
        return false;
      }

      // Type filter
      if (_selectedType != null && media.type != _selectedType) {
        return false;
      }

      // Featured filter
      if (_showFeaturedOnly && !media.isFeatured) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return media.title.toLowerCase().contains(query) ||
               media.artist.toLowerCase().contains(query) ||
               media.description.toLowerCase().contains(query) ||
               media.tags.any((tag) => tag.toLowerCase().contains(query));
      }

      return true;
    }).toList();

    // Sort by featured first, then by upload date
    _filteredMedia.sort((a, b) {
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      return b.uploadDate.compareTo(a.uploadDate);
    });
  }

  void playMedia(MediaModel media) {
    _currentPlaying = media;
    _isPlaying = true;
    notifyListeners();
  }

  void pauseMedia() {
    _isPlaying = false;
    notifyListeners();
  }

  void resumeMedia() {
    _isPlaying = true;
    notifyListeners();
  }

  void stopMedia() {
    _currentPlaying = null;
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  List<MediaModel> getMediaByCategory(MediaCategory category) {
    return _allMedia.where((media) => media.category == category).toList();
  }

  List<MediaModel> getMediaByType(MediaType type) {
    return _allMedia.where((media) => media.type == type).toList();
  }

  Future<void> likeMedia(String mediaId) async {
    final mediaIndex = _allMedia.indexWhere((m) => m.id == mediaId);
    if (mediaIndex != -1) {
      _allMedia[mediaIndex] = _allMedia[mediaIndex].copyWith(
        likes: _allMedia[mediaIndex].likes + 1,
      );
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> incrementViews(String mediaId) async {
    final mediaIndex = _allMedia.indexWhere((m) => m.id == mediaId);
    if (mediaIndex != -1) {
      _allMedia[mediaIndex] = _allMedia[mediaIndex].copyWith(
        views: _allMedia[mediaIndex].views + 1,
      );
      _applyFilters();
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedType = null;
    _searchQuery = '';
    _showFeaturedOnly = false;
    _applyFilters();
    notifyListeners();
  }
}