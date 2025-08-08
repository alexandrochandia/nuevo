import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aura_provider.dart';
import '../../modules/testimonios/testimonios_screen.dart';
import '../../screens/events_screen.dart';
import '../../modules/alabanza/alabanza_screen.dart';

class LiveSection extends StatefulWidget {
  const LiveSection({super.key});

  @override
  State<LiveSection> createState() => _LiveSectionState();
}

class _LiveSectionState extends State<LiveSection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _currentWidgetIndex = 0;
  late PageController _widgetController;

  final List<Map<String, dynamic>> _liveWidgets = [
    {
      'type': 'live_event',
      'title': 'Culto de Jóvenes',
      'subtitle': 'Comienza en 2h 15m',
      'icon': '🔴',
      'color': Colors.red,
    },
    {
      'type': 'visitors',
      'title': '127 miembros',
      'subtitle': 'conectados ahora',
      'icon': '👥',
      'color': Colors.green,
    },
    {
      'type': 'testimony',
      'title': 'Nuevo testimonio',
      'subtitle': 'de María Santos',
      'icon': '💬',
      'color': Colors.blue,
    },
    {
      'type': 'song',
      'title': 'Recomendado',
      'subtitle': 'Renuévame - Miel San Marcos',
      'icon': '🎵',
      'color': Colors.purple,
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
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _widgetController = PageController();
    
    _pulseController.repeat(reverse: true);
    _startAutoRotation();
  }

  void _startAutoRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentWidgetIndex = (_currentWidgetIndex + 1) % _liveWidgets.length;
        });
        _widgetController.animateToPage(
          _currentWidgetIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoRotation();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _widgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = context.watch<AuraProvider>().currentAuraColor;
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'En tiempo real',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 120,
            child: PageView.builder(
              controller: _widgetController,
              itemCount: _liveWidgets.length,
              itemBuilder: (context, index) {
                final widget = _liveWidgets[index];
                
                return AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: auraColor.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget['color'].withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _handleWidgetTap(widget['type']),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Animated Icon
                                Transform.scale(
                                  scale: index == _currentWidgetIndex ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: widget['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: widget['color'],
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget['icon'],
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget['subtitle'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Action Arrow
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: auraColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Progress Indicators
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _liveWidgets.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == _currentWidgetIndex
                      ? auraColor
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleWidgetTap(String type) {
    switch (type) {
      case 'live_event':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsScreen())
        );
        break;
      case 'visitors':
        // Mostrar snackbar con información
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('127 miembros conectados ahora'),
            backgroundColor: Colors.green.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          )
        );
        break;
      case 'testimony':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestimoniosScreen())
        );
        break;
      case 'song':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlabanzaScreen())
        );
        break;
    }
  }
}