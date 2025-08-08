import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_stats_provider.dart';
import '../providers/aura_provider.dart';

class CommunityStatsScreen extends StatefulWidget {
  const CommunityStatsScreen({super.key});

  @override
  State<CommunityStatsScreen> createState() => _CommunityStatsScreenState();
}

class _CommunityStatsScreenState extends State<CommunityStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommunityStatsProvider, AuraProvider>(
      builder: (context, statsProvider, auraProvider, child) {
        final stats = statsProvider.stats;
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Pulso de la Comunidad VMF',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: auraColor),
                onPressed: () => statsProvider.refreshStats(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => statsProvider.refreshStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Real-time pulse indicator
                  _buildPulseIndicator(auraColor),
                  const SizedBox(height: 30),
                  
                  // Main stats grid
                  _buildStatsGrid(stats, auraColor),
                  const SizedBox(height: 30),
                  
                  // Recent activity feed
                  _buildActivityFeed(stats, auraColor),
                  const SizedBox(height: 30),
                  
                  // Engagement analytics
                  _buildEngagementSection(stats, auraColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseIndicator(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: auraColor.withOpacity(0.1),
                    border: Border.all(color: auraColor.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: auraColor,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Comunidad VMF activa',
            style: TextStyle(
              color: auraColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Consumer<CommunityStatsProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.stats.onlineNow} miembros conectados',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats, Color auraColor) {
    final statItems = [
      {'title': 'Miembros Activos', 'value': stats.activeMembersDisplay, 'icon': Icons.people},
      {'title': 'Visitas Hoy', 'value': stats.dailyVisitsDisplay, 'icon': Icons.visibility},
      {'title': 'Testimonios', 'value': '${stats.weeklyTestimonios}', 'icon': Icons.record_voice_over},
      {'title': 'Oraciones', 'value': '${stats.prayersAnswered}', 'icon': Icons.favorite},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: auraColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: auraColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'] as IconData,
                color: auraColor,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                item['value'] as String,
                style: TextStyle(
                  color: auraColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item['title'] as String,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityFeed(dynamic stats, Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: TextStyle(
              color: auraColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.recentActivities.map<Widget>((activity) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: auraColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEngagementSection(dynamic stats, Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participación Comunitaria',
            style: TextStyle(
              color: auraColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel de Participación',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.engagementDisplay,
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: auraColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: auraColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Próximo\nEvento',
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stats.nextEvent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}