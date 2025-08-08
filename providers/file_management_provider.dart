
import 'package:flutter/material.dart';
import '../models/file_model.dart';
import '../services/file_management_service.dart';

class FileManagementProvider with ChangeNotifier {
  final FileManagementService _fileService = FileManagementService.instance;
  
  List<FileModel> _files = [];
  List<FolderModel> _folders = [];
  Map<String, dynamic> _storageStats = {};
  
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  String? _currentFolder;
  FileCategory? _selectedCategory;
  FileType? _selectedType;
  String _searchQuery = '';

  // Getters
  List<FileModel> get files => _files;
  List<FolderModel> get folders => _folders;
  Map<String, dynamic> get storageStats => _storageStats;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  String? get currentFolder => _currentFolder;
  FileCategory? get selectedCategory => _selectedCategory;
  FileType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  // Filtered files
  List<FileModel> get filteredFiles {
    var filtered = _files;

    if (_selectedCategory != null) {
      filtered = filtered.where((f) => f.category == _selectedCategory).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((f) => f.type == _selectedType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((f) => 
        f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (f.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (f.tags?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    return filtered;
  }

  List<FileModel> get favoriteFiles => 
      _files.where((f) => f.isFavorite).toList();

  List<FileModel> get recentFiles => 
      _files.take(10).toList();

  Map<FileType, int> get fileTypeStats {
    final stats = <FileType, int>{};
    for (final file in _files) {
      stats[file.type] = (stats[file.type] ?? 0) + 1;
    }
    return stats;
  }

  Map<FileCategory, int> get categoryStats {
    final stats = <FileCategory, int>{};
    for (final file in _files) {
      stats[file.category] = (stats[file.category] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> loadFiles({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _files = await _fileService.getFiles(
        category: _selectedCategory,
        type: _selectedType,
        parentFolder: _currentFolder,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      await loadStorageStats();
    } catch (e) {
      _error = 'Error loading files: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadFile({
    required dynamic file,
    required FileCategory category,
    FilePermission permission = FilePermission.private,
    String? description,
    String? tags,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final uploadedFile = await _fileService.uploadFile(
        file: file,
        category: category,
        permission: permission,
        description: description,
        tags: tags,
        parentFolder: _currentFolder,
      );

      if (uploadedFile != null) {
        _files.insert(0, uploadedFile);
        await loadStorageStats();
        _isUploading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Error uploading file: $e';
    }

    _isUploading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      final success = await _fileService.deleteFile(fileId);
      if (success) {
        _files.removeWhere((f) => f.id == fileId);
        await loadStorageStats();
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Error deleting file: $e';
      notifyListeners();
    }
    return false;
  }

  Future<String?> downloadFile(String fileId, String savePath) async {
    try {
      return await _fileService.downloadFile(fileId, savePath);
    } catch (e) {
      _error = 'Error downloading file: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> shareFile(String fileId, List<String> userIds) async {
    try {
      final success = await _fileService.shareFile(fileId, userIds);
      if (success) {
        final fileIndex = _files.indexWhere((f) => f.id == fileId);
        if (fileIndex != -1) {
          // Actualizar el archivo en la lista local
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _error = 'Error sharing file: $e';
      notifyListeners();
    }
    return false;
  }

  Future<void> toggleFavorite(String fileId) async {
    try {
      final fileIndex = _files.indexWhere((f) => f.id == fileId);
      if (fileIndex != -1) {
        final file = _files[fileIndex];
        final newFavoriteStatus = !file.isFavorite;
        
        final success = await _fileService.toggleFavorite(fileId, newFavoriteStatus);
        if (success) {
          // Actualizar localmente
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Error toggling favorite: $e';
      notifyListeners();
    }
  }

  Future<void> searchFiles(String query) async {
    _searchQuery = query;
    await loadFiles();
  }

  void setCategory(FileCategory? category) {
    _selectedCategory = category;
    loadFiles();
  }

  void setType(FileType? type) {
    _selectedType = type;
    loadFiles();
  }

  void setCurrentFolder(String? folderId) {
    _currentFolder = folderId;
    loadFiles();
  }

  Future<void> loadStorageStats() async {
    try {
      _storageStats = await _fileService.getStorageStats();
    } catch (e) {
      debugPrint('Error loading storage stats: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshFiles() {
    loadFiles(refresh: true);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
