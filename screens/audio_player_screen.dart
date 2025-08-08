import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spiritual_music_model.dart';
import '../providers/aura_provider.dart';
import '../providers/spiritual_music_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  final SpiritualMusic music;

  const AudioPlayerScreen({
    Key? key,
    required this.music,
  }) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _totalDuration = widget.music.duration.inSeconds.toDouble();
    _simulatePlayback();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _simulatePlayback() {
    _isPlaying = true;
    _isLoading = false;
    
    // Simulación de reproducción
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuraProvider, SpiritualMusicProvider>(
      builder: (context, auraProvider, musicProvider, child) {
        final auraColor = auraProvider.currentAuraColor;
        
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
            title: const Text(
              'Reproduciendo',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => _showMusicOptions(context, auraColor),
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  auraColor.withOpacity(0.1),
                  Colors.black,
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Imagen del álbum
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _isPlaying ? _rotationController.value * 2 * 3.14159 : 0,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: auraColor.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: widget.music.imageUrl != null
                                  ? Image.network(
                                      widget.music.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAlbumArt(auraColor);
                                      },
                                    )
                                  : _buildDefaultAlbumArt(auraColor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Información de la canción
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Título y artista
                        Text(
                          widget.music.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.music.artist,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Información adicional
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.music.category.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.music.category.color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                widget.music.category.displayName,
                                style: TextStyle(
                                  color: widget.music.category.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: auraColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: auraColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                widget.music.mood.displayName,
                                style: TextStyle(
                                  color: auraColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Barra de progreso
                        Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: auraColor,
                                inactiveTrackColor: Colors.grey[800],
                                thumbColor: auraColor,
                                overlayColor: auraColor.withOpacity(0.3),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                value: _currentPosition,
                                max: _totalDuration,
                                onChanged: (value) {
                                  setState(() {
                                    _currentPosition = value;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(Duration(seconds: _currentPosition.toInt())),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(widget.music.duration),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Controles de reproducción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                musicProvider.toggleFavorite(widget.music);
                              },
                              icon: Icon(
                                widget.music.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: widget.music.isFavorite ? Colors.red : Colors.grey[400],
                              ),
                              iconSize: 32,
                            ),
                            IconButton(
                              onPressed: () {
                                // Anterior
                              },
                              icon: Icon(
                                Icons.skip_previous,
                                color: Colors.grey[400],
                              ),
                              iconSize: 36,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: auraColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: auraColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _togglePlayPause,
                                icon: Icon(
                                  _isLoading
                                      ? Icons.hourglass_empty
                                      : _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Siguiente
                              },
                              icon: Icon(
                                Icons.skip_next,
                                color: Colors.grey[400],
                              ),
                              iconSize: 36,
                            ),
                            IconButton(
                              onPressed: () => _showMusicOptions(context, auraColor),
                              icon: Icon(
                                Icons.playlist_add,
                                color: Colors.grey[400],
                              ),
                              iconSize: 32,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Versículo bíblico si existe
                        if (widget.music.bibleVerse != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: auraColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: auraColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  color: auraColor,
                                  size: 20,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.music.bibleVerse!,
                                  style: TextStyle(
                                    color: auraColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAlbumArt(Color auraColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            auraColor.withOpacity(0.3),
            auraColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: auraColor,
        size: 80,
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _isPlaying = false;
        _rotationController.stop();
      } else {
        _isPlaying = true;
        _rotationController.repeat();
      }
    });
  }

  void _showMusicOptions(BuildContext context, Color auraColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: Icon(Icons.record_voice_over, color: auraColor),
              title: const Text(
                'Agregar a Testimonios',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<SpiritualMusicProvider>().addToTestimonyPlaylist(widget.music);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Agregado a playlist de testimonios'),
                    backgroundColor: auraColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book, color: auraColor),
              title: const Text(
                'Agregar a Predicación',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<SpiritualMusicProvider>().addToPreachingPlaylist(widget.music);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Agregado a playlist de predicación'),
                    backgroundColor: auraColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: auraColor),
              title: const Text(
                'Compartir',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implementar compartir
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}