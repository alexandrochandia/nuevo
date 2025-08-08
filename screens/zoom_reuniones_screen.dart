import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aura_provider.dart';
import '../utils/glow_styles.dart';

class ZoomReunionesScreen extends StatefulWidget {
  const ZoomReunionesScreen({super.key});

  @override
  State<ZoomReunionesScreen> createState() => _ZoomReunionesScreenState();
}

class _ZoomReunionesScreenState extends State<ZoomReunionesScreen> {
  final List<Map<String, dynamic>> _reuniones = [
    {
      'title': 'Estudio Bíblico Semanal',
      'time': 'Miércoles 19:00',
      'host': 'Pastor Carlos',
      'participants': 23,
      'status': 'scheduled',
      'meetingId': '123-456-789',
      'description': 'Estudio del libro de Romanos',
    },
    {
      'title': 'Oración Matutina',
      'time': 'Lunes a Viernes 07:00',
      'host': 'Hermana María',
      'participants': 15,
      'status': 'live',
      'meetingId': '987-654-321',
      'description': 'Comenzamos el día en oración',
    },
    {
      'title': 'Reunión de Jóvenes',
      'time': 'Sábados 16:00',
      'host': 'Pastor David',
      'participants': 34,
      'status': 'scheduled',
      'meetingId': '456-789-123',
      'description': 'Actividades para jóvenes cristianos',
    },
    {
      'title': 'Consejería Matrimonial',
      'time': 'Domingos 14:00',
      'host': 'Pastora Ana',
      'participants': 8,
      'status': 'private',
      'meetingId': '789-123-456',
      'description': 'Sesiones de consejería para parejas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(auraProvider.currentAuraColor),
                  _buildQuickActions(auraProvider.currentAuraColor),
                  Expanded(
                    child: _buildReunionesLista(),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildCreateMeetingFAB(auraProvider.currentAuraColor),
        );
      },
    );
  }

  Widget _buildHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎧 Zoom Reuniones',
                      style: GlowStyles.boldWhiteText.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Encuentros virtuales de fe',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.video_call,
                color: auraColor,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color auraColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              'Unirse',
              Icons.login,
              auraColor,
              () => _showJoinMeetingDialog(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              'Crear',
              Icons.add_circle,
              Colors.green,
              () => _showCreateMeetingDialog(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              'Programar',
              Icons.schedule,
              Colors.orange,
              () => _showScheduleMeetingDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReunionesLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _reuniones.length,
      itemBuilder: (context, index) {
        final reunion = _reuniones[index];
        return _buildReunionCard(reunion);
      },
    );
  }

  Widget _buildReunionCard(Map<String, dynamic> reunion) {
    Color statusColor = _getStatusColor(reunion['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reunion['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _getStatusText(reunion['status']),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reunion['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  reunion['time'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  reunion['host'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reunion['participants']} personas',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _joinMeeting(reunion),
                    icon: Icon(
                      reunion['status'] == 'live' ? Icons.video_call : Icons.login,
                      size: 16,
                    ),
                    label: Text(
                      reunion['status'] == 'live' ? 'Unirse Ahora' : 'Ver Detalles',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _shareReunion(reunion),
                  icon: const Icon(Icons.share, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateMeetingFAB(Color auraColor) {
    return FloatingActionButton.extended(
      onPressed: () => _showCreateMeetingDialog(),
      backgroundColor: auraColor,
      icon: const Icon(Icons.video_call, color: Colors.white),
      label: const Text(
        'Nueva Reunión',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.red;
      case 'scheduled':
        return Colors.green;
      case 'private':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'live':
        return 'EN VIVO';
      case 'scheduled':
        return 'PROGRAMADA';
      case 'private':
        return 'PRIVADA';
      default:
        return 'INACTIVA';
    }
  }

  void _joinMeeting(Map<String, dynamic> reunion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uniéndose a: ${reunion['title']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReunion(Map<String, dynamic> reunion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo: ${reunion['title']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showJoinMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Unirse a Reunión', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Ingresa el ID de la reunión para unirte.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  void _showCreateMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Crear Reunión', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta función estará disponible próximamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showScheduleMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Programar Reunión', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta función estará disponible próximamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
