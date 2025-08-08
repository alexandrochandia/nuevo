
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../models/file_model.dart';
import '../config/supabase_config.dart';

class FileManagementService {
  static const String bucketName = 'vmf-files';
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'
  ];
  static const List<String> allowedVideoTypes = [
    'mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv'
  ];
  static const List<String> allowedAudioTypes = [
    'mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a'
  ];
  static const List<String> allowedDocumentTypes = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'
  ];

  static FileManagementService? _instance;
  static FileManagementService get instance => _instance ??= FileManagementService._();
  
  FileManagementService._();

  Future<FileModel?> uploadFile({
    required File file,
    required FileCategory category,
    FilePermission permission = FilePermission.private,
    String? description,
    String? tags,
    String? parentFolder,
  }) async {
    try {
      // Validar tamaño del archivo
      final fileSize = await file.length();
      if (fileSize > maxFileSize) {
        throw Exception('El archivo es demasiado grande. Máximo ${(maxFileSize / (1024 * 1024)).toInt()}MB');
      }

      // Obtener información del archivo
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase().replaceAll('.', '');
      final fileType = _getFileType(fileExtension);
      final mimeType = _getMimeType(fileExtension);

      // Validar tipo de archivo
      if (!_isAllowedFileType(fileExtension)) {
        throw Exception('Tipo de archivo no permitido: $fileExtension');
      }

      // Generar nombre único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = '${timestamp}_$fileName';
      final storagePath = '${category.name}/${parentFolder ?? 'root'}/$uniqueName';

      // Subir archivo a Supabase Storage
      final bytes = await file.readAsBytes();
      final uploadResult = await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(storagePath, bytes);

      if (uploadResult.isEmpty) {
        throw Exception('Error al subir el archivo');
      }

      // Obtener URL pública
      final publicUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl(storagePath);

      // Generar thumbnail si es imagen
      String? thumbnailUrl;
      if (fileType == FileType.image) {
        thumbnailUrl = await _generateThumbnail(storagePath, bytes);
      }

      // Crear registro en la base de datos
      final fileModel = FileModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: uniqueName,
        originalName: fileName,
        path: storagePath,
        url: publicUrl,
        type: fileType,
        category: category,
        permission: permission,
        size: fileSize,
        mimeType: mimeType,
        description: description,
        tags: tags,
        uploadedBy: 'current_user_id', // Obtener del contexto
        uploadedAt: DateTime.now(),
        thumbnailUrl: thumbnailUrl,
        parentFolder: parentFolder,
      );

      await _saveFileRecord(fileModel);

      return fileModel;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<List<FileModel>> getFiles({
    FileCategory? category,
    FileType? type,
    String? parentFolder,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = SupabaseConfig.client
          .from('files')
          .select()
          .eq('uploaded_by', 'current_user_id')
          .order('uploaded_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (category != null) {
        query = query.eq('category', category.index);
      }

      if (type != null) {
        query = query.eq('type', type.index);
      }

      if (parentFolder != null) {
        query = query.eq('parent_folder', parentFolder);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%,tags.ilike.%$searchQuery%');
      }

      final response = await query;

      return (response as List)
          .map((json) => FileModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching files: $e');
      return [];
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      // Obtener información del archivo
      final fileResponse = await SupabaseConfig.client
          .from('files')
          .select()
          .eq('id', fileId)
          .single();

      final fileModel = FileModel.fromJson(fileResponse);

      // Eliminar del storage
      await SupabaseConfig.client.storage
          .from(bucketName)
          .remove([fileModel.path]);

      // Eliminar thumbnail si existe
      if (fileModel.thumbnailUrl != null) {
        final thumbnailPath = fileModel.path.replaceAll('/files/', '/thumbnails/');
        await SupabaseConfig.client.storage
            .from(bucketName)
            .remove([thumbnailPath]);
      }

      // Eliminar registro de la base de datos
      await SupabaseConfig.client
          .from('files')
          .delete()
          .eq('id', fileId);

      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  Future<String?> downloadFile(String fileId, String savePath) async {
    try {
      final fileResponse = await SupabaseConfig.client
          .from('files')
          .select()
          .eq('id', fileId)
          .single();

      final fileModel = FileModel.fromJson(fileResponse);

      // Descargar archivo
      final response = await http.get(Uri.parse(fileModel.url));
      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        // Incrementar contador de descargas
        await SupabaseConfig.client
            .from('files')
            .update({'download_count': fileModel.downloadCount + 1})
            .eq('id', fileId);

        return savePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  Future<bool> shareFile(String fileId, List<String> userIds) async {
    try {
      await SupabaseConfig.client
          .from('files')
          .update({
            'is_shared': true,
            'shared_with': userIds,
          })
          .eq('id', fileId);

      return true;
    } catch (e) {
      debugPrint('Error sharing file: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(String fileId, bool isFavorite) async {
    try {
      await SupabaseConfig.client
          .from('files')
          .update({'is_favorite': isFavorite})
          .eq('id', fileId);

      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<List<FileModel>> searchFiles(String query) async {
    try {
      final response = await SupabaseConfig.client
          .from('files')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%,tags.ilike.%$query%')
          .eq('uploaded_by', 'current_user_id')
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((json) => FileModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error searching files: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final response = await SupabaseConfig.client
          .from('files')
          .select('size, type, category')
          .eq('uploaded_by', 'current_user_id');

      int totalSize = 0;
      Map<FileType, int> typeCount = {};
      Map<FileCategory, int> categoryCount = {};

      for (final file in response) {
        totalSize += file['size'] as int;
        
        final type = FileType.values[file['type']];
        final category = FileCategory.values[file['category']];
        
        typeCount[type] = (typeCount[type] ?? 0) + 1;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return {
        'total_files': response.length,
        'total_size': totalSize,
        'type_distribution': typeCount,
        'category_distribution': categoryCount,
      };
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {};
    }
  }

  // Métodos privados
  FileType _getFileType(String extension) {
    if (allowedImageTypes.contains(extension)) return FileType.image;
    if (allowedVideoTypes.contains(extension)) return FileType.video;
    if (allowedAudioTypes.contains(extension)) return FileType.audio;
    if (extension == 'pdf') return FileType.pdf;
    if (allowedDocumentTypes.contains(extension)) return FileType.document;
    if (extension == 'txt') return FileType.text;
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(extension)) return FileType.archive;
    return FileType.other;
  }

  bool _isAllowedFileType(String extension) {
    final allAllowed = [
      ...allowedImageTypes,
      ...allowedVideoTypes,
      ...allowedAudioTypes,
      ...allowedDocumentTypes,
      'txt', 'zip', 'rar', '7z', 'tar', 'gz'
    ];
    return allAllowed.contains(extension);
  }

  String _getMimeType(String extension) {
    const mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'avi': 'video/x-msvideo',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt': 'text/plain',
      'zip': 'application/zip',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  Future<String?> _generateThumbnail(String originalPath, Uint8List imageBytes) async {
    try {
      // Implementar generación de thumbnail
      // Por ahora retornamos null, se puede implementar con image package
      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> _saveFileRecord(FileModel fileModel) async {
    await SupabaseConfig.client
        .from('files')
        .insert(fileModel.toJson());
  }
}
