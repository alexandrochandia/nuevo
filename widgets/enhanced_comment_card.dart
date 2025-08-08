
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/comment_model.dart';
import '../providers/comments_provider.dart';
import '../utils/glow_styles.dart';

class EnhancedCommentCard extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onReply;

  const EnhancedCommentCard({
    Key? key,
    required this.comment,
    this.onReply,
  }) : super(key: key);

  @override
  State<EnhancedCommentCard> createState() => _EnhancedCommentCardState();
}

class _EnhancedCommentCardState extends State<EnhancedCommentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainComment(),
          if (widget.comment.replies != null && widget.comment.replies!.isNotEmpty)
            _buildRepliesSection(),
        ],
      ),
    );
  }

  Widget _buildMainComment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentHeader(),
          const SizedBox(height: 8),
          _buildCommentContent(),
          const SizedBox(height: 8),
          _buildCommentActions(),
        ],
      ),
    );
  }

  Widget _buildCommentHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: GlowStyles.avatarGlow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: widget.comment.userAvatar,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, size: 20),
              ),
              errorWidget: (context, url, error) => Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.comment.isVerified) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                _formatTimeAgo(widget.comment.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentContent() {
    return Text(
      widget.comment.content,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  Widget _buildCommentActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildActionButton(
              icon: widget.comment.isLiked ? Icons.favorite : Icons.favorite_border,
              label: widget.comment.likesCount.toString(),
              color: widget.comment.isLiked ? Colors.red : Colors.white70,
              onTap: () => _handleLike(),
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              icon: Icons.reply,
              label: 'Responder',
              color: Colors.white70,
              onTap: widget.onReply,
            ),
          ],
        ),
        if (widget.comment.repliesCount > 0)
          GestureDetector(
            onTap: () => setState(() => _showReplies = !_showReplies),
            child: Text(
              _showReplies ? 'Ocultar respuestas' : '${widget.comment.repliesCount} respuestas',
              style: TextStyle(
                color: Colors.blue.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
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
          );
        },
      ),
    );
  }

  Widget _buildRepliesSection() {
    if (!_showReplies || widget.comment.replies == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 32, top: 8),
      child: Column(
        children: widget.comment.replies!
            .map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EnhancedCommentCard(comment: reply),
                ))
            .toList(),
      ),
    );
  }

  void _handleLike() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    context.read<CommentsProvider>().likeComment(widget.comment.id);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}
