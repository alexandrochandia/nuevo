import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/vmf_connect_controller.dart';
import '../models/vmf_post_model.dart';

class VMFVideoCard extends StatefulWidget {
  final VMFPostModel post;
  final VMFConnectController controller;
  final bool isCurrentPage;

  const VMFVideoCard({
    super.key,
    required this.post,
    required this.controller,
    required this.isCurrentPage,
  });

  @override
  State<VMFVideoCard> createState() => _VMFVideoCardState();
}

class _VMFVideoCardState extends State<VMFVideoCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrentPage) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(VMFVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _initializeVideo();
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      _pauseVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.network(widget.post.videoUrl);
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        
        _videoController!.setLooping(true);
        _playVideo();
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _playVideo() {
    if (_videoController != null && _isVideoInitialized) {
      _videoController!.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _pauseVideo() {
    if (_videoController != null && _isVideoInitialized) {
      _videoController!.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video player o thumbnail
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: _buildVideoContent(),
            ),
          ),
          
          // Overlay con información del post
          _buildPostOverlay(),
          
          // Controles laterales (like, comment, share)
          _buildSideControls(),
          
          // Indicador de play/pause
          if (!_isPlaying && _isVideoInitialized)
            const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 80,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isVideoInitialized && _videoController != null) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else {
      // Mostrar thumbnail mientras carga
      return CachedNetworkImage(
        imageUrl: widget.post.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPostOverlay() {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del usuario
          Row(
            children: [
              // Avatar del usuario
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.post.userAvatar.isNotEmpty
                    ? CachedNetworkImageProvider(widget.post.userAvatar)
                    : null,
                backgroundColor: const Color(0xFFD4AF37),
                child: widget.post.userAvatar.isEmpty
                    ? Text(
                        widget.post.username.isNotEmpty
                            ? widget.post.username[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // Nombre de usuario y tipo de post
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${widget.post.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.post.type.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.type.displayName,
                          style: TextStyle(
                            color: Color(int.parse(
                                widget.post.type.color.replaceAll('#', '0xFF'))),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Descripción del post
          if (widget.post.description.isNotEmpty)
            Text(
              widget.post.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 8),
          
          // Hashtags
          if (widget.post.hashtags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: widget.post.hashtags.take(3).map((hashtag) {
                return Text(
                  '#$hashtag',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: 8),
          
          // Música (si existe)
          if (widget.post.musicTitle != null)
            Row(
              children: [
                const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.post.musicTitle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          // Botón de like
          _buildControlButton(
            icon: widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
            count: widget.post.likesCount,
            color: widget.post.isLiked ? Colors.red : Colors.white,
            onTap: () => widget.controller.toggleLike(widget.post.id),
          ),
          
          const SizedBox(height: 20),
          
          // Botón de comentarios
          _buildControlButton(
            icon: Icons.chat_bubble_outline,
            count: widget.post.commentsCount,
            color: Colors.white,
            onTap: () => widget.controller.openComments(widget.post),
          ),
          
          const SizedBox(height: 20),
          
          // Botón de compartir
          _buildControlButton(
            icon: Icons.share_outlined,
            count: widget.post.sharesCount,
            color: Colors.white,
            onTap: () => widget.controller.sharePost(widget.post),
          ),
          
          const SizedBox(height: 20),
          
          // Botón de más opciones
          _buildControlButton(
            icon: Icons.more_vert,
            count: null,
            color: Colors.white,
            onTap: () => _showMoreOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required int? count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          if (count != null && count > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatCount(count),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }

  void _showMoreOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Opciones
            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.white),
              title: const Text('Guardar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.snackbar('Guardado', 'Post guardado en favoritos');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.white),
              title: const Text('Reportar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.snackbar('Reportado', 'Contenido reportado para revisión');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Bloquear usuario', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                Get.snackbar('Bloqueado', 'Usuario bloqueado');
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
