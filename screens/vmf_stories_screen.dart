import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart'; // Comentado temporalmente
import '../providers/vmf_stories_provider.dart';
import '../providers/aura_provider.dart';
import '../models/vmf_story_model.dart';
import '../widgets/vmf_story_card.dart';
import 'vmf_story_viewer_screen.dart';
import 'vmf_camera_screen.dart';
import '../utils/glow_styles.dart';

class VMFStoriesScreen extends StatefulWidget {
  const VMFStoriesScreen({super.key});

  @override
  State<VMFStoriesScreen> createState() => _VMFStoriesScreenState();
}

class _VMFStoriesScreenState extends State<VMFStoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _categories = [
    {
      'category': null,
      'name': 'Todas',
      'icon': '🌟',
      'color': Colors.amber,
    },
    {
      'category': VMFStoryCategory.testimonio,
      'name': 'Testimonios',
      'icon': '🙏',
      'color': Colors.blue,
    },
    {
      'category': VMFStoryCategory.predicacion,
      'name': 'Predicación',
      'icon': '📖',
      'color': Colors.purple,
    },
    {
      'category': VMFStoryCategory.alabanza,
      'name': 'Alabanza',
      'icon': '🎵',
      'color': Colors.orange,
    },
    {
      'category': VMFStoryCategory.juventud,
      'name': 'Juventud',
      'icon': '🌱',
      'color': Colors.green,
    },
    {
      'category': VMFStoryCategory.oracion,
      'name': 'Oración',
      'icon': '🕊️',
      'color': Colors.cyan,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VMFStoriesProvider, AuraProvider>(
      builder: (context, storiesProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Historias VMF',
              style: GlowStyles.boldNeonText.copyWith(
                fontSize: 24,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: auraColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: auraColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: auraColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          color: auraColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VMFCameraScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: auraColor),
                onPressed: () => storiesProvider.refreshStories(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: auraColor,
              labelColor: auraColor,
              unselectedLabelColor: Colors.white60,
              onTap: (index) {
                final category = _categories[index]['category'];
                storiesProvider.filterByCategory(category);
              },
              tabs: _categories.map((cat) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat['icon'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(cat['name'], style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          body: storiesProvider.isLoading
              ? _buildLoadingView(auraColor)
              : storiesProvider.stories.isEmpty
                  ? _buildEmptyView(auraColor)
                  : _buildStoriesGrid(storiesProvider, auraColor),
        );
      },
    );
  }

  Widget _buildLoadingView(Color auraColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(auraColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando historias VMF...',
            style: TextStyle(
              color: auraColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(Color auraColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: auraColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: auraColor.withOpacity(0.3), width: 2),
            ),
            child: Icon(
              Icons.video_library_outlined,
              color: auraColor,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay historias disponibles',
            style: TextStyle(
              color: auraColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en compartir tu historia VMF',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VMFCameraScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'Crear Historia',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: auraColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesGrid(VMFStoriesProvider storiesProvider, Color auraColor) {
    final stories = storiesProvider.stories;

    return RefreshIndicator(
      onRefresh: () => storiesProvider.refreshStories(),
      color: auraColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            return VMFStoryCard(
              story: story,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VMFStoryViewerScreen(
                      stories: stories,
                      initialIndex: index,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}