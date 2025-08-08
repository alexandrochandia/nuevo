import 'package:flutter/material.dart';

class ConnectedBrothersBox extends StatefulWidget {
  const ConnectedBrothersBox({super.key});

  @override
  State<ConnectedBrothersBox> createState() => _ConnectedBrothersBoxState();
}

class _ConnectedBrothersBoxState extends State<ConnectedBrothersBox>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Datos simulados de hermanos conectados
  final List<Map<String, dynamic>> _connectedUsers = [
    {
      'name': 'María',
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      'action': '🔥 vio tu testimonio',
      'time': 'hace 2 min',
      'isOnline': true,
    },
    {
      'name': 'Carlos',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      'action': '💬 comentó en la oración',
      'time': 'hace 5 min',
      'isOnline': true,
    },
    {
      'name': 'Ana',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      'action': '🙏 se unió a la oración',
      'time': 'hace 10 min',
      'isOnline': false,
    },
    {
      'name': 'David',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      'action': '❤️ le gustó tu mensaje',
      'time': 'hace 15 min',
      'isOnline': true,
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
      begin: 1.0,
      end: 1.2,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 200;
        return Container(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 180 : 200,
            maxHeight: isSmallScreen ? 200 : 240,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        color: Colors.black,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'HERMANOS CONECTADOS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  '${_connectedUsers.where((u) => u['isOnline']).length} en línea',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de usuarios conectados
            Expanded(
              child: ListView.builder(
                itemCount: _connectedUsers.length,
                itemBuilder: (context, index) {
                  final user = _connectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Avatar con indicador de estado
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(user['avatar']),
                            ),
                            if (user['isOnline'])
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1A1A1A),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Información del usuario
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    user['time'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user['action'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Botón de acción
                        GestureDetector(
                          onTap: () {
                            // Abrir chat o perfil
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFFD4AF37),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Footer con botón "Ver todos"
            GestureDetector(
              onTap: () {
                // Abrir lista completa de hermanos conectados
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Ver todos los hermanos conectados',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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
