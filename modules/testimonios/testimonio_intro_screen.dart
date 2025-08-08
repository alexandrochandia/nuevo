import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'testimonio_dashboard.dart';
import 'dart:async';

class TestimonioIntroScreen extends StatefulWidget {
  const TestimonioIntroScreen({super.key});

  @override
  State<TestimonioIntroScreen> createState() => _TestimonioIntroScreenState();
}

class _TestimonioIntroScreenState extends State<TestimonioIntroScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  late AnimationController _textAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeAnimations();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/videos/testimonio.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.setVolume(0.0); // Silenciar el video
          _controller?.setLooping(true); // Asegurar loop
          _controller?.play();

          // Listener para reiniciar cuando termine
          _controller?.addListener(_videoListener);

          // Timer para verificar periódicamente
          _startVideoChecker();
        }
      }).catchError((error) {
        print('Error inicializando video: $error');
      });
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      if (_controller!.value.position >= _controller!.value.duration) {
        // Si llegó al final, reiniciar
        _controller!.seekTo(Duration.zero);
        _controller!.play();
      }
    }
  }

  void _startVideoChecker() {
    // Verificar cada 5 segundos que el video siga reproduciéndose
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_controller != null && _controller!.value.isInitialized) {
        if (!_controller!.value.isPlaying) {
          // Si no se está reproduciendo, reiniciar
          _controller!.play();
        }
      }
    });
  }

  void _initializeAnimations() {
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.linear,
    ));

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textAnimationController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _buttonAnimationController.forward();
      }
    });

    // Repeat shimmer effect
    _textAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _textAnimationController.repeat();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _enterTestimonios() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const TestimonioDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _buildShimmerText(String text, double fontSize) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFFFD700), // Gold
                Color(0xFFFFF700), // Bright gold
                Color(0xFFFFE55C), // Light gold
                Color(0xFFFFF700), // Bright gold
                Color(0xFFFFD700), // Gold
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              transform: GradientRotation(_shimmerAnimation.value),
            ).createShader(bounds);
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.7),
                ),
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 20,
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_buttonFadeAnimation, _buttonScaleAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _buttonFadeAnimation.value,
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: GestureDetector(
              onTap: _enterTestimonios,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA500),
                      Color(0xFFFFD700),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.play,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ENTRAR',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Background
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1a1a1a),
                    Color(0xFF2d2d2d),
                    Color(0xFF1a1a1a),
                  ],
                ),
              ),
            ),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(flex: 2),

                  // Premium Title
                  AnimatedBuilder(
                    animation: Listenable.merge([_textFadeAnimation, _textSlideAnimation]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Column(
                            children: [
                              _buildShimmerText('BIENVENIDOS', 32),
                              const SizedBox(height: 8),
                              _buildShimmerText('A TESTIMONIOS', 28),
                              const SizedBox(height: 16),
                              Container(
                                height: 3,
                                width: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFFFD700),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Enter Button
                  _buildPremiumButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
