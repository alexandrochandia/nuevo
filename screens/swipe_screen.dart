import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../models/swipe_action.dart';
import '../providers/user_provider.dart';
import '../providers/swipe_provider.dart';
import '../widgets/swipe_buttons.dart';
import '../widgets/comment_modal.dart';
import 'dart:math' as math;
import 'dart:ui';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  List<UserModel> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _cardEntryController;
  late AnimationController _heartAnimationController;
  late AnimationController _rejectAnimationController;
  late AnimationController _detailsController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _heartScale;
  late Animation<double> _rejectScale;
  late Animation<double> _detailsAnimation;

  // Mock current user ID
  final String _currentUserId = 'current_user_id';
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUsers();
  }

  void _initializeAnimations() {
    // Background gradient animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    // Button scale animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Card entry animation
    _cardEntryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardEntryController,
      curve: Curves.easeOutCubic,
    ));

    // Heart animation for likes
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartScale = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));

    // Reject animation
    _rejectAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rejectScale = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _rejectAnimationController,
      curve: Curves.elasticOut,
    ));

    // Details animation
    _detailsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _detailsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeOutCubic,
    ));

    // Start background animation
    _backgroundAnimationController.repeat(reverse: true);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUsers();

    if (mounted) {
      setState(() {
        _users = userProvider.users;
        _isLoading = false;
      });
      _cardEntryController.forward();
    }
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (previousIndex < _users.length) {
      final user = _users[previousIndex];
      SwipeDirection swipeDirection;

      // Trigger visual feedback based on direction
      switch (direction) {
        case CardSwiperDirection.left:
          swipeDirection = SwipeDirection.left;
          _triggerRejectAnimation();
          break;
        case CardSwiperDirection.right:
          swipeDirection = SwipeDirection.right;
          _triggerLikeAnimation();
          break;
        case CardSwiperDirection.top:
          swipeDirection = SwipeDirection.up;
          _triggerSuperLikeAnimation();
          break;
        default:
          swipeDirection = SwipeDirection.left;
      }

      _performSwipe(user, swipeDirection);
    }

    if (currentIndex != null) {
      setState(() {
        _currentIndex = currentIndex;
        _showDetails = false;
      });
      _detailsController.reverse();

      // Animate new card entry
      _cardEntryController.reset();
      _cardEntryController.forward();
    }

    return true;
  }

  void _triggerLikeAnimation() {
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });
  }

  void _triggerRejectAnimation() {
    _rejectAnimationController.forward().then((_) {
      _rejectAnimationController.reverse();
    });
  }

  void _triggerSuperLikeAnimation() {
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });
  }

  Future<void> _performSwipe(UserModel user, SwipeDirection direction) async {
    final swipeProvider = Provider.of<SwipeProvider>(context, listen: false);
    await swipeProvider.performSwipe(
      userId: _currentUserId,
      targetUserId: user.id,
      direction: direction,
    );
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
    if (_showDetails) {
      _detailsController.forward();
    } else {
      _detailsController.reverse();
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _buttonAnimationController.dispose();
    _cardEntryController.dispose();
    _heartAnimationController.dispose();
    _rejectAnimationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: Stack(
        children: [
          // Dynamic background based on current user
          _buildDynamicBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60), // Space for app bar

                // Main swipe area
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _users.isEmpty
                          ? _buildEmptyState()
                          : _buildModernSwipeArea(),
                ),

                // Modern action buttons
                _buildModernActionButtons(),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Animation overlays
          _buildAnimationOverlays(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Descubre',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFFD4AF37), size: 20),
            onPressed: () {
              // Open filters/settings
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicBackground() {
    if (_users.isEmpty || _currentIndex >= _users.length) {
      return _buildDefaultBackground();
    }

    final currentUser = _users[_currentIndex];

    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_backgroundAnimation.value * 0.5),
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A1A1A).withOpacity(0.9),
                const Color(0xFF2A2A2A).withOpacity(0.7),
                const Color(0xFF0A0A0A),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: currentUser.imageUrl.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(currentUser.imageUrl),
                      fit: BoxFit.cover,
                      opacity: 0.1,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDefaultBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_backgroundAnimation.value * 2 * math.pi),
              colors: [
                const Color(0xFF0F0F0F),
                const Color(0xFF1A1A1A).withOpacity(0.8 + 0.2 * _backgroundAnimation.value),
                const Color(0xFF2A2A2A).withOpacity(0.6 + 0.4 * _backgroundAnimation.value),
                const Color(0xFF0F0F0F),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37),
                  const Color(0xFFD4AF37).withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Encontrando conexiones especiales...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Preparando perfiles únicos para ti',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37),
                  const Color(0xFFD4AF37).withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '¡Has visto todos los perfiles!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Nuevas personas se unirán pronto.\n¡Vuelve más tarde para descubrir más conexiones!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSwipeArea() {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CardSwiper(
          controller: _swiperController,
          cardsCount: _users.length,
          onSwipe: _onSwipe,
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return _buildPremiumUserCard(_users[index], percentThresholdX.toDouble(), percentThresholdY.toDouble());
          },
          numberOfCardsDisplayed: 2,
          backCardOffset: const Offset(0, -30),
          padding: const EdgeInsets.all(0),
          allowedSwipeDirection: const AllowedSwipeDirection.all(),
          threshold: 60,
          maxAngle: 25,
          scale: 0.95,
        ),
      ),
    );
  }

  Widget _buildPremiumUserCard(UserModel user, double percentThresholdX, double percentThresholdY) {
    return GestureDetector(
      onTap: _toggleDetails,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
            if (percentThresholdX > 0.2)
              BoxShadow(
                color: Colors.green.withOpacity(0.6),
                blurRadius: 40,
                offset: const Offset(0, 0),
                spreadRadius: 2,
              ),
            if (percentThresholdX < -0.2)
              BoxShadow(
                color: Colors.red.withOpacity(0.6),
                blurRadius: 40,
                offset: const Offset(0, 0),
                spreadRadius: 2,
              ),
            if (percentThresholdY < -0.2)
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.8),
                blurRadius: 50,
                offset: const Offset(0, 0),
                spreadRadius: 3,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background image with better loading
              _buildUserImage(user),

              // Premium gradient overlay
              _buildGradientOverlay(),

              // Online status indicator
              if (user.isOnline) _buildOnlineIndicator(),

              // New user badge
              if (user.isNewUser) _buildNewUserBadge(),

              // User information
              _buildUserInfo(user),

              // Details panel
              _buildDetailsPanel(user),

              // Swipe indicators
              _buildSwipeIndicators(percentThresholdX, percentThresholdY),

              // Interactive info button
              _buildInfoButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserImage(UserModel user) {
    return Positioned.fill(
      child: user.imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF1A1A1A),
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildPlaceholderImage(user),
            )
          : _buildPlaceholderImage(user),
    );
  }

  Widget _buildPlaceholderImage(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2A2A),
            const Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: const Color(0xFFD4AF37).withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.95),
            ],
            stops: const [0.0, 0.4, 0.6, 0.85, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: Colors.white, size: 8),
            SizedBox(width: 4),
            Text(
              'En línea',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewUserBadge() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.black, size: 12),
            SizedBox(width: 4),
            Text(
              'Nuevo',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.name}, ${user.age}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFD4AF37),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  user.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              user.bio,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.4,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(UserModel user) {
    return AnimatedBuilder(
      animation: _detailsAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, (1 - _detailsAnimation.value) * 200),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detailed info
                    const Text(
                      'Sobre mí',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.bio.isNotEmpty ? user.bio : 'Esta persona aún no ha añadido una descripción.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    if (user.interests.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Intereses',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.interests.map((interest) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeIndicators(double percentThresholdX, double percentThresholdY) {
    return Stack(
      children: [
        // Like indicator (right swipe)
        if (percentThresholdX > 0.2)
          Positioned(
            top: 80,
            right: 30,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'ME GUSTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

        // Pass indicator (left swipe)
        if (percentThresholdX < -0.2)
          Positioned(
            top: 80,
            left: 30,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'PASAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

        // Super like indicator (up swipe)
        if (percentThresholdY < -0.2)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.8),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SUPER LIKE',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoButton() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: GestureDetector(
        onTap: _toggleDetails,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            _showDetails ? Icons.keyboard_arrow_down : Icons.info_outline,
            color: const Color(0xFFD4AF37),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SwipeButtons(
        onPass: () {
          if (_currentIndex < _users.length) {
            _buttonAnimationController.forward().then((_) {
              _buttonAnimationController.reverse();
            });
            _swiperController.swipe(CardSwiperDirection.left);
          }
        },
        onLike: () {
          if (_currentIndex < _users.length) {
            _buttonAnimationController.forward().then((_) {
              _buttonAnimationController.reverse();
            });
            _swiperController.swipe(CardSwiperDirection.right);
          }
        },
        onSuperLike: () {
          if (_currentIndex < _users.length) {
            _buttonAnimationController.forward().then((_) {
              _buttonAnimationController.reverse();
            });
            _swiperController.swipe(CardSwiperDirection.top);
          }
        },
        onComment: () {
          if (_currentIndex < _users.length) {
            final user = _users[_currentIndex];
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => CommentModal(
                user: user,
                onCommentSent: (comment) {
                  _performSwipe(user, SwipeDirection.right);
                  _swiperController.swipe(CardSwiperDirection.right);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAnimationOverlays() {
    return Stack(
      children: [
        // Heart animation overlay
        AnimatedBuilder(
          animation: _heartScale,
          builder: (context, child) {
            if (_heartScale.value == 0) return const SizedBox.shrink();

            return Positioned.fill(
              child: Center(
                child: Transform.scale(
                  scale: _heartScale.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.pink, Colors.red],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.8),
                          blurRadius: 40,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Reject animation overlay
        AnimatedBuilder(
          animation: _rejectScale,
          builder: (context, child) {
            if (_rejectScale.value == 0) return const SizedBox.shrink();

            return Positioned.fill(
              child: Center(
                child: Transform.scale(
                  scale: _rejectScale.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.8),
                          blurRadius: 40,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}