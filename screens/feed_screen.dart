import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../providers/aura_provider.dart';
import '../models/feed_post_model.dart';
import '../widgets/feed_post_card.dart';
import 'create_feed_screen.dart';
import 'post_detail_screen.dart';
import '../utils/glow_styles.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
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
    final auraProvider = Provider.of<AuraProvider>(context);
    final auraColor = auraProvider.currentAuraColor;
    
    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  const Color(0xFF0a0a0a),
                ],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(auraColor, feedProvider),
                      _buildTabBar(auraColor),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAllPostsTab(feedProvider, auraColor),
                            _buildHighlightedTab(feedProvider, auraColor),
                            _buildCategoriesTab(feedProvider, auraColor),
                            _buildSearchTab(feedProvider, auraColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: _buildCreatePostFAB(auraColor),
        );
      },
    );
  }

  Widget _buildHeader(Color auraColor, FeedProvider feedProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: auraColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: auraColor,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        auraColor.withOpacity(0.2),
                        auraColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: auraColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.rss_feed,
                        color: auraColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Feed VMF',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Noticias Espirituales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${feedProvider.filteredPosts.length} publicaciones',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFe74c3c).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFe74c3c),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe74c3c),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFe74c3c).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'EN VIVO',
                  style: TextStyle(
                    color: Color(0xFFe74c3c),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color auraColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              auraColor.withOpacity(0.3),
              auraColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: auraColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: auraColor,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.feed, size: 18),
            text: 'Todo',
          ),
          Tab(
            icon: Icon(Icons.star, size: 18),
            text: 'Destacados',
          ),
          Tab(
            icon: Icon(Icons.category, size: 18),
            text: 'Categorías',
          ),
          Tab(
            icon: Icon(Icons.search, size: 18),
            text: 'Buscar',
          ),
        ],
      ),
    );
  }

  Widget _buildAllPostsTab(FeedProvider feedProvider, Color auraColor) {
    if (feedProvider.isLoading) {
      return _buildLoadingIndicator(auraColor);
    }

    final posts = feedProvider.filteredPosts;

    if (posts.isEmpty) {
      return _buildEmptyState(auraColor, 'No hay publicaciones disponibles');
    }

    return RefreshIndicator(
      onRefresh: () async {
        feedProvider.clearFilters();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: auraColor,
      backgroundColor: const Color(0xFF1a1a2e),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FeedPostCard(
              post: post,
              onTap: () => _openPostDetail(post),
              onLike: () => feedProvider.toggleLike(post.id),
              onComment: () => _openPostDetail(post),
              onShare: () => feedProvider.sharePost(post.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighlightedTab(FeedProvider feedProvider, Color auraColor) {
    final highlightedPosts = feedProvider.highlightedPosts;

    if (highlightedPosts.isEmpty) {
      return _buildEmptyState(auraColor, 'No hay publicaciones destacadas');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: highlightedPosts.length,
      itemBuilder: (context, index) {
        final post = highlightedPosts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FeedPostCard(
            post: post,
            onTap: () => _openPostDetail(post),
            onLike: () => feedProvider.toggleLike(post.id),
            onComment: () => _openPostDetail(post),
            onShare: () => feedProvider.sharePost(post.id),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(FeedProvider feedProvider, Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por Categoría',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Categorías
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: FeedPostCategory.values.map((category) {
              final isSelected = feedProvider.selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  feedProvider.setSelectedCategory(
                    isSelected ? null : category,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              auraColor.withOpacity(0.3),
                              auraColor.withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? auraColor
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? auraColor : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Filtrar por Tipo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tipos
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: FeedPostType.values.map((type) {
              final isSelected = feedProvider.selectedType == type;
              return GestureDetector(
                onTap: () {
                  feedProvider.setSelectedType(
                    isSelected ? null : type,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              type.color.withOpacity(0.3),
                              type.color.withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? type.color
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected ? type.color : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Clear filters button
          if (feedProvider.selectedCategory != null || feedProvider.selectedType != null)
            Center(
              child: ElevatedButton.icon(
                onPressed: () => feedProvider.clearFilters(),
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: auraColor.withOpacity(0.2),
                  foregroundColor: auraColor,
                  side: BorderSide(
                    color: auraColor.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(FeedProvider feedProvider, Color auraColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => feedProvider.setSearchQuery(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar publicaciones, autores, tags...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: auraColor,
                ),
                suffixIcon: feedProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          feedProvider.setSearchQuery('');
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Search results
          Expanded(
            child: feedProvider.searchQuery.isEmpty
                ? _buildEmptyState(auraColor, 'Escribe algo para buscar publicaciones')
                : feedProvider.filteredPosts.isEmpty
                    ? _buildEmptyState(auraColor, 'No se encontraron resultados')
                    : ListView.builder(
                        itemCount: feedProvider.filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = feedProvider.filteredPosts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FeedPostCard(
                              post: post,
                              onTap: () => _openPostDetail(post),
                              onLike: () => feedProvider.toggleLike(post.id),
                              onComment: () => _openPostDetail(post),
                              onShare: () => feedProvider.sharePost(post.id),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color auraColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(auraColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando feed espiritual...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color auraColor, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: auraColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: auraColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.rss_feed,
              color: auraColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostFAB(Color auraColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            auraColor.withOpacity(0.3),
            auraColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: auraColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _openCreatePost(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.add,
          color: auraColor,
          size: 28,
        ),
      ),
    );
  }

  void _openPostDetail(FeedPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateFeedScreen(),
      ),
    );
  }
}