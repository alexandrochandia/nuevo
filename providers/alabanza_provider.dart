import 'package:flutter/material.dart';
import '../models/song_model.dart';

class AlabanzaProvider extends ChangeNotifier {
  List<SongModel> _songs = [];
  List<SongModel> _favorites = [];
  List<SongModel> _filteredSongs = [];
  SongModel? _currentSong;
  bool _isPlaying = false;
  bool _isLoading = false;
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;

  // Getters
  List<SongModel> get songs => _filteredSongs;
  List<SongModel> get favorites => _favorites;
  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get currentPosition => _currentPosition;
  double get totalDuration => _totalDuration;

  final List<String> categories = [
    'Todas',
    'Adoración',
    'Alabanza',
    'Ministerio VMF',
    'Congregacional',
    'Juvenil',
    'Instrumentales',
    'Videos en Vivo'
  ];

  AlabanzaProvider() {
    loadSongs();
  }

  void loadSongs() {
    _isLoading = true;
    notifyListeners();

    // Datos de prueba con canciones cristianas reales
    _songs = [
      SongModel(
        id: '1',
        title: 'Como Zaqueo',
        artist: 'Miel San Marcos',
        duration: '4:23',
        thumbnail: 'https://i.ytimg.com/vi/tkbgtVFlyCQ/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=tkbgtVFlyCQ',
        videoUrl: 'https://www.youtube.com/watch?v=tkbgtVFlyCQ',
        category: 'Adoración',
        isVideo: true,
        plays: 1250,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        tags: ['adoración', 'miel san marcos', 'popular'],
      ),
      SongModel(
        id: '2',
        title: 'Reckless Love',
        artist: 'Cory Asbury',
        duration: '5:42',
        thumbnail: 'https://i.ytimg.com/vi/Sc6SSHuZvQE/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=Sc6SSHuZvQE',
        videoUrl: 'https://www.youtube.com/watch?v=Sc6SSHuZvQE',
        category: 'Alabanza',
        isVideo: true,
        plays: 2100,
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        tags: ['alabanza', 'english', 'bethel'],
      ),
      SongModel(
        id: '3',
        title: 'Waymaker',
        artist: 'Sinach',
        duration: '4:17',
        thumbnail: 'https://i.ytimg.com/vi/29IxnsqOkmE/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=29IxnsqOkmE',
        videoUrl: 'https://www.youtube.com/watch?v=29IxnsqOkmE',
        category: 'Ministerio VMF',
        isVideo: true,
        plays: 1800,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        tags: ['ministerio', 'milagros', 'fe'],
      ),
      SongModel(
        id: '4',
        title: 'Goodness of God',
        artist: 'Bethel Music',
        duration: '6:31',
        thumbnail: 'https://i.ytimg.com/vi/l9AzO1MfaVo/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=l9AzO1MfaVo',
        videoUrl: 'https://www.youtube.com/watch?v=l9AzO1MfaVo',
        category: 'Congregacional',
        isVideo: true,
        plays: 950,
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        tags: ['congregacional', 'bethel', 'bondad'],
      ),
      SongModel(
        id: '5',
        title: 'Oceans',
        artist: 'Hillsong United',
        duration: '8:56',
        thumbnail: 'https://i.ytimg.com/vi/dy9nwe9_xzw/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=dy9nwe9_xzw',
        videoUrl: 'https://www.youtube.com/watch?v=dy9nwe9_xzw',
        category: 'Adoración',
        isVideo: true,
        plays: 3200,
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        tags: ['adoración', 'hillsong', 'océanos'],
      ),
      SongModel(
        id: '6',
        title: 'Sobrenatural',
        artist: 'Redimi2 ft. Christine D\'Clario',
        duration: '4:45',
        thumbnail: 'https://i.ytimg.com/vi/7fwJ2MbzlXg/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=7fwJ2MbzlXg',
        videoUrl: 'https://www.youtube.com/watch?v=7fwJ2MbzlXg',
        category: 'Juvenil',
        isVideo: true,
        plays: 1650,
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        tags: ['juvenil', 'redimi2', 'sobrenatural'],
      ),
      SongModel(
        id: '7',
        title: 'Piano Instrumental Worship',
        artist: 'VMF Sweden Worship',
        duration: '12:34',
        thumbnail: 'https://i.ytimg.com/vi/GFIjAcOzDWU/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=GFIjAcOzDWU',
        category: 'Instrumentales',
        isVideo: false,
        plays: 850,
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        tags: ['instrumental', 'piano', 'vmf'],
      ),
      SongModel(
        id: '8',
        title: 'Culto VMF Sweden - Domingo',
        artist: 'VMF Sweden Live',
        duration: '45:20',
        thumbnail: 'https://i.ytimg.com/vi/live_stream/maxresdefault.jpg',
        audioUrl: 'https://www.youtube.com/watch?v=live_stream',
        videoUrl: 'https://www.youtube.com/watch?v=live_stream',
        category: 'Videos en Vivo',
        isVideo: true,
        plays: 520,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        tags: ['vivo', 'culto', 'vmf sweden'],
      ),
    ];

    _filteredSongs = _songs;
    _isLoading = false;
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void searchSongs(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredSongs = _songs.where((song) {
      final matchesCategory = _selectedCategory == 'Todas' || song.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      return matchesCategory && matchesSearch;
    }).toList();
    
    notifyListeners();
  }

  void playSong(SongModel song) {
    _currentSong = song;
    _isPlaying = true;
    _currentPosition = 0.0;
    _totalDuration = _parseDuration(song.duration);
    
    // Incrementar contador de reproducciones
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _songs[index] = _songs[index].copyWith(plays: _songs[index].plays + 1);
    }
    
    notifyListeners();
  }

  void pauseSong() {
    _isPlaying = false;
    notifyListeners();
  }

  void resumeSong() {
    _isPlaying = true;
    notifyListeners();
  }

  void stopSong() {
    _currentSong = null;
    _isPlaying = false;
    _currentPosition = 0.0;
    _totalDuration = 0.0;
    notifyListeners();
  }

  void seekTo(double position) {
    _currentPosition = position;
    notifyListeners();
  }

  void toggleFavorite(String songId) {
    final songIndex = _songs.indexWhere((song) => song.id == songId);
    if (songIndex != -1) {
      final song = _songs[songIndex];
      final updatedSong = song.copyWith(isFavorite: !song.isFavorite);
      _songs[songIndex] = updatedSong;
      
      if (updatedSong.isFavorite) {
        _favorites.add(updatedSong);
      } else {
        _favorites.removeWhere((fav) => fav.id == songId);
      }
      
      // Actualizar currentSong si es la misma
      if (_currentSong?.id == songId) {
        _currentSong = updatedSong;
      }
      
      notifyListeners();
    }
  }

  void playNext() {
    if (_currentSong == null) return;
    
    final currentIndex = _filteredSongs.indexWhere((song) => song.id == _currentSong!.id);
    if (currentIndex != -1 && currentIndex < _filteredSongs.length - 1) {
      playSong(_filteredSongs[currentIndex + 1]);
    }
  }

  void playPrevious() {
    if (_currentSong == null) return;
    
    final currentIndex = _filteredSongs.indexWhere((song) => song.id == _currentSong!.id);
    if (currentIndex > 0) {
      playSong(_filteredSongs[currentIndex - 1]);
    }
  }

  // Métodos aliases para compatibilidad
  void togglePlayPause() {
    if (_isPlaying) {
      pauseSong();
    } else {
      resumeSong();
    }
  }

  void nextSong() => playNext();
  void previousSong() => playPrevious();

  double _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60 + seconds).toDouble();
    }
    return 0.0;
  }

  String formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}