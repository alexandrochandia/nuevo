
import 'package:flutter/material.dart';

class ZoomScreen extends StatelessWidget {
  const ZoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎥 Reuniones Zoom VMF'),
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
            _buildQuickJoinCard(),
            const SizedBox(height: 24),
            _buildScheduledMeetings(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickJoinCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.video_call,
              color: Color(0xFFFFD700),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unirse a Reunión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'ID de reunión',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _joinMeeting(),
              icon: const Icon(Icons.video_call),
              label: const Text('Unirse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1E3A8A),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledMeetings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reuniones Programadas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildMeetingCard(
          'Servicio Dominical VMF',
          'Domingo 11:00 AM',
          'ID: 123 456 789',
          Icons.church,
        ),
        const SizedBox(height: 12),
        _buildMeetingCard(
          'Estudio Bíblico',
          'Miércoles 7:00 PM',
          'ID: 987 654 321',
          Icons.menu_book,
        ),
        const SizedBox(height: 12),
        _buildMeetingCard(
          'Oración Matutina',
          'Viernes 6:00 AM',
          'ID: 456 789 123',
          Icons.favorite,
        ),
        const SizedBox(height: 12),
        _buildMeetingCard(
          'Reunión de Jóvenes',
          'Sábado 6:00 PM',
          'ID: 321 654 987',
          Icons.group,
        ),
      ],
    );
  }

  Widget _buildMeetingCard(
    String title,
    String time,
    String meetingId,
    IconData icon,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFD700),
          child: Icon(icon, color: const Color(0xFF1E3A8A)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              meetingId,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _joinSpecificMeeting(meetingId),
          icon: const Icon(Icons.video_call, color: Colors.white),
        ),
      ),
    );
  }

  void _joinMeeting() {
    // Implementar lógica para unirse a reunión
  }

  void _joinSpecificMeeting(String meetingId) {
    // Implementar lógica para unirse a reunión específica
  }
}
