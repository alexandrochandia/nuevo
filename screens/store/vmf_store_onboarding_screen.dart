import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/aura_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'vmf_store_screen.dart';

// Temporary simple page indicator until smooth_page_indicator is installed
class SimplePageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Color activeColor;
  final Color inactiveColor;

  const SimplePageIndicator({
    Key? key,
    required this.currentPage,
    required this.pageCount,
    required this.activeColor,
    required this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class VMFStoreOnboardingScreen extends StatefulWidget {
  const VMFStoreOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<VMFStoreOnboardingScreen> createState() => _VMFStoreOnboardingScreenState();
}

class _VMFStoreOnboardingScreenState extends State<VMFStoreOnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Obtén Premium',
      description: 'Disfruta de app sin interrupciones y con menos distracción',
      imagePath: 'assets/images/Onboarding/slide1.png',
      backgroundColor: const Color(0xFF1A1A1A),
    ),
    OnboardingSlide(
      title: 'Contenido Exclusivo',
      description: 'Accede a recursos y productos solo para miembros Premium',
      imagePath: 'assets/images/Onboarding/slide2.png',
      backgroundColor: const Color(0xFF2A2A2A),
    ),
    OnboardingSlide(
      title: 'Apoya la Misión',
      description: 'Cada compra ayuda a expandir el mensaje de fe en el mundo',
      imagePath: 'assets/images/Onboarding/slide3.png',
      backgroundColor: const Color(0xFF3A3A3A),
    ),
    OnboardingSlide(
      title: 'Recibe Descuentos',
      description: 'Aprovecha ofertas especiales en nuestra VMF Store',
      imagePath: 'assets/images/Onboarding/slide4.png',
      backgroundColor: const Color(0xFF4A4A4A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _finishOnboarding();
  }

  void _finishOnboarding() {
    // Usar Future.microtask para navegación segura
    Future.microtask(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_store_onboarding', true);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/store');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context, listen: false);
    final auraColor = auraProvider.currentAuraColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con Skip button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo VMF
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: auraColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'VMF',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    // Skip button
                    if (_currentPage < _slides.length - 1)
                      GestureDetector(
                        onTap: _skipOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Saltar',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // PageView con slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _fadeController.reset();
                    _slideController.reset();
                    _fadeController.forward();
                    _slideController.forward();
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildSlide(_slides[index], auraColor),
                      ),
                    );
                  },
                ),
              ),

              // Indicadores y botones de navegación
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Page indicators
                    SimplePageIndicator(
                      currentPage: _currentPage,
                      pageCount: _slides.length,
                      activeColor: auraColor,
                      inactiveColor: Colors.white.withOpacity(0.3),
                    ),

                    const SizedBox(height: 30),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous button
                        if (_currentPage > 0)
                          _buildNavButton(
                            'Anterior',
                            onTap: _previousPage,
                            isPrimary: false,
                            auraColor: auraColor,
                          )
                        else
                          const SizedBox(width: 100),

                        // Next/Finish button
                        _buildNavButton(
                          _currentPage == _slides.length - 1
                              ? 'Explorar Tienda'
                              : 'Siguiente',
                          onTap: _nextPage,
                          isPrimary: true,
                          auraColor: auraColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, Color auraColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen con efecto glassmorphism
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: auraColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                slide.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback en caso de error al cargar la imagen
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          slide.backgroundColor.withOpacity(0.8),
                          slide.backgroundColor.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getSlideIcon(_currentPage),
                        size: 120,
                        color: auraColor.withOpacity(0.8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Título
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  color: auraColor.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Descripción
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSlideIcon(int index) {
    switch (index) {
      case 0:
        return Icons.store_rounded;
      case 1:
        return Icons.auto_stories_rounded;
      case 2:
        return Icons.security_rounded;
      case 3:
        return Icons.people_rounded;
      default:
        return Icons.store_rounded;
    }
  }

  Widget _buildNavButton(
      String text, {
        required VoidCallback onTap,
        required bool isPrimary,
        required Color auraColor,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
            colors: [
              auraColor,
              auraColor.withOpacity(0.8),
            ],
          )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isPrimary ? auraColor : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: auraColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}

// The edited code snippet provided is a complete replacement for the original
// VMFStoreOnboardingScreen and its associated classes. Therefore, the entire
// content of the edited snippet will be used.
// I will create the OnboardingData class as defined in the edited snippet.
class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final String buttonText;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}