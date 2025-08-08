import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../screens/new_users_swiper_screen.dart';
import '../features/vmf_connect/vmf_connect_screen.dart';
import '../screens/store/vmf_store_onboarding_screen.dart';
import '../screens/store/vmf_store_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DJIMimoBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DJIMimoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<DJIMimoBottomNav> createState() => _DJIMimoBottomNavState();
}

class _DJIMimoBottomNavState extends State<DJIMimoBottomNav> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isVerySmallScreen = screenWidth < 320;
            final isSmallScreen = screenWidth < 380;
            final isMediumScreen = screenWidth < 450;

            // Ajustar padding según el tamaño de pantalla
            final horizontalPadding = isVerySmallScreen ? 4.0 :
            isSmallScreen ? 6.0 :
            isMediumScreen ? 12.0 : 20.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home
                  Expanded(
                    flex: 1,
                    child: _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: isVerySmallScreen ? 'Home' : 'Inicio',
                      index: 0,
                      isActive: widget.currentIndex == 0,
                      isCompact: isSmallScreen,
                    ),
                  ),

                  // VMF Tienda
                  Expanded(
                    flex: 1,
                    child: _buildStoreNavItem(
                      icon: Icons.store_outlined,
                      activeIcon: Icons.store,
                      label: isVerySmallScreen ? 'VMF' :
                      isSmallScreen ? 'Tienda' : 'VMF Tienda',
                      index: 1,
                      isActive: widget.currentIndex == 1,
                      isCompact: isSmallScreen,
                      isVMFItem: true,
                    ),
                  ),

                  // BOTÓN CENTRAL - CÁMARA ESTILO DJI MIMO
                  Flexible(
                    flex: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 2.0 :
                          isSmallScreen ? 4.0 : 6.0
                      ),
                      child: _buildCentralCameraButton(isCompact: isSmallScreen),
                    ),
                  ),

                  // Eventos
                  Expanded(
                    flex: 1,
                    child: _buildNavItem(
                      icon: Icons.event_outlined,
                      activeIcon: Icons.event,
                      label: isVerySmallScreen ? 'Event' :
                      isSmallScreen ? 'Event' : 'Eventos',
                      index: 3,
                      isActive: widget.currentIndex == 3,
                      isCompact: isSmallScreen,
                    ),
                  ),

                  // LIVE (Botón rojo pulsante)
                  Expanded(
                    flex: 1,
                    child: _buildLiveButton(
                      isCompact: isSmallScreen,
                      isActive: widget.currentIndex == 4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
    bool isCompact = false,
    bool isVMFItem = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 4 : 8,
            vertical: isCompact ? 4 : 6
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isCompact ? 4 : 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFD4AF37).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? const Color(0xFFD4AF37)
                    : Colors.white.withOpacity(0.6),
                size: isCompact ? 20 : 22,
              ),
            ),
            SizedBox(height: isCompact ? 2 : 3),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: isVMFItem && label.contains('VMF') ?
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'VMF',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37), // Oro para VMF
                          fontSize: isCompact ? 8 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (label.length > 3) TextSpan(
                        text: label.substring(3), // El resto del texto
                        style: TextStyle(
                          color: isActive ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.6),
                          fontSize: isCompact ? 8 : 9,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ) :
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.6),
                    fontSize: isCompact ? 8 : 9,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
    bool isCompact = false,
    bool isVMFItem = false,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        
        // Check if onboarding has been completed
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool hasSeenStoreOnboarding = prefs.getBool('has_seen_store_onboarding') ?? false;
        
        if (!hasSeenStoreOnboarding) {
          // Show onboarding
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VMFStoreOnboardingScreen(),
            ),
          );
        } else {
          // Go directly to store
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VMFStoreScreen(),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 4 : 8,
            vertical: isCompact ? 4 : 6
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isCompact ? 4 : 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFD4AF37).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? const Color(0xFFD4AF37)
                    : Colors.white.withOpacity(0.6),
                size: isCompact ? 20 : 22,
              ),
            ),
            SizedBox(height: isCompact ? 2 : 3),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: isVMFItem && label.contains('VMF') ?
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'VMF',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37), // Oro para VMF
                          fontSize: isCompact ? 8 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (label.length > 3) TextSpan(
                        text: label.substring(3), // El resto del texto
                        style: TextStyle(
                          color: isActive ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.6),
                          fontSize: isCompact ? 8 : 9,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ) :
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.6),
                    fontSize: isCompact ? 8 : 9,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveButton({required bool isCompact, required bool isActive}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? 1.0 + _pulseAnimation.value * 0.1 : 1.0,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onTap(4);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 10 : 12,
                horizontal: isCompact ? 6 : 8,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 12,
                  vertical: isCompact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: isActive ? 12 : 8,
                      spreadRadius: isActive ? 3 : 2,
                    ),
                  ],
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCentralCameraButton({bool isCompact = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isVerySmallScreen = screenWidth < 320;
        final isSmallScreen = screenWidth < 380;

        // Ajustar tamaño del botón según pantalla
        final buttonSize = isVerySmallScreen ? 60.0 :
        isSmallScreen ? 70.0 :
        isCompact ? 80.0 : 90.0;

        final iconSize = isVerySmallScreen ? 20.0 :
        isSmallScreen ? 24.0 :
        isCompact ? 28.0 : 32.0;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showCameraOptionsModal();
          },
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withOpacity(0.9),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: isCompact ? 6 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.black,
              size: iconSize,
            ),
          ),
        );
      },
    );
  }

  void _showCameraOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 16),

              // Título
              Text(
                'Opciones de Cámara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Opciones en grid horizontal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactCameraOption(
                        icon: Icons.camera_alt,
                        label: 'Foto',
                        onTap: () {
                          Navigator.pop(context);
                          // Abrir cámara para foto
                        },
                      ),
                      _buildCompactCameraOption(
                        icon: Icons.videocam,
                        label: 'Video',
                        onTap: () {
                          Navigator.pop(context);
                          // Abrir cámara para video
                        },
                      ),
                      _buildCompactCameraOption(
                        icon: Icons.video_collection,
                        label: 'VMF\nConnect',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VMFConnectScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCompactCameraOption(
                        icon: Icons.people,
                        label: 'Usuarios',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewUsersSwiperScreen(),
                            ),
                          );
                        },
                      ),
                      _buildCompactCameraOption(
                        icon: Icons.video_library,
                        label: 'Galería',
                        onTap: () {
                          Navigator.pop(context);
                          // Abrir galería
                        },
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

  Widget _buildCameraOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCameraOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter para el anillo de la cámara estilo DJI
class CameraRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dibujar líneas radiales como en DJI Mimo
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final startX = center.dx + (radius - 8) * cos(angle);
      final startY = center.dy + (radius - 8) * sin(angle);
      final endX = center.dx + (radius - 2) * cos(angle);
      final endY = center.dy + (radius - 2) * sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Función auxiliar para cos y sin
double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);
