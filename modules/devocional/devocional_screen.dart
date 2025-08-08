
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/devotional_model.dart';
import '../../providers/devotional_provider.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/devotional_card.dart';
import '../../screens/devotional_detail_screen.dart';
import '../../utils/glow_styles.dart';

class DevocionalScreen extends StatefulWidget {
  const DevocionalScreen({super.key});

  @override
  State<DevocionalScreen> createState() => _DevocionalScreenState();
}

class _DevocionalScreenState extends State<DevocionalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final devotionalProvider = Provider.of<DevotionalProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f23),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(auraColor, devotionalProvider),
            _buildSearchAndFilters(auraColor, devotionalProvider),
          ];
        },
        body: Column(
          children: [
            _buildTabBar(auraColor),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllDevotionals(devotionalProvider, auraColor),
                  _buildTodayDevotional(devotionalProvider, auraColor),
                  _buildFavorites(devotionalProvider, auraColor),
                  _buildCategories(devotionalProvider, auraColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Color auraColor, DevotionalProvider provider) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0f0f23),
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '📖 Devocional VMF',
            style: GlowStyles.boldWhiteText.copyWith(fontSize: 16),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                GlowStyles.neonBlue.withOpacity(0.05),
                const Color(0xFF0f0f23),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 20,
                child: Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: auraColor.withOpacity(0.2),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fortalece tu fe',
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'cada día',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => provider.toggleShowFavoritesOnly(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: provider.showFavoritesOnly 
                  ? auraColor.withOpacity(0.3) 
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.showFavoritesOnly ? auraColor : Colors.transparent,
              ),
            ),
            child: Icon(
              Icons.bookmark,
              color: provider.showFavoritesOnly ? auraColor : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(Color auraColor, DevotionalProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0f0f23),
          border: Border(
            bottom: BorderSide(color: auraColor.withOpacity(0.1)),
          ),
        ),
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a3a),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: auraColor.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar devocionales...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: auraColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                          icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.6)),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Filtros de categoría
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.availableCategories.length,
                itemBuilder: (context, index) {
                  final category = provider.availableCategories[index];
                  final isSelected = provider.selectedCategory == category;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category.emoji),
                          const SizedBox(width: 4),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0f0f23) : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      onSelected: (selected) {
                        provider.setCategory(selected ? category : DevotionalCategory.daily);
                      },
                      selectedColor: auraColor,
                      backgroundColor: const Color(0xFF1a1a3a),
                      side: BorderSide(color: auraColor.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(Color auraColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f23),
        border: Border(
          bottom: BorderSide(color: auraColor.withOpacity(0.2)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Todos', icon: Icon(Icons.apps, size: 16)),
          Tab(text: 'Hoy', icon: Icon(Icons.today, size: 16)),
          Tab(text: 'Favoritos', icon: Icon(Icons.bookmark, size: 16)),
          Tab(text: 'Explorar', icon: Icon(Icons.explore, size: 16)),
        ],
        labelColor: auraColor,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: auraColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildAllDevotionals(DevotionalProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: auraColor),
      );
    }

    final devotionals = provider.filteredDevotionals;

    if (devotionals.isEmpty) {
      return _buildEmptyState(auraColor, 'No se encontraron devocionales');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: devotionals.length,
      itemBuilder: (context, index) {
        final devotional = devotionals[index];
        return DevotionalCard(
          devotional: devotional,
          onFavoriteToggle: () => provider.toggleFavorite(devotional),
        );
      },
    );
  }

  Widget _buildTodayDevotional(DevotionalProvider provider, Color auraColor) {
    final todayDevotional = provider.todayDevotional;
    
    if (todayDevotional == null) {
      return _buildEmptyState(auraColor, 'No hay devocional para hoy');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Devocional destacado del día
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  auraColor.withOpacity(0.1),
                  const Color(0xFF1a1a3a).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: auraColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: auraColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.today,
                        color: Color(0xFF0f0f23),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Devocional de Hoy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  todayDevotional.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  todayDevotional.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: auraColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: auraColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '"${todayDevotional.mainVerse}"',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todayDevotional.verseReference,
                        style: TextStyle(
                          color: auraColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevotionalDetailScreen(
                        devotional: todayDevotional,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: auraColor,
                    foregroundColor: const Color(0xFF0f0f23),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Leer Completo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Devocionales recientes
          _buildSectionTitle('Recientes', auraColor),
          const SizedBox(height: 12),
          ...provider.getRecentDevotionals(limit: 3).map(
            (devotional) => DevotionalCard(
              devotional: devotional,
              isCompact: true,
              onFavoriteToggle: () => provider.toggleFavorite(devotional),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites(DevotionalProvider provider, Color auraColor) {
    final favorites = provider.favorites;

    if (favorites.isEmpty) {
      return _buildEmptyState(
        auraColor,
        'No tienes devocionales guardados',
        subtitle: 'Guarda tus devocionales favoritos tocando el ícono de marcador',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final devotional = favorites[index];
        return DevotionalCard(
          devotional: devotional,
          onFavoriteToggle: () => provider.toggleFavorite(devotional),
        );
      },
    );
  }

  Widget _buildCategories(DevotionalProvider provider, Color auraColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Explorar por Categorías', auraColor),
        const SizedBox(height: 16),
        ...DevotionalCategory.values.map(
          (category) => _buildCategoryItem(category, provider, auraColor),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    DevotionalCategory category,
    DevotionalProvider provider,
    Color auraColor,
  ) {
    final count = provider.getDevotionalsByCategory(category).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a3a).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: auraColor.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: auraColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              category.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          category.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$count devocionales disponibles',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: auraColor,
          size: 16,
        ),
        onTap: () {
          provider.setCategory(category);
          _tabController.animateTo(0); // Cambiar a la pestaña "Todos"
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color auraColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: auraColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color auraColor, String message, {String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 80,
            color: auraColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
