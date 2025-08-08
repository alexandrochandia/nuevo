
import 'package:flutter/material.dart';
import '../models/spiritual_post_model.dart';
import '../utils/overflow_utils.dart';

class SpiritualPostCard extends StatelessWidget {
  final SpiritualPostModel post;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onComment;

  const SpiritualPostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
    required this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post
          _buildPostHeader(),
          
          // Contenido del post
          _buildPostContent(),
          
          // Versículo bíblico si existe
          if (post.bibleVerse != null) _buildBibleVerse(),
          
          // Media si existe
          if (post.mediaUrls.isNotEmpty) _buildMediaSection(),
          
          // Tags
          if (post.tags.isNotEmpty) _buildTags(),
          
          // Estadísticas y acciones
          _buildPostActions(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius: 24,
            backgroundImage: post.userAvatar != null
                ? NetworkImage(post.userAvatar!)
                : null,
            backgroundColor: const Color(0xFF6C63FF),
            child: post.userAvatar == null
                ? Text(
                    post.userName.isNotEmpty 
                        ? post.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (post.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF6C63FF),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _getPostTypeIcon(),
                    const SizedBox(width: 4),
                    Text(
                      _getPostTypeText(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(post.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botón de opciones
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[400],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (post.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[400],
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  post.location!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBibleVerse() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                color: const Color(0xFF6C63FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Versículo Bíblico',
                style: TextStyle(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${post.bibleVerse}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          if (post.bibleReference != null) ...[
            const SizedBox(height: 8),
            Text(
              post.bibleReference!,
              style: TextStyle(
                color: const Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.mediaUrls.length,
        itemBuilder: (context, index) {
          final mediaUrl = post.mediaUrls[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[800],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: post.tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
              ),
            ),
            child: Text(
              '#$tag',
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Estadísticas
          Row(
            children: [
              Text(
                '${post.likesCount} likes',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${post.commentsCount} comentarios',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${post.sharesCount} compartidas',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: 'Me gusta',
                color: post.isLiked ? Colors.red : Colors.grey[400]!,
                onTap: onLike,
              ),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: 'Comentar',
                color: Colors.grey[400]!,
                onTap: onComment,
              ),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Compartir',
                color: Colors.grey[400]!,
                onTap: onShare,
              ),
              _buildActionButton(
                icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                label: 'Guardar',
                color: post.isBookmarked ? const Color(0xFF6C63FF) : Colors.grey[400]!,
                onTap: onBookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPostTypeIcon() {
    switch (post.postType) {
      case 'verse':
        return const Text('📖', style: TextStyle(fontSize: 12));
      case 'prayer':
        return const Text('🙏', style: TextStyle(fontSize: 12));
      case 'testimony':
        return const Text('✨', style: TextStyle(fontSize: 12));
      case 'reflection':
        return const Text('💭', style: TextStyle(fontSize: 12));
      case 'announcement':
        return const Text('📢', style: TextStyle(fontSize: 12));
      case 'music':
        return const Text('🎵', style: TextStyle(fontSize: 12));
      default:
        return const Text('📝', style: TextStyle(fontSize: 12));
    }
  }

  String _getPostTypeText() {
    switch (post.postType) {
      case 'verse':
        return 'Versículo';
      case 'prayer':
        return 'Oración';
      case 'testimony':
        return 'Testimonio';
      case 'reflection':
        return 'Reflexión';
      case 'announcement':
        return 'Anuncio';
      case 'music':
        return 'Música';
      default:
        return 'Post';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
