import 'package:flutter/material.dart';

class DailyVideoBox extends StatelessWidget {
  const DailyVideoBox({super.key});

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
                // Header con play button
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: isSmallScreen ? 16 : 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                        vertical: isSmallScreen ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NUEVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 8 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Título
                Text(
                  '🎥 Video del Día',
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
                    'Mensaje inspirador\nde hoy:\n"Fe y Esperanza"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 10 : 12,
                      height: 1.3,
                    ),
                  ),
                ),
                
                // Duración y botón
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFFD4AF37),
                      size: isSmallScreen ? 12 : 14,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      '15:30',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37),
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Reproducir video
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
                        foregroundColor: const Color(0xFFD4AF37),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                        ),
                      ),
                      child: Text(
                        'Ver',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
