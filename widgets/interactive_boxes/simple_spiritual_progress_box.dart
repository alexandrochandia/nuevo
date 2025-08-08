import 'package:flutter/material.dart';

class SpiritualProgressBox extends StatelessWidget {
  const SpiritualProgressBox({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 200;
        final isMediumScreen = constraints.maxWidth < 300;
        
        return Container(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 160 : (isMediumScreen ? 180 : 200),
            maxHeight: isSmallScreen ? 200 : (isMediumScreen ? 220 : 240),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: isSmallScreen ? 10 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
            child: Stack(
              children: [
                // Imagen de fondo
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/espiritual.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A1A1A),
                            Color(0xFF2D2D2D),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Overlay de gradiente para legibilidad
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Contenido
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 10 : (isMediumScreen ? 12 : 16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con nivel
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : (isMediumScreen ? 6 : 8),
                                  vertical: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Nivel 7',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              flex: 2,
                              child: Text(
                                '2,450 pts',
                                style: TextStyle(
                                  color: const Color(0xFFD4AF37),
                                  fontSize: isSmallScreen ? 8 : (isMediumScreen ? 9 : 10),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                
                        
                        SizedBox(height: isSmallScreen ? 6 : (isMediumScreen ? 8 : 10)),
                        
                        // Título
                        Text(
                          '🙏 Progreso Espiritual',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 13),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                
                        
                        SizedBox(height: isSmallScreen ? 6 : (isMediumScreen ? 8 : 10)),
                        
                        // Barra de progreso
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Próximo nivel: 550 pts',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 7 : (isMediumScreen ? 8 : 9),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4)),
                            Container(
                              width: double.infinity,
                              height: isSmallScreen ? 4 : (isMediumScreen ? 5 : 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.75,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                
                        
                        const Spacer(),
                        
                        // Estadísticas rápidas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildStat('🙏', '12', 'Oraciones', isSmallScreen, isMediumScreen),
                            ),
                            Expanded(
                              child: _buildStat('📖', '5', 'Lecturas', isSmallScreen, isMediumScreen),
                            ),
                            Expanded(
                              child: _buildStat('❤️', '8', 'Ayudas', isSmallScreen, isMediumScreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String emoji, String value, String label, bool isSmall, bool isMedium) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          emoji,
          style: TextStyle(
            fontSize: isSmall ? 12 : (isMedium ? 14 : 16),
          ),
        ),
        SizedBox(height: isSmall ? 1 : (isMedium ? 2 : 3)),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFFD4AF37),
            fontSize: isSmall ? 9 : (isMedium ? 10 : 12),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmall ? 1 : 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isSmall ? 6 : (isMedium ? 7 : 8),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
