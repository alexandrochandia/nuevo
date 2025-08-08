
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spiritual_posts_provider.dart';
import '../models/spiritual_post_model.dart';
import '../widgets/spiritual_post_card.dart';
import '../widgets/create_post_modal.dart';

class SpiritualFeedScreen extends StatefulWidget {
  const SpiritualFeedScreen({Key? key}) : super(key: key);

  @override
  State<SpiritualFeedScreen> createState() => _SpiritualFeedScreenState();
}

class _SpiritualFeedScreenState extends State<SpiritualFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpiritualPostsProvider>().loadFeedPosts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar con gradiente
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFF4C46E5),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Feed Espiritual',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.8),
                        const Color(0xFF4C46E5).withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _showSearchModal(context),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.white),
                onPressed: () => _showBookmarkedPosts(context),
              ),
            ],
          ),

          // Tabs de categorías
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFF6C63FF),
                labelColor: const Color(0xFF6C63FF),
                unselectedLabelColor: Colors.grey,
                onTap: (index) => _loadPostsByCategory(index),
                tabs: const [
                  Tab(text: '📖 Todo'),
                  Tab(text: '🙏 Oraciones'),
                  Tab(text: '✨ Testimonios'),
                  Tab(text: '💭 Reflexiones'),
                  Tab(text: '📢 Anuncios'),
                  Tab(text: '🎵 Música'),
                ],
              ),
            ),
          ),

          // Lista de posts
          Consumer<SpiritualPostsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                );
              }

              if (provider.error != null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.loadFeedPosts();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay posts disponibles',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sé el primero en compartir contenido espiritual',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = provider.posts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SpiritualPostCard(
                        post: post,
                        onLike: () => provider.toggleLike(post.id),
                        onBookmark: () => provider.toggleBookmark(post.id),
                        onShare: () => provider.sharePost(post.id),
                        onComment: () => _showCommentsModal(context, post),
                      ),
                    );
                  },
                  childCount: provider.posts.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostModal(context),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _loadPostsByCategory(int index) {
    final provider = context.read<SpiritualPostsProvider>();
    switch (index) {
      case 0:
        provider.loadFeedPosts();
        break;
      case 1:
        provider.loadPostsByType('prayer');
        break;
      case 2:
        provider.loadPostsByType('testimony');
        break;
      case 3:
        provider.loadPostsByType('reflection');
        break;
      case 4:
        provider.loadPostsByType('announcement');
        break;
      case 5:
        provider.loadPostsByType('music');
        break;
    }
  }

  void _showCreatePostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostModal(),
    );
  }

  void _showSearchModal(BuildContext context) {
    showSearch(
      context: context,
      delegate: SpiritualPostSearchDelegate(),
    );
  }

  void _showBookmarkedPosts(BuildContext context) {
    context.read<SpiritualPostsProvider>().loadBookmarkedPosts();
  }

  void _showCommentsModal(BuildContext context, SpiritualPostModel post) {
    // TODO: Implementar modal de comentarios
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class SpiritualPostSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar contenido espiritual...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      primaryColor: const Color(0xFF6C63FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0F),
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      context.read<SpiritualPostsProvider>().searchPosts(query);
    }

    return Container(
      color: const Color(0xFF0A0A0F),
      child: Consumer<SpiritualPostsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.posts.length,
            itemBuilder: (context, index) {
              final post = provider.posts[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SpiritualPostCard(
                  post: post,
                  onLike: () => provider.toggleLike(post.id),
                  onBookmark: () => provider.toggleBookmark(post.id),
                  onShare: () => provider.sharePost(post.id),
                  onComment: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Busca versículos, testimonios, reflexiones...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
