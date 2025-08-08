import 'package:flutter/material.dart';

class LiveWorshipMapBox extends StatelessWidget {
  const LiveWorshipMapBox({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 200;
        return Container(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 160 : 180,
            maxHeight: isSmallScreen ? 180 : 220,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF2D2D2D),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: isSmallScreen ? 10 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12,
                        vertical: isSmallScreen ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.live_tv,
                            color: Colors.black,
                            size: isSmallScreen ? 12 : 16,
                          ),
                          SizedBox(width: isSmallScreen ? 4 : 6),
                          Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFFD4AF37),
                      size: isSmallScreen ? 16 : 20,
                    ),
                  ],
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Título
                Text(
                  '🗺️ Mapa en Vivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 4 : 6),
                
                // Descripción
                Expanded(
                  child: Text(
                    'Próximo culto:\nDomingo 19:00\nEstocolmo, Suecia',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 10 : 12,
                      height: 1.3,
                    ),
                  ),
                ),
                
                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Abrir Google Maps
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
                      foregroundColor: const Color(0xFFD4AF37),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                      ),
                    ),
                    child: Text(
                      'Ver ubicación',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
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
}
