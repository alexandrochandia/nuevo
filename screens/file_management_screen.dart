
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_management_provider.dart';
import '../providers/aura_provider.dart';
import '../models/file_model.dart';
import '../widgets/file_upload_modal.dart';
import '../widgets/file_card.dart';
import '../widgets/file_grid_view.dart';
import '../widgets/storage_stats_widget.dart';
import '../utils/glow_styles.dart';

class FileManagementScreen extends StatefulWidget {
  const FileManagementScreen({super.key});

  @override
  State<FileManagementScreen> createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileManagementProvider>().loadFiles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FileManagementProvider, AuraProvider>(
      builder: (context, fileProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: auraProvider.currentAuraColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Gestión de Archivos',
              style: GlowStyles.boldNeonText.copyWith(fontSize: 24),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.list : Icons.grid_view,
                  color: auraProvider.currentAuraColor,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: auraProvider.currentAuraColor),
                onPressed: () => fileProvider.refreshFiles(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Todos', icon: Icon(Icons.folder)),
                Tab(text: 'Favoritos', icon: Icon(Icons.favorite)),
                Tab(text: 'Recientes', icon: Icon(Icons.access_time)),
                Tab(text: 'Estadísticas', icon: Icon(Icons.analytics)),
              ],
              labelColor: auraProvider.currentAuraColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: auraProvider.currentAuraColor,
            ),
          ),
          body: Column(
            children: [
              _buildSearchBar(fileProvider, auraProvider),
              _buildFilterChips(fileProvider, auraProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllFilesTab(fileProvider, auraProvider),
                    _buildFavoritesTab(fileProvider, auraProvider),
                    _buildRecentTab(fileProvider, auraProvider),
                    _buildStatsTab(fileProvider, auraProvider),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(fileProvider, auraProvider),
        );
      },
    );
  }

  Widget _buildSearchBar(FileManagementProvider provider, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar archivos...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            Icons.search,
            color: auraProvider.currentAuraColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear();
                    provider.searchFiles('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          provider.searchFiles(value);
        },
      ),
    );
  }

  Widget _buildFilterChips(FileManagementProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            'Todos',
            provider.selectedCategory == null && provider.selectedType == null,
            () {
              provider.setCategory(null);
              provider.setType(null);
            },
            auraProvider,
          ),
          const SizedBox(width: 8),
          ...FileCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                category.name.toUpperCase(),
                provider.selectedCategory == category,
                () => provider.setCategory(category),
                auraProvider,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    AuraProvider auraProvider,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? auraProvider.currentAuraColor.withOpacity(0.2)
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? auraProvider.currentAuraColor 
                : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: auraProvider.currentAuraColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? auraProvider.currentAuraColor 
                : Colors.grey[400],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAllFilesTab(FileManagementProvider provider, AuraProvider auraProvider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: auraProvider.currentAuraColor,
        ),
      );
    }

    if (provider.filteredFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay archivos',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para subir tu primer archivo',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return _isGridView
        ? FileGridView(
            files: provider.filteredFiles,
            onFileTap: _showFileDetails,
            onFileAction: _showFileActions,
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.filteredFiles.length,
            itemBuilder: (context, index) {
              final file = provider.filteredFiles[index];
              return FileCard(
                file: file,
                onTap: () => _showFileDetails(file),
                onLongPress: () => _showFileActions(file),
              );
            },
          );
  }

  Widget _buildFavoritesTab(FileManagementProvider provider, AuraProvider auraProvider) {
    final favorites = provider.favoriteFiles;
    
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay favoritos',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final file = favorites[index];
        return FileCard(
          file: file,
          onTap: () => _showFileDetails(file),
          onLongPress: () => _showFileActions(file),
        );
      },
    );
  }

  Widget _buildRecentTab(FileManagementProvider provider, AuraProvider auraProvider) {
    final recent = provider.recentFiles;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final file = recent[index];
        return FileCard(
          file: file,
          onTap: () => _showFileDetails(file),
          onLongPress: () => _showFileActions(file),
        );
      },
    );
  }

  Widget _buildStatsTab(FileManagementProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StorageStatsWidget(
            stats: provider.storageStats,
            auraColor: auraProvider.currentAuraColor,
          ),
          const SizedBox(height: 24),
          _buildTypeStats(provider, auraProvider),
          const SizedBox(height: 24),
          _buildCategoryStats(provider, auraProvider),
        ],
      ),
    );
  }

  Widget _buildTypeStats(FileManagementProvider provider, AuraProvider auraProvider) {
    final stats = provider.fileTypeStats;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Archivos por Tipo',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...stats.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    FileModel(
                      id: '',
                      name: '',
                      originalName: '',
                      path: '',
                      url: '',
                      type: entry.key,
                      category: FileCategory.personal,
                      permission: FilePermission.private,
                      size: 0,
                      mimeType: '',
                      uploadedBy: '',
                      uploadedAt: DateTime.now(),
                    ).typeIcon,
                    color: auraProvider.currentAuraColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      color: auraProvider.currentAuraColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(FileManagementProvider provider, AuraProvider auraProvider) {
    final stats = provider.categoryStats;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Archivos por Categoría',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...stats.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: FileModel(
                        id: '',
                        name: '',
                        originalName: '',
                        path: '',
                        url: '',
                        type: FileType.other,
                        category: entry.key,
                        permission: FilePermission.private,
                        size: 0,
                        mimeType: '',
                        uploadedBy: '',
                        uploadedAt: DateTime.now(),
                      ).categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      color: auraProvider.currentAuraColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(FileManagementProvider provider, AuraProvider auraProvider) {
    return FloatingActionButton(
      backgroundColor: auraProvider.currentAuraColor,
      child: const Icon(Icons.add, color: Colors.black),
      onPressed: () => _showUploadModal(provider, auraProvider),
    );
  }

  void _showUploadModal(FileManagementProvider provider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FileUploadModal(
        onUpload: (file, category, permission, description, tags) async {
          return await provider.uploadFile(
            file: file,
            category: category,
            permission: permission,
            description: description,
            tags: tags,
          );
        },
      ),
    );
  }

  void _showFileDetails(FileModel file) {
    // Implementar detalles del archivo
  }

  void _showFileActions(FileModel file) {
    // Implementar acciones del archivo
  }
}
