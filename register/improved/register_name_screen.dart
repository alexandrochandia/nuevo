import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../utils/overflow_utils.dart';
import '../../utils/error_handler.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import '../../widgets/improved_text_field.dart';
import 'registration_controller.dart';

/// Pantalla profesional para captura de nombre en el registro
class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});

  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _buttonController;

  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  String? _nameError;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startAnimationSequence();
    _loadExistingData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();

    _nameController.addListener(_onNameChanged);
    _nameFocusNode.addListener(_onFocusChanged);
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

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _buttonController.forward();
    });
  }

  void _loadExistingData() {
    final controller = context.read<RegistrationController>();
    final existingName = controller.getData<String>('name');
    if (existingName != null && existingName.isNotEmpty) {
      _nameController.text = existingName;
    }
  }

  void _onNameChanged() {
    final name = _nameController.text;
    final controller = context.read<RegistrationController>();

    // Actualizar datos en el controller
    controller.updateData('name', name);

    // Validar en tiempo real si ya se ha mostrado validación
    if (_showValidation) {
      _validateName(name);
    }

    setState(() {});
  }

  void _onFocusChanged() {
    if (!_nameFocusNode.hasFocus && _nameController.text.isNotEmpty) {
      _showValidation = true;
      _validateName(_nameController.text);
    }
  }

  String? _validateName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _nameError = 'El nombre es requerido';
      setState(() {});
      return _nameError;
    }

    if (trimmedName.length < 2) {
      _nameError = 'El nombre debe tener al menos 2 caracteres';
      setState(() {});
      return _nameError;
    }

    if (trimmedName.length > 50) {
      _nameError = 'El nombre no puede tener más de 50 caracteres';
      setState(() {});
      return _nameError;
    }

    _nameError = null;
    setState(() {});
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _headerController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header animado
                  _buildAnimatedHeader(controller),

                  // Contenido principal
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildMainContent(controller),
                    ),
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

                  // Progreso circular
                  ProfessionalProgressIndicator(
                    currentStep: controller.currentStep + 1,
                    totalSteps: RegistrationController.totalSteps,
                    progress: controller.progress,
                    size: 60,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Título principal
                Text(
                  'Escribe tu nombre',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Descripción
                Text(
                  'Comparte tu identidad con la comunidad. Tu nombre será visible en tu perfil.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                // Campo de nombre mejorado
                ImprovedTextField(
                  label: 'Tu nombre completo',
                  hintText: 'Ej: María González',
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  validator: _showValidation ? (value) => _validateName(value ?? '') : null,
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  focusedBorderColor: _nameError != null
                      ? Colors.red
                      : const Color(0xFFD4AF37),
                  onSubmitted: (value) => _handleNext(controller),
                ),

                const SizedBox(height: 20),

                // Tips de nombre
                _buildNameTips(),

                const SizedBox(height: 16),

                // Preview del nombre
                if (_nameController.text.trim().isNotEmpty)
                  _buildNamePreview(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameTips() {
    final tips = [
      {'icon': Icons.check_circle_outline, 'text': 'Usa tu nombre real para crear confianza'},
      {'icon': Icons.security_outlined, 'text': 'Tu información está protegida y segura'},
      {'icon': Icons.visibility_outlined, 'text': 'Solo será visible en tu perfil público'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tips para tu nombre:',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  tip['icon'] as IconData,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip['text'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNamePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1),
            const Color(0xFFD4AF37).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista previa de tu perfil:',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFD4AF37).withOpacity(0.3),
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text.trim().substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.trim().isNotEmpty
                          ? _nameController.text.trim()
                          : 'Tu nombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Miembro de VMF Sweden',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
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

  Widget _buildActionButtons(RegistrationController controller) {
    final name = _nameController.text.trim();
    final canContinue = name.isNotEmpty && name.length >= 2;

    return SlideTransition(
      position: _buttonSlideAnimation,
      child: Column(
        children: [
          // Texto de recompensa
          if (canContinue)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFD4AF37),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Gana 10 coins al completar',
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Botón principal
          ProfessionalRegisterButton(
            text: 'Siguiente',
            onPressed: canContinue ? () => _handleNext(controller) : null,
            isEnabled: canContinue,
            isLoading: controller.isLoading,
            loadingText: 'Guardando...',
            trailingIcon: Icons.arrow_forward,
            showGlow: canContinue,
          ),

          const SizedBox(height: 16),

          // Botón de retroceso
          TextButton.icon(
            onPressed: () => _handleGoBack(controller),
            icon: const Icon(Icons.arrow_back, color: Colors.white54),
            label: const Text(
              'Atrás',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(RegistrationController controller) async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();
    
    final name = _nameController.text.trim();
    
    // Marcar que se debe mostrar validación
    _showValidation = true;
    
    // Validar nombre
    final validationError = _validateName(name);
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      // Actualizar datos en el controller
      controller.updateData('name', name);
      
      // Avanzar al siguiente paso
      final success = await controller.nextStep();
      
      if (success && mounted) {
        // Mostrar feedback de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Nombre guardado exitosamente! +10 coins'),
            backgroundColor: Color(0xFFD4AF37),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navegar a la siguiente pantalla usando el router
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/register-birthday');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al avanzar. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se guardó tu nombre. Inténtalo más tarde.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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