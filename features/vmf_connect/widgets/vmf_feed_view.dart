import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/vmf_connect_controller.dart';
import '../models/vmf_post_model.dart';
import 'vmf_video_card.dart';

class VMFFeedView extends StatelessWidget {
  final VMFConnectController controller;

  const VMFFeedView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.posts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4AF37),
          ),
        );
      }

      if (controller.posts.isEmpty) {
        return _buildEmptyState();
      }

      return PageView.builder(
        controller: controller.pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          controller.currentIndex.value = index;
          
          // Cargar más posts cuando esté cerca del final
          if (index >= controller.posts.length - 3) {
            controller.loadMorePosts();
          }
        },
        itemCount: controller.posts.length,
        itemBuilder: (context, index) {
          final post = controller.posts[index];
          return VMFVideoCard(
            post: post,
            controller: controller,
            isCurrentPage: controller.currentIndex.value == index,
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono grande
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library_outlined,
              size: 60,
              color: Color(0xFFD4AF37),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Título
          const Text(
            '¡Bienvenido a VMF Connect!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Descripción
          const Text(
            'Comparte tu testimonio, alabanzas y momentos de fe con la comunidad VMF',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Botón para crear primer contenido
          ElevatedButton.icon(
            onPressed: () => controller.openCreateContent(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Crear mi primer video',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón para refrescar
          TextButton.icon(
            onPressed: () => controller.refreshPosts(),
            icon: const Icon(
              Icons.refresh,
              color: Colors.grey,
            ),
            label: const Text(
              'Actualizar feed',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Categorías sugeridas
          const Text(
            'Categorías populares:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: VMFPostType.values.take(4).map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color(int.parse(type.color.replaceAll('#', '0xFF')))
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(int.parse(type.color.replaceAll('#', '0xFF')))
                        .withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: Color(int.parse(type.color.replaceAll('#', '0xFF'))),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
