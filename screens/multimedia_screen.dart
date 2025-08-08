import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aura_provider.dart';
import '../utils/glow_styles.dart';

class MultimediaScreen extends StatefulWidget {
  const MultimediaScreen({super.key});

  @override
  State<MultimediaScreen> createState() => _MultimediaScreenState();
}

class _MultimediaScreenState extends State<MultimediaScreen> {
  final List<Map<String, dynamic>> _mediaCategories = [
    {
      'title': 'Videos Sermones',
      'subtitle': 'Mensajes inspiradores',
      'icon': Icons.video_library,
      'color': Color(0xFF2196F3),
      'count': 45,
    },
    {
      'title': 'Podcasts',
      'subtitle': 'Reflexiones diarias',
      'icon': Icons.podcasts,
      'color': Color(0xFF9C27B0),
      'count': 23,
    },
    {
      'title': 'Música Cristiana',
      'subtitle': 'Alabanzas y adoración',
      'icon': Icons.music_note,
      'color': Color(0xFF4CAF50),
      'count': 67,
    },
    {
      'title': 'Testimonios Video',
      'subtitle': 'Historias de fe',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
      'count': 34,
    },
    {
      'title': 'Documentales',
      'subtitle': 'Contenido educativo',
      'icon': Icons.movie,
      'color': Color(0xFFFF9800),
      'count': 12,
    },
    {
      'title': 'Conferencias',
      'subtitle': 'Eventos especiales',
      'icon': Icons.event,
      'color': Color(0xFFD4AF37),
      'count': 18,
    },
  ];

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
                  Expanded(
                    child: _buildMediaGrid(),
                  ),
                ],
              ),
            ),
          ),
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
                      '🎞️ Multimedia VMF',
                      style: GlowStyles.boldWhiteText.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Contenido espiritual multimedia',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.video_collection,
                color: auraColor,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _mediaCategories.length,
        itemBuilder: (context, index) {
          final category = _mediaCategories[index];
          return _buildMediaCard(category);
        },
      ),
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category['title']} - Próximamente disponible'),
            backgroundColor: category['color'],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category['color'].withOpacity(0.8),
              category['color'].withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: category['color'].withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  category['icon'],
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                category['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category['subtitle'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category['count']} items',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
