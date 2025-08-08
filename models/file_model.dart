
import 'package:flutter/material.dart';

enum FileType {
  image,
  video,
  audio,
  document,
  pdf,
  text,
  archive,
  other
}

enum FileCategory {
  personal,
  ministry,
  events,
  testimonies,
  music,
  sermons,
  resources,
  shared
}

enum FilePermission {
  private,
  public,
  ministry,
  admin
}

class FileModel {
  final String id;
  final String name;
  final String originalName;
  final String path;
  final String url;
  final FileType type;
  final FileCategory category;
  final FilePermission permission;
  final int size;
  final String mimeType;
  final String? description;
  final String? tags;
  final String uploadedBy;
  final DateTime uploadedAt;
  final DateTime? modifiedAt;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  final bool isShared;
  final List<String> sharedWith;
  final int downloadCount;
  final bool isFavorite;
  final String? parentFolder;

  FileModel({
    required this.id,
    required this.name,
    required this.originalName,
    required this.path,
    required this.url,
    required this.type,
    required this.category,
    required this.permission,
    required this.size,
    required this.mimeType,
    this.description,
    this.tags,
    required this.uploadedBy,
    required this.uploadedAt,
    this.modifiedAt,
    this.thumbnailUrl,
    this.metadata,
    this.isShared = false,
    this.sharedWith = const [],
    this.downloadCount = 0,
    this.isFavorite = false,
    this.parentFolder,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      name: json['name'],
      originalName: json['original_name'],
      path: json['path'],
      url: json['url'],
      type: FileType.values[json['type']],
      category: FileCategory.values[json['category']],
      permission: FilePermission.values[json['permission']],
      size: json['size'],
      mimeType: json['mime_type'],
      description: json['description'],
      tags: json['tags'],
      uploadedBy: json['uploaded_by'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      modifiedAt: json['modified_at'] != null 
          ? DateTime.parse(json['modified_at']) 
          : null,
      thumbnailUrl: json['thumbnail_url'],
      metadata: json['metadata'],
      isShared: json['is_shared'] ?? false,
      sharedWith: List<String>.from(json['shared_with'] ?? []),
      downloadCount: json['download_count'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      parentFolder: json['parent_folder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'path': path,
      'url': url,
      'type': type.index,
      'category': category.index,
      'permission': permission.index,
      'size': size,
      'mime_type': mimeType,
      'description': description,
      'tags': tags,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt.toIso8601String(),
      'modified_at': modifiedAt?.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
      'metadata': metadata,
      'is_shared': isShared,
      'shared_with': sharedWith,
      'download_count': downloadCount,
      'is_favorite': isFavorite,
      'parent_folder': parentFolder,
    };
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData get typeIcon {
    switch (type) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.video_file;
      case FileType.audio:
        return Icons.audio_file;
      case FileType.document:
        return Icons.description;
      case FileType.pdf:
        return Icons.picture_as_pdf;
      case FileType.text:
        return Icons.text_snippet;
      case FileType.archive:
        return Icons.archive;
      case FileType.other:
        return Icons.insert_drive_file;
    }
  }

  Color get categoryColor {
    switch (category) {
      case FileCategory.personal:
        return Colors.blue;
      case FileCategory.ministry:
        return Colors.purple;
      case FileCategory.events:
        return Colors.orange;
      case FileCategory.testimonies:
        return Colors.green;
      case FileCategory.music:
        return Colors.pink;
      case FileCategory.sermons:
        return Colors.indigo;
      case FileCategory.resources:
        return Colors.teal;
      case FileCategory.shared:
        return Colors.amber;
    }
  }

  bool get canEdit => permission != FilePermission.public;
  bool get canDelete => permission == FilePermission.private;
  bool get canShare => permission != FilePermission.private;
}

class FolderModel {
  final String id;
  final String name;
  final String? description;
  final FileCategory category;
  final FilePermission permission;
  final String createdBy;
  final DateTime createdAt;
  final String? parentId;
  final List<String> children;
  final int fileCount;
  final Color? color;

  FolderModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.permission,
    required this.createdBy,
    required this.createdAt,
    this.parentId,
    this.children = const [],
    this.fileCount = 0,
    this.color,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: FileCategory.values[json['category']],
      permission: FilePermission.values[json['permission']],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      parentId: json['parent_id'],
      children: List<String>.from(json['children'] ?? []),
      fileCount: json['file_count'] ?? 0,
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'permission': permission.index,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'parent_id': parentId,
      'children': children,
      'file_count': fileCount,
      'color': color?.value,
    };
  }
}
