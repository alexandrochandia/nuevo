import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/smart_engagement_banner/index.dart';
import '../widgets/interactive_boxes/simple_live_worship_map_box.dart';
import '../widgets/interactive_boxes/simple_daily_video_box.dart';
import '../widgets/interactive_boxes/daily_verse_box.dart';
import '../widgets/interactive_boxes/simple_connected_brothers_box.dart';
import '../widgets/interactive_boxes/simple_spiritual_progress_box.dart';
import '../widgets/profile_modal.dart';

import 'testimonios_screen.dart';
import 'multimedia_screen.dart';
import '../screens/modern_casas_iglesias_screen.dart';
import 'digital_offering_screen.dart';
import 'zoom_reuniones_screen.dart';
import 'alabanza_screen.dart';
import 'devocional_diario_screen.dart';

class ExploraItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String backgroundImage;
  final VoidCallback onTap;

  ExploraItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundImage,
    required this.onTap,
  });
}

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late PageController _pageController;
  int _currentBannerIndex = 0;

  // Featured content data with real images
  final List<Map<String, dynamic>> _featuredContent = [
    {
      'title': 'Oración Matutina',
      'subtitle': 'Comienza tu día con fe',
      'thumbnail': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
      'gradient': [Color(0xFFD4AF37), Color(0xFFB8860B)],
    },
    {
      'title': 'Testimonios de Fe',
      'subtitle': 'Historias que inspiran',
      'thumbnail': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&h=600&fit=crop',
      'gradient': [Color(0xFF9C27B0), Color(0xFF673AB7)],
    },
    {
      'title': 'Música Cristiana',
      'subtitle': 'Alabanzas y adoración',
      'thumbnail': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=600&fit=crop',
      'gradient': [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
  ];

  // Quick actions data with real images
  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Testimonios',
      'subtitle': 'Comparte tu historia',
      'icon': Icons.favorite,
      'color': Color(0xFFE91E63),
      'route': '/testimonios',
      'backgroundImage': 'https://images.unsplash.com/photo-1529390079861-591de354faf5?w=400&h=300&fit=crop',
      'gradient': [Color(0xFFE91E63), Color(0xFFAD1457)],
    },
    {
      'title': 'Oración',
      'subtitle': 'Momentos de reflexión',
      'icon': Icons.self_improvement,
      'color': Color(0xFF9C27B0),
      'route': '/oracion',
      'backgroundImage': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      'gradient': [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    },
    {
      'title': 'Eventos',
      'subtitle': 'Próximas actividades',
      'icon': Icons.event,
      'color': Color(0xFF2196F3),
      'route': '/eventos',
      'backgroundImage': 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400&h=300&fit=crop',
      'gradient': [Color(0xFF2196F3), Color(0xFF1976D2)],
    },
    {
      'title': 'Música',
      'subtitle': 'Alabanzas y adoración',
      'icon': Icons.music_note,
      'color': Color(0xFF4CAF50),
      'route': '/musica',
      'backgroundImage': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
      'gradient': [Color(0xFF4CAF50), Color(0xFF388E3C)],
    },
    {
      'title': 'Galería',
      'subtitle': 'Momentos especiales',
      'icon': Icons.photo_library,
      'color': Color(0xFFFF9800),
      'route': '/galeria',
      'backgroundImage': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&h=300&fit=crop',
      'gradient': [Color(0xFFFF9800), Color(0xFFF57C00)],
    },
    {
      'title': 'Tienda',
      'subtitle': 'Productos cristianos',
      'icon': Icons.shopping_bag,
      'color': Color(0xFFD4AF37),
      'route': '/store-onboarding',
      'backgroundImage': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&h=300&fit=crop',
      'gradient': [Color(0xFFD4AF37), Color(0xFFB8860B)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final auraColor = Color(0xFFD4AF37);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1A1A1A),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildModernHeader(auraColor),
                const SizedBox(height: 10),
                _buildFeaturedContentCarousel(),
                const SizedBox(height: 30),
                _buildQuickActionsGrid(),
                const SizedBox(height: 30),
                
                // 🎠 CARRUSEL EXPLORA VMF
                _buildExploraVMFCarousel(auraColor),
                const SizedBox(height: 30),

                // 🎯 BOXES INTERACTIVOS ESTILO DJI MIMO + ESPIRITUAL VMF
                _buildInteractiveBoxesSection(),

                const SizedBox(height: 20),
                SmartEngagementBanner(
                  config: {
                    'title': 'Únete a nuestra comunidad',
                    'message': '¡Conecta con otros creyentes!',
                    'showAfterSeconds': 3,
                  },
                  context: context,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernHeader(Color auraColor) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF111112),
              Color(0xFF161616),
            ],
          ),
        ),
        child: Row(
          children: [
            // Avatar y información del usuario
            Expanded(
              child: Row(
                children: [
                  // Avatar clickeable para modal premium
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showProfileModal();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Nombre y botón editar perfil
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre con insignia verificada
                        Row(
                          children: [
                            Text(
                              'usuario vmf',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                fontFamily: '-apple-system',
                                letterSpacing: 0.1,
                              ),
                            ),
                            SizedBox(width: 6),
                            // Insignia verificada
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(0xFF6A6A6A),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.black.withOpacity(0.6),
                                size: 12,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6),

                        // Eliminar el botón Edit Profile como solicitaste
                        SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Visitors label
            Text(
              'Visitors',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: '-apple-system',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, Color auraColor, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: auraColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: auraColor,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedContentCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Contenido Destacado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _featuredContent.length,
            itemBuilder: (context, index) {
              final content = _featuredContent[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (content['gradient'][0] as Color).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Image.network(
                          content['thumbnail'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: content['gradient'],
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: content['gradient'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Dark overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              content['subtitle'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.7),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featuredContent.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? Color(0xFFD4AF37)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Acciones Rápidas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _handleQuickAction(action['route']);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: action['color'].withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.network(
                            action['backgroundImage'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: action['gradient'],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: action['gradient'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Dark overlay for text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    action['icon'],
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          action['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black,
                                                blurRadius: 4,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          action['subtitle'],
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 12,
                                            height: 1.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.7),
                                                blurRadius: 3,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleQuickAction(String route) {
    switch (route) {
      case 'casas_iglesias':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ModernCasasIglesiasScreen(),
          ),
        );
        break;
      case '/testimonios':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestimoniosScreen()),
        );
        break;
      case '/oracion':
      // Navigate to prayer screen
        break;
      case '/eventos':
      // Navigate to events screen
        break;
      case '/musica':
      // Navigate to music screen
        break;
      case '/galeria':
      // Navigate to gallery screen
        break;
      case '/tienda':
      // Navigate to store screen
        break;
    }
  }



  // 🎯 SECCIÓN DE BOXES INTERACTIVOS ESTILO DJI MIMO + ESPIRITUAL VMF
  Widget _buildInteractiveBoxesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;
          final spacing = isSmallScreen ? 8.0 : 16.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la sección
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '✨ Experiencia Interactiva',
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: spacing),

              // Primera fila: Mapa en Vivo + Video del Día
              if (isSmallScreen)
              // En pantallas pequeñas, mostrar en columna
                Column(
                  children: [
                    const SizedBox(
                      height: 180,
                      child: LiveWorshipMapBox(),
                    ),
                    SizedBox(height: spacing),
                    const SizedBox(
                      height: 180,
                      child: DailyVideoBox(),
                    ),
                  ],
                )
              else
              // En pantallas grandes, mostrar en fila
                SizedBox(
                  height: 180, // Altura fija para evitar problemas de layout
                  child: Row(
                    children: [
                      const Expanded(
                        child: LiveWorshipMapBox(),
                      ),
                      SizedBox(width: spacing),
                      const Expanded(
                        child: DailyVideoBox(),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: spacing),

              // Segunda fila: Versículo Diario (ancho completo)
              const DailyVerseBox(),

              SizedBox(height: spacing),

              // Tercera fila: Hermanos Conectados + Progreso Espiritual
              if (isSmallScreen)
              // En pantallas pequeñas, mostrar en columna
                Column(
                  children: [
                    const SizedBox(
                      height: 200,
                      child: ConnectedBrothersBox(),
                    ),
                    SizedBox(height: spacing),
                    const SizedBox(
                      height: 200,
                      child: SpiritualProgressBox(),
                    ),
                  ],
                )
              else
              // En pantallas grandes, mostrar en fila
                SizedBox(
                  height: 200, // Altura fija para evitar problemas de layout
                  child: Row(
                    children: [
                      const Expanded(
                        child: ConnectedBrothersBox(),
                      ),
                      SizedBox(width: spacing),
                      const Expanded(
                        child: SpiritualProgressBox(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Botón para ver más funciones interactivas
              GestureDetector(
                onTap: () {
                  // Navegar a pantalla de funciones avanzadas
                  _showMoreInteractiveFeaturesDialog();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.2),
                        const Color(0xFFD4AF37).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.explore,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isSmallScreen ? 'Más funciones' : 'Explorar más funciones interactivas',
                            style: TextStyle(
                              color: const Color(0xFFD4AF37),
                              fontSize: isSmallScreen ? 11 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/new-users-swiper');
            },
            child: Container(
              width: 90,
              height: 90,
              child: Image.asset(
                'assets/images/nuevos.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.create,
                  color: Color(0xFFD4AF37),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Crear Contenido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Funcionalidad de creación de contenido próximamente disponible.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreInteractiveFeaturesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🚀 Próximamente',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estamos trabajando en más funciones interactivas:\n\n🎮 Encuestas rápidas tipo Tinder\n💬 Chat en tiempo real\n🌍 Mapa de calor espiritual mundial\n📅 Agenda espiritual personalizada\n🎁 Sistema de recompensas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('¡Genial!'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExploraVMFCarousel(Color auraColor) {
    final exploraItems = [
      ExploraItem(
        title: 'Multimedia',
        subtitle: 'Videos y contenido',
        icon: Icons.video_collection,
        color: const Color(0xFF2196F3),
        backgroundImage: 'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=400&h=300&fit=crop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MultimediaScreen())),
      ),
      ExploraItem(
        title: 'Casas Iglesias',
        subtitle: 'Ubicaciones y comunidad',
        icon: Icons.home_work,
        color: const Color(0xFF4CAF50),
        backgroundImage: 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=400&h=300&fit=crop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ModernCasasIglesiasScreen())),
      ),
      ExploraItem(
        title: 'Ofrendas',
        subtitle: 'Donaciones digitales',
        icon: Icons.volunteer_activism,
        color: const Color(0xFFFF9800),
        backgroundImage: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=400&h=300&fit=crop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DigitalOfferingScreen())),
      ),
      ExploraItem(
        title: 'Zoom Reuniones',
        subtitle: 'Encuentros virtuales',
        icon: Icons.video_call,
        color: const Color(0xFF9C27B0),
        backgroundImage: 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?w=400&h=300&fit=crop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ZoomReunionesScreen())),
      ),
      ExploraItem(
        title: 'Alabanza',
        subtitle: 'Música cristiana',
        icon: Icons.music_note,
        color: const Color(0xFFE91E63),
        backgroundImage: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AlabanzaScreen())),
      ),
      ExploraItem(
        title: 'Devocional Diario',
        subtitle: 'Reflexiones espirituales',
        icon: Icons.auto_stories,
        color: auraColor,
        backgroundImage: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DevocionalDiarioScreen())),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '🎠 Explora VMF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: auraColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive height based on screen size
            double carouselHeight = constraints.maxWidth < 400 ? 160 : 180;
            
            return Container(
              height: carouselHeight,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: exploraItems.length,
                itemBuilder: (context, index) {
                  final item = exploraItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Background image
                          Positioned.fill(
                            child: Image.network(
                              item.backgroundImage,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        item.color.withOpacity(0.8),
                                        item.color.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        item.color.withOpacity(0.8),
                                        item.color.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                item.onTap();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(constraints.maxWidth < 400 ? 16 : 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: constraints.maxWidth < 400 ? 50 : 60,
                                      height: constraints.maxWidth < 400 ? 50 : 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: Colors.white,
                                        size: constraints.maxWidth < 400 ? 28 : 32,
                                      ),
                                    ),
                                    SizedBox(height: constraints.maxWidth < 400 ? 12 : 16),
                                    Flexible(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: constraints.maxWidth < 400 ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        item.subtitle,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: constraints.maxWidth < 400 ? 12 : 14,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.7),
                                              blurRadius: 3,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Explorar',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: constraints.maxWidth < 400 ? 11 : 12,
                                            fontWeight: FontWeight.w600,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.7),
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white.withOpacity(0.9),
                                          size: constraints.maxWidth < 400 ? 10 : 12,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showProfileModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const ProfileModal();
      },
    );
  }




  }
