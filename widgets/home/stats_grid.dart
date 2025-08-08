import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aura_provider.dart';
import '../../providers/user_provider.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final auraColor = context.watch<AuraProvider>().currentAuraColor;
    final userProvider = context.watch<UserProvider>();
    
    final stats = [
      {'title': 'Miembros', 'value': '${userProvider.onlineUsersCount}', 'subtitle': 'conectados', 'icon': '👥'},
      {'title': 'Eventos', 'value': '3', 'subtitle': 'esta semana', 'icon': '📅'},
      {'title': 'Testimonios', 'value': '${userProvider.newUsersCount}', 'subtitle': 'nuevos', 'icon': '💬'},
      {'title': 'Total', 'value': '${userProvider.totalUsers}', 'subtitle': 'miembros', 'icon': '🙏'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: auraColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat['icon']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['value']!,
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    stat['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    stat['subtitle']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}