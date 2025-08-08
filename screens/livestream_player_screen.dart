import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/livestream_provider.dart';
import '../providers/aura_provider.dart';
import '../models/livestream_model.dart';
import '../utils/livestream_utils.dart';
import 'package:intl/intl.dart';

class LiveStreamPlayerScreen extends StatefulWidget {
  final LiveStreamModel stream;

  const LiveStreamPlayerScreen({
    super.key,
    required this.stream,
  });

  @override
  State<LiveStreamPlayerScreen> createState() => _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState extends State<LiveStreamPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _liveIndicatorController;
  late Animation<double> _overlayAnimation;
  late Animation<double> _liveIndicatorAnimation;
  
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();
  
  bool _showOverlay = true;
  bool _showComments = false;
  bool _showDonations = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _liveIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));
    
    _liveIndicatorAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _liveIndicatorController,
      curve: Curves.easeInOut,
    ));
    
    _overlayController.forward();
    
    if (widget.stream.isLive) {
      _liveIndicatorController.repeat(reverse: true);
    }
    
    // Auto-hide overlay after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideOverlayMethod();
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _liveIndicatorController.dispose();
    _commentController.dispose();
    _commentsScrollController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_showOverlay) {
      _hideOverlayMethod();
    } else {
      _showOverlayMethod();
    }
  }

  void _showOverlayMethod() {
    setState(() {
      _showOverlay = true;
    });
    _overlayController.forward();
    
    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showOverlay) {
        _hideOverlayMethod();
      }
    });
  }

  void _hideOverlayMethod() {
    _overlayController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LiveStreamProvider, AuraProvider>(
      builder: (context, livestreamProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: WillPopScope(
            onWillPop: () async {
              if (_isFullscreen) {
                _toggleFullscreen();
                return false;
              }
              return true;
            },
            child: Stack(
              children: [
                // Video player area
                _buildVideoPlayer(auraProvider),
                
                // Overlay controls
                if (_showOverlay)
                  AnimatedBuilder(
                    animation: _overlayAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _overlayAnimation.value,
                        child: _buildOverlayControls(livestreamProvider, auraProvider),
                      );
                    },
                  ),
                
                // Comments panel
                if (_showComments && !_isFullscreen)
                  _buildCommentsPanel(livestreamProvider, auraProvider),
                
                // Donations panel
                if (_showDonations && !_isFullscreen)
                  _buildDonationsPanel(livestreamProvider, auraProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(AuraProvider auraProvider) {
    return GestureDetector(
      onTap: _toggleOverlay,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            // Video placeholder (in real app, this would be the actual video player)
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.stream.thumbnailUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=450&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.stream.isLive) ...[
                          AnimatedBuilder(
                            animation: _liveIndicatorAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 80 * _liveIndicatorAnimation.value,
                                height: 80 * _liveIndicatorAnimation.value,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'EN VIVO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Icon(
                            widget.stream.hasEnded ? Icons.replay : Icons.schedule,
                            color: Colors.white,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.stream.hasEnded 
                                ? 'Transmisión finalizada' 
                                : 'Transmisión programada',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          'Video simulado - En producción se integraría reproductor real',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Live viewer count overlay
            if (widget.stream.isLive && !_isFullscreen)
              Positioned(
                top: 50,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.stream.viewerCount} espectadores',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayControls(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top controls
            _buildTopControls(auraProvider),
            
            const Spacer(),
            
            // Bottom controls
            if (!_isFullscreen)
              _buildBottomControls(livestreamProvider, auraProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              if (_isFullscreen) {
                _toggleFullscreen();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const Spacer(),
          
          // Stream info
          if (!_isFullscreen)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.stream.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.stream.pastor ?? 'Pastor no especificado',
                    style: TextStyle(
                      color: auraProvider.currentAuraColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          
          const Spacer(),
          
          // Fullscreen button
          IconButton(
            onPressed: _toggleFullscreen,
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stream description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: auraProvider.currentAuraColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      LiveStreamUtils.getTypeEmoji(widget.stream.type),
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LiveStreamUtils.getTypeDisplayName(widget.stream.type),
                      style: TextStyle(
                        color: auraProvider.currentAuraColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: LiveStreamUtils.getStatusColor(widget.stream.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        LiveStreamUtils.getStatusDisplayName(widget.stream.status),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.stream.description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                Icons.chat_bubble_outline,
                'Comentarios',
                _showComments,
                () {
                  setState(() {
                    _showComments = !_showComments;
                    if (_showComments) _showDonations = false;
                  });
                },
                auraProvider.currentAuraColor,
              ),
              
              if (widget.stream.allowDonations ?? false)
                _buildControlButton(
                  Icons.favorite_outline,
                  'Donar',
                  _showDonations,
                  () {
                    setState(() {
                      _showDonations = !_showDonations;
                      if (_showDonations) _showComments = false;
                    });
                  },
                  Colors.pink,
                ),
              
              _buildControlButton(
                Icons.share_outlined,
                'Compartir',
                false,
                () {
                  _shareStream();
                },
                Colors.blue,
              ),
              
              _buildControlButton(
                Icons.more_vert,
                'Más',
                false,
                () {
                  _showMoreOptions(livestreamProvider, auraProvider);
                },
                Colors.grey[400]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : Colors.white24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? color : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsPanel(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: auraProvider.currentAuraColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: auraProvider.currentAuraColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Comentarios en vivo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showComments = false;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white12),
              
              // Comments list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: livestreamProvider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = livestreamProvider.comments[index];
                    return _buildCommentItem(comment, auraProvider);
                  },
                ),
              ),
              
              // Comment input
              if (widget.stream.allowComments ?? false)
                _buildCommentInput(livestreamProvider, auraProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(LiveStreamComment comment, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: comment.isPinned 
            ? auraProvider.currentAuraColor.withOpacity(0.1)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: comment.isPinned 
            ? Border.all(color: auraProvider.currentAuraColor.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(comment.userAvatar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.userName,
                  style: TextStyle(
                    color: comment.isFromPastor 
                        ? auraProvider.currentAuraColor 
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (comment.isFromPastor)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: auraProvider.currentAuraColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PASTOR',
                    style: TextStyle(
                      color: auraProvider.currentAuraColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (comment.isPinned)
                Icon(
                  Icons.push_pin,
                  color: auraProvider.currentAuraColor,
                  size: 12,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.message,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                DateFormat('HH:mm').format(comment.timestamp),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.read<LiveStreamProvider>().likeComment(comment.id),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      color: Colors.grey[500],
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.likes.toString(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: auraProvider.currentAuraColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _sendComment(livestreamProvider),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendComment(livestreamProvider),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: auraProvider.currentAuraColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsPanel(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.pink.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.pink,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Apoya la obra de Dios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showDonations = false;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white12),
              
              // Donation content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Quick donation amounts
                      Text(
                        'Cantidades sugeridas (SEK)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [100, 200, 500, 1000].map((amount) {
                          return GestureDetector(
                            onTap: () => _makeDonation(amount.toDouble(), 'SEK'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.pink.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${amount} kr',
                                style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Recent donations
                      Text(
                        'Donaciones recientes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...livestreamProvider.donations.map((donation) => 
                        _buildDonationItem(donation)
                      ).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDonationItem(LiveStreamDonation donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.pink,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      donation.isAnonymous ? 'Anónimo' : donation.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      donation.formattedAmount,
                      style: TextStyle(
                        color: Colors.pink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (donation.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    donation.message,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment(LiveStreamProvider livestreamProvider) {
    if (_commentController.text.trim().isNotEmpty) {
      livestreamProvider.addComment(_commentController.text.trim());
      _commentController.clear();
      
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        _commentsScrollController.animateTo(
          _commentsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _makeDonation(double amount, String currency) {
    // In a real app, this would integrate with payment processing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Confirmar Donación',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Deseas donar ${amount.toStringAsFixed(0)} $currency a la obra de VMF Sweden?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LiveStreamProvider>().makeDonation(
                amount, 
                currency, 
                'Donación durante transmisión en vivo'
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡Gracias por tu donación de ${amount.toStringAsFixed(0)} $currency!'),
                  backgroundColor: Colors.pink,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: Text('Donar'),
          ),
        ],
      ),
    );
  }

  void _shareStream() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de compartir próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showMoreOptions(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('Reportar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: auraProvider.currentAuraColor),
              title: Text('Información', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Show stream info
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}