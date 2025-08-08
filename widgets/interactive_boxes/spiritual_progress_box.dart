import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SpiritualProgressBox extends StatefulWidget {
  const SpiritualProgressBox({super.key});

  @override
  State<SpiritualProgressBox> createState() => _SpiritualProgressBoxState();
}

class _SpiritualProgressBoxState extends State<SpiritualProgressBox>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Datos de progreso espiritual
  final Map<String, dynamic> _progressData = {
    'totalProgress': 0.75, // 75% completado
    'points': 1250,
    'level': 'Discípulo',
    'nextLevel': 'Maestro',
    'pointsToNext': 250,
    'tasks': [
      {
        'name': 'Perfil Completo',
        'icon': Icons.person,
        'completed': true,
        'progress': 1.0,
      },
      {
        'name': 'Primer Testimonio',
        'icon': Icons.record_voice_over,
        'completed': true,
        'progress': 1.0,
      },
      {
        'name': 'Oración Diaria',
        'icon': Icons.favorite,
        'completed': false,
        'progress': 0.6, // 18/30 días
      },
      {
        'name': 'Comunidad Activa',
        'icon': Icons.people,
        'completed': false,
        'progress': 0.4, // 4/10 interacciones
      },
    ],
    'achievements': [
      {
        'name': 'Primer Testimonio',
        'icon': '🎤',
        'unlocked': true,
      },
      {
        'name': '30 días orando',
        'icon': '🙏',
        'unlocked': false,
      },
      {
        'name': 'Corazón de Oro',
        'icon': '💛',
        'unlocked': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _progressData['totalProgress'],
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
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
            // Header con nivel y puntos
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
                        Icons.trending_up,
                        color: Colors.black,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'MI PROGRESO',
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_progressData['points']} pts',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progreso principal circular
            Row(
              children: [
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CircularPercentIndicator(
                      radius: 35.0,
                      lineWidth: 6.0,
                      animation: false,
                      percent: _progressAnimation.value,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _progressData['level'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: const Color(0xFFD4AF37),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel: ${_progressData['level']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Próximo: ${_progressData['nextLevel']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        width: 120,
                        lineHeight: 6.0,
                        percent: 0.8, // 250/300 puntos para siguiente nivel
                        backgroundColor: Colors.white.withOpacity(0.2),
                        progressColor: const Color(0xFFD4AF37),
                        barRadius: const Radius.circular(3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_progressData['pointsToNext']} pts para siguiente nivel',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tareas de progreso
            const Text(
              'Tareas Espirituales:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: _progressData['tasks'].length,
                itemBuilder: (context, index) {
                  final task = _progressData['tasks'][index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          task['icon'],
                          color: task['completed'] 
                              ? const Color(0xFFD4AF37)
                              : Colors.white.withOpacity(0.5),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task['name'],
                                style: TextStyle(
                                  color: task['completed'] 
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              LinearPercentIndicator(
                                width: 100,
                                lineHeight: 3.0,
                                percent: task['progress'],
                                backgroundColor: Colors.white.withOpacity(0.2),
                                progressColor: task['completed'] 
                                    ? Colors.green
                                    : const Color(0xFFD4AF37),
                                barRadius: const Radius.circular(2),
                              ),
                            ],
                          ),
                        ),
                        if (task['completed'])
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Logros desbloqueados
            Row(
              children: [
                const Text(
                  'Logros: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ..._progressData['achievements'].map<Widget>((achievement) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: achievement['unlocked'] 
                            ? const Color(0xFFD4AF37).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement['icon'],
                        style: TextStyle(
                          fontSize: 16,
                          color: achievement['unlocked'] 
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
