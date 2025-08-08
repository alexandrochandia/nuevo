
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../../config/supabase_config.dart';
import '../../../services/auth_service.dart';
import 'youtube_streaming_controller.dart';

class VMFLiveStreamingService {
  static const int zegoAppID = 1234567890; // Tu App ID de ZEGO
  static const String zegoAppSign = "TU_ZEGO_APP_SIGN"; // Tu App Sign de ZEGO
  
  // Configuración VMF Sweden
  static const String vmfBrandColor = "#D4AF37"; // Dorado VMF
  static const String vmfSecondaryColor = "#000000"; // Negro VMF
  
  // Obtener configuración de host VMF
  static ZegoUIKitPrebuiltLiveStreamingConfig getHostConfig() {
    return ZegoUIKitPrebuiltLiveStreamingConfig.host(
      plugins: [ZegoUIKitSignalingPlugin()],
    )..audioVideoView.showAvatarInAudioMode = true
    ..audioVideoView.showSoundWavesInAudioMode = true
    ..topMenuBar.showCloseButton = true
    ..topMenuBar.showMoreButton = true
    ..bottomMenuBar.hostButtons = [
      ZegoLiveStreamingMenuBarButtonName.toggleCameraButton,
      ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton,
      ZegoLiveStreamingMenuBarButtonName.switchCameraButton,
    ]
    ..bottomMenuBar.maxCount = 5
    ..confirmDialogInfo = ZegoLiveStreamingDialogInfo(
      title: "Finalizar Transmisión VMF",
      message: "¿Estás seguro de que quieres terminar la transmisión en vivo?",
      cancelButtonName: "Cancelar",
      confirmButtonName: "Confirmar",
    );
  }
  
  // Obtener configuración de audiencia VMF
  static ZegoUIKitPrebuiltLiveStreamingConfig getAudienceConfig() {
    return ZegoUIKitPrebuiltLiveStreamingConfig.audience(
      plugins: [ZegoUIKitSignalingPlugin()],
    )..audioVideoView.showAvatarInAudioMode = true
    ..audioVideoView.showSoundWavesInAudioMode = true
    ..topMenuBar.showCloseButton = true
    ..bottomMenuBar.audienceButtons = [
      ZegoLiveStreamingMenuBarButtonName.chatButton,
      ZegoLiveStreamingMenuBarButtonName.coHostControlButton,
    ]
    ..bottomMenuBar.maxCount = 5;
  }
  
  // Crear transmisión en Supabase
  static Future<Map<String, dynamic>?> createLiveStream({
    required String title,
    required String description,
    String? youtubeStreamKey,
  }) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      final liveStreamData = {
        'title': title,
        'description': description,
        'host_id': user.id,
        'host_name': user.userMetadata?['full_name'] ?? 'Anfitrión VMF',
        'status': 'live',
        'viewers_count': 0,
        'youtube_stream_key': youtubeStreamKey,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final client = SupabaseConfig.client;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      final response = await client
          .from('live_streams')
          .insert(liveStreamData)
          .select()
          .single();
          
      return response;
    } catch (e) {
      print('Error al crear transmisión: $e');
      return null;
    }
  }
  
  // Actualizar conteo de espectadores
  static Future<void> updateViewersCount(String liveStreamId, int count) async {
    try {
      final client = SupabaseConfig.client;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      await client
          .from('live_streams')
          .update({'viewers_count': count})
          .eq('id', liveStreamId);
    } catch (e) {
      print('Error al actualizar conteo: $e');
    }
  }
  
  // Finalizar transmisión
  static Future<void> endLiveStream(String liveStreamId) async {
    try {
      final client = SupabaseConfig.client;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      await client
          .from('live_streams')
          .update({
            'status': 'ended',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', liveStreamId);
    } catch (e) {
      print('Error al finalizar transmisión: $e');
    }
  }
  
  // Obtener transmisiones activas
  static Future<List<Map<String, dynamic>>> getActiveLiveStreams() async {
    try {
      final client = SupabaseConfig.client;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      final response = await client
          .from('live_streams')
          .select('*')
          .eq('status', 'live')
          .order('created_at', ascending: false);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error al obtener transmisiones: $e');
      return [];
    }
  }
}
