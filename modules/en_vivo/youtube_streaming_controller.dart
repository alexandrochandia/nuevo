` tags.

```
<replit_final_file>
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeStreamingController {
  static const String youtubeStudioUrl = 'https://studio.youtube.com/channel/UC/livestreaming';

  // Configurar streaming simultáneo a YouTube
  static Future<void> setupYouTubeStreaming({
    required String streamKey,
    required String title,
    required String description,
  }) async {
    // En una implementación real, esto se conectaría con la API de YouTube
    // Por ahora, abrimos YouTube Studio para configuración manual
    await _openYouTubeStudio();
  }

  static Future<void> _openYouTubeStudio() async {
    final Uri url = Uri.parse(youtubeStudioUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Widget para mostrar guía de configuración YouTube
  static Widget buildYouTubeSetupGuide(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.youtube_searched_for, color: Colors.red, size: 30),
              SizedBox(width: 12),
              Text(
                'Streaming en YouTube',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Para transmitir simultáneamente en YouTube:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Ve a YouTube Studio'),
          _buildStep('2', 'Selecciona "Transmitir en vivo"'),
          _buildStep('3', 'Copia tu clave de transmisión'),
          _buildStep('4', 'Pégala en la configuración VMF'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openYouTubeStudio(),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir YouTube Studio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Validar clave de streaming de YouTube
  static bool isValidYouTubeStreamKey(String key) {
    // Validación básica del formato de clave de YouTube
    return key.length >= 12 && key.contains('-');
  }

  // Obtener URL de vista previa para YouTube
  static String getYouTubePreviewUrl(String streamKey) {
    return 'https://studio.youtube.com/live_creation';
  }
}