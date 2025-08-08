import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EventStatsWidget extends StatefulWidget {
  final int totalEvents;
  final int upcomingEvents;
  final int ongoingEvents;
  final int totalAttendees;

  const EventStatsWidget({
    Key? key,
    required this.totalEvents,
    required this.upcomingEvents,
    required this.ongoingEvents,
    required this.totalAttendees,
  }) : super(key: key);

  @override
  State<EventStatsWidget> createState() => _EventStatsWidgetState();
}

class _EventStatsWidgetState extends State<EventStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.2,
          0.8 + (index * 0.05),
          curve: Curves.elasticOut,
        ),
      ));
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Estadísticas de Eventos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'En vivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _animations[0],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animations[0].value,
                      child: _buildStatCard(
                        'Total Eventos',
                        widget.totalEvents.toString(),
                        Icons.event,
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animations[1],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animations[1].value,
                      child: _buildStatCard(
                        'Próximos',
                        widget.upcomingEvents.toString(),
                        Icons.schedule,
                        Colors.blue[100]!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _animations[2],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animations[2].value,
                      child: _buildStatCard(
                        'En Curso',
                        widget.ongoingEvents.toString(),
                        Icons.play_circle,
                        Colors.green[100]!,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animations[3],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animations[3].value,
                      child: _buildStatCard(
                        'Asistentes',
                        widget.totalAttendees.toString(),
                        Icons.people,
                        Colors.orange[100]!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
