
import 'package:flutter/material.dart';

class SwipeButtons extends StatefulWidget {
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;
  final VoidCallback onComment;

  const SwipeButtons({
    super.key,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    required this.onComment,
  });

  @override
  State<SwipeButtons> createState() => _SwipeButtonsState();
}

class _SwipeButtonsState extends State<SwipeButtons>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _glowAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(4, (index) => 
      AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      )
    );

    _scaleAnimations = _controllers.map((controller) =>
      Tween<double>(begin: 1.0, end: 0.9).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      )
    ).toList();

    _glowAnimations = _controllers.map((controller) =>
      Tween<double>(begin: 0.3, end: 0.8).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      )
    ).toList();
  }

  void _animateButton(int index, VoidCallback callback) {
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
      callback();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _buildLuxuryActionButton(
            index: 0,
            icon: Icons.close,
            color: Colors.red,
            size: 60,
            onPressed: () => _animateButton(0, widget.onPass),
            label: 'Pass',
          ),
          
          // Comment Button
          _buildLuxuryActionButton(
            index: 1,
            icon: Icons.chat_bubble_outline,
            color: const Color(0xFF64B5F6),
            size: 50,
            onPressed: () => _animateButton(1, widget.onComment),
            label: 'Message',
          ),
          
          // Like Button (Main)
          _buildLuxuryActionButton(
            index: 2,
            icon: Icons.favorite,
            color: Colors.pink,
            size: 70,
            onPressed: () => _animateButton(2, widget.onLike),
            label: 'Like',
            isMain: true,
          ),
          
          // Super Like Button
          _buildLuxuryActionButton(
            index: 3,
            icon: Icons.star,
            color: const Color(0xFFD4AF37),
            size: 50,
            onPressed: () => _animateButton(3, widget.onSuperLike),
            label: 'Super',
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryActionButton({
    required int index,
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onPressed,
    required String label,
    bool isMain = false,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimations[index], _glowAnimations[index]]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _controllers[index].forward(),
          onTapUp: (_) => _controllers[index].reverse(),
          onTapCancel: () => _controllers[index].reverse(),
          onTap: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(_glowAnimations[index].value),
                        blurRadius: isMain ? 30 : 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: color.withOpacity(_glowAnimations[index].value * 0.6),
                        blurRadius: isMain ? 50 : 30,
                        offset: const Offset(0, 15),
                      ),
                      if (isMain)
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 80,
                          offset: const Offset(0, 20),
                        ),
                      // Inner shadow for depth
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Icon with enhanced shadow
                      Center(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: size * 0.45,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Enhanced label with glow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
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
}
