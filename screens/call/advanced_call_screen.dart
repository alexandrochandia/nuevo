
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../services/advanced_call_service.dart';
import '../../models/call_models.dart';
import '../../utils/glow_styles.dart';

class AdvancedCallScreen extends StatefulWidget {
  final String? callId;
  final bool isIncoming;
  final IncomingCall? incomingCall;
  
  const AdvancedCallScreen({
    super.key,
    this.callId,
    this.isIncoming = false,
    this.incomingCall,
  });

  @override
  State<AdvancedCallScreen> createState() => _AdvancedCallScreenState();
}

class _AdvancedCallScreenState extends State<AdvancedCallScreen> 
    with TickerProviderStateMixin {
  final AdvancedCallService callService = Get.find();
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  bool _showControls = true;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0,
    );
    
    if (widget.isIncoming && widget.incomingCall != null) {
      _handleIncomingCall();
    }
    
    // Auto-hide controls after 5 seconds
    _startControlsTimer();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  void _handleIncomingCall() {
    // Handle incoming call logic
  }
  
  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && callService.isInCall.value) {
        setState(() => _showControls = false);
        _fadeController.animateTo(0.0);
      }
    });
  }
  
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    _fadeController.animateTo(_showControls ? 1.0 : 0.0);
    
    if (_showControls) {
      _startControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Stack(
        children: [
          // Video area
          _buildVideoArea(),
          
          // Minimized call overlay
          if (callService.isCallMinimized.value) _buildMinimizedOverlay(),
          
          // Call controls
          if (!callService.isCallMinimized.value) _buildCallControls(),
          
          // Participants grid for group calls
          if (callService.callType.value == 'group' && !callService.isCallMinimized.value)
            _buildParticipantsGrid(),
          
          // Network quality indicator
          _buildNetworkIndicator(),
          
          // Call info overlay
          _buildCallInfoOverlay(),
        ],
      )),
    );
  }
  
  Widget _buildVideoArea() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: callService.participants.isNotEmpty
            ? _buildMainVideo()
            : _buildWaitingScreen(),
      ),
    );
  }
  
  Widget _buildMainVideo() {
    final mainParticipant = callService.participants.firstWhere(
      (p) => p.uid != 0,
      orElse: () => callService.participants.first,
    );
    
    return Stack(
      children: [
        // Main video view
        if (mainParticipant.isVideoEnabled && mainParticipant.uid != 0)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: callService.agoraEngine,
              canvas: VideoCanvas(uid: mainParticipant.uid),
              connection: RtcConnection(channelId: callService.currentChannelName),
            ),
          )
        else
          _buildAvatarView(mainParticipant),
        
        // Local video preview
        if (callService.isVideoEnabled.value && !callService.isCallMinimized.value)
          _buildLocalVideoPreview(),
        
        // Audio-only overlay
        if (callService.callType.value == 'audio')
          _buildAudioOnlyOverlay(mainParticipant),
      ],
    );
  }
  
  Widget _buildLocalVideoPreview() {
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: callService.agoraEngine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAvatarView(CallParticipant participant) {
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
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5 + (_pulseController.value * 0.5)),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: participant.avatar != null
                          ? NetworkImage(participant.avatar!)
                          : null,
                      child: participant.avatar == null
                          ? Text(
                              participant.name.characters.first.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              participant.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAudioOnlyOverlay(CallParticipant participant) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Llamada de audio',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              participant.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaitingScreen() {
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Conectando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCallControls() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Audio toggle
                _buildControlButton(
                  icon: callService.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
                  onTap: callService.toggleAudio,
                  backgroundColor: callService.isAudioEnabled.value 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.red,
                ),
                
                // Video toggle (only for video calls)
                if (callService.callType.value != 'audio')
                  _buildControlButton(
                    icon: callService.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
                    onTap: callService.toggleVideo,
                    backgroundColor: callService.isVideoEnabled.value 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.red,
                  ),
                
                // End call
                _buildControlButton(
                  icon: Icons.call_end,
                  onTap: () async {
                    await callService.endCall();
                    Get.back();
                  },
                  backgroundColor: Colors.red,
                  size: 70,
                ),
                
                // Speaker toggle
                _buildControlButton(
                  icon: callService.isSpeakerEnabled.value ? Icons.volume_up : Icons.volume_down,
                  onTap: callService.toggleSpeaker,
                  backgroundColor: callService.isSpeakerEnabled.value 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                ),
                
                // More options
                _buildControlButton(
                  icon: Icons.more_vert,
                  onTap: _showMoreOptions,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
  
  Widget _buildParticipantsGrid() {
    if (callService.participants.length <= 2) return const SizedBox();
    
    return Positioned(
      right: 20,
      top: 100,
      child: Container(
        width: 200,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: callService.participants.length.clamp(0, 6),
          itemBuilder: (context, index) {
            final participant = callService.participants[index];
            return _buildParticipantTile(participant);
          },
        ),
      ),
    );
  }
  
  Widget _buildParticipantTile(CallParticipant participant) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: participant.isSpeaking ? Colors.green : Colors.white54,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            if (participant.isVideoEnabled && participant.uid != 0)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: callService.agoraEngine,
                  canvas: VideoCanvas(uid: participant.uid),
                  connection: RtcConnection(channelId: callService.currentChannelName),
                ),
              )
            else
              Container(
                color: Colors.grey[800],
                child: Center(
                  child: CircleAvatar(
                    radius: 20,
                    child: Text(
                      participant.name.characters.first.toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            
            // Participant info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Text(
                  participant.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Audio indicator
            if (!participant.isAudioEnabled)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.mic_off,
                  color: Colors.red,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMinimizedOverlay() {
    return Positioned(
      top: 50,
      right: 20,
      child: GestureDetector(
        onTap: callService.toggleCallMinimized,
        child: Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Mini video
                if (callService.participants.isNotEmpty)
                  AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: callService.agoraEngine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                
                // Call duration
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(callService.callDuration.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNetworkIndicator() {
    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getNetworkIcon(callService.networkQuality.value),
              color: _getNetworkColor(callService.networkQuality.value),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              callService.connectionState.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCallInfoOverlay() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Call duration
          Text(
            _formatDuration(callService.callDuration.value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Participant count for group calls
          if (callService.callType.value == 'group')
            Text(
              '${callService.participants.length} participantes',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
  
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                callService.isRecording.value ? Icons.stop : Icons.fiber_manual_record,
                color: callService.isRecording.value ? Colors.red : Colors.grey,
              ),
              title: Text(
                callService.isRecording.value ? 'Detener grabación' : 'Grabar llamada',
              ),
              onTap: () {
                callService.toggleRecording();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                callService.isScreenSharing.value ? Icons.stop_screen_share : Icons.screen_share,
                color: Colors.blue,
              ),
              title: Text(
                callService.isScreenSharing.value ? 'Dejar de compartir' : 'Compartir pantalla',
              ),
              onTap: () {
                callService.toggleScreenSharing();
                Navigator.pop(context);
              },
            ),
            if (callService.callType.value != 'audio')
              ListTile(
                leading: const Icon(Icons.flip_camera_ios, color: Colors.green),
                title: const Text('Cambiar cámara'),
                onTap: () {
                  callService.switchCamera();
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: Icon(
                callService.isCallMinimized.value ? Icons.fullscreen : Icons.fullscreen_exit,
                color: Colors.orange,
              ),
              title: Text(
                callService.isCallMinimized.value ? 'Maximizar' : 'Minimizar',
              ),
              onTap: () {
                callService.toggleCallMinimized();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  IconData _getNetworkIcon(double quality) {
    if (quality >= 0.8) return Icons.signal_wifi_4_bar;
    if (quality >= 0.6) return Icons.signal_wifi_3_bar;
    if (quality >= 0.4) return Icons.signal_wifi_2_bar;
    if (quality >= 0.2) return Icons.signal_wifi_1_bar;
    return Icons.signal_wifi_0_bar;
  }
  
  Color _getNetworkColor(double quality) {
    if (quality >= 0.8) return Colors.green;
    if (quality >= 0.6) return Colors.yellow;
    if (quality >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
