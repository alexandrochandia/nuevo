import 'package:flutter/material.dart';

class LiveStreamUtils {
  // Helper methods for status
  static Color getStatusColor(String? status) {
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

  static IconData getStatusIcon(String? status) {
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

  static String getStatusDisplayName(String? status) {
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
  static Color getTypeColor(String? type) {
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

  static String getTypeEmoji(String? type) {
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

  static String getTypeDisplayName(String? type) {
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

  // Helper methods for formatting
  static String formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }
}
