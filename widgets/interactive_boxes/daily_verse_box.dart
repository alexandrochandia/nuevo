import 'package:flutter/material.dart';

class DailyVerseBox extends StatefulWidget {
  const DailyVerseBox({super.key});

  @override
  State<DailyVerseBox> createState() => _DailyVerseBoxState();
}

class _DailyVerseBoxState extends State<DailyVerseBox> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isRevealed = false;

  // Versículos del día
  final List<Map<String, String>> _verses = [
    {
      'text': '"Porque yo sé los pensamientos que tengo acerca de vosotros, dice Jehová, pensamientos de paz, y no de mal, para daros el fin que esperáis."',
      'reference': 'Jeremías 29:11',
    },
    {
      'text': '"Todo lo puedo en Cristo que me fortalece."',
      'reference': 'Filipenses 4:13',
    },
    {
      'text': '"Confía en Jehová de todo tu corazón, y no te apoyes en tu propia prudencia."',
      'reference': 'Proverbios 3:5',
    },
  ];

  late Map<String, String> _currentVerse;

  @override
  void initState() {
    super.initState();

    // Seleccionar versículo aleatorio
    _currentVerse = _verses[DateTime.now().day % _verses.length];

    // Configurar animaciones
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animación de pulso
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _revealVerse() {
    if (!_isRevealed) {
      setState(() {
        _isRevealed = true;
      });
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        return GestureDetector(
          onTap: _revealVerse,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRevealed ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: isSmallScreen ? 120 : 140,
                    maxHeight: isSmallScreen ? 140 : 160,
                  ),
                  margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isRevealed
                          ? [
                              const Color(0xFF1A1A1A),
                              const Color(0xFF2D2D2D),
                            ]
                          : [
                              const Color(0xFFD4AF37).withOpacity(0.3),
                              const Color(0xFF1A1A1A),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(_isRevealed ? 0.3 : 0.6),
                        blurRadius: _isRevealed ? 15 : 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: _isRevealed
                          ? _buildRevealedContent(isSmallScreen)
                          : _buildHiddenContent(isSmallScreen),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRevealedContent(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono
        Icon(
          Icons.auto_stories,
          color: const Color(0xFFD4AF37),
          size: isSmallScreen ? 20 : 24,
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),

        // Texto del versículo
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              _currentVerse['text']!,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 4 : 6),

        // Referencia
        Text(
          _currentVerse['reference']!,
          style: TextStyle(
            color: const Color(0xFFD4AF37),
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHiddenContent(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono mágico
        Icon(
          Icons.auto_fix_high,
          color: const Color(0xFFD4AF37),
          size: isSmallScreen ? 28 : 32,
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),

        // Texto de invitación
        Text(
          '✨ Versículo del Día ✨',
          style: TextStyle(
            color: const Color(0xFFD4AF37),
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),

        Text(
          'Toca para revelar',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }
}
