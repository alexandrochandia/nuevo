import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/alabanza_provider.dart';
import '../providers/aura_provider.dart';

class SongOptionsModal extends StatelessWidget {
  final SongModel song;

  const SongOptionsModal({
    super.key,
    required this.song,
  });

  static void show(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SongOptionsModal(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AlabanzaProvider, AuraProvider>(
      builder: (context, alabanzaProvider, auraProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1a1a2e),
                const Color(0xFF0f0f23),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: auraProvider.selectedAuraColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: auraProvider.selectedAuraColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de arrastre
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: auraProvider.selectedAuraColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Información de la canción
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Thumbnail
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              auraProvider.selectedAuraColor.withOpacity(0.3),
                              auraProvider.selectedAuraColor.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: auraProvider.selectedAuraColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          song.isVideo ? Icons.videocam : Icons.music_note,
                          color: auraProvider.selectedAuraColor,
                          size: 28,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Información
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: auraProvider.selectedAuraColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    song.category,
                                    style: TextStyle(
                                      color: auraProvider.selectedAuraColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  song.duration,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Opciones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Reproducir/Pausar
                      _buildOption(
                        context,
                        icon: alabanzaProvider.currentSong?.id == song.id && alabanzaProvider.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        title: alabanzaProvider.currentSong?.id == song.id && alabanzaProvider.isPlaying
                            ? 'Pausar'
                            : 'Reproducir',
                        subtitle: 'Controlar reproducción',
                        onTap: () {
                          if (alabanzaProvider.currentSong?.id == song.id) {
                            alabanzaProvider.isPlaying
                                ? alabanzaProvider.pauseSong()
                                : alabanzaProvider.resumeSong();
                          } else {
                            alabanzaProvider.playSong(song);
                          }
                          Navigator.pop(context);
                        },
                        auraColor: auraProvider.selectedAuraColor,
                      ),
                      
                      // Favoritos
                      _buildOption(
                        context,
                        icon: song.isFavorite ? Icons.favorite : Icons.favorite_border,
                        title: song.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                        subtitle: 'Gestionar canciones favoritas',
                        onTap: () {
                          alabanzaProvider.toggleFavorite(song.id);
                          Navigator.pop(context);
                        },
                        auraColor: auraProvider.selectedAuraColor,
                      ),
                      
                      // Reproducir siguiente
                      _buildOption(
                        context,
                        icon: Icons.skip_next,
                        title: 'Reproducir siguiente',
                        subtitle: 'Agregar a lista de reproducción',
                        onTap: () {
                          alabanzaProvider.playSong(song);
                          Navigator.pop(context);
                        },
                        auraColor: auraProvider.selectedAuraColor,
                      ),
                      
                      // Compartir
                      _buildOption(
                        context,
                        icon: Icons.share,
                        title: 'Compartir',
                        subtitle: 'Compartir canción con otros',
                        onTap: () {
                          _showShareOptions(context, song);
                        },
                        auraColor: auraProvider.selectedAuraColor,
                      ),
                      
                      // Información
                      _buildOption(
                        context,
                        icon: Icons.info_outline,
                        title: 'Información',
                        subtitle: 'Ver detalles de la canción',
                        onTap: () {
                          _showSongInfo(context, song, auraProvider.selectedAuraColor);
                        },
                        auraColor: auraProvider.selectedAuraColor,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color auraColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        auraColor.withOpacity(0.2),
                        auraColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: auraColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Compartir Canción',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: const Text('Copiar enlace', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enlace copiado al portapapeles')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('Compartir por mensaje', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo mensajes...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSongInfo(BuildContext context, SongModel song, Color auraColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Información de la Canción',
          style: TextStyle(color: auraColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Título:', song.title),
            _buildInfoRow('Artista:', song.artist),
            _buildInfoRow('Duración:', song.duration),
            _buildInfoRow('Categoría:', song.category),
            _buildInfoRow('Reproducciones:', '${song.plays}'),
            _buildInfoRow('Tipo:', song.isVideo ? 'Video' : 'Audio'),
            _buildInfoRow('Etiquetas:', song.tags.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Cerrar', style: TextStyle(color: auraColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}