import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // Seleccionar imagen desde cámara o galería
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Seleccionar múltiples imágenes
  static Future<List<File>> pickMultipleImages({
    int imageQuality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  // Seleccionar video
  static Future<File?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  // Mostrar modal de selección de imagen
  static Future<File?> showImagePickerModal(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleccionar Imagen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await pickImage(source: ImageSource.camera);
                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    },
                  ),
                  _buildPickerOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await pickImage(source: ImageSource.gallery);
                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Mostrar modal de selección de video
  static Future<File?> showVideoPickerModal(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleccionar Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    context: context,
                    icon: Icons.videocam,
                    label: 'Cámara',
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await pickVideo(source: ImageSource.camera);
                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    },
                  ),
                  _buildPickerOption(
                    context: context,
                    icon: Icons.video_library,
                    label: 'Galería',
                    onTap: () async {
                      Navigator.pop(context);
                      final file = await pickVideo(source: ImageSource.gallery);
                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validar tipo de archivo
  static bool isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  static bool isVideoFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'].contains(extension);
  }

  static bool isAudioFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'].contains(extension);
  }

  // Obtener tamaño de archivo formateado
  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Obtener extensión de archivo
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
}