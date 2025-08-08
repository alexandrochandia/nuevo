import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vmf_post_model.dart';

class VMFCreateContentController extends GetxController {
  // Form controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hashtagsController = TextEditingController();
  
  // Observable variables
  final Rx<VMFPostType> selectedType = VMFPostType.testimonio.obs;
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final RxString selectedMusic = RxString('');
  final RxBool allowComments = true.obs;
  final RxBool allowDownloads = false.obs;
  final RxBool isUploading = false.obs;
  
  // Computed properties
  RxBool get canPublish => (selectedVideo.value != null && 
                           descriptionController.text.trim().isNotEmpty).obs;
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    
    // Listen to text changes
    descriptionController.addListener(() => update());
    hashtagsController.addListener(() => update());
  }
  
  @override
  void onClose() {
    descriptionController.dispose();
    hashtagsController.dispose();
    super.onClose();
  }
  
  // Seleccionar video
  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3), // Máximo 3 minutos
      );
      
      if (video != null) {
        selectedVideo.value = File(video.path);
        Get.snackbar(
          'Video seleccionado',
          'Video listo para publicar',
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo seleccionar el video: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  // Remover video seleccionado
  void removeVideo() {
    selectedVideo.value = null;
  }
  
  // Seleccionar música
  void selectMusic(String music) {
    selectedMusic.value = music;
  }
  
  // Remover música
  void removeMusic() {
    selectedMusic.value = '';
  }
  
  // Procesar hashtags
  List<String> _processHashtags(String hashtagsText) {
    return hashtagsText
        .split(' ')
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.replaceAll('#', '').toLowerCase())
        .toSet() // Eliminar duplicados
        .toList();
  }
  
  // Subir video a Firebase Storage
  Future<String> _uploadVideo(File videoFile) async {
    try {
      final String fileName = 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4';
      final Reference ref = _storage.ref().child(fileName);
      
      final UploadTask uploadTask = ref.putFile(videoFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir video: $e');
    }
  }
  
  // Generar thumbnail del video
  Future<String> _generateThumbnail(File videoFile) async {
    // Por ahora retornamos una URL placeholder
    // En una implementación real, usarías un paquete como video_thumbnail
    return 'https://via.placeholder.com/400x600/333333/FFFFFF?text=Video+Thumbnail';
  }
  
  // Publicar contenido
  Future<void> publishContent() async {
    if (selectedVideo.value == null || descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos requeridos',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isUploading.value = true;
      
      // Obtener usuario actual
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Subir video
      Get.snackbar(
        'Subiendo...',
        'Subiendo tu video, por favor espera',
        backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      final String videoUrl = await _uploadVideo(selectedVideo.value!);
      final String thumbnailUrl = await _generateThumbnail(selectedVideo.value!);
      
      // Procesar hashtags
      final List<String> hashtags = _processHashtags(hashtagsController.text);
      
      // Crear el post
      final VMFPostModel newPost = VMFPostModel(
        id: '', // Se asignará automáticamente por Firestore
        userId: currentUser.uid,
        username: currentUser.displayName ?? 'Usuario VMF',
        userAvatar: currentUser.photoURL ?? '',
        description: descriptionController.text.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        type: selectedType.value,
        hashtags: hashtags,
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        isApproved: false, // Requiere aprobación
        musicUrl: selectedMusic.value.isNotEmpty ? selectedMusic.value : null,
        musicTitle: selectedMusic.value.isNotEmpty ? selectedMusic.value : null,
      );
      
      // Guardar en Firestore
      await _firestore.collection('vmf_posts').add(newPost.toFirestore());
      
      // Limpiar formulario
      _clearForm();
      
      // Mostrar mensaje de éxito
      Get.back(); // Cerrar pantalla de creación
      Get.snackbar(
        '¡Contenido enviado!',
        'Tu ${selectedType.value.displayName.toLowerCase()} está en revisión y se publicará pronto',
        backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo publicar el contenido: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }
  
  // Limpiar formulario
  void _clearForm() {
    descriptionController.clear();
    hashtagsController.clear();
    selectedVideo.value = null;
    selectedMusic.value = '';
    selectedType.value = VMFPostType.testimonio;
    allowComments.value = true;
    allowDownloads.value = false;
  }
  
  // Validar contenido antes de publicar
  bool _validateContent() {
    if (selectedVideo.value == null) {
      Get.snackbar('Error', 'Debes seleccionar un video');
      return false;
    }
    
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Debes agregar una descripción');
      return false;
    }
    
    if (descriptionController.text.trim().length < 10) {
      Get.snackbar('Error', 'La descripción debe tener al menos 10 caracteres');
      return false;
    }
    
    return true;
  }
  
  // Guardar borrador
  Future<void> saveDraft() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      final Map<String, dynamic> draft = {
        'userId': currentUser.uid,
        'description': descriptionController.text,
        'hashtags': hashtagsController.text,
        'type': selectedType.value.toString(),
        'music': selectedMusic.value,
        'allowComments': allowComments.value,
        'allowDownloads': allowDownloads.value,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection('vmf_drafts')
          .doc(currentUser.uid)
          .set(draft);
      
      Get.snackbar(
        'Borrador guardado',
        'Tu contenido se guardó como borrador',
        backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el borrador: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  // Cargar borrador
  Future<void> loadDraft() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      final DocumentSnapshot doc = await _firestore
          .collection('vmf_drafts')
          .doc(currentUser.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        descriptionController.text = data['description'] ?? '';
        hashtagsController.text = data['hashtags'] ?? '';
        selectedMusic.value = data['music'] ?? '';
        allowComments.value = data['allowComments'] ?? true;
        allowDownloads.value = data['allowDownloads'] ?? false;
        
        // Restaurar tipo de post
        final typeString = data['type'] ?? '';
        if (typeString.isNotEmpty) {
          selectedType.value = VMFPostType.values.firstWhere(
            (type) => type.toString() == typeString,
            orElse: () => VMFPostType.testimonio,
          );
        }
        
        Get.snackbar(
          'Borrador cargado',
          'Se restauró tu contenido guardado',
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
  }
}
