
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/livestream_model.dart';
import '../../services/supabase_service.dart';

class VMFLiveController extends GetxController {
  static VMFLiveController get to => Get.find();
  
  // Agora Configuration
  static const String agoraAppId = ""; // Configurar con tu App ID real
  
  // Reactive variables
  RxBool isLive = false.obs;
  RxBool isHost = false.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool isAudioEnabled = true.obs;
  RxBool isLoading = false.obs;
  RxInt viewersCount = 0.obs;
  RxString streamDuration = "00:00".obs;
  RxList<Map<String, dynamic>> chatMessages = <Map<String, dynamic>>[].obs;
  RxList<LiveStreamModel> activeStreams = <LiveStreamModel>[].obs;
  
  // Controllers
  late RtcEngine agoraEngine;
  late TextEditingController chatController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  
  String? currentChannelName;
  String? currentStreamId;
  DateTime? streamStartTime;
  
  @override
  void onInit() {
    super.onInit();
    chatController = TextEditingController();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    _initializeAgora();
    loadActiveStreams();
  }
  
  @override
  void onClose() {
    chatController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    _cleanup();
    super.onClose();
  }
  
  // Initialize Agora Engine
  Future<void> _initializeAgora() async {
    try {
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine.initialize(RtcEngineContext(appId: agoraAppId));
      
      // Enable video
      await agoraEngine.enableVideo();
      await agoraEngine.enableAudio();
      
      // Set up event handlers
      agoraEngine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("VMF Live: Joined channel ${connection.channelId}");
          isLive.value = true;
          if (isHost.value) {
            _startStreamTimer();
          }
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          debugPrint("VMF Live: User $uid joined");
          if (isHost.value) {
            viewersCount.value++;
            _updateViewersCount();
          }
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          debugPrint("VMF Live: User $uid left");
          if (isHost.value) {
            viewersCount.value = (viewersCount.value - 1).clamp(0, double.infinity).toInt();
            _updateViewersCount();
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("VMF Live: Left channel");
          isLive.value = false;
          _stopStreamTimer();
        },
      ));
      
    } catch (e) {
      debugPrint("Error initializing Agora: $e");
    }
  }
  
  // Start streaming as host
  Future<bool> startStreaming({
    required String title,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      
      // Request permissions
      if (!await _checkPermissions()) {
        Get.snackbar(
          "Permisos Requeridos",
          "Se necesitan permisos de cámara y micrófono para transmitir",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      // Generate unique channel name
      currentChannelName = "vmf_live_${DateTime.now().millisecondsSinceEpoch}";
      isHost.value = true;
      streamStartTime = DateTime.now();
      
      // Create stream record in Supabase
      final streamData = {
        'title': title,
        'description': description ?? '',
        'host_name': 'Usuario VMF', // Obtener del provider de usuario
        'channel_name': currentChannelName,
        'status': 'live',
        'viewers_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await SupabaseService.supabase
          .from('live_streams')
          .insert(streamData)
          .select()
          .single();
      
      currentStreamId = response['id'];
      
      // Join Agora channel as broadcaster
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await agoraEngine.joinChannel(
        token: "", // En producción, generar token desde tu servidor
        channelId: currentChannelName!,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      
      return true;
      
    } catch (e) {
      debugPrint("Error starting stream: $e");
      Get.snackbar(
        "Error",
        "No se pudo iniciar la transmisión: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Join stream as viewer
  Future<bool> joinStream(String channelName) async {
    try {
      isLoading.value = true;
      
      currentChannelName = channelName;
      isHost.value = false;
      
      // Join as audience
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await agoraEngine.joinChannel(
        token: "",
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      
      return true;
      
    } catch (e) {
      debugPrint("Error joining stream: $e");
      Get.snackbar(
        "Error",
        "No se pudo unir a la transmisión: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // End streaming
  Future<void> endStreaming() async {
    try {
      isLoading.value = true;
      
      if (isHost.value && currentStreamId != null) {
        // Update stream status in Supabase
        await SupabaseService.supabase
            .from('live_streams')
            .update({
              'status': 'ended',
              'ended_at': DateTime.now().toIso8601String(),
              'duration_minutes': _calculateDurationMinutes(),
            })
            .eq('id', currentStreamId!);
      }
      
      // Leave Agora channel
      await agoraEngine.leaveChannel();
      
      // Reset state
      _resetStreamState();
      
      Get.back(); // Return to previous screen
      
    } catch (e) {
      debugPrint("Error ending stream: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Toggle video
  Future<void> toggleVideo() async {
    isVideoEnabled.value = !isVideoEnabled.value;
    await agoraEngine.enableLocalVideo(isVideoEnabled.value);
  }
  
  // Toggle audio
  Future<void> toggleAudio() async {
    isAudioEnabled.value = !isAudioEnabled.value;
    await agoraEngine.enableLocalAudio(isAudioEnabled.value);
  }
  
  // Switch camera
  Future<void> switchCamera() async {
    await agoraEngine.switchCamera();
  }
  
  // Send chat message
  void sendChatMessage() {
    if (chatController.text.trim().isEmpty) return;
    
    final message = {
      'text': chatController.text.trim(),
      'sender': 'Usuario VMF', // Obtener del provider de usuario
      'timestamp': DateTime.now().toIso8601String(),
      'isHost': isHost.value,
    };
    
    chatMessages.add(message);
    chatController.clear();
    
    // TODO: Implementar envío real a través de Agora Data Channel o Supabase Realtime
  }
  
  // Load active streams
  Future<void> loadActiveStreams() async {
    try {
      final response = await SupabaseService.supabase
          .from('live_streams')
          .select()
          .eq('status', 'live')
          .order('created_at', ascending: false);
      
      activeStreams.value = response
          .map((data) => LiveStreamModel.fromJson(data))
          .toList();
          
    } catch (e) {
      debugPrint("Error loading streams: $e");
    }
  }
  
  // Helper methods
  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    return permissions[Permission.camera] == PermissionStatus.granted &&
           permissions[Permission.microphone] == PermissionStatus.granted;
  }
  
  void _startStreamTimer() {
    // Actualizar duración cada segundo
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
    // El timer se detiene automáticamente cuando isLive es false
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
  
  int _calculateDurationMinutes() {
    if (streamStartTime == null) return 0;
    return DateTime.now().difference(streamStartTime!).inMinutes;
  }
  
  Future<void> _updateViewersCount() async {
    if (currentStreamId != null) {
      await SupabaseService.supabase
          .from('live_streams')
          .update({'viewers_count': viewersCount.value})
          .eq('id', currentStreamId!);
    }
  }
  
  void _resetStreamState() {
    currentChannelName = null;
    currentStreamId = null;
    streamStartTime = null;
    viewersCount.value = 0;
    streamDuration.value = "00:00";
    chatMessages.clear();
    isHost.value = false;
    isVideoEnabled.value = true;
    isAudioEnabled.value = true;
  }
  
  Future<void> _cleanup() async {
    try {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
    } catch (e) {
      debugPrint("Error during cleanup: $e");
    }
  }
}
