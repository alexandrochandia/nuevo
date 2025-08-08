
import 'package:flutter/material.dart';

class TiendaScreen extends StatelessWidget {
  const TiendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Tienda VMF Sweden'),
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
            _buildCategoryCard(
              context,
              'Productos Religiosos',
              'Biblias, cruces, música cristiana',
              Icons.book,
              () => _navigateToCategory(context, 'religiosos'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Merchandising VMF',
              'Camisetas, gorras, accesorios',
              Icons.shopping_bag,
              () => _navigateToCategory(context, 'merchandising'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Donaciones Especiales',
              'Apoya la misión de VMF Sweden',
              Icons.favorite,
              () => Navigator.pushNamed(context, '/ofrendas'),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard(
              context,
              'Material de Estudio',
              'Libros, guías devocionales',
              Icons.school,
              () => _navigateToCategory(context, 'estudio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String subtitle,
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
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo categoría: $category'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}
