import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_model.dart';
import '../providers/media_provider.dart';
import '../providers/aura_provider.dart';

class MediaPlayerScreen extends StatefulWidget {
  final MediaModel media;

  const MediaPlayerScreen({super.key, required this.media});

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MediaProvider, AuraProvider>(
      builder: (context, mediaProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0a0a0a),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0a0a0a),
                  const Color(0xFF1a1a2e),
                  auraProvider.currentAuraColor.withOpacity(0.2),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(auraProvider),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildMediaDisplay(auraProvider),
                          _buildMediaInfo(auraProvider),
                          _buildPlayerControls(mediaProvider, auraProvider),
                          _buildMediaDetails(auraProvider),
                        ],
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

  Widget _buildHeader(AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: auraProvider.currentAuraColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: auraProvider.currentAuraColor,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Reproductor VMF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: auraProvider.currentAuraColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compartiendo: ${widget.media.title}'),
                  backgroundColor: auraProvider.currentAuraColor,
                ),
              );
            },
            icon: Icon(
              Icons.share_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaDisplay(AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Media image/icon
          ClipRRect(
            borderRadius: BorderRadius.circular(140),
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                image: widget.media.type == MediaType.video || widget.media.type == MediaType.live
                    ? DecorationImage(
                        image: NetworkImage(widget.media.thumbnailUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: widget.media.type == MediaType.audio 
                    ? auraProvider.currentAuraColor.withOpacity(0.2)
                    : null,
                border: Border.all(
                  color: auraProvider.currentAuraColor.withOpacity(0.5),
                  width: 3,
                ),
              ),
              child: widget.media.type == MediaType.audio
                  ? AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 80,
                            color: auraProvider.currentAuraColor,
                          ),
                        );
                      },
                    )
                  : null,
            ),
          ),
          // Live indicator
          if (widget.media.isLive)
            Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, color: Colors.white, size: 10),
                    SizedBox(width: 6),
                    Text(
                      'EN VIVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaInfo(AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            widget.media.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: auraProvider.currentAuraColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.media.artist,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.media.categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: widget.media.categoryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.media.categoryText,
                  style: TextStyle(
                    color: widget.media.categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: auraProvider.currentAuraColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: auraProvider.currentAuraColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.media.typeText,
                  style: TextStyle(
                    color: auraProvider.currentAuraColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls(MediaProvider mediaProvider, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Progress bar (simulated)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.3, // Simulated progress
                    child: Container(
                      decoration: BoxDecoration(
                        color: auraProvider.currentAuraColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1:23', // Simulated current time
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.media.duration,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _toggleLike(mediaProvider),
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.white.withOpacity(0.7),
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Previous track
                },
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 36,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: auraProvider.currentAuraColor,
                  boxShadow: [
                    BoxShadow(
                      color: auraProvider.currentAuraColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => mediaProvider.togglePlayPause(),
                  icon: Icon(
                    mediaProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                  iconSize: 60,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Next track
                },
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 36,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Repeat/shuffle
                },
                icon: Icon(
                  Icons.repeat_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaDetails(AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: auraProvider.currentAuraColor,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.media.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Stats
          Row(
            children: [
              _buildStatBox(
                Icons.visibility_rounded,
                widget.media.formattedViews,
                'Vistas',
                auraProvider,
              ),
              const SizedBox(width: 15),
              _buildStatBox(
                Icons.favorite_rounded,
                widget.media.likes.toString(),
                'Me gusta',
                auraProvider,
              ),
              const SizedBox(width: 15),
              if (widget.media.rating > 0)
                _buildStatBox(
                  Icons.star_rounded,
                  widget.media.rating.toStringAsFixed(1),
                  'Rating',
                  auraProvider,
                ),
            ],
          ),
          if (widget.media.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: auraProvider.currentAuraColor,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.media.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: auraProvider.currentAuraColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: auraProvider.currentAuraColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: auraProvider.currentAuraColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label, AuraProvider auraProvider) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: auraProvider.currentAuraColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: auraProvider.currentAuraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: auraProvider.currentAuraColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: auraProvider.currentAuraColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLike(MediaProvider mediaProvider) {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      mediaProvider.likeMedia(widget.media.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Agregado a favoritos!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}