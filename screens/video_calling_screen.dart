import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aura_provider.dart';
import '../widgets/glow_avatar_widget.dart';

class VideoCallingScreen extends StatefulWidget {
  final String? contactName;
  final String? contactImageUrl;
  final String? contactId;
  final bool isIncomingCall;

  const VideoCallingScreen({
    super.key,
    this.contactName,
    this.contactImageUrl,
    this.contactId,
    this.isIncomingCall = false,
  });

  @override
  State<VideoCallingScreen> createState() => _VideoCallingScreenState();
}

class _VideoCallingScreenState extends State<VideoCallingScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isCallConnected = false;
  bool _isCallStarted = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    if (!widget.isIncomingCall) {
      _pulseController.repeat(reverse: true);
    }
    
    _fadeController.forward();
    
    // Simular conexión después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isCallStarted) {
        setState(() {
          _isCallConnected = true;
        });
        _pulseController.stop();
      }
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }
  
  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
  }
  
  void _endCall() {
    Navigator.of(context).pop();
  }
  
  void _acceptCall() {
    setState(() {
      _isCallStarted = true;
    });
    _pulseController.repeat(reverse: true);
  }
  
  void _declineCall() {
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF000814),
              Color(0xFF0f1419),
              Color(0xFF1a1a2e),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.isIncomingCall && !_isCallStarted
                ? _buildIncomingCallUI()
                : _buildActiveCallUI(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIncomingCallUI() {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Column(
          children: [
            // Header
            _buildHeader(),
            
            // Contact info
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: auraProvider.selectedAuraColor.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: auraProvider.selectedAuraColor.withOpacity(0.2),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: GlowAvatarWidget(
                            size: 150,
                            imageUrl: widget.contactImageUrl,
                            name: widget.contactName ?? 'Hermano VMF',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    widget.contactName ?? 'Hermano VMF',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: auraProvider.selectedAuraColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: auraProvider.selectedAuraColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Videollamada VMF Sweden',
                      style: TextStyle(
                        fontSize: 16,
                        color: auraProvider.selectedAuraColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Incoming call controls
            _buildIncomingCallControls(auraProvider),
          ],
        );
      },
    );
  }
  
  Widget _buildActiveCallUI() {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Column(
          children: [
            // Header with call status
            _buildCallHeader(),
            
            // Video area
            Expanded(
              child: Stack(
                children: [
                  // Remote video (full screen)
                  _buildRemoteVideo(),
                  
                  // Local video (small overlay)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildLocalVideo(auraProvider),
                  ),
                  
                  // Call info overlay
                  if (!_isCallConnected)
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: _buildConnectingOverlay(auraProvider),
                    ),
                ],
              ),
            ),
            
            // Active call controls
            _buildActiveCallControls(auraProvider),
          ],
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const Expanded(
            child: Text(
              'Videollamada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(width: 45),
        ],
      ),
    );
  }
  
  Widget _buildCallHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isCallConnected ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isCallConnected ? 'Conectado' : 'Conectando...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            widget.contactName ?? 'Hermano VMF',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRemoteVideo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _isCallConnected
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white54,
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Video conectado',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.6),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),
    );
  }
  
  Widget _buildLocalVideo(AuraProvider auraProvider) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: auraProvider.selectedAuraColor.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: auraProvider.selectedAuraColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: _isCameraOn
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: Colors.white54,
                    size: 30,
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildConnectingOverlay(AuraProvider auraProvider) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: GlowAvatarWidget(
                size: 80,
                imageUrl: widget.contactImageUrl,
                name: widget.contactName ?? 'Hermano VMF',
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: auraProvider.selectedAuraColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Text(
            'Conectando con hermano...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIncomingCallControls(AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decline button
          GestureDetector(
            onTap: _declineCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.red,
                size: 35,
              ),
            ),
          ),
          
          // Accept button
          GestureDetector(
            onTap: _acceptCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.green,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveCallControls(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            onTap: _toggleMute,
            isActive: !_isMuted,
            color: Colors.white,
            auraProvider: auraProvider,
          ),
          
          // Camera button
          _buildControlButton(
            icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
            onTap: _toggleCamera,
            isActive: _isCameraOn,
            color: Colors.white,
            auraProvider: auraProvider,
          ),
          
          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            onTap: _endCall,
            isActive: false,
            color: Colors.red,
            auraProvider: auraProvider,
            isEndCall: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
    required Color color,
    required AuraProvider auraProvider,
    bool isEndCall = false,
  }) {
    final buttonColor = isEndCall ? Colors.red : (isActive ? auraProvider.selectedAuraColor : Colors.grey);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: buttonColor.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: buttonColor,
          size: 28,
        ),
      ),
    );
  }
}