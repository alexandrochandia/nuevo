import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vmf_sweden_swipe/features/vmf_connect/controllers/vmf_connect_controller.dart';
import 'package:vmf_sweden_swipe/features/vmf_connect/widgets/vmf_feed_view.dart';
import 'package:vmf_sweden_swipe/features/vmf_connect/screens/vmf_create_content_screen.dart';

class VMFConnectScreen extends StatelessWidget {
  const VMFConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VMFConnectController());
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'VMF Connect',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFFD4AF37), size: 20),
              onPressed: () {
                // TODO: Implementar búsqueda
                Get.snackbar(
                  'Próximamente',
                  'Función de búsqueda en desarrollo',
                  backgroundColor: const Color(0xFFD4AF37).withOpacity(0.9),
                  colorText: Colors.black,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFFD4AF37), size: 20),
              onPressed: () {
                // TODO: Implementar notificaciones
                Get.snackbar(
                  'Próximamente',
                  'Sistema de notificaciones en desarrollo',
                  backgroundColor: const Color(0xFFD4AF37).withOpacity(0.9),
                  colorText: Colors.black,
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo con gradiente sutil
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF1A1A1A),
                  Color(0xFF0A0A0A),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Contenido principal
          VMFFeedView(controller: Get.find<VMFConnectController>()),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(
              () => const VMFCreateContentScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }
}
