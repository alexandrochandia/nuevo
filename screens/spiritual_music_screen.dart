import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spiritual_music_provider.dart';
import '../providers/aura_provider.dart';
import '../models/spiritual_music_model.dart';
import '../widgets/spiritual_music_card.dart';
import '../widgets/music_filter_modal.dart';
import '../screens/audio_player_screen.dart';
import '../utils/glow_styles.dart';

class SpiritualMusicScreen extends StatefulWidget {
  const SpiritualMusicScreen({Key? key}) : super(key: key);

  @override
  State<SpiritualMusicScreen> createState() => _SpiritualMusicScreenState();
}

class _SpiritualMusicScreenState extends State<SpiritualMusicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SpiritualMusicProvider, AuraProvider>(
      builder: (context, musicProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;
        
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GlowStyles.neonBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: GlowStyles.neonBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Música Espiritual',
                  style: GlowStyles.boldWhiteText.copyWith(fontSize: 20),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _showFilterModal(context, musicProvider, auraColor),
                icon: Icon(
                  Icons.filter_list,
                  color: auraColor,
                ),
              ),
              IconButton(
                onPressed: () => musicProvider.refreshData(),
                icon: Icon(
                  Icons.refresh,
                  color: auraColor,
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: auraColor,
              labelColor: auraColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Biblioteca'),
                Tab(text: 'Favoritos'),
                Tab(text: 'Testimonios'),
                Tab(text: 'Predicación'),
                Tab(text: 'Populares'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Barra de búsqueda
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: auraColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    musicProvider.applyFilters(searchQuery: value);
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar música espiritual...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: auraColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Contenido de tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMusicLibrary(musicProvider, auraColor),
                    _buildFavorites(musicProvider, auraColor),
                    _buildTestimonyPlaylist(musicProvider, auraColor),
                    _buildPreachingPlaylist(musicProvider, auraColor),
                    _buildPopularMusic(musicProvider, auraColor),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showMusicUploadModal(context, auraColor),
            backgroundColor: auraColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildMusicLibrary(SpiritualMusicProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.musicLibrary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay música disponible',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.musicLibrary.length,
      itemBuilder: (context, index) {
        final music = provider.musicLibrary[index];
        return SpiritualMusicCard(
          music: music,
          auraColor: auraColor,
          onPlay: () => _playMusic(context, music, provider),
          onFavorite: () => provider.toggleFavorite(music),
          onAddToTestimony: () => provider.addToTestimonyPlaylist(music),
          onAddToPreaching: () => provider.addToPreachingPlaylist(music),
        );
      },
    );
  }

  Widget _buildFavorites(SpiritualMusicProvider provider, Color auraColor) {
    if (provider.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes favoritos aún',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.favorites.length,
      itemBuilder: (context, index) {
        final music = provider.favorites[index];
        return SpiritualMusicCard(
          music: music,
          auraColor: auraColor,
          onPlay: () => _playMusic(context, music, provider),
          onFavorite: () => provider.toggleFavorite(music),
          onAddToTestimony: () => provider.addToTestimonyPlaylist(music),
          onAddToPreaching: () => provider.addToPreachingPlaylist(music),
        );
      },
    );
  }

  Widget _buildTestimonyPlaylist(SpiritualMusicProvider provider, Color auraColor) {
    if (provider.testimonyPlaylist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay música para testimonios',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.testimonyPlaylist.length,
      itemBuilder: (context, index) {
        final music = provider.testimonyPlaylist[index];
        return SpiritualMusicCard(
          music: music,
          auraColor: auraColor,
          onPlay: () => _playMusic(context, music, provider),
          onFavorite: () => provider.toggleFavorite(music),
          onRemoveFromTestimony: () => provider.removeFromTestimonyPlaylist(music.id),
          onAddToPreaching: () => provider.addToPreachingPlaylist(music),
        );
      },
    );
  }

  Widget _buildPreachingPlaylist(SpiritualMusicProvider provider, Color auraColor) {
    if (provider.preachingPlaylist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_play,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay música para predicación',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.preachingPlaylist.length,
      itemBuilder: (context, index) {
        final music = provider.preachingPlaylist[index];
        return SpiritualMusicCard(
          music: music,
          auraColor: auraColor,
          onPlay: () => _playMusic(context, music, provider),
          onFavorite: () => provider.toggleFavorite(music),
          onAddToTestimony: () => provider.addToTestimonyPlaylist(music),
          onRemoveFromPreaching: () => provider.removeFromPreachingPlaylist(music.id),
        );
      },
    );
  }

  Widget _buildPopularMusic(SpiritualMusicProvider provider, Color auraColor) {
    final popularMusic = provider.getMostPopular();

    if (popularMusic.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              color: Colors.grey[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay música popular',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: popularMusic.length,
      itemBuilder: (context, index) {
        final music = popularMusic[index];
        return SpiritualMusicCard(
          music: music,
          auraColor: auraColor,
          onPlay: () => _playMusic(context, music, provider),
          onFavorite: () => provider.toggleFavorite(music),
          onAddToTestimony: () => provider.addToTestimonyPlaylist(music),
          onAddToPreaching: () => provider.addToPreachingPlaylist(music),
        );
      },
    );
  }

  void _playMusic(BuildContext context, SpiritualMusic music, SpiritualMusicProvider provider) {
    provider.playMusic(music);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(music: music),
      ),
    );
  }

  void _showFilterModal(BuildContext context, SpiritualMusicProvider provider, Color auraColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MusicFilterModal(
        provider: provider,
        auraColor: auraColor,
      ),
    );
  }

  void _showMusicUploadModal(BuildContext context, Color auraColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.cloud_upload, color: auraColor),
            const SizedBox(width: 12),
            const Text(
              'Agregar Música',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'Funcionalidad de subida de música espiritual.\n\nEsta característica permite a los líderes de la iglesia agregar nueva música a la biblioteca espiritual.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: auraColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí se implementaría la lógica de subida
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: auraColor,
            ),
            child: const Text('Subir Música', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}