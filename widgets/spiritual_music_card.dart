import 'package:flutter/material.dart';
import '../models/spiritual_music_model.dart';

class SpiritualMusicCard extends StatelessWidget {
  final SpiritualMusic music;
  final Color auraColor;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;
  final VoidCallback? onAddToTestimony;
  final VoidCallback? onAddToPreaching;
  final VoidCallback? onRemoveFromTestimony;
  final VoidCallback? onRemoveFromPreaching;

  const SpiritualMusicCard({
    Key? key,
    required this.music,
    required this.auraColor,
    required this.onPlay,
    required this.onFavorite,
    this.onAddToTestimony,
    this.onAddToPreaching,
    this.onRemoveFromTestimony,
    this.onRemoveFromPreaching,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPlay,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Imagen del álbum
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: music.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(music.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: music.imageUrl == null ? auraColor.withOpacity(0.2) : null,
                    ),
                    child: music.imageUrl == null
                        ? Icon(
                            Icons.music_note,
                            color: auraColor,
                            size: 24,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Información de la música
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          music.artist,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Badge de categoría
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: music.category.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: music.category.color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                music.category.displayName,
                                style: TextStyle(
                                  color: music.category.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Duración
                            Icon(
                              Icons.access_time,
                              color: Colors.grey[400],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(music.duration),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Reproducciones
                            Icon(
                              Icons.play_arrow,
                              color: Colors.grey[400],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${music.playCount}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Botones de acción
                  Column(
                    children: [
                      // Botón de reproducir
                      Container(
                        decoration: BoxDecoration(
                          color: auraColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: auraColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: onPlay,
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Botón de favorito
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          music.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: music.isFavorite ? Colors.red : Colors.grey[400],
                        ),
                        iconSize: 20,
                      ),
                      
                      // Botón de menú
                      IconButton(
                        onPressed: () => _showOptionsMenu(context),
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                        ),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
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
            
            // Título
            Text(
              music.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              music.artist,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Opciones
            if (onAddToTestimony != null)
              ListTile(
                leading: Icon(Icons.record_voice_over, color: auraColor),
                title: const Text(
                  'Agregar a Testimonios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddToTestimony!();
                },
              ),
            
            if (onAddToPreaching != null)
              ListTile(
                leading: Icon(Icons.menu_book, color: auraColor),
                title: const Text(
                  'Agregar a Predicación',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddToPreaching!();
                },
              ),
            
            if (onRemoveFromTestimony != null)
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text(
                  'Quitar de Testimonios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromTestimony!();
                },
              ),
            
            if (onRemoveFromPreaching != null)
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text(
                  'Quitar de Predicación',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromPreaching!();
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
            
            ListTile(
              leading: Icon(Icons.info, color: auraColor),
              title: const Text(
                'Información',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showMusicInfo(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMusicInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          music.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Artista', music.artist),
              _buildInfoRow('Álbum', music.album),
              _buildInfoRow('Categoría', music.category.displayName),
              _buildInfoRow('Propósito', music.purpose.displayName),
              _buildInfoRow('Estado de ánimo', music.mood.displayName),
              _buildInfoRow('Duración', _formatDuration(music.duration)),
              _buildInfoRow('Reproducciones', '${music.playCount}'),
              if (music.bibleVerse != null)
                _buildInfoRow('Versículo', music.bibleVerse!),
              if (music.spiritualMessage != null)
                _buildInfoRow('Mensaje', music.spiritualMessage!),
              if (music.description != null)
                _buildInfoRow('Descripción', music.description!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: auraColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}