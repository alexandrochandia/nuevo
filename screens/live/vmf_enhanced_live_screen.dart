import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../modules/en_vivo/vmf_live_enhanced_controller.dart';
import '../../models/livestream_model.dart';
import '../../utils/glow_styles.dart';

class VMFEnhancedLiveScreen extends StatefulWidget {
  final String? streamId;
  final bool isHost;

  const VMFEnhancedLiveScreen({
    super.key,
    this.streamId,
    this.isHost = false,
  });

  @override
  State<VMFEnhancedLiveScreen> createState() => _VMFEnhancedLiveScreenState();
}

class _VMFEnhancedLiveScreenState extends State<VMFEnhancedLiveScreen> {
  final VMFLiveEnhancedController controller = Get.put(VMFLiveEnhancedController());
  bool _showControls = true;
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    if (widget.streamId != null && !widget.isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.joinAdvancedStream(widget.streamId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() => Stack(
          children: [
            // Video rendering area
            _buildVideoArea(),

            // Top bar with stream info
            if (_showControls) _buildTopBar(),

            // Chat overlay
            if (_showChat) _buildChatOverlay(),

            // Control buttons
            if (_showControls) _buildControlButtons(),

            // Stream stats overlay
            _buildStatsOverlay(),

            // Loading overlay
            if (controller.isLoading.value) _buildLoadingOverlay(),
          ],
        )),
      ),
    );
  }

  Widget _buildVideoArea() {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: controller.isLive.value
            ? _buildLiveVideo()
            : _buildPreviewScreen(),
      ),
    );
  }

  Widget _buildLiveVideo() {
    return Stack(
      children: [
        // Main video (host or remote)
        if (controller.isHost.value)
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: controller.agoraEngine,
              canvas: const VideoCanvas(uid: 0),
            ),
          )
        else if (controller.remoteUids.isNotEmpty)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: controller.agoraEngine,
              canvas: VideoCanvas(uid: controller.remoteUids.first),
              connection: RtcConnection(channelId: controller.currentChannelName),
            ),
          ),

        // Screen sharing overlay
        if (controller.isScreenSharing.value)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Text(
                'Compartiendo pantalla...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 100,
              color: Colors.white54,
            ),
            const SizedBox(height: 20),
            Text(
              controller.isHost.value
                  ? 'Configurar transmisión'
                  : 'Esperando transmisión...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              controller.connectionState.value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            if (controller.isHost.value && !controller.isLive.value) ...[
              const SizedBox(height: 30),
              _buildStartStreamButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartStreamButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showStartStreamDialog(),
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text(
          'Iniciar Transmisión',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // ✅ Reemplazado primary por backgroundColor
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
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
            // Back button
            IconButton(
              onPressed: () => _showExitDialog(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),

            // Stream info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.isLive.value) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(width: 4),
                          const Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    controller.titleController.text.isNotEmpty
                        ? controller.titleController.text
                        : 'Transmisión VMF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Network quality indicator
            _buildNetworkQualityIndicator(),

            const SizedBox(width: 8),

            // Settings button
            IconButton(
              onPressed: () => _showSettingsDialog(),
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkQualityIndicator() {
    final quality = controller.networkQuality.value;
    Color color;
    IconData icon;

    if (quality >= 0.8) {
      color = Colors.green;
      icon = Icons.signal_wifi_4_bar;
    } else if (quality >= 0.5) {
      color = Colors.orange;
      icon = Icons.network_wifi;
    } else if (quality >= 0.3) {
      color = Colors.red;
      icon = Icons.signal_wifi_bad;
    } else {
      color = Colors.red;
      icon = Icons.signal_wifi_off;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildChatOverlay() {
    return Positioned(
      right: 0,
      top: 80,
      bottom: 120,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Chat header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chat en vivo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showChat = false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) => _buildChatMessage(controller.chatMessages[index]),
              ),
            ),

            // Chat input
            if (controller.enableChat.value) _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(LiveStreamComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: comment.isFromPastor
            ? Colors.purple.withOpacity(0.2)
            : Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (comment.isFromPastor)
                Icon(
                  Icons.verified,
                  color: Colors.purple,
                  size: 16,
                ),
              if (comment.isFromPastor) const SizedBox(width: 4),
              Text(
                comment.userName,
                style: TextStyle(
                  color: comment.isFromPastor ? Colors.purple : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(comment.timestamp),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.chatController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribir mensaje...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: 1,
              onSubmitted: (_) => controller.sendEnhancedChatMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: controller.sendEnhancedChatMessage,
            icon: const Icon(Icons.send, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Chat toggle
          _buildControlButton(
            icon: Icons.chat,
            label: 'Chat',
            isActive: _showChat,
            onPressed: () => setState(() => _showChat = !_showChat),
          ),

          // Audio toggle
          if (controller.isHost.value || controller.isLive.value)
            _buildControlButton(
              icon: controller.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
              label: 'Audio',
              isActive: controller.isAudioEnabled.value,
              onPressed: controller.toggleAdvancedAudio,
            ),

          // Video toggle
          if (controller.isHost.value)
            _buildControlButton(
              icon: controller.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
              label: 'Video',
              isActive: controller.isVideoEnabled.value,
              onPressed: controller.toggleAdvancedVideo,
            ),

          // Camera switch
          if (controller.isHost.value && controller.isVideoEnabled.value)
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              label: 'Cámara',
              onPressed: controller.switchCameraWithAnimation,
            ),

          // End/Leave button
          _buildControlButton(
            icon: Icons.call_end,
            label: controller.isHost.value ? 'Finalizar' : 'Salir',
            isDestructive: true,
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    bool isDestructive = false,
    required VoidCallback onPressed,
  }) {
    final color = isDestructive
        ? Colors.red
        : isActive
        ? Colors.purple
        : Colors.white54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverlay() {
    if (!controller.isLive.value) return const SizedBox();

    return Positioned(
      top: 80,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${controller.viewersCount.value}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  controller.streamDuration.value,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (controller.commentsCount.value > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.commentsCount.value}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              controller.connectionState.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartStreamDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Iniciar Transmisión',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Título de la transmisión',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Ej: Culto Dominical - VMF Sweden',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'Describe el contenido de tu transmisión...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.startAdvancedStreaming(
                title: controller.titleController.text.trim().isNotEmpty
                    ? controller.titleController.text.trim()
                    : 'Transmisión VMF',
                description: controller.descriptionController.text.trim(),
                type: LiveStreamType.culto,
                recordStream: controller.enableRecording.value,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // ✅ Reemplazado primary por backgroundColor
            child: const Text(
              'Iniciar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Configuración de Transmisión',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quality setting
            ListTile(
              leading: const Icon(Icons.hd, color: Colors.white),
              title: const Text('Calidad', style: TextStyle(color: Colors.white)),
              subtitle: Obx(() => Text(
                controller.streamQuality.value,
                style: TextStyle(color: Colors.white70),
              )),
              onTap: () => _showQualitySelector(),
            ),

            // Beauty filters
            if (controller.isHost.value)
              Obx(() => SwitchListTile(
                secondary: const Icon(Icons.face_retouching_natural, color: Colors.white),
                title: const Text('Filtros de belleza', style: TextStyle(color: Colors.white)),
                value: controller.isBeautyEnabled.value,
                onChanged: (_) => controller.toggleBeautyFilters(),
                activeColor: Colors.purple,
              )),

            // Recording
            if (controller.isHost.value)
              Obx(() => SwitchListTile(
                secondary: const Icon(Icons.videocam, color: Colors.white),
                title: const Text('Grabar transmisión', style: TextStyle(color: Colors.white)),
                value: controller.enableRecording.value,
                onChanged: (value) => controller.enableRecording.value = value,
                activeColor: Colors.purple,
              )),

            // Auto moderation
            Obx(() => SwitchListTile(
              secondary: const Icon(Icons.security, color: Colors.white),
              title: const Text('Moderación automática', style: TextStyle(color: Colors.white)),
              value: controller.autoModeration.value,
              onChanged: (value) => controller.autoModeration.value = value,
              activeColor: Colors.purple,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showQualitySelector() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Seleccionar Calidad',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('HD', '720p - Recomendado'),
            _buildQualityOption('FHD', '1080p - Alta calidad'),
            _buildQualityOption('4K', '2160p - Ultra HD'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String quality, String description) {
    return Obx(() => RadioListTile<String>(
      title: Text(quality, style: const TextStyle(color: Colors.white)),
      subtitle: Text(description, style: TextStyle(color: Colors.white70)),
      value: quality,
      groupValue: controller.streamQuality.value,
      onChanged: (value) {
        controller.streamQuality.value = value!;
        Get.back();
      },
      activeColor: Colors.purple,
    ));
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          controller.isHost.value ? 'Terminar Transmisión' : 'Salir de la Transmisión',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          controller.isHost.value
              ? '¿Estás seguro de que quieres terminar la transmisión? Esta acción no se puede deshacer.'
              : '¿Estás seguro de que quieres salir de la transmisión?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (controller.isHost.value) {
                controller.endAdvancedStreaming();
              } else {
                controller.agoraEngine.leaveChannel();
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // ✅ Reemplazado primary por backgroundColor
            child: Text(
              controller.isHost.value ? 'Terminar' : 'Salir',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}h';
    }
  }
}
