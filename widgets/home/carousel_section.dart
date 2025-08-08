import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aura_provider.dart';
import '../../modules/testimonios/testimonios_screen.dart';
import '../../screens/events_screen.dart';
import '../../modules/casas_iglesias/casas_iglesias_screen.dart';
import '../../modules/alabanza/alabanza_screen.dart';

class CarouselSection extends StatefulWidget {
  const CarouselSection({super.key});

  @override
  State<CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<CarouselSection> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Testimonios',
      'subtitle': 'Comparte tu fe',
      'icon': '💬',
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      'action': 'testimonios',
    },
    {
      'title': 'Eventos VMF',
      'subtitle': 'Próximos encuentros',
      'icon': '📅',
      'gradient': [Color(0xFF6c5ce7), Color(0xFF74b9ff)],
      'action': 'eventos',
    },
    {
      'title': 'Casas Iglesias',
      'subtitle': 'Encuentra tu comunidad',
      'icon': '⛪',
      'gradient': [Color(0xFF00b894), Color(0xFF00cec9)],
      'action': 'iglesias',
    },
    {
      'title': 'Alabanza',
      'subtitle': 'Música cristiana',
      'icon': '🎵',
      'gradient': [Color(0xFFfd79a8), Color(0xFFfdcb6e)],
      'action': 'alabanza',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = context.watch<AuraProvider>().currentAuraColor;
    
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          final isActive = index == _currentPage;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: isActive ? 0 : 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: section['gradient'],
              ),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(isActive ? 0.4 : 0.2),
                  blurRadius: isActive ? 20 : 10,
                  spreadRadius: isActive ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _handleSectionTap(section['action']),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        section['icon'],
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        section['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section['subtitle'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explorar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSectionTap(String action) {
    switch (action) {
      case 'testimonios':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestimoniosScreen())
        );
        break;
      case 'eventos':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsScreen())
        );
        break;
      case 'iglesias':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CasasIglesiasScreen())
        );
        break;
      case 'alabanza':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlabanzaScreen())
        );
        break;
    }
  }
}