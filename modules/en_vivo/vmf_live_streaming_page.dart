
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'youtube_streaming_controller.dart';

class VMFLiveStreamingPage extends StatefulWidget {
  final String liveID;
  final bool isHost;
  final String userID;
  final String userName;

  const VMFLiveStreamingPage({
    Key? key,
    required this.liveID,
    this.isHost = false,
    required this.userID,
    required this.userName,
  }) : super(key: key);

  @override
  State<VMFLiveStreamingPage> createState() => _VMFLiveStreamingPageState();
}

class _VMFLiveStreamingPageState extends State<VMFLiveStreamingPage> {
  final YoutubeStreamingController _youtubeController = YoutubeStreamingController();
  bool _isYoutubeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Stack(
          children: [
            // ZEGO Live Streaming
            ZegoUIKitPrebuiltLiveStreaming(
              appID: 1234567890, // Reemplaza con tu ZEGO App ID
              appSign: 'your_app_sign_here', // Reemplaza con tu ZEGO App Sign
              userID: widget.userID,
              userName: widget.userName,
              liveID: widget.liveID,
              config: widget.isHost
                  ? ZegoUIKitPrebuiltLiveStreamingConfig.host(
                      plugins: [ZegoUIKitSignalingPlugin()],
                      audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
                        showAvatarInAudioMode: true,
                        showSoundWavesInAudioMode: true,
                      ),
                      topMenuBarConfig: ZegoTopMenuBarConfig(
                        buttons: [
                          ZegoMenuBarButtonName.minimizingButton,
                          ZegoMenuBarButtonName.showMemberListButton,
                        ],
                        title: 'VMF Sweden Live 🔴',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: const Color(0xFF2C2C2C),
                      ),
                      bottomMenuBarConfig: ZegoBottomMenuBarConfig(
                        buttons: [
                          ZegoMenuBarButtonName.toggleCameraButton,
                          ZegoMenuBarButtonName.toggleMicrophoneButton,
                          ZegoMenuBarButtonName.switchCameraButton,
                          ZegoMenuBarButtonName.coHostControlButton,
                        ],
                        backgroundColor: const Color(0xFF2C2C2C),
                      ),
                      confirmDialogInfo: ZegoDialogInfo(
                        title: 'Finalizar transmisión',
                        message: '¿Estás seguro de que quieres finalizar la transmisión en vivo?',
                        cancelButtonName: 'Cancelar',
                        confirmButtonName: 'Finalizar',
                      ),
                    )
                  : ZegoUIKitPrebuiltLiveStreamingConfig.audience(
                      plugins: [ZegoUIKitSignalingPlugin()],
                      audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
                        showAvatarInAudioMode: true,
                        showSoundWavesInAudioMode: true,
                      ),
                      topMenuBarConfig: ZegoTopMenuBarConfig(
                        buttons: [
                          ZegoMenuBarButtonName.minimizingButton,
                        ],
                        title: 'VMF Sweden Live 🔴',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: const Color(0xFF2C2C2C),
                      ),
                      bottomMenuBarConfig: ZegoBottomMenuBarConfig(
                        buttons: [
                          ZegoMenuBarButtonName.coHostControlButton,
                          ZegoMenuBarButtonName.toggleMicrophoneButton,
                        ],
                        backgroundColor: const Color(0xFF2C2C2C),
                      ),
                    ),
            ),
            
            // VMF Branding Overlay
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'VMF SWEDEN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // YouTube Stream Controls (solo para hosts)
            if (widget.isHost)
              Positioned(
                bottom: 100,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      onPressed: _toggleYoutubeStream,
                      backgroundColor: _isYoutubeEnabled ? Colors.red : Colors.grey,
                      child: Icon(
                        _isYoutubeEnabled ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isYoutubeEnabled ? 'YouTube ON' : 'YouTube OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  void _toggleYoutubeStream() async {
    try {
      if (_isYoutubeEnabled) {
        await _youtubeController.stopYoutubeStream();
        setState(() => _isYoutubeEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transmisión de YouTube detenida')),
        );
      } else {
        await _youtubeController.startYoutubeStream(widget.liveID);
        setState(() => _isYoutubeEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transmisión de YouTube iniciada')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    if (_isYoutubeEnabled) {
      _youtubeController.stopYoutubeStream();
    }
    super.dispose();
  }
}
