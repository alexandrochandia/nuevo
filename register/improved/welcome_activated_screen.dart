import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/professional_register_button.dart';
import '../../utils/error_handler.dart';
import '../../utils/overflow_utils.dart';
import 'registration_controller.dart';
import 'dart:math' as math;
import 'dart:io';
import 'dart:convert'; // Import dart:convert for base64 decoding

/// Pantalla de bienvenida activada después del registro - Versión Luxury
class WelcomeActivatedScreen extends StatefulWidget {
  final String userName;

  const WelcomeActivatedScreen({
    super.key,
    required this.userName,
  });

  @override
  State<WelcomeActivatedScreen> createState() => _WelcomeActivatedScreenState();
}

class _WelcomeActivatedScreenState extends State<WelcomeActivatedScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particlesController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _statsController;
  late AnimationController _contentController;

  late Animation<double> _mainAnimation;
  late Animation<double> _particlesAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _contentAnimation;

  // Cache for the decoded image to prevent repeated processing
  Widget? _cachedUserPhoto;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _mainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particlesController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.elasticOut),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _mainController.forward();
        _particlesController.repeat();
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _statsController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _statsController.dispose();
    _contentController.dispose();
    _cachedUserPhoto = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                _buildLuxuryBackground(),
                _buildFloatingParticles(),
                _buildMainContent(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuxuryBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            const Color(0xFF0D0D0D),
            const Color(0xFF1A1A1A),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Geometric patterns
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  painter: GeometricPatternPainter(),
                  size: Size(MediaQuery.of(context).size.width, 
                            MediaQuery.of(context).size.height),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particlesAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_particlesAnimation.value),
          size: Size(MediaQuery.of(context).size.width, 
                    MediaQuery.of(context).size.height),
        );
      },
    );
  }

  Widget _buildMainContent(RegistrationController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con estadísticas en línea
            _buildInlineStats(),

            const SizedBox(height: 24),

            // Avatar principal con foto del usuario
            _buildLuxuryUserAvatar(controller),

            const SizedBox(height: 20),

            // Contenido de bienvenida
            _buildWelcomeContent(),

            const SizedBox(height: 16),

            // Features premium
            _buildPremiumFeatures(),

            const SizedBox(height: 24),

            // Botón de acción
            _buildLuxuryActionButton(controller),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineStats() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -30 * (1 - _statsAnimation.value)),
          child: Opacity(
            opacity: _statsAnimation.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("10K+", "Miembros", Icons.people),
                _buildStatItem("24/7", "Soporte", Icons.support_agent),
                _buildStatItem("Premium", "Acceso", Icons.diamond),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1),
            const Color(0xFFD4AF37).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryUserAvatar(RegistrationController controller) {
    // Cache the user photo widget to prevent repeated processing
    if (_cachedUserPhoto == null) {
      // Obtener fotos con manejo seguro de tipos
      dynamic photosData = controller.getData('photos');

      dynamic userPhoto;
      if (photosData is List && photosData.isNotEmpty) {
        userPhoto = photosData.first;
      } else if (photosData is String && photosData.isNotEmpty) {
        userPhoto = photosData;
      } else {
        userPhoto = null;
      }

      // Build and cache the photo widget
      _cachedUserPhoto = ClipOval(
        child: userPhoto != null 
            ? _buildUserPhoto(userPhoto)
            : _buildFallbackAvatar(),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_mainAnimation, _pulseAnimation]),
      builder: (context, child) {
        // Clamp animation values to prevent overflow
        final clampedMain = _mainAnimation.value.clamp(0.0, 1.0);
        final clampedPulse = _pulseAnimation.value.clamp(0.8, 1.2);

        return Transform.scale(
          scale: clampedMain * clampedPulse,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Anillos orbitales
                for (int i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * (i + 1) * 0.5,
                        child: Container(
                          width: 200 - (i * 25),
                          height: 200 - (i * 25),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3 - (i * 0.1)),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Avatar principal con foto del usuario
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD4AF37),
                        Color(0xFFFFD700),
                        Color(0xFFD4AF37),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: _cachedUserPhoto ?? ClipOval(
                      child: _buildFallbackAvatar(),
                    ),
                  ),
                ),

                // Badge de verificación
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FF88), Color(0xFF00DD77)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF88).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserPhoto(dynamic photo) {
    try {
      // Verificar si es null primero
      if (photo == null) {
        print('Photo is null, using fallback');
        return _buildFallbackAvatar();
      }

      // Si es un File
      if (photo is File) {
        print('Photo is File: ${photo.path}');
        return Image.file(
          photo,
          fit: BoxFit.cover,
          width: 132,
          height: 132,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading File image: $error');
            return _buildFallbackAvatar();
          },
        );
      }
      // Si es una String, verificar si es base64 o ruta de archivo
      else if (photo is String && photo.isNotEmpty) {
        print('Photo is String, length: ${photo.length}');

        // Verificar si es base64 (JPEG comienza con /9j/ o otros formatos)
        if (photo.startsWith('/9j/') || 
            photo.startsWith('iVBOR') || 
            photo.startsWith('data:image') ||
            photo.length > 100) { // Likely base64 if very long
          try {
            // Eliminar el prefijo data:image si existe
            String base64String = photo;
            if (photo.startsWith('data:image')) {
              final parts = photo.split(',');
              if (parts.length > 1) {
                base64String = parts[1];
              }
            }

            // Limpiar la cadena base64 de caracteres no válidos
            base64String = base64String.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

            // Verificar que la longitud sea válida para base64
            if (base64String.length % 4 != 0) {
              // Agregar padding si es necesario
              while (base64String.length % 4 != 0) {
                base64String += '=';
              }
            }

            // Convertir base64 a bytes una sola vez
            final bytes = base64.decode(base64String);
            print('Base64 decoded successfully, bytes length: ${bytes.length}');

            return Container(
              width: 132,
              height: 132,
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: 132,
                height: 132,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true, // Prevents flashing during rebuilds
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading base64 image: $error');
                  return _buildFallbackAvatar();
                },
              ),
            );
          } catch (e) {
            print('Error decoding base64: $e');
            return _buildFallbackAvatar();
          }
        } else {
          // Intentar como ruta de archivo solo si parece una ruta válida
          if (photo.startsWith('/') || photo.contains('.')) {
            print('Trying as file path: $photo');
            final file = File(photo);
            if (file.existsSync()) {
              return Image.file(
                file,
                fit: BoxFit.cover,
                width: 132,
                height: 132,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading String path image: $error');
                  return _buildFallbackAvatar();
                },
              );
            } else {
              print('File does not exist: $photo');
              return _buildFallbackAvatar();
            }
          } else {
            print('String does not look like a valid path or base64, using fallback');
            return _buildFallbackAvatar();
          }
        }
      }
      // Si no es ninguno de los tipos esperados
      else {
        print('Photo is not a valid type: ${photo.runtimeType}, using fallback');
        return _buildFallbackAvatar();
      }
    } catch (e) {
      print('General error in _buildUserPhoto: $e');
      // En caso de cualquier error, mostrar el avatar por defecto
      return _buildFallbackAvatar();
    }
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.8),
            const Color(0xFFFFD700).withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.userName.isNotEmpty 
              ? widget.userName.substring(0, 1).toUpperCase()
              : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _contentAnimation.value)),
            child: Column(
              children: [
                // Saludo personalizado
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  ).createShader(bounds),
                  child: Text(
                    '¡Bienvenido, ${widget.userName}!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Tu cuenta Premium ha sido activada',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Ahora formas parte de nuestra exclusiva comunidad espiritual con acceso completo a todas las funcionalidades premium.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumFeatures() {
    final features = [
      {'icon': Icons.star, 'title': 'Acceso Premium', 'desc': 'Funciones exclusivas'},
      {'icon': Icons.people, 'title': 'Comunidad VIP', 'desc': 'Conecta con líderes'},
      {'icon': Icons.live_tv, 'title': 'Contenido Live', 'desc': 'Eventos en vivo'},
      {'icon': Icons.support_agent, 'title': 'Soporte 24/7', 'desc': 'Asistencia prioritaria'},
    ];

    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        // Clamp animation value to prevent overflow
        final clampedValue = _contentAnimation.value.clamp(0.0, 1.0);

        return Opacity(
          opacity: clampedValue * 0.9,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Beneficios Activados',
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Use Wrap instead of GridView to prevent overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((feature) {
                    return Container(
                      width: (MediaQuery.of(context).size.width - 80) / 2,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37).withOpacity(0.1),
                            const Color(0xFFD4AF37).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            feature['icon'] as IconData,
                            color: const Color(0xFFD4AF37),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  feature['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  feature['desc'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLuxuryActionButton(RegistrationController controller) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _contentAnimation.value,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => _handleStartExperience(controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (controller.isLoading)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.rocket_launch,
                              color: Colors.black,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Comenzar Experiencia',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _handleStartExperience(controller),
                child: Text(
                  'Explorar la comunidad espiritual →',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleStartExperience(RegistrationController controller) async {
    if (controller.isLoading) return;

    try {
      controller.setLoading(true);

      // Pequeño delay para efecto visual
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        // Navigate to home screen
        context.go('/home');
      }
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        // Fallback to home
        context.go('/home');
      }
    } finally {
      if (mounted) {
        controller.setLoading(false);
      }
    }
  }
}

// Painter para patrones geométricos de fondo
class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Crear patrones geométricos sutiles
    for (int i = 0; i < 6; i++) {
      final radius = 50.0 + (i * 30);
      path.addOval(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter para partículas flotantes
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Seed fijo para consistencia

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + (random.nextDouble() * 3);
      final opacity = (0.1 + (random.nextDouble() * 0.3)) * 
                     (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi + i));

      paint.color = const Color(0xFFD4AF37).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}