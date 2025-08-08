import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../config/supabase_config.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  // Simular reproducción de música
  Future<void> playAudio(String url) async {
    if (kDebugMode) {
      print('🎵 Reproduciendo audio: $url');
    }
    
    // Simular tiempo de carga
    await Future.delayed(const Duration(seconds: 1));
    
    if (kDebugMode) {
      print('✅ Audio iniciado correctamente');
    }
  }

  Future<void> pauseAudio() async {
    if (kDebugMode) {
      print('⏸️ Audio pausado');
    }
  }

  Future<void> stopAudio() async {
    if (kDebugMode) {
      print('⏹️ Audio detenido');
    }
  }

  // Simular reproducción de video
  Future<void> playVideo(String url) async {
    if (kDebugMode) {
      print('🎬 Reproduciendo video: $url');
    }
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (kDebugMode) {
      print('✅ Video iniciado correctamente');
    }
  }

  // Obtener canciones desde Supabase (con fallback)
  Future<List<SongModel>> fetchSongs() async {
    try {
      if (SupabaseConfig.client != null) {
        final response = await SupabaseConfig.client!
            .from('songs')
            .select('*')
            .order('created_at', ascending: false);
        
        return response.map<SongModel>((json) => SongModel.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener canciones de Supabase: $e');
      }
    }
    
    // Retornar datos de prueba si Supabase no está disponible
    return _getMockSongs();
  }

  // Guardar canción favorita en Supabase
  Future<void> toggleFavorite(String songId, bool isFavorite) async {
    try {
      if (SupabaseConfig.client != null) {
        await SupabaseConfig.client!
            .from('songs')
            .update({'is_favorite': isFavorite})
            .eq('id', songId);
        
        if (kDebugMode) {
          print('✅ Favorito actualizado: $songId -> $isFavorite');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al actualizar favorito: $e');
      }
    }
  }

  // Actualizar contador de reproducciones
  Future<void> incrementPlayCount(String songId) async {
    try {
      if (SupabaseConfig.client != null) {
        await SupabaseConfig.client!
            .rpc('increment_plays', params: {'song_id': songId});
        
        if (kDebugMode) {
          print('✅ Contador de reproducciones actualizado: $songId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al actualizar contador: $e');
      }
    }
  }

  // Buscar canciones
  Future<List<SongModel>> searchSongs(String query) async {
    try {
      if (SupabaseConfig.client != null) {
        final response = await SupabaseConfig.client!
            .from('songs')
            .select('*')
            .or('title.ilike.%$query%,artist.ilike.%$query%,tags.cs.{$query}')
            .order('plays', ascending: false);
        
        return response.map<SongModel>((json) => SongModel.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en búsqueda: $e');
      }
    }
    
    // Filtrar datos de prueba
    final mockSongs = _getMockSongs();
    return mockSongs.where((song) {
      final queryLower = query.toLowerCase();
      return song.title.toLowerCase().contains(queryLower) ||
          song.artist.toLowerCase().contains(queryLower) ||
          song.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();
  }

  // Obtener canciones por categoría
  Future<List<SongModel>> getSongsByCategory(String category) async {
    try {
      if (SupabaseConfig.client != null) {
        final response = await SupabaseConfig.client!
            .from('songs')
            .select('*')
            .eq('category', category)
            .order('plays', ascending: false);
        
        return response.map<SongModel>((json) => SongModel.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener canciones por categoría: $e');
      }
    }
    
    // Filtrar datos de prueba
    final mockSongs = _getMockSongs();
    return mockSongs.where((song) => song.category == category).toList();
  }

  // Datos de prueba
  List<SongModel> _getMockSongs() {
    return [
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
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
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
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['vivo', 'culto', 'vmf sweden'],
      ),
    ];
  }

  // Obtener categorías disponibles
  List<String> getCategories() {
    return [
      'Todas',
      'Adoración',
      'Alabanza',
      'Ministerio VMF',
      'Congregacional',
      'Juvenil',
      'Instrumentales',
      'Videos en Vivo'
    ];
  }

  // Validar URL de YouTube
  bool isValidYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  // Obtener ID de video de YouTube
  String? getYouTubeVideoId(String url) {
    final regExp = RegExp(r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}