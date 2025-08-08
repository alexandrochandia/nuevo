import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vmf_connect_controller.dart';

class VMFConnectHeader extends StatelessWidget {
  final VMFConnectController controller;

  const VMFConnectHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo VMF
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.church,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'VMF Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Botones de acción
          Row(
            children: [
              // Botón de búsqueda
              IconButton(
                onPressed: () => _showSearchModal(context),
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              // Botón de filtros
              IconButton(
                onPressed: () => _showFiltersModal(context),
                icon: const Icon(
                  Icons.tune,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              
              // Botón de notificaciones
              Stack(
                children: [
                  IconButton(
                    onPressed: () => _showNotifications(context),
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  // Indicador de notificaciones nuevas
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Título
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Buscar en VMF Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar testimonios, alabanzas...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Búsquedas populares
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Búsquedas populares:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '#testimonio',
                      '#alabanza',
                      '#predicacion',
                      '#oracion',
                      '#reflexion',
                    ].map((tag) => _buildSearchTag(tag)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTag(String tag) {
    return GestureDetector(
      onTap: () {
        // Implementar búsqueda por tag
        Get.back();
        Get.snackbar(
          'Búsqueda',
          'Buscando: $tag',
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
          colorText: Colors.white,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.5),
          ),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showFiltersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Título
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filtrar contenido',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Opciones de filtro
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterOption('🙏 Testimonios', true),
                  _buildFilterOption('✝️ Predicaciones', true),
                  _buildFilterOption('🎵 Alabanzas', true),
                  _buildFilterOption('💭 Reflexiones', false),
                  _buildFilterOption('🕊️ Oraciones', false),
                  _buildFilterOption('🏛️ Eventos', true),
                  _buildFilterOption('😊 Comedia cristiana', false),
                ],
              ),
            ),
            
            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.refreshPosts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        value: isSelected,
        onChanged: (value) {
          // Implementar lógica de filtros
        },
        activeColor: const Color(0xFFD4AF37),
        checkColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    Get.snackbar(
      'Notificaciones',
      'Próximamente: notificaciones de VMF Connect',
      backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
