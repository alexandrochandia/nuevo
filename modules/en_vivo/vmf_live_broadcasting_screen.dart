
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'vmf_live_controller.dart';

class VMFLiveBroadcastingScreen extends StatefulWidget {
  final bool isHost;
  final String? channelName;
  final String? streamTitle;
  
  const VMFLiveBroadcastingScreen({
    super.key,
    required this.isHost,
    this.channelName,
    this.streamTitle,
  });

  @override
  State<VMFLiveBroadcastingScreen> createState() => _VMFLiveBroadcastingScreenState();
}

class _VMFLiveBroadcastingScreenState extends State<VMFLiveBroadcastingScreen> {
  final VMFLiveController controller = Get.put(VMFLiveController());
  
  @override
  void initState() {
    super.initState();
    
    if (widget.isHost) {
      _showStartStreamDialog();
    } else if (widget.channelName != null) {
      controller.joinStream(widget.channelName!);
    }
  }
  
  void _showStartStreamDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Icon(Icons.live_tv, color: const Color(0xFFD4AF37), size: 28),
            const SizedBox(width: 12),
            const Text(
              'Iniciar Transmisión VMF',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Título de la transmisión *',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                hintText: 'ej: Estudio Bíblico de hoy',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFD4AF37)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFD4AF37), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                hintText: 'Describe brevemente tu transmisión...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFD4AF37)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFFD4AF37), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : _startStream,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Iniciar Transmisión'),
          )),
        ],
      ),
    );
  }
  
  Future<void> _startStream() async {
    if (controller.titleController.text.trim().isEmpty) {
      Get.snackbar(
        "Campo Requerido",
        "Por favor ingresa un título para la transmisión",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    
    final success = await controller.startStreaming(
      title: controller.titleController.text.trim(),
      description: controller.descriptionController.text.trim(),
    );
    
    if (success && mounted) {
      Navigator.pop(context); // Close dialog
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && !controller.isLive.value) {
            return _buildLoadingScreen();
          }
          
          if (controller.isLive.value) {
            return _buildLiveInterface();
          }
          
          return _buildWaitingScreen();
        }),
      ),
    );
  }
  
  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Preparando transmisión...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'VMF Sweden Live',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaitingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF1A1A1A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.live_tv,
              size: 80,
              color: const Color(0xFFD4AF37),
            ),
            const SizedBox(height: 24),
            const Text(
              'Conectando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'VMF Sweden Live',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLiveInterface() {
    return Stack(
      children: [
        // Video View
        _buildVideoView(),
        
        // Top Bar
        _buildTopBar(),
        
        // Chat Overlay
        Positioned(
          bottom: 120,
          left: 16,
          right: widget.isHost ? 100 : 16,
          child: _buildChatOverlay(),
        ),
        
        // Control Panel
        _buildControlPanel(),
        
        // Host Controls (if host)
        if (widget.isHost) _buildHostControls(),
      ],
    );
  }
  
  Widget _buildVideoView() {
    return SizedBox.expand(
      child: widget.isHost
          ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: controller.agoraEngine,
                canvas: const VideoCanvas(uid: 0),
              ),
            )
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.agoraEngine,
                canvas: const VideoCanvas(uid: 1), // Host UID
                connection: RtcConnection(channelId: controller.currentChannelName),
              ),
            ),
    );
  }
  
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Live Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'EN VIVO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Duration
            Obx(() => Text(
              controller.streamDuration.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
            
            const Spacer(),
            
            // Viewers Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    controller.viewersCount.value.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Close Button
            GestureDetector(
              onTap: _showEndStreamDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatOverlay() {
    return Container(
      height: 200,
      child: Obx(() => ListView.builder(
        reverse: true,
        itemCount: controller.chatMessages.length,
        itemBuilder: (context, index) {
          final message = controller.chatMessages[controller.chatMessages.length - 1 - index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message['isHost'] == true)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'HOST',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    '${message['sender']}: ${message['text']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      )),
    );
  }
  
  Widget _buildControlPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Chat Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller.chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      onPressed: controller.sendChatMessage,
                      icon: const Icon(Icons.send, color: Color(0xFFD4AF37)),
                    ),
                  ),
                  onSubmitted: (_) => controller.sendChatMessage(),
                ),
              ),
            ),
            
            if (!widget.isHost) ...[
              const SizedBox(width: 12),
              // Share Button
              GestureDetector(
                onTap: _shareStream,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildHostControls() {
    return Positioned(
      bottom: 80,
      right: 16,
      child: Column(
        children: [
          // Video Toggle
          Obx(() => _buildControlButton(
            icon: controller.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
            isActive: controller.isVideoEnabled.value,
            onTap: controller.toggleVideo,
          )),
          
          const SizedBox(height: 12),
          
          // Audio Toggle
          Obx(() => _buildControlButton(
            icon: controller.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
            isActive: controller.isAudioEnabled.value,
            onTap: controller.toggleAudio,
          )),
          
          const SizedBox(height: 12),
          
          // Switch Camera
          _buildControlButton(
            icon: Icons.switch_camera,
            isActive: true,
            onTap: controller.switchCamera,
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFFD4AF37)
              : Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? const Color(0xFFD4AF37) : Colors.red).withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
    );
  }
  
  void _showEndStreamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Finalizar Transmisión',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          widget.isHost 
              ? '¿Estás seguro de que quieres finalizar la transmisión?'
              : '¿Quieres salir de la transmisión?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.endStreaming();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(widget.isHost ? 'Finalizar' : 'Salir'),
          ),
        ],
      ),
    );
  }
  
  void _shareStream() {
    // Implementar funcionalidad de compartir
    Get.snackbar(
      "Compartir",
      "Función de compartir transmisión próximamente",
      backgroundColor: const Color(0xFFD4AF37),
      colorText: Colors.black,
    );
  }
}
