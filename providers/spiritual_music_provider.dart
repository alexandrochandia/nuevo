import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/spiritual_music_model.dart';

class SpiritualMusicProvider with ChangeNotifier {
  List<SpiritualMusic> _musicLibrary = [];
  List<SpiritualMusic> _favorites = [];
  List<SpiritualMusic> _testimonyPlaylist = [];
  List<SpiritualMusic> _preachingPlaylist = [];
  SpiritualMusic? _currentlyPlaying;
  String _searchQuery = '';
  MusicCategory? _selectedCategory;
  MusicPurpose? _selectedPurpose;
  MusicMood? _selectedMood;
  bool _showOnlyFavorites = false;
  bool _showOnlyInstrumental = false;
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<SpiritualMusic> get musicLibrary => _filteredMusic;
  List<SpiritualMusic> get allMusic => _musicLibrary;
  List<SpiritualMusic> get favorites => _favorites;
  List<SpiritualMusic> get testimonyPlaylist => _testimonyPlaylist;
  List<SpiritualMusic> get preachingPlaylist => _preachingPlaylist;
  SpiritualMusic? get currentlyPlaying => _currentlyPlaying;
  String get searchQuery => _searchQuery;
  MusicCategory? get selectedCategory => _selectedCategory;
  MusicPurpose? get selectedPurpose => _selectedPurpose;
  MusicMood? get selectedMood => _selectedMood;
  bool get showOnlyFavorites => _showOnlyFavorites;
  bool get showOnlyInstrumental => _showOnlyInstrumental;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<SpiritualMusic> get _filteredMusic {
    var filtered = List<SpiritualMusic>.from(_musicLibrary);

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((music) =>
        music.title.toLowerCase().contains(query) ||
        music.artist.toLowerCase().contains(query) ||
        music.album.toLowerCase().contains(query) ||
        music.tags.any((tag) => tag.toLowerCase().contains(query)) ||
        (music.lyrics?.toLowerCase().contains(query) ?? false) ||
        (music.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filtrar por categoría
    if (_selectedCategory != null) {
      filtered = filtered.where((music) => music.category == _selectedCategory).toList();
    }

    // Filtrar por propósito
    if (_selectedPurpose != null) {
      filtered = filtered.where((music) => music.purpose == _selectedPurpose).toList();
    }

    // Filtrar por estado de ánimo
    if (_selectedMood != null) {
      filtered = filtered.where((music) => music.mood == _selectedMood).toList();
    }

    // Filtrar por favoritos
    if (_showOnlyFavorites) {
      filtered = filtered.where((music) => music.isFavorite).toList();
    }

    // Filtrar por instrumental
    if (_showOnlyInstrumental) {
      filtered = filtered.where((music) => music.isInstrumental).toList();
    }

    // Ordenar por popularidad y después por nombre
    filtered.sort((a, b) {
      if (a.playCount != b.playCount) {
        return b.playCount.compareTo(a.playCount);
      }
      return a.title.compareTo(b.title);
    });

    return filtered;
  }

  SpiritualMusicProvider() {
    _loadData();
    _generateMockData();
  }

  // Cargar datos
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar música
      final musicJson = prefs.getStringList('spiritual_music') ?? [];
      _musicLibrary = musicJson
          .map((json) => SpiritualMusic.fromJson(jsonDecode(json)))
          .toList();

      // Cargar favoritos
      final favoritesJson = prefs.getStringList('spiritual_favorites') ?? [];
      _favorites = favoritesJson
          .map((json) => SpiritualMusic.fromJson(jsonDecode(json)))
          .toList();

      // Cargar playlist de testimonio
      final testimonyJson = prefs.getStringList('testimony_playlist') ?? [];
      _testimonyPlaylist = testimonyJson
          .map((json) => SpiritualMusic.fromJson(jsonDecode(json)))
          .toList();

      // Cargar playlist de predicación
      final preachingJson = prefs.getStringList('preaching_playlist') ?? [];
      _preachingPlaylist = preachingJson
          .map((json) => SpiritualMusic.fromJson(jsonDecode(json)))
          .toList();

      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar música: $e';
      debugPrint(_error);
    }
  }

  // Guardar datos
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar música
      final musicJson = _musicLibrary
          .map((music) => jsonEncode(music.toJson()))
          .toList();
      await prefs.setStringList('spiritual_music', musicJson);

      // Guardar favoritos
      final favoritesJson = _favorites
          .map((music) => jsonEncode(music.toJson()))
          .toList();
      await prefs.setStringList('spiritual_favorites', favoritesJson);

      // Guardar playlist de testimonio
      final testimonyJson = _testimonyPlaylist
          .map((music) => jsonEncode(music.toJson()))
          .toList();
      await prefs.setStringList('testimony_playlist', testimonyJson);

      // Guardar playlist de predicación
      final preachingJson = _preachingPlaylist
          .map((music) => jsonEncode(music.toJson()))
          .toList();
      await prefs.setStringList('preaching_playlist', preachingJson);
    } catch (e) {
      debugPrint('Error saving music data: $e');
    }
  }

  // Reproducir música
  Future<void> playMusic(SpiritualMusic music) async {
    _currentlyPlaying = music;
    
    // Incrementar contador de reproducción
    final index = _musicLibrary.indexWhere((m) => m.id == music.id);
    if (index != -1) {
      _musicLibrary[index] = music.copyWith(playCount: music.playCount + 1);
    }
    
    await _saveData();
    notifyListeners();
  }

  // Pausar música
  void pauseMusic() {
    // Simulación de pausa
    notifyListeners();
  }

  // Parar música
  void stopMusic() {
    _currentlyPlaying = null;
    notifyListeners();
  }

  // Agregar/quitar favorito
  Future<void> toggleFavorite(SpiritualMusic music) async {
    final index = _musicLibrary.indexWhere((m) => m.id == music.id);
    if (index != -1) {
      final updatedMusic = music.copyWith(isFavorite: !music.isFavorite);
      _musicLibrary[index] = updatedMusic;
      
      if (updatedMusic.isFavorite) {
        _favorites.add(updatedMusic);
      } else {
        _favorites.removeWhere((m) => m.id == music.id);
      }
      
      await _saveData();
      notifyListeners();
    }
  }

  // Agregar a playlist de testimonio
  Future<void> addToTestimonyPlaylist(SpiritualMusic music) async {
    if (!_testimonyPlaylist.any((m) => m.id == music.id)) {
      _testimonyPlaylist.add(music);
      await _saveData();
      notifyListeners();
    }
  }

  // Agregar a playlist de predicación
  Future<void> addToPreachingPlaylist(SpiritualMusic music) async {
    if (!_preachingPlaylist.any((m) => m.id == music.id)) {
      _preachingPlaylist.add(music);
      await _saveData();
      notifyListeners();
    }
  }

  // Quitar de playlist de testimonio
  Future<void> removeFromTestimonyPlaylist(String musicId) async {
    _testimonyPlaylist.removeWhere((m) => m.id == musicId);
    await _saveData();
    notifyListeners();
  }

  // Quitar de playlist de predicación
  Future<void> removeFromPreachingPlaylist(String musicId) async {
    _preachingPlaylist.removeWhere((m) => m.id == musicId);
    await _saveData();
    notifyListeners();
  }

  // Aplicar filtros
  void applyFilters({
    String? searchQuery,
    MusicCategory? category,
    MusicPurpose? purpose,
    MusicMood? mood,
    bool? showOnlyFavorites,
    bool? showOnlyInstrumental,
  }) {
    _searchQuery = searchQuery ?? _searchQuery;
    _selectedCategory = category;
    _selectedPurpose = purpose;
    _selectedMood = mood;
    _showOnlyFavorites = showOnlyFavorites ?? _showOnlyFavorites;
    _showOnlyInstrumental = showOnlyInstrumental ?? _showOnlyInstrumental;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedPurpose = null;
    _selectedMood = null;
    _showOnlyFavorites = false;
    _showOnlyInstrumental = false;
    notifyListeners();
  }

  // Obtener música por categoría
  List<SpiritualMusic> getMusicByCategory(MusicCategory category) {
    return _musicLibrary.where((music) => music.category == category).toList();
  }

  // Obtener música por propósito
  List<SpiritualMusic> getMusicByPurpose(MusicPurpose purpose) {
    return _musicLibrary.where((music) => music.purpose == purpose).toList();
  }

  // Obtener música más popular
  List<SpiritualMusic> getMostPopular({int limit = 10}) {
    final popular = List<SpiritualMusic>.from(_musicLibrary);
    popular.sort((a, b) => b.playCount.compareTo(a.playCount));
    return popular.take(limit).toList();
  }

  // Obtener música reciente
  List<SpiritualMusic> getRecentlyAdded({int limit = 10}) {
    final recent = List<SpiritualMusic>.from(_musicLibrary);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recent.take(limit).toList();
  }

  // Obtener estadísticas
  Map<String, dynamic> getStatistics() {
    return {
      'total': _musicLibrary.length,
      'favorites': _favorites.length,
      'testimonyPlaylist': _testimonyPlaylist.length,
      'preachingPlaylist': _preachingPlaylist.length,
      'instrumental': _musicLibrary.where((m) => m.isInstrumental).length,
      'totalPlays': _musicLibrary.fold(0, (sum, m) => sum + m.playCount),
      'categories': MusicCategory.values.length,
      'purposes': MusicPurpose.values.length,
    };
  }

  // Refrescar datos
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    await _loadData();
    
    _isLoading = false;
    notifyListeners();
  }

  void _generateMockData() {
    if (_musicLibrary.isNotEmpty) return;

    final mockMusic = [
      SpiritualMusic(
        id: 'music_1',
        title: 'Aquí Estoy',
        artist: 'Jesús Adrián Romero',
        album: 'El Aire de Tu Casa',
        audioUrl: 'https://example.com/aqui-estoy.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        duration: const Duration(minutes: 4, seconds: 32),
        category: MusicCategory.worship,
        purpose: MusicPurpose.worship,
        tags: ['adoración', 'intimidad', 'encuentro'],
        lyrics: 'Aquí estoy, a tus pies Señor\nVengo a ti con mi corazón\nQuiero estar en tu presencia\nY sentir tu dulce amor...',
        description: 'Canción de adoración íntima perfecta para momentos de encuentro personal con Dios.',
        isForWorship: true,
        isForTestimony: true,
        isFavorite: true,
        playCount: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        bibleVerse: 'Salmos 139:23-24',
        spiritualMessage: 'Una invitación a la intimidad con Dios en adoración.',
        mood: MusicMood.peaceful,
        instruments: ['Piano', 'Guitarra acústica', 'Violín'],
        copyright: '© Vastago Producciones',
        isOriginal: false,
        composer: 'Jesús Adrián Romero',
      ),

      SpiritualMusic(
        id: 'music_2',
        title: 'Grande y Fuerte',
        artist: 'Miel San Marcos',
        album: 'Como en el Cielo',
        audioUrl: 'https://example.com/grande-fuerte.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        duration: const Duration(minutes: 5, seconds: 18),
        category: MusicCategory.praise,
        purpose: MusicPurpose.celebration,
        tags: ['alabanza', 'poder', 'victoria'],
        lyrics: 'Grande y fuerte, poderoso eres Tú\nRey eterno, siempre fiel\nNada puede compararse a Ti...',
        description: 'Canción de alabanza poderosa que exalta la grandeza y fuerza de Dios.',
        isForWorship: true,
        isForPreaching: true,
        isFavorite: false,
        playCount: 203,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        bibleVerse: 'Salmos 24:8',
        spiritualMessage: 'Celebrando la grandeza y poder invencible de nuestro Dios.',
        mood: MusicMood.powerful,
        instruments: ['Batería', 'Guitarra eléctrica', 'Bajo', 'Teclados'],
        copyright: '© Miel San Marcos Music',
        isOriginal: false,
        composer: 'Josh Morales',
      ),

      SpiritualMusic(
        id: 'music_3',
        title: 'Testimonio de Fe',
        artist: 'Marcela Gándara',
        album: 'El Mismo Cielo',
        audioUrl: 'https://example.com/testimonio-fe.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400',
        duration: const Duration(minutes: 3, seconds: 45),
        category: MusicCategory.testimony,
        purpose: MusicPurpose.testimony,
        tags: ['testimonio', 'fe', 'esperanza'],
        lyrics: 'Mi testimonio es de fe\nDe esperanza y de amor\nDios transformó mi vida\nY me llenó de su favor...',
        description: 'Canción testimonial perfecta para compartir experiencias de fe y transformación.',
        isForTestimony: true,
        isFavorite: true,
        playCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        bibleVerse: 'Apocalipsis 12:11',
        spiritualMessage: 'El poder del testimonio personal en la vida del creyente.',
        mood: MusicMood.hopeful,
        instruments: ['Piano', 'Guitarra acústica', 'Violonchelo'],
        copyright: '© CanZion Producciones',
        isOriginal: false,
        composer: 'Marcela Gándara',
      ),

      SpiritualMusic(
        id: 'music_4',
        title: 'Instrumental de Reflexión',
        artist: 'VMF Worship Team',
        album: 'Momentos de Paz',
        audioUrl: 'https://example.com/instrumental-reflexion.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        duration: const Duration(minutes: 6, seconds: 12),
        category: MusicCategory.instrumental,
        purpose: MusicPurpose.meditation,
        tags: ['instrumental', 'reflexión', 'paz'],
        description: 'Pieza instrumental diseñada para momentos de reflexión y meditación espiritual.',
        isInstrumental: true,
        isForPreaching: true,
        isForTestimony: true,
        isFavorite: false,
        playCount: 67,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        spiritualMessage: 'Música que facilita la conexión espiritual y la reflexión profunda.',
        mood: MusicMood.contemplative,
        instruments: ['Piano', 'Violín', 'Flauta', 'Guitarra acústica'],
        copyright: '© VMF Sweden',
        isOriginal: true,
        composer: 'Lars Andersson',
        arranger: 'VMF Worship Team',
      ),

      SpiritualMusic(
        id: 'music_5',
        title: 'Palabra de Vida',
        artist: 'Alex Campos',
        album: 'Lenguaje de Amor',
        audioUrl: 'https://example.com/palabra-vida.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400',
        duration: const Duration(minutes: 4, seconds: 15),
        category: MusicCategory.preaching,
        purpose: MusicPurpose.teaching,
        tags: ['palabra', 'enseñanza', 'vida'],
        lyrics: 'Tu palabra es vida\nEs luz en mi caminar\nGuía mis pasos\nY me enseña a amar...',
        description: 'Canción ideal para acompañar enseñanzas bíblicas y momentos de predicación.',
        isForPreaching: true,
        isForWorship: true,
        isFavorite: true,
        playCount: 134,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        bibleVerse: 'Salmos 119:105',
        spiritualMessage: 'La importancia de la Palabra de Dios como guía y luz.',
        mood: MusicMood.uplifting,
        instruments: ['Guitarra acústica', 'Piano', 'Strings'],
        copyright: '© Grupo Kanzión',
        isOriginal: false,
        composer: 'Alex Campos',
      ),

      SpiritualMusic(
        id: 'music_6',
        title: 'Himno de Esperanza',
        artist: 'Coro VMF Sweden',
        album: 'Himnario Moderno',
        audioUrl: 'https://example.com/himno-esperanza.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        duration: const Duration(minutes: 3, seconds: 58),
        category: MusicCategory.hymns,
        purpose: MusicPurpose.worship,
        tags: ['himno', 'esperanza', 'clásico'],
        lyrics: 'Himno de esperanza cantamos\nA nuestro Dios y Salvador\nQue nos da la victoria\nY nos llena de su amor...',
        description: 'Himno tradicional adaptado para la congregación moderna.',
        isForWorship: true,
        isFavorite: false,
        playCount: 78,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        bibleVerse: 'Romanos 15:13',
        spiritualMessage: 'La esperanza que tenemos en Cristo es inquebrantable.',
        mood: MusicMood.hopeful,
        instruments: ['Órgano', 'Coro', 'Piano'],
        copyright: '© VMF Sweden',
        isOriginal: true,
        composer: 'Tradicional',
        arranger: 'Coro VMF Sweden',
      ),

      SpiritualMusic(
        id: 'music_7',
        title: 'Fuego Juvenil',
        artist: 'Generación 12',
        album: 'Somos Uno',
        audioUrl: 'https://example.com/fuego-juvenil.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        duration: const Duration(minutes: 4, seconds: 42),
        category: MusicCategory.youth,
        purpose: MusicPurpose.celebration,
        tags: ['juventud', 'fuego', 'pasión'],
        lyrics: 'Fuego juvenil arde en mi corazón\nPasión por ti Señor\nSomos una generación\nQue busca tu amor...',
        description: 'Canción energética diseñada para conectar con la juventud en su pasión por Dios.',
        isForWorship: true,
        isFavorite: true,
        playCount: 187,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        bibleVerse: '1 Timoteo 4:12',
        spiritualMessage: 'La pasión juvenil puede ser canalizada para glorificar a Dios.',
        mood: MusicMood.celebratory,
        instruments: ['Guitarra eléctrica', 'Batería', 'Bajo', 'Sintetizador'],
        copyright: '© Generación 12 Music',
        isOriginal: false,
        composer: 'Generación 12',
      ),

      SpiritualMusic(
        id: 'music_8',
        title: 'Sanidad y Restauración',
        artist: 'Christine D\'Clario',
        album: 'Eterno Live',
        audioUrl: 'https://example.com/sanidad-restauracion.mp3',
        imageUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400',
        duration: const Duration(minutes: 5, seconds: 28),
        category: MusicCategory.worship,
        purpose: MusicPurpose.prayer,
        tags: ['sanidad', 'restauración', 'milagros'],
        lyrics: 'Sanidad y restauración\nFluje de tu trono Señor\nTu poder nos transforma\nTu amor nos renueva...',
        description: 'Canción de adoración enfocada en la sanidad y restauración divina.',
        isForWorship: true,
        isForTestimony: true,
        isFavorite: false,
        playCount: 112,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        bibleVerse: 'Jeremías 30:17',
        spiritualMessage: 'Dios es nuestro sanador y restaurador.',
        mood: MusicMood.healing,
        instruments: ['Piano', 'Guitarra acústica', 'Violín', 'Cello'],
        copyright: '© Integrity Music',
        isOriginal: false,
        composer: 'Christine D\'Clario',
      ),
    ];

    _musicLibrary = mockMusic;
    _favorites = mockMusic.where((m) => m.isFavorite).toList();
    _testimonyPlaylist = mockMusic.where((m) => m.isForTestimony).take(3).toList();
    _preachingPlaylist = mockMusic.where((m) => m.isForPreaching).take(3).toList();
    _saveData();
    notifyListeners();
  }
}