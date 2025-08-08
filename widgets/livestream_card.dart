import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/livestream_model.dart';
import '../providers/aura_provider.dart';
import 'package:intl/intl.dart';

class LiveStreamCard extends StatelessWidget {
  final LiveStreamModel stream;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const LiveStreamCard({
    super.key,
    required this.stream,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: stream.isLive 
                  ? Colors.red.withOpacity(0.5)
                  : auraProvider.currentAuraColor.withOpacity(0.3),
              width: stream.isLive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: stream.isLive 
                    ? Colors.red.withOpacity(0.2)
                    : auraProvider.currentAuraColor.withOpacity(0.1),
                blurRadius: stream.isLive ? 20 : 10,
                spreadRadius: stream.isLive ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThumbnail(auraProvider),
                  _buildContent(auraProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(AuraProvider auraProvider) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.grey[800],
      ),
      child: Stack(
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              stream.thumbnailUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=450&fit=crop',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Status badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(stream.status),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(stream.status).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(stream.status),
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusDisplayName(stream.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Type badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(stream.type).withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTypeEmoji(stream.type),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTypeDisplayName(stream.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Viewer count for live streams
          if (stream.isLive)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatViewerCount(stream.viewerCount ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Duration for ended streams
          if (stream.hasEnded && stream.duration != null)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(Duration(minutes: stream.durationMinutes ?? 0)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            stream.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Pastor and time info
          Row(
            children: [
              Icon(
                Icons.person,
                size: 14,
                color: auraProvider.currentAuraColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stream.pastor ?? 'Pastor no especificado',
                  style: TextStyle(
                    color: auraProvider.currentAuraColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          Row(
            children: [
              Icon(
                _getTimeIcon(),
                size: 14,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getTimeText(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            stream.description,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Tags and actions
          Row(
            children: [
              // Tags
              if (stream.tags?.isNotEmpty ?? false)
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (stream.tags ?? []).take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: auraProvider.currentAuraColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: auraProvider.currentAuraColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: auraProvider.currentAuraColor,
                          fontSize: 10,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (stream.allowComments ?? false)
                    _buildActionButton(
                      Icons.chat_bubble_outline,
                      Colors.blue,
                      () {},
                    ),
                  if (stream.allowDonations ?? false)
                    _buildActionButton(
                      Icons.favorite_outline,
                      Colors.pink,
                      () {},
                    ),
                  _buildActionButton(
                    Icons.share_outlined,
                    Colors.grey[400]!,
                    () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  IconData _getTimeIcon() {
    switch (stream.status) {
      case LiveStreamStatus.live:
        return Icons.radio_button_checked;
      case LiveStreamStatus.scheduled:
      case LiveStreamStatus.upcoming:
        return Icons.schedule;
      case LiveStreamStatus.ended:
        return Icons.history;
      default:
        return Icons.schedule; // Default icon
    }
  }

  String _getTimeText() {
    final now = DateTime.now();
    
    switch (stream.status) {
      case LiveStreamStatus.live:
        if (stream.startTime != null) {
          final duration = now.difference(stream.startTime!);
          return 'En vivo desde hace ${_formatDuration(duration)}';
        }
        return 'EN VIVO AHORA';
        
      case LiveStreamStatus.scheduled:
      case LiveStreamStatus.upcoming:
        final timeUntil = (stream.scheduledTime ?? DateTime.now()).difference(now);
        if (timeUntil.inDays > 0) {
          return 'En ${timeUntil.inDays} días - ${DateFormat('MMM dd, HH:mm').format(stream.scheduledTime ?? DateTime.now())}';
        } else if (timeUntil.inHours > 0) {
          return 'En ${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
        } else if (timeUntil.inMinutes > 0) {
          return 'En ${timeUntil.inMinutes} minutos';
        } else {
          return 'Comenzando pronto';
        }
        
      case LiveStreamStatus.ended:
        final timeSince = now.difference(stream.scheduledTime ?? DateTime.now());
        if (timeSince.inDays > 0) {
          return 'Hace ${timeSince.inDays} días';
        } else if (timeSince.inHours > 0) {
          return 'Hace ${timeSince.inHours} horas';
        } else {
          return 'Hace ${timeSince.inMinutes} minutos';
        }
      default:
        return 'Programado'; // Default text
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  // Helper methods for status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'live':
        return Colors.red;
      case 'scheduled':
      case 'upcoming':
        return Colors.orange;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'live':
        return Icons.radio_button_checked;
      case 'scheduled':
      case 'upcoming':
        return Icons.schedule;
      case 'ended':
        return Icons.history;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'live':
        return 'EN VIVO';
      case 'scheduled':
        return 'PROGRAMADO';
      case 'upcoming':
        return 'PRÓXIMO';
      case 'ended':
        return 'FINALIZADO';
      default:
        return 'DESCONOCIDO';
    }
  }

  // Helper methods for type
  Color _getTypeColor(String? type) {
    switch (type) {
      case 'worship':
        return Colors.purple;
      case 'bible_study':
      case 'estudio':
        return Colors.blue;
      case 'youth':
      case 'juventud':
        return Colors.green;
      case 'conference':
      case 'conferencia':
        return Colors.indigo;
      case 'marriage':
      case 'matrimonio':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getTypeEmoji(String? type) {
    switch (type) {
      case 'worship':
        return '🙏';
      case 'bible_study':
      case 'estudio':
        return '📖';
      case 'youth':
      case 'juventud':
        return '🔥';
      case 'conference':
      case 'conferencia':
        return '🎤';
      case 'marriage':
      case 'matrimonio':
        return '💕';
      default:
        return '📺';
    }
  }

  String _getTypeDisplayName(String? type) {
    switch (type) {
      case 'worship':
        return 'Culto';
      case 'bible_study':
      case 'estudio':
        return 'Estudio';
      case 'youth':
      case 'juventud':
        return 'Juventud';
      case 'conference':
      case 'conferencia':
        return 'Conferencia';
      case 'marriage':
      case 'matrimonio':
        return 'Matrimonio';
      default:
        return 'General';
    }
  }
}