import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/devotional_model.dart';
import '../providers/aura_provider.dart';
import '../screens/devotional_detail_screen.dart';

class DevotionalCard extends StatelessWidget {
  final DevotionalModel devotional;
  final VoidCallback? onFavoriteToggle;
  final bool isCompact;

  const DevotionalCard({
    super.key,
    required this.devotional,
    this.onFavoriteToggle,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return Container(
      margin: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0f0f23).withOpacity(0.9),
            const Color(0xFF1a1a3a).withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDevotionalDetail(context),
          child: isCompact ? _buildCompactCard(auraColor) : _buildFullCard(auraColor),
        ),
      ),
    );
  }

  Widget _buildFullCard(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con imagen
        _buildCardHeader(auraColor),
        
        // Contenido
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Categoría y tiempo de lectura
              _buildCategoryAndTime(auraColor),
              const SizedBox(height: 12),
              
              // Título
              Text(
                devotional.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Subtítulo
              Text(
                devotional.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Versículo principal
              _buildMainVerse(auraColor),
              const SizedBox(height: 16),
              
              // Footer con autor y estadísticas
              _buildCardFooter(auraColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactCard(Color auraColor) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Imagen circular
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: auraColor.withOpacity(0.5), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                devotional.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: auraColor.withOpacity(0.2),
                  child: Icon(Icons.auto_stories, color: auraColor, size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  devotional.title,
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
                  devotional.verseReference,
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${devotional.readTime} min • ${devotional.author}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Botón favorito
          _buildFavoriteButton(auraColor),
        ],
      ),
    );
  }

  Widget _buildCardHeader(Color auraColor) {
    return Stack(
      children: [
        // Imagen de fondo
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                Image.network(
                  devotional.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: auraColor.withOpacity(0.2),
                    child: Icon(Icons.auto_stories, color: auraColor, size: 80),
                  ),
                ),
                // Overlay degradado
                Container(
                  decoration: BoxDecoration(
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
              ],
            ),
          ),
        ),
        
        // Badges y favorito
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: [
              if (devotional.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: auraColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Destacado',
                    style: TextStyle(
                      color: Color(0xFF0f0f23),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        Positioned(
          top: 12,
          right: 12,
          child: _buildFavoriteButton(auraColor),
        ),
      ],
    );
  }

  Widget _buildCategoryAndTime(Color auraColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: auraColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: auraColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                devotional.category.emoji,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                devotional.category.displayName,
                style: TextStyle(
                  color: auraColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.white.withOpacity(0.6), size: 14),
            const SizedBox(width: 4),
            Text(
              '${devotional.readTime} min',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainVerse(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: auraColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${devotional.mainVerse}"',
            style: TextStyle(
              color: auraColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            devotional.verseReference,
            style: TextStyle(
              color: auraColor.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(Color auraColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: auraColor.withOpacity(0.2),
          child: Icon(
            Icons.person,
            size: 14,
            color: auraColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            devotional.author,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Icon(Icons.visibility, color: Colors.white.withOpacity(0.5), size: 14),
            const SizedBox(width: 4),
            Text(
              devotional.views.toString(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.star, color: auraColor, size: 14),
            const SizedBox(width: 2),
            Text(
              devotional.rating.toStringAsFixed(1),
              style: TextStyle(
                color: auraColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(Color auraColor) {
    return GestureDetector(
      onTap: onFavoriteToggle,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: devotional.isFavorite ? auraColor : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          devotional.isFavorite ? Icons.bookmark : Icons.bookmark_border,
          color: devotional.isFavorite ? auraColor : Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  void _openDevotionalDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevotionalDetailScreen(devotional: devotional),
      ),
    );
  }
}