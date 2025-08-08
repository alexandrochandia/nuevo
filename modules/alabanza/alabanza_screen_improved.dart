import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alabanza_provider.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/alabanza_card.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/song_options_modal.dart';
import '../../utils/glow_styles.dart';

class AlabanzaScreenImproved extends StatefulWidget {
  const AlabanzaScreenImproved({super.key});

  @override
  State<AlabanzaScreenImproved> createState() => _AlabanzaScreenImprovedState();
}

class _AlabanzaScreenImprovedState extends State<AlabanzaScreenImproved>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AlabanzaProvider, AuraProvider>(
      builder: (context, alabanzaProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0f0f23),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0f0f23),
                  Color(0xFF1a1a2e),
                  Color(0xFF0f0f23),
                ],
                stops: [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header premium
                  _buildHeader(auraProvider),
                  
                  // Reproductor actual si hay una canción
                  if (alabanzaProvider.currentSong != null)
                    _buildCurrentPlayer(alabanzaProvider, auraProvider),
                  
                  // Tabs y contenido
                  Expanded(
                    child: Column(
                      children: [
                        // Tabs
                        _buildTabs(auraProvider),
                        
                        // Contenido de tabs
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              _buildAllSongs(alabanzaProvider, auraProvider),
                              _buildFavorites(alabanzaProvider, auraProvider),
                              _buildCategories(alabanzaProvider, auraProvider),
                              _buildPlaylists(alabanzaProvider, auraProvider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Título con efecto glow - FIXED: Added flexible layout
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: auraProvider.selectedAuraColor,
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  '🎵 Alabanza VMF',
                  style: TextStyle(
                    fontSize: 22, // Reduced from 24 to prevent overflow
                    fontWeight: FontWeight.bold,
                    color: auraProvider.selectedAuraColor,
                    shadows: [
                      Shadow(
                        color: auraProvider.selectedAuraColor.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _showSearchDialog(),
                icon: Icon(
                  Icons.search,
                  color: auraProvider.selectedAuraColor,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estadísticas - FIXED: Responsive layout
          Consumer<AlabanzaProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1a1a2e).withOpacity(0.8),
                      const Color(0xFF16213e).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: auraProvider.selectedAuraColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '${provider.songs.length}',
                          'Canciones',
                          Icons.music_note,
                          auraProvider.selectedAuraColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: auraProvider.selectedAuraColor.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${provider.favorites.length}',
                          'Favoritas',
                          Icons.favorite,
                          auraProvider.selectedAuraColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: auraProvider.selectedAuraColor.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '${provider.categories.length - 1}',
                          'Categorías',
                          Icons.category,
                          auraProvider.selectedAuraColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11, // Reduced from 12
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildCurrentPlayer(AlabanzaProvider alabanzaProvider, AuraProvider auraProvider) {
    final currentSong = alabanzaProvider.currentSong!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            auraProvider.selectedAuraColor.withOpacity(0.1),
            auraProvider.selectedAuraColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: auraProvider.selectedAuraColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: auraProvider.selectedAuraColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Información de la canción actual - FIXED: Better overflow handling
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      auraProvider.selectedAuraColor,
                      auraProvider.selectedAuraColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: auraProvider.selectedAuraColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  currentSong.isVideo ? Icons.videocam : Icons.music_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSong.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => SongOptionsModal.show(context, currentSong),
                icon: Icon(
                  Icons.more_vert,
                  color: auraProvider.selectedAuraColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Controles de reproducción - FIXED: Better spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => alabanzaProvider.playPrevious(),
                icon: Icon(
                  Icons.skip_previous,
                  color: auraProvider.selectedAuraColor,
                  size: 32,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      auraProvider.selectedAuraColor,
                      auraProvider.selectedAuraColor.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: auraProvider.selectedAuraColor.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    alabanzaProvider.isPlaying
                        ? alabanzaProvider.pauseSong()
                        : alabanzaProvider.resumeSong();
                  },
                  icon: Icon(
                    alabanzaProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => alabanzaProvider.playNext(),
                icon: Icon(
                  Icons.skip_next,
                  color: auraProvider.selectedAuraColor,
                  size: 32,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Barra de progreso - FIXED: Better layout
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 4,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: alabanzaProvider.totalDuration > 0
                      ? (alabanzaProvider.currentPosition / alabanzaProvider.totalDuration).clamp(0.0, 1.0)
                      : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          auraProvider.selectedAuraColor,
                          auraProvider.selectedAuraColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Tiempo - FIXED: Prevent overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                alabanzaProvider.formatDuration(alabanzaProvider.currentPosition),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                alabanzaProvider.formatDuration(alabanzaProvider.totalDuration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraProvider.selectedAuraColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              auraProvider.selectedAuraColor,
              auraProvider.selectedAuraColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 11, // Reduced from 12
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10, // Reduced from 12
        ),
        isScrollable: false,
        tabAlignment: TabAlignment.fill,
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Favoritas'),
          Tab(text: 'Categorías'),
          Tab(text: 'Playlists'),
        ],
      ),
    );
  }

  // FIXED: Improved list builders with better overflow handling
  Widget _buildAllSongs(AlabanzaProvider alabanzaProvider, AuraProvider auraProvider) {
    if (alabanzaProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraProvider.selectedAuraColor),
        ),
      );
    }

    if (alabanzaProvider.songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: auraProvider.selectedAuraColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay canciones disponibles',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: alabanzaProvider.songs.length,
      itemBuilder: (context, index) {
        final song = alabanzaProvider.songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AlabanzaCard(
            song: song,
            onTap: () => alabanzaProvider.playSong(song),
          ),
        );
      },
    );
  }

  Widget _buildFavorites(AlabanzaProvider alabanzaProvider, AuraProvider auraProvider) {
    final favorites = alabanzaProvider.songs.where((song) => song.isFavorite).toList();
    
    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: auraProvider.selectedAuraColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No tienes canciones favoritas',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca el corazón en cualquier canción para agregarla',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final song = favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AlabanzaCard(
            song: song,
            onTap: () => alabanzaProvider.playSong(song),
          ),
        );
      },
    );
  }

  Widget _buildCategories(AlabanzaProvider alabanzaProvider, AuraProvider auraProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: alabanzaProvider.categories.length,
      itemBuilder: (context, index) {
        final category = alabanzaProvider.categories[index];
        if (category == 'Todas') return const SizedBox.shrink();
        
        final songsInCategory = alabanzaProvider.songs
            .where((song) => song.category == category)
            .toList();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e).withOpacity(0.8),
                const Color(0xFF16213e).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: auraProvider.selectedAuraColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => alabanzaProvider.filterByCategory(category),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            auraProvider.selectedAuraColor,
                            auraProvider.selectedAuraColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: auraProvider.selectedAuraColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${songsInCategory.length} canciones',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: auraProvider.selectedAuraColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylists(AlabanzaProvider alabanzaProvider, AuraProvider auraProvider) {
    final playlists = [
      {'name': 'Lo más reproducido', 'icon': Icons.trending_up, 'count': 8},
      {'name': 'Nuevas canciones', 'icon': Icons.new_releases, 'count': 5},
      {'name': 'Adoración profunda', 'icon': Icons.favorite, 'count': 12},
      {'name': 'Alabanza congregacional', 'icon': Icons.people, 'count': 15},
    ];

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e).withOpacity(0.8),
                const Color(0xFF16213e).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: auraProvider.selectedAuraColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showComingSoonDialog(playlist['name'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            auraProvider.selectedAuraColor,
                            auraProvider.selectedAuraColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: auraProvider.selectedAuraColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        playlist['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${playlist['count']} canciones',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: auraProvider.selectedAuraColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Adoración':
        return Icons.favorite;
      case 'Alabanza':
        return Icons.music_note;
      case 'Ministerio VMF':
        return Icons.church;
      case 'Congregacional':
        return Icons.people;
      case 'Juvenil':
        return Icons.group;
      case 'Instrumentales':
        return Icons.piano;
      case 'Videos en Vivo':
        return Icons.live_tv;
      default:
        return Icons.music_note;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<AuraProvider>(
        builder: (context, auraProvider, child) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            title: Text(
              'Buscar Canciones',
              style: TextStyle(color: auraProvider.selectedAuraColor),
            ),
            content: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por título, artista o etiqueta...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: auraProvider.selectedAuraColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: auraProvider.selectedAuraColor),
                ),
              ),
              onSubmitted: (value) {
                Provider.of<AlabanzaProvider>(context, listen: false)
                    .searchSongs(value);
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<AlabanzaProvider>(context, listen: false)
                      .searchSongs(_searchController.text);
                  Navigator.pop(context);
                },
                child: Text(
                  'Buscar',
                  style: TextStyle(color: auraProvider.selectedAuraColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AuraProvider>(
        builder: (context, auraProvider, child) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            title: Text(
              'Próximamente',
              style: TextStyle(color: auraProvider.selectedAuraColor),
            ),
            content: Text(
              '$feature estará disponible en una próxima actualización.',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Entendido',
                  style: TextStyle(color: auraProvider.selectedAuraColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}