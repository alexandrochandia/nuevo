
import 'package:flutter/material.dart';
import '../../utils/glow_styles.dart';

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📅 Eventos VMF Sweden', style: GlowStyles.boldNeonText),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            onPressed: () => _addEvent(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF111827)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildEventCard(
              context,
              'Conferencia VMF 2024',
              'Gran evento anual de VMF Sweden',
              DateTime(2024, 3, 15),
              'Estocolmo',
              Icons.event,
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Noche de Alabanza',
              'Adoración y música cristiana',
              DateTime(2024, 2, 20),
              'Göteborg',
              Icons.music_note,
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Retiro Juvenil',
              'Encuentro para jóvenes',
              DateTime(2024, 2, 25),
              'Malmö',
              Icons.group,
            ),
            const SizedBox(height: 16),
            _buildEventCard(
              context,
              'Conferencia Online',
              'Transmisión por internet',
              DateTime(2024, 3, 5),
              'Virtual',
              Icons.computer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String description,
    DateTime date,
    String location,
    IconData icon,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFFD700),
                  child: Icon(icon, color: const Color(0xFF1E3A8A)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GlowStyles.boldNeonText.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: GlowStyles.boldWhiteText.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  location,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _shareEvent(context, title),
                  child: const Text('Compartir'),
                ),
                ElevatedButton(
                  onPressed: () => _registerEvent(context, title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF1E3A8A),
                  ),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función disponible para administradores'),
        backgroundColor: Color(0xFF1E3A8A),
      ),
    );
  }

  void _registerEvent(BuildContext context, String event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registrado en: $event'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  void _shareEvent(BuildContext context, String event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo: $event'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}
