
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_models.dart';
import 'supabase_service.dart';

class AdvancedCallService extends GetxService {
  static AdvancedCallService get to => Get.find();
  
  // Agora Configuration
  static const String agoraAppId = "YOUR_AGORA_APP_ID";
  
  // Reactive variables
  RxBool isInCall = false.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool isAudioEnabled = true.obs;
  RxBool isSpeakerEnabled = false.obs;
  RxBool isRecording = false.obs;
  RxBool isScreenSharing = false.obs;
  RxBool isCallMinimized = false.obs;
  
  // Call participants
  RxList<CallParticipant> participants = <CallParticipant>[].obs;
  RxString currentCallId = ''.obs;
  RxString callType = 'video'.obs; // video, audio, group
  RxInt callDuration = 0.obs;
  
  // Network quality
  RxDouble networkQuality = 0.0.obs;
  RxString connectionState = "Desconectado".obs;
  
  // Call history
  RxList<CallHistoryItem> callHistory = <CallHistoryItem>[].obs;
  
  late RtcEngine agoraEngine;
  String? currentChannelName;
  String? currentToken;
  DateTime? callStartTime;
  
  @override
  void onInit() {
    super.onInit();
    _initializeAgora();
    _loadCallHistory();
  }
  
  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }
  
  // Initialize Agora Engine
  Future<void> _initializeAgora() async {
    try {
      connectionState.value = "Inicializando...";
      
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine.initialize(RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      
      await agoraEngine.enableVideo();
      await agoraEngine.enableAudio();
      
      // Set up event handlers
      agoraEngine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: _onJoinChannelSuccess,
        onUserJoined: _onUserJoined,
        onUserOffline: _onUserOffline,
        onLeaveChannel: _onLeaveChannel,
        onConnectionStateChanged: _onConnectionStateChanged,
        onNetworkQuality: _onNetworkQuality,
        onError: _onError,
        onRemoteVideoStateChanged: _onRemoteVideoStateChanged,
        onRemoteAudioStateChanged: _onRemoteAudioStateChanged,
      ));
      
      connectionState.value = "Listo para llamadas";
      
    } catch (e) {
      debugPrint("Error initializing Agora: $e");
      connectionState.value = "Error de conexión";
    }
  }
  
  // Start a video call
  Future<bool> startVideoCall({
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
  }) async {
    try {
      if (!await _requestPermissions()) return false;
      
      currentChannelName = "call_${DateTime.now().millisecondsSinceEpoch}";
      currentToken = await _generateToken(currentChannelName!);
      callType.value = 'video';
      
      // Create call record in Supabase
      final callRecord = {
        'id': currentChannelName,
        'caller_id': 'current_user_id', // Get from auth
        'receiver_id': receiverId,
        'call_type': 'video',
        'status': 'calling',
        'created_at': DateTime.now().toIso8601String(),
        'channel_name': currentChannelName,
      };
      
      await SupabaseService.supabase
          .from('video_calls')
          .insert(callRecord);
      
      // Send call notification to receiver
      await _sendCallNotification(receiverId, receiverName, 'video');
      
      // Join channel
      await agoraEngine.joinChannel(
        token: currentToken ?? "",
        channelId: currentChannelName!,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      
      isInCall.value = true;
      callStartTime = DateTime.now();
      currentCallId.value = currentChannelName!;
      
      // Add caller to participants
      participants.add(CallParticipant(
        uid: 0,
        name: 'Tú',
        isVideoEnabled: true,
        isAudioEnabled: true,
        isHost: true,
      ));
      
      _startCallTimer();
      
      return true;
      
    } catch (e) {
      debugPrint("Error starting video call: $e");
      return false;
    }
  }
  
  // Start an audio call
  Future<bool> startAudioCall({
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
  }) async {
    try {
      if (!await _requestPermissions()) return false;
      
      currentChannelName = "call_${DateTime.now().millisecondsSinceEpoch}";
      currentToken = await _generateToken(currentChannelName!);
      callType.value = 'audio';
      
      // Disable video for audio call
      await agoraEngine.enableLocalVideo(false);
      isVideoEnabled.value = false;
      
      // Create call record
      final callRecord = {
        'id': currentChannelName,
        'caller_id': 'current_user_id',
        'receiver_id': receiverId,
        'call_type': 'audio',
        'status': 'calling',
        'created_at': DateTime.now().toIso8601String(),
        'channel_name': currentChannelName,
      };
      
      await SupabaseService.supabase
          .from('video_calls')
          .insert(callRecord);
      
      await _sendCallNotification(receiverId, receiverName, 'audio');
      
      await agoraEngine.joinChannel(
        token: currentToken ?? "",
        channelId: currentChannelName!,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      
      isInCall.value = true;
      callStartTime = DateTime.now();
      currentCallId.value = currentChannelName!;
      
      participants.add(CallParticipant(
        uid: 0,
        name: 'Tú',
        isVideoEnabled: false,
        isAudioEnabled: true,
        isHost: true,
      ));
      
      _startCallTimer();
      
      return true;
      
    } catch (e) {
      debugPrint("Error starting audio call: $e");
      return false;
    }
  }
  
  // Start group call
  Future<bool> startGroupCall({
    required List<String> participantIds,
    required String groupName,
    String callType = 'video',
  }) async {
    try {
      if (!await _requestPermissions()) return false;
      
      currentChannelName = "group_call_${DateTime.now().millisecondsSinceEpoch}";
      currentToken = await _generateToken(currentChannelName!);
      this.callType.value = 'group';
      
      if (callType == 'audio') {
        await agoraEngine.enableLocalVideo(false);
        isVideoEnabled.value = false;
      }
      
      // Create group call record
      final callRecord = {
        'id': currentChannelName,
        'host_id': 'current_user_id',
        'call_type': callType,
        'group_name': groupName,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'channel_name': currentChannelName,
        'max_participants': participantIds.length + 1,
      };
      
      await SupabaseService.supabase
          .from('group_calls')
          .insert(callRecord);
      
      // Send invitations to all participants
      for (String participantId in participantIds) {
        await _sendGroupCallInvitation(participantId, groupName, callType);
      }
      
      await agoraEngine.joinChannel(
        token: currentToken ?? "",
        channelId: currentChannelName!,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      
      isInCall.value = true;
      callStartTime = DateTime.now();
      currentCallId.value = currentChannelName!;
      
      participants.add(CallParticipant(
        uid: 0,
        name: 'Host (Tú)',
        isVideoEnabled: callType == 'video',
        isAudioEnabled: true,
        isHost: true,
      ));
      
      _startCallTimer();
      
      return true;
      
    } catch (e) {
      debugPrint("Error starting group call: $e");
      return false;
    }
  }
  
  // Answer incoming call
  Future<bool> answerCall(String callId, String channelName) async {
    try {
      if (!await _requestPermissions()) return false;
      
      currentChannelName = channelName;
      currentToken = await _generateToken(channelName);
      currentCallId.value = callId;
      
      // Update call status
      await SupabaseService.supabase
          .from('video_calls')
          .update({'status': 'answered', 'answered_at': DateTime.now().toIso8601String()})
          .eq('id', callId);
      
      await agoraEngine.joinChannel(
        token: currentToken ?? "",
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      
      isInCall.value = true;
      callStartTime = DateTime.now();
      
      _startCallTimer();
      
      return true;
      
    } catch (e) {
      debugPrint("Error answering call: $e");
      return false;
    }
  }
  
  // End call
  Future<void> endCall() async {
    try {
      if (callStartTime != null) {
        final duration = DateTime.now().difference(callStartTime!).inSeconds;
        
        // Update call record with duration
        if (currentCallId.value.isNotEmpty) {
          await SupabaseService.supabase
              .from('video_calls')
              .update({
                'status': 'ended',
                'ended_at': DateTime.now().toIso8601String(),
                'duration_seconds': duration,
              })
              .eq('id', currentCallId.value);
          
          // Add to call history
          await _addToCallHistory(duration);
        }
      }
      
      await agoraEngine.leaveChannel();
      
      // Reset call state
      isInCall.value = false;
      isVideoEnabled.value = true;
      isAudioEnabled.value = true;
      isSpeakerEnabled.value = false;
      isRecording.value = false;
      isScreenSharing.value = false;
      isCallMinimized.value = false;
      
      participants.clear();
      currentCallId.value = '';
      callDuration.value = 0;
      callStartTime = null;
      
      // Re-enable video for next call
      await agoraEngine.enableLocalVideo(true);
      
    } catch (e) {
      debugPrint("Error ending call: $e");
    }
  }
  
  // Toggle video
  Future<void> toggleVideo() async {
    isVideoEnabled.value = !isVideoEnabled.value;
    await agoraEngine.enableLocalVideo(isVideoEnabled.value);
    
    // Update participant state
    final myParticipant = participants.firstWhereOrNull((p) => p.uid == 0);
    if (myParticipant != null) {
      myParticipant.isVideoEnabled = isVideoEnabled.value;
      participants.refresh();
    }
  }
  
  // Toggle audio
  Future<void> toggleAudio() async {
    isAudioEnabled.value = !isAudioEnabled.value;
    await agoraEngine.enableLocalAudio(isAudioEnabled.value);
    
    // Update participant state
    final myParticipant = participants.firstWhereOrNull((p) => p.uid == 0);
    if (myParticipant != null) {
      myParticipant.isAudioEnabled = isAudioEnabled.value;
      participants.refresh();
    }
  }
  
  // Toggle speaker
  Future<void> toggleSpeaker() async {
    isSpeakerEnabled.value = !isSpeakerEnabled.value;
    await agoraEngine.setEnableSpeakerphone(isSpeakerEnabled.value);
  }
  
  // Switch camera
  Future<void> switchCamera() async {
    await agoraEngine.switchCamera();
  }
  
  // Start/stop recording
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }
  
  // Start screen sharing
  Future<void> toggleScreenSharing() async {
    if (isScreenSharing.value) {
      await agoraEngine.stopScreenCapture();
      isScreenSharing.value = false;
    } else {
      await agoraEngine.startScreenCapture(const ScreenCaptureParameters());
      isScreenSharing.value = true;
    }
  }
  
  // Minimize/maximize call
  void toggleCallMinimized() {
    isCallMinimized.value = !isCallMinimized.value;
  }
  
  // Private methods
  Future<bool> _requestPermissions() async {
    final permissions = [Permission.camera, Permission.microphone];
    final statuses = await permissions.request();
    
    return statuses.values.every((status) => status.isGranted);
  }
  
  Future<String> _generateToken(String channelName) async {
    // In production, generate token from your server
    // For now, return empty string (works with Agora's test mode)
    return "";
  }
  
  Future<void> _sendCallNotification(String receiverId, String receiverName, String callType) async {
    // Send push notification to receiver
    // Implementation depends on your notification service
  }
  
  Future<void> _sendGroupCallInvitation(String participantId, String groupName, String callType) async {
    // Send group call invitation
    // Implementation depends on your notification service
  }
  
  void _startCallTimer() {
    // Start call duration timer
    Stream.periodic(const Duration(seconds: 1), (i) => i).listen((tick) {
      if (isInCall.value && callStartTime != null) {
        callDuration.value = DateTime.now().difference(callStartTime!).inSeconds;
      }
    });
  }
  
  Future<void> _startRecording() async {
    // Implement cloud recording
    isRecording.value = true;
  }
  
  Future<void> _stopRecording() async {
    // Stop cloud recording
    isRecording.value = false;
  }
  
  Future<void> _addToCallHistory(int duration) async {
    final historyItem = CallHistoryItem(
      id: currentCallId.value,
      callType: callType.value,
      duration: duration,
      timestamp: callStartTime!,
      participants: participants.map((p) => p.name).toList(),
      status: 'completed',
    );
    
    callHistory.insert(0, historyItem);
  }
  
  Future<void> _loadCallHistory() async {
    try {
      final response = await SupabaseService.supabase
          .from('video_calls')
          .select()
          .eq('caller_id', 'current_user_id')
          .order('created_at', ascending: false)
          .limit(50);
      
      callHistory.value = response.map((item) => CallHistoryItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Error loading call history: $e");
    }
  }
  
  void _cleanup() async {
    try {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
    } catch (e) {
      debugPrint("Error cleaning up Agora: $e");
    }
  }
  
  // Event handlers
  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    debugPrint("Successfully joined channel: ${connection.channelId}");
    connectionState.value = "Conectado";
  }
  
  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    debugPrint("User joined: $remoteUid");
    
    participants.add(CallParticipant(
      uid: remoteUid,
      name: 'Usuario $remoteUid',
      isVideoEnabled: true,
      isAudioEnabled: true,
      isHost: false,
    ));
  }
  
  void _onUserOffline(RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
    debugPrint("User offline: $remoteUid");
    participants.removeWhere((p) => p.uid == remoteUid);
  }
  
  void _onLeaveChannel(RtcConnection connection, RtcStats stats) {
    debugPrint("Left channel");
    participants.clear();
  }
  
  void _onConnectionStateChanged(RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
    switch (state) {
      case ConnectionStateType.connectionStateConnected:
        connectionState.value = "Conectado";
        break;
      case ConnectionStateType.connectionStateReconnecting:
        connectionState.value = "Reconectando...";
        break;
      case ConnectionStateType.connectionStateDisconnected:
        connectionState.value = "Desconectado";
        break;
      default:
        connectionState.value = "Conectando...";
    }
  }
  
  void _onNetworkQuality(RtcConnection connection, int remoteUid, NetworkQualityType txQuality, NetworkQualityType rxQuality) {
    // Update network quality (0-6 scale, convert to 0-1)
    networkQuality.value = (txQuality.index / 6.0);
  }
  
  void _onError(ErrorCodeType err, String msg) {
    debugPrint("Agora error: $err - $msg");
  }
  
  void _onRemoteVideoStateChanged(RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
    final participant = participants.firstWhereOrNull((p) => p.uid == remoteUid);
    if (participant != null) {
      participant.isVideoEnabled = state == RemoteVideoState.remoteVideoStateStarting || 
                                   state == RemoteVideoState.remoteVideoStateDecoding;
      participants.refresh();
    }
  }
  
  void _onRemoteAudioStateChanged(RtcConnection connection, int remoteUid, RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
    final participant = participants.firstWhereOrNull((p) => p.uid == remoteUid);
    if (participant != null) {
      participant.isAudioEnabled = state == RemoteAudioState.remoteAudioStateStarting || 
                                   state == RemoteAudioState.remoteAudioStateDecoding;
      participants.refresh();
    }
  }
}
