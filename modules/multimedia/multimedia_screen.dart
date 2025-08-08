
import 'package:flutter/material.dart';
import '../alabanza/alabanza_screen.dart';
import '../../utils/glow_styles.dart';

class MultimediaScreen extends StatelessWidget {
  const MultimediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎞️ Multimedia VMF', style: GlowStyles.boldNeonText),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF111827)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMediaCard(
              context,
              'Sermones en Video',
              'Mensajes inspiradores de VMF',
              Icons.video_library,
                  () => _openMediaCategory(context, 'sermones'),
            ),
            const SizedBox(height: 16),
            _buildMediaCard(
              context,
              'Música Cristiana',
              'Alabanzas y adoración',
              Icons.music_note,
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlabanzaScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMediaCard(
              context,
              'Podcasts VMF',
              'Episodios de enseñanza',
              Icons.headset,
                  () => _openMediaCategory(context, 'podcasts'),
            ),
            const SizedBox(height: 16),
            _buildMediaCard(
              context,
              'Transmisiones en Vivo',
              'Servicios en directo',
              Icons.live_tv,
                  () => Navigator.pushNamed(context, '/en_vivo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFD700),
          child: Icon(icon, color: const Color(0xFF1E3A8A)),
        ),
        title: Text(
          title,
          style: GlowStyles.boldNeonText.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: GlowStyles.boldWhiteText.copyWith(color: Colors.white70),
        ),
        trailing: const Icon(Icons.play_arrow, color: Colors.white),
        onTap: onTap,
      ),
    );
  }

  void _openMediaCategory(BuildContext context, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reproduciendo: $category'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}
