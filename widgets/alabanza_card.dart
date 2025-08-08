import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/alabanza_provider.dart';
import '../providers/aura_provider.dart';

class AlabanzaCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final bool showPlayButton;

  const AlabanzaCard({
    super.key,
    required this.song,
    this.onTap,
    this.showPlayButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AlabanzaProvider, AuraProvider>(
      builder: (context, alabanzaProvider, auraProvider, child) {
        final isCurrentSong = alabanzaProvider.currentSong?.id == song.id;
        final isPlaying = isCurrentSong && alabanzaProvider.isPlaying;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1a2e).withOpacity(0.9),
                const Color(0xFF16213e).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentSong
                  ? auraProvider.selectedAuraColor.withOpacity(0.6)
                  : Colors.white.withOpacity(0.1),
              width: isCurrentSong ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrentSong
                    ? auraProvider.selectedAuraColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: isCurrentSong ? 12 : 8,
                spreadRadius: isCurrentSong ? 2 : 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () => alabanzaProvider.playSong(song),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Thumbnail con glow
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: auraProvider.selectedAuraColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Imagen de fondo
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    auraProvider.selectedAuraColor.withOpacity(0.3),
                                    auraProvider.selectedAuraColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Icon(
                                song.isVideo ? Icons.videocam : Icons.music_note,
                                color: auraProvider.selectedAuraColor,
                                size: 24,
                              ),
                            ),
                            // Overlay de reproducción
                            if (isPlaying)
                              Container(
                                color: Colors.black.withOpacity(0.4),
                                child: Center(
                                  child: Icon(
                                    Icons.pause,
                                    color: auraProvider.selectedAuraColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Información de la canción
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCurrentSong
                                  ? auraProvider.selectedAuraColor
                                  : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: auraProvider.selectedAuraColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  song.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: auraProvider.selectedAuraColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${song.plays} reproducciones',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Controles
                    Column(
                      children: [
                        // Botón de favorito
                        IconButton(
                          onPressed: () => alabanzaProvider.toggleFavorite(song.id),
                          icon: Icon(
                            song.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: song.isFavorite
                                ? Colors.red
                                : Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                        
                        // Duración
                        Text(
                          song.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    
                    // Botón de reproducción
                    if (showPlayButton)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              auraProvider.selectedAuraColor,
                              auraProvider.selectedAuraColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: auraProvider.selectedAuraColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (isCurrentSong) {
                              isPlaying
                                  ? alabanzaProvider.pauseSong()
                                  : alabanzaProvider.resumeSong();
                            } else {
                              alabanzaProvider.playSong(song);
                            }
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}