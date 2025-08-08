import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/vmf_story_model.dart';
import '../providers/aura_provider.dart';

class VMFStoryCard extends StatelessWidget {
  final VMFStoryModel story;
  final VoidCallback onTap;

  const VMFStoryCard({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image/thumbnail
                  _buildBackground(),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  
                  // Content overlay
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top section with user info and category
                        Row(
                          children: [
                            _buildUserAvatar(),
                            const SizedBox(width: 8),
                            Expanded(child: _buildUserInfo()),
                            _buildCategoryBadge(auraColor),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Bottom section with story info
                        _buildStoryInfo(auraColor),
                      ],
                    ),
                  ),
                  
                  // Play button overlay
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: auraColor, width: 2),
                      ),
                      child: Icon(
                        story.type == VMFStoryType.video 
                            ? Icons.play_arrow 
                            : Icons.visibility,
                        color: auraColor,
                        size: 30,
                      ),
                    ),
                  ),
                  
                  // Verification badge
                  if (story.isVerified)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    if (story.thumbnail?.isNotEmpty == true) {
      return CachedNetworkImage(
        imageUrl: story.thumbnail!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Icon(
            Icons.error_outline,
            color: Colors.white54,
            size: 40,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCategoryColor().withOpacity(0.6),
              _getCategoryColor().withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Text(
            _getCategoryIcon(),
            style: const TextStyle(fontSize: 60),
          ),
        ),
      );
    }
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: story.userProfileImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: story.userProfileImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[600],
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[600],
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
              )
            : Container(
                color: Colors.grey[600],
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          story.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          _getTimeAgo(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(Color auraColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        _getCategoryName(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStoryInfo(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (story.description?.isNotEmpty == true)
          Text(
            story.description!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.visibility,
              color: auraColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${story.views}',
              style: TextStyle(
                color: auraColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.favorite,
              color: story.isLiked ? Colors.red : Colors.white60,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${story.likes}',
              style: TextStyle(
                color: story.isLiked ? Colors.red : Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${story.duration.inSeconds}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(story.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  String _getCategoryName() {
    switch (story.category) {
      case VMFStoryCategory.testimonio:
        return 'Testimonio';
      case VMFStoryCategory.predicacion:
        return 'Predicación';
      case VMFStoryCategory.alabanza:
        return 'Alabanza';
      case VMFStoryCategory.juventud:
        return 'Juventud';
      case VMFStoryCategory.matrimonio:
        return 'Matrimonio';
      case VMFStoryCategory.oracion:
        return 'Oración';
      case VMFStoryCategory.estudio:
        return 'Estudio';
      case VMFStoryCategory.eventos:
        return 'Eventos';
    }
  }

  String _getCategoryIcon() {
    switch (story.category) {
      case VMFStoryCategory.testimonio:
        return '🙏';
      case VMFStoryCategory.predicacion:
        return '📖';
      case VMFStoryCategory.alabanza:
        return '🎵';
      case VMFStoryCategory.juventud:
        return '🌱';
      case VMFStoryCategory.matrimonio:
        return '💑';
      case VMFStoryCategory.oracion:
        return '🕊️';
      case VMFStoryCategory.estudio:
        return '📚';
      case VMFStoryCategory.eventos:
        return '📅';
    }
  }

  Color _getCategoryColor() {
    switch (story.category) {
      case VMFStoryCategory.testimonio:
        return Colors.blue;
      case VMFStoryCategory.predicacion:
        return Colors.purple;
      case VMFStoryCategory.alabanza:
        return Colors.orange;
      case VMFStoryCategory.juventud:
        return Colors.green;
      case VMFStoryCategory.matrimonio:
        return Colors.pink;
      case VMFStoryCategory.oracion:
        return Colors.cyan;
      case VMFStoryCategory.estudio:
        return Colors.indigo;
      case VMFStoryCategory.eventos:
        return Colors.amber;
    }
  }
}