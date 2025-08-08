import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../utils/overflow_utils.dart';
import '../../utils/error_handler.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import 'registration_controller.dart';
import 'dart:math' as math;

/// Pantalla profesional para configuración de notificaciones
class RegisterNotificationsScreen extends StatefulWidget {
  const RegisterNotificationsScreen({super.key});

  @override
  State<RegisterNotificationsScreen> createState() => _RegisterNotificationsScreenState();
}

class _RegisterNotificationsScreenState extends State<RegisterNotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _notificationController;
  late AnimationController _pulseController;

  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _notificationAnimation;
  late Animation<double> _pulseAnimation;

  Map<String, bool> _notificationSettings = {
    'push_enabled': true,
    'matches': true,
    'messages': true,
    'events': true,
    'prayers': false,
    'devotionals': true,
    'live_streams': true,
    'testimonials': false,
  };

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

    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
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

    _notificationAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
  }

  void _loadExistingData() {
    final controller = context.read<RegistrationController>();
    final existingSettings = controller.getData<Map<String, bool>>('notification_settings');
    if (existingSettings != null) {
      setState(() {
        _notificationSettings = Map.from(existingSettings);
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _notificationController.dispose();
    _pulseController.dispose();
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
              children: [
                const SizedBox(height: 20),
                
                // Hero section con icono animado
                _buildHeroSection(),

                const SizedBox(height: 40),

                // Lista de configuraciones
                Expanded(
                  child: _buildNotificationsList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Icono principal animado
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37),
                      const Color(0xFFD4AF37).withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      blurRadius: 20 * _pulseAnimation.value,
                      spreadRadius: 5 * _pulseAnimation.value,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Título
        OverflowUtils.responsiveText(
          '¡Mantente conectado!',
          style: TextStyle(
            fontSize: OverflowUtils.getResponsiveFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Descripción
        OverflowUtils.responsiveText(
          'Personaliza tus notificaciones para no perderte nada importante de nuestra comunidad.',
          style: TextStyle(
            fontSize: OverflowUtils.getResponsiveFontSize(context, 16),
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    final notificationTypes = [
      {
        'key': 'push_enabled',
        'title': 'Notificaciones Push',
        'subtitle': 'Habilitar todas las notificaciones push',
        'icon': Icons.notifications,
        'color': const Color(0xFFD4AF37),
        'isMain': true,
      },
      {
        'key': 'matches',
        'title': 'Nuevos Matches',
        'subtitle': 'Cuando alguien muestre interés en ti',
        'icon': Icons.favorite,
        'color': const Color(0xFFE91E63),
      },
      {
        'key': 'messages',
        'title': 'Mensajes',
        'subtitle': 'Nuevos mensajes y conversaciones',
        'icon': Icons.chat_bubble,
        'color': const Color(0xFF2196F3),
      },
      {
        'key': 'events',
        'title': 'Eventos',
        'subtitle': 'Eventos y actividades cercanos',
        'icon': Icons.event,
        'color': const Color(0xFF9C27B0),
      },
      {
        'key': 'prayers',
        'title': 'Oraciones',
        'subtitle': 'Peticiones de oración y respuestas',
        'icon': Icons.church,
        'color': const Color(0xFF607D8B),
      },
      {
        'key': 'devotionals',
        'title': 'Devocionales',
        'subtitle': 'Nuevos devocionales y reflexiones',
        'icon': Icons.menu_book,
        'color': const Color(0xFF795548),
      },
      {
        'key': 'live_streams',
        'title': 'Transmisiones en Vivo',
        'subtitle': 'Cuando comience un stream',
        'icon': Icons.live_tv,
        'color': const Color(0xFFF44336),
      },
      {
        'key': 'testimonials',
        'title': 'Testimonios',
        'subtitle': 'Nuevos testimonios compartidos',
        'icon': Icons.record_voice_over,
        'color': const Color(0xFF00BCD4),
      },
    ];

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: notificationTypes.length,
      itemBuilder: (context, index) {
        final type = notificationTypes[index];
        return _buildNotificationTile(type);
      },
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> type) {
    final key = type['key'] as String;
    final isEnabled = _notificationSettings[key] ?? false;
    final isMainSetting = type['isMain'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isEnabled 
                ? (type['color'] as Color).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            isEnabled 
                ? (type['color'] as Color).withOpacity(0.05)
                : Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled 
              ? (type['color'] as Color).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: isEnabled ? 2 : 1,
        ),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: (type['color'] as Color).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleNotification(key),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? (type['color'] as Color).withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isEnabled ? Border.all(
                      color: (type['color'] as Color).withOpacity(0.4),
                      width: 1,
                    ) : null,
                  ),
                  child: Icon(
                    type['icon'] as IconData,
                    color: isEnabled 
                        ? type['color'] as Color
                        : Colors.white.withOpacity(0.6),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type['title'] as String,
                        style: TextStyle(
                          fontSize: isMainSetting ? 18 : 16,
                          fontWeight: isMainSetting ? FontWeight.bold : FontWeight.w600,
                          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Switch
                AnimatedBuilder(
                  animation: _notificationAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0,
                      child: Switch.adaptive(
                        value: isEnabled,
                        onChanged: (_) => _toggleNotification(key),
                        activeColor: type['color'] as Color,
                        activeTrackColor: (type['color'] as Color).withOpacity(0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(RegistrationController controller) {
    return Column(
      children: [
        // Resumen de configuración
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
                Icons.info_outline,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tienes ${_notificationSettings.values.where((v) => v).length} de ${_notificationSettings.length} notificaciones habilitadas. Puedes cambiar esto después en configuración.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
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
          onPressed: () => _handleNext(controller),
          isLoading: controller.isLoading,
          loadingText: 'Guardando configuración...',
          trailingIcon: Icons.arrow_forward,
          showGlow: true,
        ),

        const SizedBox(height: 12),

        // Botones secundarios con manejo de overflow
        LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = (constraints.maxWidth - 12) / 2;
            return Row(
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _enableAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_active, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
                        'Habilitar',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: _disableAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.notifications_off, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
                        'Deshabilitar',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _toggleNotification(String key) {
    setState(() {
      _notificationSettings[key] = !(_notificationSettings[key] ?? false);
    });

    // Si es la configuración principal, afecta a todas
    if (key == 'push_enabled') {
      final enabled = _notificationSettings[key]!;
      if (!enabled) {
        setState(() {
          _notificationSettings.forEach((k, v) {
            if (k != 'push_enabled') _notificationSettings[k] = false;
          });
        });
      }
    }

    // Actualizar controlador después de todos los cambios
    final controller = context.read<RegistrationController>();
    controller.updateData('notification_settings', _notificationSettings);

    // Animación de feedback
    _notificationController.forward().then((_) {
      _notificationController.reverse();
    });
  }

  void _enableAll() {
    setState(() {
      _notificationSettings.forEach((key, value) {
        _notificationSettings[key] = true;
      });
    });
    
    final controller = context.read<RegistrationController>();
    controller.updateData('notification_settings', _notificationSettings);
    
    if (mounted) {
      ErrorHandler.showSuccessSnackBar(
        context, 
        'Todas las notificaciones habilitadas'
      );
    }
  }

  void _disableAll() {
    setState(() {
      _notificationSettings.forEach((key, value) {
        _notificationSettings[key] = false;
      });
    });
    
    final controller = context.read<RegistrationController>();
    controller.updateData('notification_settings', _notificationSettings);
    
    if (mounted) {
      ErrorHandler.showSuccessSnackBar(
        context, 
        'Todas las notificaciones deshabilitadas'
      );
    }
  }

  void _handleNext(RegistrationController controller) async {
    if (!mounted) return;
    
    try {
      // Guardar configuración de notificaciones ANTES de avanzar
      await controller.updateData('notification_settings', _notificationSettings);
      
      // Avanzar al siguiente paso
      final success = await controller.nextStep();
      
      if (success && mounted) {
        final enabledCount = _notificationSettings.values.where((v) => v).length;
        ErrorHandler.showSuccessSnackBar(
          context, 
          '¡Configuración guardada! +${enabledCount * 2} coins'
        );
        
        // Navegar al siguiente paso usando go_router
        context.go('/register-photos');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Error al guardar la configuración. Inténtalo de nuevo.',
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