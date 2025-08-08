import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/vmf_story_model.dart';
import '../providers/vmf_stories_provider.dart';
import '../providers/aura_provider.dart';

class VMFStoryViewerScreen extends StatefulWidget {
  final List<VMFStoryModel> stories;
  final int initialIndex;

  const VMFStoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<VMFStoryViewerScreen> createState() => _VMFStoryViewerScreenState();
}

class _VMFStoryViewerScreenState extends State<VMFStoryViewerScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _likeController;
  
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Story duration
    );
    
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _initializeCurrentStory();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressController.dispose();
    _likeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeCurrentStory() {
    final story = widget.stories[_currentIndex];
    
    // Add view to current story
    context.read<VMFStoriesProvider>().addView(story.id, 'current_user');
    
    // Initialize video if it's a video story
    if (story.type == VMFStoryType.video && story.content.isNotEmpty) {
      _initializeVideo(story.content);
    } else {
      _isVideoInitialized = false;
      _progressController.reset();
      _progressController.forward();
    }
  }

  void _initializeVideo(String videoUrl) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    
    _videoController!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController!.play();
        _progressController.reset();
        _progressController.forward();
      }
    }).catchError((error) {
      print('Error initializing video: $error');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
        _progressController.reset();
        _progressController.forward();
      }
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _currentIndex++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _toggleLike() {
    if (!_isLikeAnimating) {
      setState(() {
        _isLikeAnimating = true;
      });
      
      _likeController.forward().then((_) {
        _likeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isLikeAnimating = false;
            });
          }
        });
      });
      
      final story = widget.stories[_currentIndex];
      context.read<VMFStoriesProvider>().toggleLike(story.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.stories.length,
          onPageChanged: (index) {
            _currentIndex = index;
            _progressController.reset();
            _initializeCurrentStory();
          },
          itemBuilder: (context, index) {
            final story = widget.stories[index];
            return _buildStoryPage(story);
          },
        ),
      ),
    );
  }

  Widget _buildStoryPage(VMFStoryModel story) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;
        
        return GestureDetector(
          onTapUp: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth / 2) {
              _previousStory();
            } else {
              _nextStory();
            }
          },
          onDoubleTap: _toggleLike,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background content
              _buildStoryContent(story),
              
              // Progress bar
              _buildProgressBar(auraColor),
              
              // Top overlay with user info
              _buildTopOverlay(story, auraColor),
              
              // Bottom overlay with story info
              _buildBottomOverlay(story, auraColor),
              
              // Like animation
              if (_isLikeAnimating)
                _buildLikeAnimation(),
              
              // Navigation hints
              _buildNavigationHints(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryContent(VMFStoryModel story) {
    if (story.type == VMFStoryType.video && _isVideoInitialized && _videoController != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else if (story.type == VMFStoryType.image && story.content.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: story.content,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildTextStory(story),
      );
    } else {
      return _buildTextStory(story);
    }
  }

  Widget _buildTextStory(VMFStoryModel story) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(story.category),
            _getCategoryColor(story.category).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getCategoryIcon(story.category),
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              if (story.description?.isNotEmpty == true)
                Text(
                  story.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color auraColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(auraColor),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopOverlay(VMFStoryModel story, Color auraColor) {
    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // User avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: auraColor, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: story.userProfileImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[600],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[600],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      story.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (story.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  _getTimeAgo(story.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: auraColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(VMFStoryModel story, Color auraColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Story info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (story.description?.isNotEmpty == true)
                    Text(
                      story.description!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  if (story.hashtags.isNotEmpty)
                    Text(
                      story.hashtags.join(' '),
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            
            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like button
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.2).animate(_likeController),
                  child: IconButton(
                    onPressed: _toggleLike,
                    icon: Icon(
                      story.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: story.isLiked ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                Text(
                  '${story.likes}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Views count
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility,
                      color: auraColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${story.views}',
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeAnimation() {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.5).animate(_likeController),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_likeController),
          child: const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 100,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationHints() {
    return Positioned.fill(
      child: Row(
        children: [
          // Left tap area (previous)
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white24,
                  size: 40,
                ),
              ),
            ),
          ),
          // Right tap area (next)
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white24,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  String _getCategoryIcon(VMFStoryCategory category) {
    switch (category) {
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

  Color _getCategoryColor(VMFStoryCategory category) {
    switch (category) {
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