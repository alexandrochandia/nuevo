import 'package:flutter/material.dart';

class ConnectedBrothersBox extends StatelessWidget {
  const ConnectedBrothersBox({super.key});

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
                // Header con indicador online
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 8 : 10,
                      height: isSmallScreen ? 8 : 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      '24 conectados',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37),
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.people,
                      color: const Color(0xFFD4AF37),
                      size: isSmallScreen ? 16 : 20,
                    ),
                  ],
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Título
                Text(
                  '👥 Hermanos Conectados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Avatares de usuarios conectados
                Expanded(
                  child: Row(
                    children: [
                      // Stack de avatares
                      SizedBox(
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 30 : 40,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: CircleAvatar(
                                radius: isSmallScreen ? 12 : 15,
                                backgroundColor: const Color(0xFFD4AF37),
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: isSmallScreen ? 16 : 20,
                              child: CircleAvatar(
                                radius: isSmallScreen ? 12 : 15,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: isSmallScreen ? 32 : 40,
                              child: CircleAvatar(
                                radius: isSmallScreen ? 12 : 15,
                                backgroundColor: Colors.purple,
                                child: Text(
                                  'J',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: isSmallScreen ? 48 : 60,
                              child: CircleAvatar(
                                radius: isSmallScreen ? 12 : 15,
                                backgroundColor: Colors.grey,
                                child: Text(
                                  '+21',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 8 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de acción
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ver todos los conectados
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
                      'Ver todos',
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
