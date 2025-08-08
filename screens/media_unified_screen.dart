import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../providers/aura_provider.dart';
import '../models/media_model.dart';
import '../widgets/media_card.dart';
import 'media_player_screen.dart';
import '../utils/glow_styles.dart';

class MediaUnifiedScreen extends StatefulWidget {
  const MediaUnifiedScreen({super.key});

  @override
  State<MediaUnifiedScreen> createState() => _MediaUnifiedScreenState();
}

class _MediaUnifiedScreenState extends State<MediaUnifiedScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MediaProvider, AuraProvider>(
      builder: (context, mediaProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0a0a0a),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0a0a0a),
                  const Color(0xFF1a1a2e),
                  auraProvider.currentAuraColor.withOpacity(0.1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(auraProvider),
                  _buildSearchBar(mediaProvider, auraProvider),
                  _buildTabBar(auraProvider),
                  Expanded(
                    child: _buildTabContent(mediaProvider, auraProvider),
                  ),
                  if (mediaProvider.currentPlaying != null)
                    _buildMiniPlayer(mediaProvider, auraProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AuraProvider auraProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlowStyles.neonBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GlowStyles.neonBlue.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: auraProvider.currentAuraColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multimedia VMF',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: auraProvider.currentAuraColor,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: auraProvider.currentAuraColor.withOpacity(0.5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Alabanza, sermones y más contenido espiritual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(MediaProvider mediaProvider, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => mediaProvider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Buscar contenido...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: auraProvider.currentAuraColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => mediaProvider.toggleFeaturedOnly(),
              icon: Icon(
                mediaProvider.showFeaturedOnly ? Icons.star : Icons.star_border,
                color: mediaProvider.showFeaturedOnly 
                    ? auraProvider.currentAuraColor 
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: auraProvider.currentAuraColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: auraProvider.currentAuraColor,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Destacados'),
          Tab(text: 'Alabanza'),
          Tab(text: 'Sermones'),
        ],
      ),
    );
  }

  Widget _buildTabContent(MediaProvider mediaProvider, AuraProvider auraProvider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFeaturedContent(mediaProvider, auraProvider),
        _buildCategoryContent(MediaCategory.alabanza, mediaProvider, auraProvider),
        _buildCategoryContent(MediaCategory.sermones, mediaProvider, auraProvider),
      ],
    );
  }

  Widget _buildFeaturedContent(MediaProvider mediaProvider, AuraProvider auraProvider) {
    if (mediaProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraProvider.currentAuraColor),
        ),
      );
    }

    final featuredMedia = mediaProvider.featuredMedia;
    final liveMedia = mediaProvider.liveMedia;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (liveMedia.isNotEmpty) ...[
            _buildSectionHeader('🔴 En Vivo Ahora', auraProvider),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: liveMedia.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 15),
                    child: MediaCard(
                      media: liveMedia[index],
                      onTap: () => _playMedia(liveMedia[index], mediaProvider),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
          _buildSectionHeader('⭐ Contenido Destacado', auraProvider),
          const SizedBox(height: 15),
          ...featuredMedia.map((media) => Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: MediaCard(
              media: media,
              onTap: () => _playMedia(media, mediaProvider),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(
    MediaCategory category, 
    MediaProvider mediaProvider, 
    AuraProvider auraProvider
  ) {
    if (mediaProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraProvider.currentAuraColor),
        ),
      );
    }

    final categoryMedia = mediaProvider.getMediaByCategory(category);

    if (categoryMedia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay contenido disponible',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categoryMedia.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: MediaCard(
            media: categoryMedia[index],
            onTap: () => _playMedia(categoryMedia[index], mediaProvider),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, AuraProvider auraProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: auraProvider.currentAuraColor,
      ),
    );
  }

  Widget _buildMiniPlayer(MediaProvider mediaProvider, AuraProvider auraProvider) {
    final media = mediaProvider.currentPlaying!;
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: auraProvider.currentAuraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              media.thumbnailUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: auraProvider.currentAuraColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    media.typeIcon,
                    color: auraProvider.currentAuraColor,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  media.title,
                  style: TextStyle(
                    color: auraProvider.currentAuraColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  media.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => mediaProvider.togglePlayPause(),
                icon: Icon(
                  mediaProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: auraProvider.currentAuraColor,
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaPlayerScreen(media: media),
                    ),
                  );
                },
                icon: Icon(
                  Icons.open_in_full_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _playMedia(MediaModel media, MediaProvider mediaProvider) {
    mediaProvider.playMedia(media);
    mediaProvider.incrementViews(media.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPlayerScreen(media: media),
      ),
    );
  }
}