import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import '../../utils/error_handler.dart';
import '../../utils/overflow_utils.dart';
import 'registration_controller.dart';
import 'dart:math' as math;

/// Pantalla profesional para selección de género en el registro
class RegisterGenderScreen extends StatefulWidget {
  const RegisterGenderScreen({super.key});

  @override
  State<RegisterGenderScreen> createState() => _RegisterGenderScreenState();
}

class _RegisterGenderScreenState extends State<RegisterGenderScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _selectionController;

  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _selectionAnimation;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _loadExistingData();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _selectionAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });
  }

  void _loadExistingData() {
    final controller = context.read<RegistrationController>();
    final existingGender = controller.getData<String>('gender');
    if (existingGender != null) {
      setState(() {
        _selectedGender = existingGender;
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Padding(
              padding: OverflowUtils.responsivePadding(context),
              child: Column(
                children: [
                  // Header animado
                  _buildAnimatedHeader(controller),

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
        );
      },
    );
  }

  Widget _buildAnimatedHeader(RegistrationController controller) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _headerAnimation.value,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - _headerAnimation.value)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spacer en lugar de botón atrás
                  const SizedBox(width: 48),

                  // Progreso
                  ProfessionalProgressIndicator(
                    currentStep: controller.currentStep + 1,
                    totalSteps: RegistrationController.totalSteps,
                    progress: controller.progress,
                    size: 60,
                  ),

                  // Coins
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${(controller.progress * 50).round()}',
                          style: const TextStyle(
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(RegistrationController controller) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _contentAnimation.value)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Título
                  OverflowUtils.responsiveText(
                    '¿Cuál es tu género?',
                    style: TextStyle(
                      fontSize: OverflowUtils.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Descripción
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OverflowUtils.responsiveText(
                      'Esto nos ayuda a personalizar tu experiencia y crear conexiones espirituales más apropiadas.',
                      style: TextStyle(
                        fontSize: OverflowUtils.getResponsiveFontSize(context, 12),
                        color: Colors.white.withOpacity(0.7),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Opciones de género
                  _buildGenderOptions(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildGenderOption(
              'male',
              'Hombre',
              'assets/images/2.png', // imageBackPath
              'assets/images/4.png', // imageFrontPath
              const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildGenderOption(
              'female',
              'Mujer',
              'assets/images/3.png', // imageBackPath
              'assets/images/5.png', // imageFrontPath
              const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
      String id,
      String label,
      String imageBackPath,
      String imageFrontPath,
      Color glowColor,
      ) {
    final isSelected = _selectedGender == id;

    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _selectionAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => _handleGenderSelection(id),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 160,
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : Colors.white.withOpacity(0.2),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular gender option with glow effect
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFD4AF37).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.3),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ] : [],
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : Colors.grey.withOpacity(0.5),
                        width: isSelected ? 3 : 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        isSelected ? imageFrontPath : imageBackPath,
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: ${isSelected ? imageFrontPath : imageBackPath}');
                          // Fallback a iconos si las imágenes no están disponibles
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD4AF37).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              id == 'male' ? Icons.male : Icons.female,
                              size: 60,
                              color: isSelected
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white.withOpacity(0.6),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Título
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Indicador de selección
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check,
                        color: accentColor,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(RegistrationController controller) {
    final canContinue = _selectedGender != null;

    return Column(
      children: [
        // Información de privacidad
        if (_selectedGender != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu información está protegida y será utilizada solo para mejorar tu experiencia en la plataforma.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Botón principal
        ProfessionalRegisterButton(
          text: 'Continuar',
          onPressed: canContinue ? () => _handleNext(controller) : null,
          isEnabled: canContinue,
          isLoading: controller.isLoading,
          loadingText: 'Guardando...',
          trailingIcon: Icons.arrow_forward,
          showGlow: canContinue,
        ),

        const SizedBox(height: 16),


      ],
    );
  }

  void _handleGenderSelection(String genderId) {
    setState(() {
      _selectedGender = genderId;
    });

    // Actualizar datos en el controller
    final controller = context.read<RegistrationController>();
    controller.updateData('gender', genderId);

    // Animar selección
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });

    // Feedback háptico sutil
    // HapticFeedback.selectionClick();
  }

  void _handleNext(RegistrationController controller) async {
    if (_selectedGender == null) return;

    try {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Género seleccionado: $_selectedGender'),
          backgroundColor: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 1),
        ),
      );

      // Simple direct navigation
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.go('/register-name');
      }
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        // Fallback navigation
        Navigator.of(context).pushReplacementNamed('/register-name');
      }
    }
  }

  void _handleGoBack(RegistrationController controller) {
    if (controller.canGoBack) {
      controller.previousStep();
      Navigator.pop(context);
    }
  }
  // Color de acento para la interfaz
  Color get accentColor => const Color(0xFF4A90E2);
}