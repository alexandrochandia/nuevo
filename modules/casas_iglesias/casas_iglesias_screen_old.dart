
import 'package:flutter/material.dart';

class CasasIglesiasScreen extends StatelessWidget {
  const CasasIglesiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Casas Iglesias VMF'),
        backgroundColor: const Color(0xFF1E3A8A),
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
            _buildLocationCard(
              context,
              'Estocolmo Centro',
              'Drottninggatan 45, Stockholm',
              'Domingos 11:00 AM',
              Icons.location_city,
            ),
            const SizedBox(height: 16),
            _buildLocationCard(
              context,
              'Göteborg Casa de Oración',
              'Avenyn 23, Göteborg',
              'Miércoles 7:00 PM',
              Icons.home_work,
            ),
            const SizedBox(height: 16),
            _buildLocationCard(
              context,
              'Malmö Comunidad',
              'Södergatan 12, Malmö',
              'Viernes 6:30 PM',
              Icons.church,
            ),
            const SizedBox(height: 16),
            _buildLocationCard(
              context,
              'Uppsala Casa VMF',
              'Kungsgatan 8, Uppsala',
              'Sábados 5:00 PM',
              Icons.house,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openMap(context),
                icon: const Icon(Icons.map),
                label: const Text('Ver Mapa Completo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    String name,
    String address,
    String schedule,
    IconData icon,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _contactLocation(context, name),
              icon: const Icon(Icons.phone, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _openMap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo mapa con todas las ubicaciones...'),
        backgroundColor: Color(0xFF1E3A8A),
      ),
    );
  }

  void _contactLocation(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactando: $name'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}
