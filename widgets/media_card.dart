import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_model.dart';
import '../providers/aura_provider.dart';

class MediaCard extends StatelessWidget {
  final MediaModel media;
  final VoidCallback onTap;
  final bool isHorizontal;

  const MediaCard({
    super.key,
    required this.media,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e).withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: auraProvider.currentAuraColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: auraProvider.currentAuraColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: isHorizontal ? _buildHorizontalLayout(auraProvider) : _buildVerticalLayout(auraProvider),
          ),
        );
      },
    );
  }

  Widget _buildVerticalLayout(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildThumbnail(auraProvider),
        Expanded(
          child: _buildContent(auraProvider),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(AuraProvider auraProvider) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: _buildThumbnail(auraProvider),
        ),
        Expanded(
          child: _buildContent(auraProvider),
        ),
      ],
    );
  }

  Widget _buildThumbnail(AuraProvider auraProvider) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: isHorizontal 
              ? const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                )
              : const BorderRadius.vertical(top: Radius.circular(15)),
          child: Container(
            width: double.infinity,
            height: isHorizontal ? 120 : 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(media.thumbnailUrl),
                fit: BoxFit.cover,
                onError: (error, stackTrace) {},
              ),
            ),
            child: Image.network(
              media.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        auraProvider.currentAuraColor.withOpacity(0.3),
                        auraProvider.currentAuraColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      media.typeIcon,
                      color: auraProvider.currentAuraColor,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Live indicator
        if (media.isLive)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  SizedBox(width: 4),
                  Text(
                    'EN VIVO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Premium badge
        if (media.isPremium)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Featured badge
        if (media.isFeatured && !media.isLive && !media.isPremium)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: auraProvider.currentAuraColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'DESTACADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Play button overlay
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              media.typeIcon,
              color: auraProvider.currentAuraColor,
              size: 24,
            ),
          ),
        ),
        // Duration
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              media.duration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: media.categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: media.categoryColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              media.categoryText,
              style: TextStyle(
                color: media.categoryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            media.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: auraProvider.currentAuraColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Artist
          Text(
            media.artist,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            media.shortDescription,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              height: 1.4,
            ),
            maxLines: isHorizontal ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.visibility_rounded,
                media.formattedViews,
                auraProvider,
              ),
              const SizedBox(width: 15),
              _buildStatItem(
                Icons.favorite_rounded,
                media.likes.toString(),
                auraProvider,
              ),
              const SizedBox(width: 15),
              _buildStatItem(
                Icons.schedule_rounded,
                media.formattedUploadDate,
                auraProvider,
              ),
              const Spacer(),
              if (media.rating > 0)
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: const Color(0xFFFFD700),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      media.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, AuraProvider auraProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}