import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/overflow_utils.dart';
import '../../utils/error_handler.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import 'registration_controller.dart';
import 'dart:math' as math;

/// Pantalla de bienvenida profesional para el registro
class RegisterWelcomeScreen extends StatefulWidget {
  const RegisterWelcomeScreen({super.key});

  @override
  State<RegisterWelcomeScreen> createState() => _RegisterWelcomeScreenState();
}

class _RegisterWelcomeScreenState extends State<RegisterWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particlesController;
  late AnimationController _buttonController;

  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _particlesAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _particlesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particlesController,
      curve: Curves.linear,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _particlesController.repeat();
        _buttonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particlesController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Fondo con partículas animadas
              _buildAnimatedBackground(),

              // Contenido principal
              SafeArea(
                child: Padding(
                  padding: OverflowUtils.responsivePadding(context),
                  child: Column(
                    children: [
                      // Header con progreso
                      _buildHeader(controller),

                      // Contenido principal
                      Expanded(
                        child: _buildMainContent(controller),
                      ),

                      // Botones de acción
                      _buildActionButtons(controller),
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

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            const Color(0xFF0A0A0A),
            Colors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RegistrationController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de retroceso (opcional)
          Container(width: 40), // Placeholder para simetría

          // Indicador de progreso
          StepIndicators(
            totalSteps: RegistrationController.totalSteps,
            currentStep: controller.currentStep,
            activeColor: const Color(0xFFD4AF37),
            inactiveColor: Colors.white.withOpacity(0.3),
          ),

          // Coins indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.black, size: 16),
                SizedBox(width: 4),
                Text(
                  '0',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(RegistrationController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo animado con brillo
        AnimatedBuilder(
          animation: _logoAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.4 * _logoAnimation.value),
                      blurRadius: 20 * _logoAnimation.value,
                      spreadRadius: 5 * _logoAnimation.value,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: const Color(0xFFD4AF37),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'VMF',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'SWEDEN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 60),

        // Título principal animado
        AnimatedBuilder(
          animation: _textAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimation.value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - _textAnimation.value)),
                child: OverflowUtils.responsiveText(
                  '¡Bienvenido a VMF Sweden!',
                  style: TextStyle(
                    fontSize: OverflowUtils.getResponsiveFontSize(context, 32),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Subtítulo animado
        AnimatedBuilder(
          animation: _textAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimation.value * 0.9,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _textAnimation.value)),
                child: OverflowUtils.responsiveText(
                  'Tu nueva comunidad espiritual te espera',
                  style: TextStyle(
                    fontSize: OverflowUtils.getResponsiveFontSize(context, 18),
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Lista de características
        AnimatedBuilder(
          animation: _textAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimation.value * 0.8,
              child: Transform.translate(
                offset: Offset(0, 40 * (1 - _textAnimation.value)),
                child: _buildFeaturesList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Comunidad Verificada',
        'subtitle': 'Conexiones auténticas y seguras',
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'Valores Compartidos',
        'subtitle': 'Encuentra personas con tu misma fe',
      },
      {
        'icon': Icons.location_on_outlined,
        'title': 'Conexión Local',
        'subtitle': 'Conecta con la comunidad en Suecia',
      },
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: _buildFeatureItem(feature),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Icon(
            feature['icon'] as IconData,
            color: const Color(0xFFD4AF37),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                feature['subtitle'] as String,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(RegistrationController controller) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Botón principal
          ProfessionalRegisterButton(
            text: 'Comenzar mi registro',
            onPressed: () => _handleStartRegistration(controller),
            isLoading: controller.isLoading,
            loadingText: 'Iniciando...',
            icon: Icons.arrow_forward,
            showGlow: true,
          ),

          const SizedBox(height: 16),

          // Botón secundario
          SecondaryRegisterButton(
            text: '¿Ya tienes cuenta? Inicia sesión',
            onPressed: () => _handleGoToLogin(),
            icon: Icons.login,
          ),

          const SizedBox(height: 24),

          // Términos y condiciones
          OverflowUtils.responsiveText(
            'Al continuar, aceptas nuestros Términos de Servicio\ny Política de Privacidad',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  void _handleStartRegistration(RegistrationController controller) async {
    try {
      // Marcar el paso de bienvenida como completado
      controller.updateData('welcome_completed', true);

      // Avanzar al siguiente paso
      final success = await controller.nextStep();
      if (success && mounted) {
        // Navegar a la siguiente pantalla
        Navigator.pushNamed(context, '/register-gender');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Error al iniciar el registro. Inténtalo de nuevo.',
        );
      }
    }
  }

  void _handleGoToLogin() {
    Navigator.pushNamed(context, '/login');
  }
}

