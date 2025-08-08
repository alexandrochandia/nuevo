
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import '../../utils/error_handler.dart';
import '../../utils/overflow_utils.dart';
import 'registration_controller.dart';
import 'package:intl/intl.dart';

/// Pantalla profesional para selección de fecha de nacimiento
class RegisterBirthdayScreen extends StatefulWidget {
  const RegisterBirthdayScreen({super.key});

  @override
  State<RegisterBirthdayScreen> createState() => _RegisterBirthdayScreenState();
}

class _RegisterBirthdayScreenState extends State<RegisterBirthdayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DateTime? _selectedDate;
  final DateFormat _formatter = DateFormat('dd/MM/yyyy');
  int? _calculatedAge;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadExistingData();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _loadExistingData() {
    final controller = context.read<RegistrationController>();
    final existingDate = controller.getData<DateTime>('birthday');
    if (existingDate != null) {
      setState(() {
        _selectedDate = existingDate;
        _calculatedAge = controller.calculateAge(existingDate);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header
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
          ),
        );
      },
    );
  }

  Widget _buildHeader(RegistrationController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Spacer en lugar de botón atrás
          const SizedBox(width: 48),

          // Progreso simple sin animaciones
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${controller.currentStep + 1}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
    );
  }

  Widget _buildMainContent(RegistrationController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Título
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '¿Cuál es tu fecha\nde nacimiento?',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 350 ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Descripción
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Esto nos ayuda a crear conexiones apropiadas y personalizar tu experiencia según tu edad.',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 350 ? 14 : 16,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Selector de fecha
                  Expanded(
                    flex: 3,
                    child: _buildDateSelector(),
                  ),

                  // Información de edad si está seleccionada
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 15),
                    _buildAgeInfo(),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedDate != null
              ? const Color(0xFFD4AF37).withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: _selectedDate != null ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header del selector
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cake_outlined,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Fecha de Nacimiento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),

          // Contenido del selector
          Expanded(
            child: _selectedDate == null
                ? _buildInitialDatePrompt()
                : _buildSelectedDateDisplay(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialDatePrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.black,
              size: 28,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Toca para seleccionar\ntu fecha de nacimiento',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Botón de selección
          ElevatedButton(
            onPressed: _showDatePicker,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month, size: 20),
                SizedBox(width: 8),
                Text(
                  'Seleccionar Fecha',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fecha seleccionada
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatter.format(_selectedDate!),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botón para cambiar fecha
          TextButton.icon(
            onPressed: _showDatePicker,
            icon: const Icon(Icons.edit_calendar, color: Colors.white70, size: 18),
            label: const Text(
              'Cambiar fecha',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeInfo() {
    if (_calculatedAge == null) return const SizedBox.shrink();

    final isValidAge = _calculatedAge! >= 18 && _calculatedAge! <= 100;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isValidAge
            ? const Color(0xFFD4AF37).withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValidAge
              ? const Color(0xFFD4AF37).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValidAge ? Icons.check_circle_outline : Icons.warning_amber,
            color: isValidAge ? const Color(0xFFD4AF37) : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValidAge
                      ? 'Tienes $_calculatedAge años'
                      : _calculatedAge! < 18
                      ? 'Debes ser mayor de 18 años'
                      : 'Edad no válida',
                  style: TextStyle(
                    color: isValidAge ? const Color(0xFFD4AF37) : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isValidAge)
                  Text(
                    'Edad perfecta para unirte a nuestra comunidad',
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
    );
  }

  Widget _buildActionButtons(RegistrationController controller) {
    final canContinue = _selectedDate != null &&
        _calculatedAge != null &&
        _calculatedAge! >= 18 &&
        _calculatedAge! <= 100;

    return Column(
      children: [
        // Información de privacidad
        if (_selectedDate != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.security,
                  color: Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu fecha de nacimiento es privada y se usa solo para verificación de edad.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Botón principal
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canContinue && !_isProcessing ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canContinue ? const Color(0xFFD4AF37) : Colors.grey,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: canContinue ? 8 : 0,
            ),
            child: _isProcessing
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continuar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),


      ],
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header del picker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selecciona tu fecha de nacimiento',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Date picker mejorado con estilo iOS
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    backgroundColor: Colors.white,
                    maximumDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                    minimumDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
                    initialDateTime: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                        _calculatedAge = context.read<RegistrationController>().calculateAge(newDate);
                      });
                    },
                  ),
                ),
              ),
            ),

            // Botón de confirmación
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDate != null) {
                      final controller = context.read<RegistrationController>();
                      controller.updateBirthday(_selectedDate!);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ÚNICO MÉTODO _handleNext
  void _handleNext() async {
    if (_selectedDate == null) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Por favor selecciona tu fecha de nacimiento',
      );
      return;
    }

    // Verificación con null safety
    if (_calculatedAge == null || _calculatedAge! < 18) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Debes tener al menos 18 años para usar esta aplicación',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Actualizar datos en el controller
      final controller = context.read<RegistrationController>();
      controller.updateBirthday(_selectedDate!);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fecha de nacimiento guardada: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
          backgroundColor: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 1),
        ),
      );

      // Simple direct navigation
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.go('/register-notifications');
      }
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        // Fallback navigation
        Navigator.of(context).pushReplacementNamed('/register-notifications');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
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
