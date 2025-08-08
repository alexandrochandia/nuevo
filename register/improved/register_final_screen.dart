
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import '../../utils/error_handler.dart';
import '../../utils/overflow_utils.dart';
import 'registration_controller.dart';
import 'dart:math' as math;

/// Pantalla final del registro con verificación y confirmación
class RegisterFinalScreen extends StatefulWidget {
  const RegisterFinalScreen({super.key});

  @override
  State<RegisterFinalScreen> createState() => _RegisterFinalScreenState();
}

class _RegisterFinalScreenState extends State<RegisterFinalScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _processingController;
  late AnimationController _completedController;

  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _processingAnimation;
  late Animation<double> _completedAnimation;

  bool _isProcessing = false;
  bool _isCompleted = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
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

    _processingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _completedController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _processingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processingController,
      curve: Curves.easeInOut,
    ));

    _completedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completedController,
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

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _processingController.dispose();
    _completedController.dispose();
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
                  // Botón de retroceso
                  IconButton(
                    onPressed: () => _handleGoBack(controller),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

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
                  const SizedBox(height: 20),

                  // Estado del proceso
                  _buildProcessStatus(),

                  const SizedBox(height: 30),

                  // Título principal
                  _buildTitle(),

                  const SizedBox(height: 20),

                  // Descripción
                  _buildDescription(),

                  const SizedBox(height: 30),

                  // Resumen de datos
                  _buildDataSummary(controller),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProcessStatus() {
    if (_isProcessing) {
      return _buildProcessingIndicator();
    } else if (_isCompleted) {
      return _buildCompletedIndicator();
    } else {
      return _buildInitialIndicator();
    }
  }

  Widget _buildInitialIndicator() {
    return Container(
      width: 120,
      height: 120,
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
      ),
      child: const Icon(
        Icons.check_circle,
        size: 60,
        color: Colors.black,
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return AnimatedBuilder(
      animation: _processingAnimation,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _processingAnimation.value,
                  strokeWidth: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 40,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedIndicator() {
    return AnimatedBuilder(
      animation: _completedAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _completedAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Colors.green,
                  Color(0xFF4CAF50),
                  Colors.green,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    String title;
    if (_isProcessing) {
      title = 'Procesando tu registro...';
    } else if (_isCompleted) {
      title = '¡Registro completado!';
    } else {
      title = 'Finalizar registro';
    }

    return OverflowUtils.responsiveText(
      title,
      style: TextStyle(
        fontSize: OverflowUtils.getResponsiveFontSize(context, 28),
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    String description;
    if (_isProcessing) {
      description = 'Estamos verificando tu información y creando tu perfil...';
    } else if (_isCompleted) {
      description = 'Tu cuenta ha sido creada exitosamente. ¡Bienvenido a VMF Sweden!';
    } else {
      description = 'Revisa tu información y confirma tu registro para unirte a nuestra comunidad espiritual.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OverflowUtils.responsiveText(
        description,
        style: TextStyle(
          fontSize: OverflowUtils.getResponsiveFontSize(context, 16),
          color: Colors.white.withOpacity(0.8),
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }

  Widget _buildDataSummary(RegistrationController controller) {
    if (_isProcessing || _isCompleted) {
      return const SizedBox.shrink();
    }

    final data = controller.registrationData;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de tu información:',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (data['name'] != null)
            _buildSummaryItem('Nombre', data['name']),
          if (data['gender'] != null)
            _buildSummaryItem('Género', data['gender'] == 'male' ? 'Hombre' : 'Mujer'),
          if (data['birthday'] != null)
            _buildSummaryItem('Edad', '${controller.calculateAge(data['birthday'])} años'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RegistrationController controller) {
    if (_isCompleted) {
      return _buildCompletedButtons(controller);
    } else if (_isProcessing) {
      return _buildProcessingButtons();
    } else {
      return _buildInitialButtons(controller);
    }
  }

  Widget _buildInitialButtons(RegistrationController controller) {
    return Column(
      children: [
        ProfessionalRegisterButton(
          text: 'Completar Registro',
          onPressed: () => _handleCompleteRegistration(controller),
          isEnabled: true,
          isLoading: controller.isLoading,
          loadingText: 'Completando...',
          trailingIcon: Icons.check_circle,
          showGlow: true,
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => _handleGoBack(controller),
          icon: const Icon(Icons.arrow_back, color: Colors.white54),
          label: const Text(
            'Revisar información',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingButtons() {
    return const Column(
      children: [
        Text(
          'Por favor espera...',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCompletedButtons(RegistrationController controller) {
    return Column(
      children: [
        ProfessionalRegisterButton(
          text: 'Continuar',
          onPressed: () => _handleNavigateToWelcome(controller),
          isEnabled: !_isNavigating,
          isLoading: _isNavigating,
          loadingText: 'Navegando...',
          trailingIcon: Icons.arrow_forward,
          showGlow: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _handleCompleteRegistration(RegistrationController controller) async {
    if (_isProcessing || _isCompleted) return;

    setState(() {
      _isProcessing = true;
    });

    // Iniciar animación de procesamiento
    _processingController.forward();

    try {
      // Completar el registro
      final success = await controller.completeRegistration();

      if (success && mounted) {
        setState(() {
          _isProcessing = false;
          _isCompleted = true;
        });

        // Animar el indicador de completado
        _completedController.forward();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro completado exitosamente!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.error ?? 'Error al completar el registro'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error inesperado. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleNavigateToWelcome(RegistrationController controller) async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      // Obtener el nombre del usuario del controller
      final userName = controller.getData<String>('name') ?? 'Usuario';

      print('Navegando con userName: $userName');

      // Pequeño delay para evitar navegaciones concurrentes
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Navegar al welcome screen pasando el nombre de usuario
        final registrationController = context.read<RegistrationController>();
        final userName = registrationController.getData<String>('name') ?? 'Usuario';
        context.go('/welcome-activated', extra: userName);
      }
    } catch (e) {
      print('Error en navegación: $e');
      
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al navegar. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGoBack(RegistrationController controller) {
    if (controller.canGoBack) {
      controller.previousStep();
      Navigator.pop(context);
    }
  }
}
