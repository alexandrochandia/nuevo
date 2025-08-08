import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aura_provider.dart';
import '../utils/glow_styles.dart';

class AlabanzaScreen extends StatefulWidget {
  const AlabanzaScreen({super.key});

  @override
  State<AlabanzaScreen> createState() => _AlabanzaScreenState();
}

class _AlabanzaScreenState extends State<AlabanzaScreen> {
  final List<Map<String, dynamic>> _canciones = [
    {
      'title': 'Amazing Grace',
      'artist': 'Coro VMF Sweden',
      'duration': '4:32',
      'category': 'Clásicos',
      'image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
      'isPlaying': false,
    },
    {
      'title': 'How Great Thou Art',
      'artist': 'Ministerio de Alabanza',
      'duration': '5:18',
      'category': 'Adoración',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=300&fit=crop',
      'isPlaying': false,
    },
    {
      'title': 'Reckless Love',
      'artist': 'VMF Worship Team',
      'duration': '6:24',
      'category': 'Contemporánea',
      'image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
      'isPlaying': false,
    },
    {
      'title': 'Way Maker',
      'artist': 'Coro Juvenil VMF',
      'duration': '4:45',
      'category': 'Contemporánea',
      'image': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=300&fit=crop',
      'isPlaying': false,
    },
  ];

  final List<String> _categorias = ['Todas', 'Clásicos', 'Contemporánea', 'Adoración', 'Juvenil'];
  String _categoriaSeleccionada = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(auraProvider.currentAuraColor),
                  _buildCategorias(auraProvider.currentAuraColor),
                  Expanded(
                    child: _buildCancionesLista(),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildMiniPlayer(auraProvider.currentAuraColor),
        );
      },
    );
  }

  Widget _buildHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎶 Alabanza VMF',
                      style: GlowStyles.boldWhiteText.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Música cristiana y adoración',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.music_note,
                color: auraColor,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias(Color auraColor) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          final isSelected = categoria == _categoriaSeleccionada;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _categoriaSeleccionada = categoria;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? auraColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? auraColor : Colors.white.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  categoria,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCancionesLista() {
    final cancionesFiltradas = _categoriaSeleccionada == 'Todas' 
        ? _canciones 
        : _canciones.where((c) => c['category'] == _categoriaSeleccionada).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: cancionesFiltradas.length,
      itemBuilder: (context, index) {
        final cancion = cancionesFiltradas[index];
        return _buildCancionCard(cancion, index);
      },
    );
  }

  Widget _buildCancionCard(Map<String, dynamic> cancion, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(cancion['image']),
              fit: BoxFit.cover,
            ),
          ),
          child: cancion['isPlaying'] 
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              : null,
        ),
        title: Text(
          cancion['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cancion['artist'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Provider.of<AuraProvider>(context).currentAuraColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cancion['category'],
                    style: TextStyle(
                      color: Provider.of<AuraProvider>(context).currentAuraColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cancion['duration'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _toggleFavorite(index),
              icon: Icon(
                Icons.favorite_border,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
            IconButton(
              onPressed: () => _playCancion(index),
              icon: Icon(
                cancion['isPlaying'] ? Icons.pause_circle : Icons.play_circle,
                color: Provider.of<AuraProvider>(context).currentAuraColor,
                size: 32,
              ),
            ),
          ],
        ),
        onTap: () => _playCancion(index),
      ),
    );
  }

  Widget _buildMiniPlayer(Color auraColor) {
    final cancionActual = _canciones.firstWhere(
      (c) => c['isPlaying'], 
      orElse: () => <String, dynamic>{},
    );

    if (cancionActual.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: auraColor.withOpacity(0.3)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(cancionActual['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cancionActual['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cancionActual['artist'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _previousSong(),
              icon: Icon(
                Icons.skip_previous,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            IconButton(
              onPressed: () => _togglePlayPause(),
              icon: Icon(
                Icons.pause_circle,
                color: auraColor,
                size: 36,
              ),
            ),
            IconButton(
              onPressed: () => _nextSong(),
              icon: Icon(
                Icons.skip_next,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playCancion(int index) {
    setState(() {
      // Pausar todas las canciones
      for (var cancion in _canciones) {
        cancion['isPlaying'] = false;
      }
      // Reproducir la seleccionada
      _canciones[index]['isPlaying'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reproduciendo: ${_canciones[index]['title']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_canciones[index]['title']} agregada a favoritos'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _togglePlayPause() {
    final index = _canciones.indexWhere((c) => c['isPlaying']);
    if (index != -1) {
      setState(() {
        _canciones[index]['isPlaying'] = !_canciones[index]['isPlaying'];
      });
    }
  }

  void _previousSong() {
    final currentIndex = _canciones.indexWhere((c) => c['isPlaying']);
    if (currentIndex > 0) {
      _playCancion(currentIndex - 1);
    }
  }

  void _nextSong() {
    final currentIndex = _canciones.indexWhere((c) => c['isPlaying']);
    if (currentIndex < _canciones.length - 1) {
      _playCancion(currentIndex + 1);
    }
  }
}
