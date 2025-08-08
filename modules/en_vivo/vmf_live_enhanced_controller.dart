
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/livestream_model.dart';
import '../../services/supabase_service.dart';

class VMFLiveEnhancedController extends GetxController {
  static VMFLiveEnhancedController get to => Get.find();
  
  // Agora Configuration
  static const String agoraAppId = "YOUR_AGORA_APP_ID"; // Configurar con tu App ID real
  
  // Reactive variables
  RxBool isLive = false.obs;
  RxBool isHost = false.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool isAudioEnabled = true.obs;
  RxBool isLoading = false.obs;
  RxBool isConnecting = false.obs;
  RxBool isBeautyEnabled = false.obs;
  RxBool isScreenSharing = false.obs;
  
  // Stream stats
  RxInt viewersCount = 0.obs;
  RxInt likesCount = 0.obs;
  RxInt commentsCount = 0.obs;
  RxString streamDuration = "00:00".obs;
  RxDouble networkQuality = 0.0.obs;
  RxString connectionState = "Desconectado".obs;
  
  // Interactive features
  RxList<LiveStreamComment> chatMessages = <LiveStreamComment>[].obs;
  RxList<LiveStreamDonation> donations = <LiveStreamDonation>[].obs;
  RxList<String> moderators = <String>[].obs;
  RxList<String> bannedUsers = <String>[].obs;
  
  // Stream management
  RxList<LiveStreamModel> activeStreams = <LiveStreamModel>[].obs;
  RxList<LiveStreamModel> scheduledStreams = <LiveStreamModel>[].obs;
  RxList<LiveStreamModel> pastStreams = <LiveStreamModel>[].obs;
  
  // Stream settings
  RxString streamQuality = "HD".obs; // HD, FHD, 4K
  RxBool enableChat = true.obs;
  RxBool enableDonations = true.obs;
  RxBool enableRecording = false.obs;
  RxBool autoModeration = true.obs;
  
  // Controllers
  late RtcEngine agoraEngine;
  late TextEditingController chatController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  
  String? currentChannelName;
  String? currentStreamId;
  String? currentToken;
  DateTime? streamStartTime;
  int? localUid;
  List<int> remoteUids = [];
  
  @override
  void onInit() {
    super.onInit();
    chatController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    _initializeAgora();
    _loadStreamHistory();
    _startPeriodicUpdates();
  }
  
  @override
  void onClose() {
    chatController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    _cleanup();
    super.onClose();
  }
  
  // Initialize Agora Engine with advanced settings
  Future<void> _initializeAgora() async {
    try {
      isLoading.value = true;
      connectionState.value = "Inicializando...";
      
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine.initialize(RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      
      // Enable video and audio
      await agoraEngine.enableVideo();
      await agoraEngine.enableAudio();
      
      // Set video configuration
      await _setVideoConfiguration();
      
      // Set up event handlers
      agoraEngine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: _onJoinChannelSuccess,
        onUserJoined: _onUserJoined,
        onUserOffline: _onUserOffline,
        onLeaveChannel: _onLeaveChannel,
        onConnectionStateChanged: _onConnectionStateChanged,
        onNetworkQuality: _onNetworkQuality,
        onRtcStats: _onRtcStats,
        onError: _onError,
        onRemoteVideoStats: _onRemoteVideoStats,
        onLocalVideoStats: _onLocalVideoStats,
      ));
      
      connectionState.value = "Listo";
      
    } catch (e) {
      debugPrint("Error initializing Agora: $e");
      connectionState.value = "Error de conexión";
      _showError("Error al inicializar el sistema de streaming");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Set video configuration based on quality
  Future<void> _setVideoConfiguration() async {
    VideoEncoderConfiguration config;
    
    switch (streamQuality.value) {
      case "4K":
        config = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 3840, height: 2160),
          frameRate: 30,
          bitrate: 8000,
        );
        break;
      case "FHD":
        config = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          frameRate: 30,
          bitrate: 4000,
        );
        break;
      case "HD":
      default:
        config = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1280, height: 720),
          frameRate: 30,
          bitrate: 2000,
        );
        break;
    }
    
    await agoraEngine.setVideoEncoderConfiguration(config);
  }
  
  // Advanced stream creation with scheduling support
  Future<bool> startAdvancedStreaming({
    required String title,
    String? description,
    LiveStreamType type = LiveStreamType.culto,
    DateTime? scheduledTime,
    bool recordStream = false,
    List<String> tags = const [],
  }) async {
    try {
      isLoading.value = true;
      connectionState.value = "Iniciando transmisión...";
      
      // Check permissions
      if (!await _checkAdvancedPermissions()) {
        _showError("Se necesitan permisos adicionales para la transmisión");
        return false;
      }
      
      // Generate unique channel and get token
      currentChannelName = "vmf_${type.name}_${DateTime.now().millisecondsSinceEpoch}";
      currentToken = await _generateToken(currentChannelName!);
      
      isHost.value = true;
      streamStartTime = DateTime.now();
      
      // Create stream record in Supabase
      final streamData = {
        'title': title,
        'description': description ?? '',
        'host_name': 'Pastor VMF', // Obtener del usuario actual
        'channel_name': currentChannelName,
        'status': scheduledTime != null && scheduledTime.isAfter(DateTime.now()) 
            ? 'scheduled' : 'live',
        'stream_type': type.name,
        'viewers_count': 0,
        'scheduled_time': scheduledTime?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'allow_gifts': enableDonations.value,
        'enable_moderation': autoModeration.value,
        'stream_category': 'spiritual',
        'tags': tags,
        'recording_enabled': recordStream,
      };
      
      final response = await SupabaseService.supabase
          .from('live_streams_enhanced')
          .insert(streamData)
          .select()
          .single();
      
      currentStreamId = response['id'];
      
      // Configure Agora for broadcasting
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      // Join channel with token
      await agoraEngine.joinChannel(
        token: currentToken ?? "",
        channelId: currentChannelName!,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
      
      // Start recording if enabled
      if (recordStream) {
        await _startCloudRecording();
      }
      
      connectionState.value = "Transmitiendo";
      return true;
      
    } catch (e) {
      debugPrint("Error starting advanced stream: $e");
      _showError("No se pudo iniciar la transmisión: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Join stream as viewer with enhanced features
  Future<bool> joinAdvancedStream(String streamId) async {
    try {
      isLoading.value = true;
      connectionState.value = "Conectando...";
      
      // Get stream details
      final streamResponse = await SupabaseService.supabase
          .from('live_streams_enhanced')
          .select()
          .eq('id', streamId)
          .single();
      
      final stream = LiveStreamModel.fromJson(streamResponse);
      currentChannelName = stream.channelName;
      currentStreamId = streamId;
      currentToken = await _generateToken(currentChannelName!);
      
      isHost.value = false;
      
      // Join as audience
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await agoraEngine.joinChannel(
        token: currentToken ?? "",
        channelId: currentChannelName!,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleAudience,
        ),
      );
      
      // Load chat history
      await _loadChatHistory();
      
      return true;
      
    } catch (e) {
      debugPrint("Error joining advanced stream: $e");
      _showError("No se pudo unir a la transmisión: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Enhanced stream ending with statistics
  Future<void> endAdvancedStreaming() async {
    try {
      isLoading.value = true;
      connectionState.value = "Finalizando...";
      
      if (isHost.value && currentStreamId != null) {
        // Calculate stream statistics
        final stats = await _calculateStreamStats();
        
        // Update stream in Supabase
        await SupabaseService.supabase
            .from('live_streams_enhanced')
            .update({
              'status': 'ended',
              'ended_at': DateTime.now().toIso8601String(),
              'duration_minutes': stats['duration'],
              'max_viewers': stats['maxViewers'],
              'total_comments': stats['totalComments'],
              'total_likes': stats['totalLikes'],
              'total_donations': stats['totalDonations'],
            })
            .eq('id', currentStreamId!);
        
        // Stop cloud recording if enabled
        if (enableRecording.value) {
          await _stopCloudRecording();
        }
      }
      
      // Leave channel
      await agoraEngine.leaveChannel();
      
      // Reset state
      _resetStreamState();
      
      // Show end stream summary if host
      if (isHost.value) {
        _showStreamSummary();
      }
      
      Get.back();
      
    } catch (e) {
      debugPrint("Error ending advanced stream: $e");
      _showError("Error al finalizar la transmisión");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Enhanced video controls
  Future<void> toggleAdvancedVideo() async {
    isVideoEnabled.value = !isVideoEnabled.value;
    await agoraEngine.enableLocalVideo(isVideoEnabled.value);
    
    if (isHost.value) {
      _broadcastHostAction(isVideoEnabled.value ? 'video_on' : 'video_off');
    }
  }
  
  // Enhanced audio controls
  Future<void> toggleAdvancedAudio() async {
    isAudioEnabled.value = !isAudioEnabled.value;
    await agoraEngine.enableLocalAudio(isAudioEnabled.value);
    
    if (isHost.value) {
      _broadcastHostAction(isAudioEnabled.value ? 'audio_on' : 'audio_off');
    }
  }
  
  // Switch camera with animation
  Future<void> switchCameraWithAnimation() async {
    await agoraEngine.switchCamera();
    _broadcastHostAction('camera_switch');
  }
  
  // Beauty filters
  Future<void> toggleBeautyFilters() async {
    isBeautyEnabled.value = !isBeautyEnabled.value;
    
    if (isBeautyEnabled.value) {
      await agoraEngine.setBeautyEffectOptions(
        enabled: true,
        options: const BeautyOptions(
          lighteningContrastLevel: LighteningContrastLevel.lighteningContrastNormal,
          lighteningLevel: 0.7,
          smoothnessLevel: 0.5,
          rednessLevel: 0.1,
        ),
      );
    } else {
      await agoraEngine.setBeautyEffectOptions(enabled: false, options: const BeautyOptions());
    }
  }
  
  // Screen sharing
  Future<void> toggleScreenSharing() async {
    isScreenSharing.value = !isScreenSharing.value;
    
    if (isScreenSharing.value) {
      await agoraEngine.startScreenCapture(const ScreenCaptureParameters2());
    } else {
      await agoraEngine.stopScreenCapture();
    }
  }
  
  // Enhanced chat with moderation
  Future<void> sendEnhancedChatMessage() async {
    if (chatController.text.trim().isEmpty) return;
    
    final message = chatController.text.trim();
    
    // Check for spam/inappropriate content
    if (autoModeration.value && await _isInappropriateContent(message)) {
      _showError("Mensaje no permitido por las políticas de la comunidad");
      return;
    }
    
    final chatMessage = LiveStreamComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // Obtener del usuario actual
      userName: 'Usuario VMF',
      userAvatar: 'https://via.placeholder.com/50',
      message: message,
      timestamp: DateTime.now(),
      isFromPastor: false, // Verificar si es pastor
    );
    
    chatMessages.add(chatMessage);
    commentsCount.value++;
    
    // Save to Supabase
    if (currentStreamId != null) {
      await SupabaseService.supabase
          .from('live_stream_messages')
          .insert({
            'stream_id': currentStreamId,
            'user_id': chatMessage.userId,
            'content': message,
            'message_type': 'text',
            'sent_at': chatMessage.timestamp.toIso8601String(),
          });
    }
    
    chatController.clear();
  }
  
  // Send donation/gift
  Future<void> sendDonation(double amount, String currency, String message) async {
    if (!enableDonations.value) return;
    
    final donation = LiveStreamDonation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      userName: 'Usuario VMF',
      amount: amount,
      currency: currency,
      message: message,
      timestamp: DateTime.now(),
    );
    
    donations.add(donation);
    
    // Broadcast donation animation
    _broadcastDonation(donation);
    
    // Save to Supabase
    if (currentStreamId != null) {
      await SupabaseService.supabase
          .from('live_stream_gifts')
          .insert({
            'stream_id': currentStreamId,
            'sender_id': donation.userId,
            'gift_name': 'donation',
            'gift_value': amount.toInt(),
            'sent_at': donation.timestamp.toIso8601String(),
          });
    }
  }
  
  // Moderation functions
  Future<void> banUser(String userId) async {
    if (!isHost.value) return;
    
    bannedUsers.add(userId);
    
    // Remove user from stream
    await SupabaseService.supabase
        .from('live_stream_banned_users')
        .insert({
          'stream_id': currentStreamId,
          'user_id': userId,
          'banned_by': 'current_user_id',
          'reason': 'Host action',
          'banned_at': DateTime.now().toIso8601String(),
        });
  }
  
  Future<void> addModerator(String userId) async {
    if (!isHost.value) return;
    
    moderators.add(userId);
    
    await SupabaseService.supabase
        .from('live_stream_moderators')
        .insert({
          'stream_id': currentStreamId,
          'user_id': userId,
          'promoted_by': 'current_user_id',
          'promoted_at': DateTime.now().toIso8601String(),
        });
  }
  
  // Event handlers
  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    debugPrint("VMF Live: Joined channel ${connection.channelId}");
    isLive.value = true;
    connectionState.value = "Conectado";
    
    if (isHost.value) {
      _startStreamTimer();
      _startViewerTracking();
    }
  }
  
  void _onUserJoined(RtcConnection connection, int uid, int elapsed) {
    debugPrint("VMF Live: User $uid joined");
    remoteUids.add(uid);
    
    if (isHost.value) {
      viewersCount.value++;
      _updateViewersCount();
    }
  }
  
  void _onUserOffline(RtcConnection connection, int uid, UserOfflineReasonType reason) {
    debugPrint("VMF Live: User $uid left");
    remoteUids.remove(uid);
    
    if (isHost.value) {
      viewersCount.value = (viewersCount.value - 1).clamp(0, double.infinity).toInt();
      _updateViewersCount();
    }
  }
  
  void _onLeaveChannel(RtcConnection connection, RtcStats stats) {
    debugPrint("VMF Live: Left channel");
    isLive.value = false;
    connectionState.value = "Desconectado";
    _stopStreamTimer();
  }
  
  void _onConnectionStateChanged(RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
    switch (state) {
      case ConnectionStateType.connectionStateDisconnected:
        connectionState.value = "Desconectado";
        break;
      case ConnectionStateType.connectionStateConnecting:
        connectionState.value = "Conectando...";
        break;
      case ConnectionStateType.connectionStateConnected:
        connectionState.value = "Conectado";
        break;
      case ConnectionStateType.connectionStateReconnecting:
        connectionState.value = "Reconectando...";
        break;
      case ConnectionStateType.connectionStateFailed:
        connectionState.value = "Error de conexión";
        break;
    }
  }
  
  void _onNetworkQuality(RtcConnection connection, int uid, QualityType txQuality, QualityType rxQuality) {
    // Update network quality indicator
    final quality = txQuality.index / 6.0;
    networkQuality.value = quality;
  }
  
  void _onRtcStats(RtcConnection connection, RtcStats stats) {
    // Update stream statistics
    debugPrint("Stream stats - Users: ${stats.userCount}, CPU: ${stats.cpuAppUsage}%");
  }
  
  void _onError(ErrorCodeType err, String msg) {
    debugPrint("Agora Error: $err - $msg");
    _showError("Error de transmisión: $msg");
  }
  
  void _onWarning(WarnCodeType warn, String msg) {
    debugPrint("Agora Warning: $warn - $msg");
  }
  
  void _onRemoteVideoStats(RtcConnection connection, RemoteVideoStats stats) {
    debugPrint("Remote video stats - Bitrate: ${stats.receivedBitrate}");
  }
  
  void _onLocalVideoStats(RtcConnection connection, LocalVideoStats stats) {
    debugPrint("Local video stats - Bitrate: ${stats.sentBitrate}");
  }
  
  // Helper methods
  Future<bool> _checkAdvancedPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.phone,
    ].request();
    
    return permissions.values.every((status) => status == PermissionStatus.granted);
  }
  
  Future<String?> _generateToken(String channelName) async {
    // En producción, generar token desde tu servidor de tokens
    // Por ahora retornamos null para usar sin token
    return null;
  }
  
  Future<void> _startCloudRecording() async {
    // Implementar grabación en la nube
    debugPrint("Starting cloud recording...");
  }
  
  Future<void> _stopCloudRecording() async {
    // Detener grabación en la nube
    debugPrint("Stopping cloud recording...");
  }
  
  Future<bool> _isInappropriateContent(String message) async {
    // Implementar moderación automática
    final badWords = ['spam', 'publicidad']; // Lista básica
    return badWords.any((word) => message.toLowerCase().contains(word));
  }
  
  void _broadcastHostAction(String action) {
    // Broadcast action to all viewers
    debugPrint("Broadcasting host action: $action");
  }
  
  void _broadcastDonation(LiveStreamDonation donation) {
    // Show donation animation to all viewers
    debugPrint("Broadcasting donation: ${donation.formattedAmount}");
  }
  
  Future<Map<String, dynamic>> _calculateStreamStats() async {
    final duration = streamStartTime != null 
        ? DateTime.now().difference(streamStartTime!).inMinutes 
        : 0;
    
    return {
      'duration': duration,
      'maxViewers': viewersCount.value,
      'totalComments': commentsCount.value,
      'totalLikes': likesCount.value,
      'totalDonations': donations.fold(0.0, (sum, d) => sum + d.amount),
    };
  }
  
  void _showStreamSummary() {
    Get.dialog(
      AlertDialog(
        title: const Text('Resumen de Transmisión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Duración: ${streamDuration.value}'),
            Text('Espectadores máximos: ${viewersCount.value}'),
            Text('Comentarios: ${commentsCount.value}'),
            Text('Me gusta: ${likesCount.value}'),
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
  
  void _startStreamTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (isLive.value && streamStartTime != null) {
        final duration = DateTime.now().difference(streamStartTime!);
        streamDuration.value = _formatDuration(duration);
        return true;
      }
      return false;
    });
  }
  
  void _stopStreamTimer() {
    // Timer stops automatically when isLive is false
  }
  
  void _startViewerTracking() {
    // Track viewers periodically
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (isLive.value && isHost.value) {
        await _updateViewersCount();
        return true;
      }
      return false;
    });
  }
  
  void _startPeriodicUpdates() {
    // Update stream lists periodically
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!isLive.value) {
        await loadActiveStreams();
        return true;
      }
      return false;
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }
  
  Future<void> _updateViewersCount() async {
    if (currentStreamId != null) {
      await SupabaseService.supabase
          .from('live_streams_enhanced')
          .update({'viewers_count': viewersCount.value})
          .eq('id', currentStreamId!);
    }
  }
  
  Future<void> _loadChatHistory() async {
    if (currentStreamId == null) return;
    
    try {
      final response = await SupabaseService.supabase
          .from('live_stream_messages')
          .select()
          .eq('stream_id', currentStreamId!)
          .order('sent_at');
      
      chatMessages.value = response
          .map((data) => LiveStreamComment.fromJson(data))
          .toList();
          
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }
  }
  
  Future<void> _loadStreamHistory() async {
    try {
      // Load active streams
      final activeResponse = await SupabaseService.supabase
          .from('live_streams_enhanced')
          .select()
          .eq('status', 'live')
          .order('created_at', ascending: false);
      
      activeStreams.value = activeResponse
          .map((data) => LiveStreamModel.fromJson(data))
          .toList();
      
      // Load scheduled streams
      final scheduledResponse = await SupabaseService.supabase
          .from('live_streams_enhanced')
          .select()
          .eq('status', 'scheduled')
          .order('scheduled_time');
      
      scheduledStreams.value = scheduledResponse
          .map((data) => LiveStreamModel.fromJson(data))
          .toList();
      
      // Load past streams
      final pastResponse = await SupabaseService.supabase
          .from('live_streams_enhanced')
          .select()
          .eq('status', 'ended')
          .order('ended_at', ascending: false)
          .limit(20);
      
      pastStreams.value = pastResponse
          .map((data) => LiveStreamModel.fromJson(data))
          .toList();
          
    } catch (e) {
      debugPrint("Error loading stream history: $e");
    }
  }
  
  // Public method to load active streams
  Future<void> loadActiveStreams() async {
    await _loadStreamHistory();
  }
  
  void _resetStreamState() {
    currentChannelName = null;
    currentStreamId = null;
    currentToken = null;
    streamStartTime = null;
    localUid = null;
    remoteUids.clear();
    viewersCount.value = 0;
    likesCount.value = 0;
    commentsCount.value = 0;
    streamDuration.value = "00:00";
    chatMessages.clear();
    donations.clear();
    moderators.clear();
    bannedUsers.clear();
    isHost.value = false;
    isVideoEnabled.value = true;
    isAudioEnabled.value = true;
    isBeautyEnabled.value = false;
    isScreenSharing.value = false;
    networkQuality.value = 0.0;
  }
  
  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  
  Future<void> _cleanup() async {
    try {
      if (isLive.value) {
        await endAdvancedStreaming();
      }
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
    } catch (e) {
      debugPrint("Error during cleanup: $e");
    }
  }
}
