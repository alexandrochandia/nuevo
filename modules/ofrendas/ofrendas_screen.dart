
import 'package:flutter/material.dart';

class OfrendasScreen extends StatelessWidget {
  const OfrendasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💝 Ofrendas VMF Sweden'),
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
            _buildDonationCard(
              context,
              'Ofrenda General',
              'Apoya el ministerio de VMF Sweden',
              Icons.favorite,
              () => _makeDonation(context, 'general'),
            ),
            const SizedBox(height: 16),
            _buildDonationCard(
              context,
              'Misiones',
              'Evangelización en Suecia',
              Icons.public,
              () => _makeDonation(context, 'misiones'),
            ),
            const SizedBox(height: 16),
            _buildDonationCard(
              context,
              'Construcción',
              'Nuevas casas iglesias',
              Icons.construction,
              () => _makeDonation(context, 'construccion'),
            ),
            const SizedBox(height: 16),
            _buildDonationCard(
              context,
              'Ayuda Social',
              'Apoyo a familias necesitadas',
              Icons.volunteer_activism,
              () => _makeDonation(context, 'social'),
            ),
            const SizedBox(height: 32),
            _buildSwishSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
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
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwishSection(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Donar con Swish',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '123 456 7890',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openSwish(context),
              icon: const Icon(Icons.payment),
              label: const Text('Abrir Swish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makeDonation(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donación: $type'),
        content: const Text('Selecciona el método de pago'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(context, type);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Procesando donación: $type'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  void _openSwish(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo aplicación Swish...'),
        backgroundColor: Color(0xFF1E3A8A),
      ),
    );
  }
}
