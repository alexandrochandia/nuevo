import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/aura_provider.dart';
import '../models/search_model.dart';
import '../widgets/glow_container.dart';
import '../utils/glow_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final searchProvider = context.read<SearchProvider>();
      setState(() {
        _suggestions = searchProvider.getSuggestions(query);
        _showSuggestions = _suggestions.isNotEmpty && _searchFocusNode.hasFocus;
      });
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus && _suggestions.isNotEmpty;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchProvider>().search(query);
      _searchFocusNode.unfocus();
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchProvider, AuraProvider>(
      builder: (context, searchProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Búsqueda VMF',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: auraColor),
                onPressed: () => _showFilterModal(auraColor),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(auraColor),
              if (_showSuggestions) _buildSuggestions(auraColor),
              if (!_showSuggestions) _buildContent(searchProvider, auraColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar hermanos, eventos, contenido...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: auraColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchProvider>().clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1a1a1a),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: auraColor.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: auraColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: auraColor, width: 2),
                ),
              ),
              onSubmitted: _performSearch,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions(Color auraColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: auraColor.withOpacity(0.3)),
        ),
        child: ListView.builder(
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              leading: Icon(Icons.history, color: auraColor.withOpacity(0.7)),
              title: Text(
                suggestion,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(SearchProvider searchProvider, Color auraColor) {
    if (searchProvider.currentQuery.isEmpty) {
      return Expanded(
        child: _buildEmptyState(searchProvider, auraColor),
      );
    }

    if (searchProvider.isSearching) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(auraColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Buscando...',
                style: TextStyle(
                  color: auraColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (searchProvider.error.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                searchProvider.error,
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => searchProvider.search(searchProvider.currentQuery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: auraColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          _buildResultsHeader(searchProvider, auraColor),
          _buildTabBar(auraColor),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllResults(searchProvider, auraColor),
                _buildFilteredResults(searchProvider, SearchResultType.member, auraColor),
                _buildFilteredResults(searchProvider, SearchResultType.event, auraColor),
                _buildFilteredResults(searchProvider, SearchResultType.media, auraColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SearchProvider searchProvider, Color auraColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Búsquedas populares
          if (searchProvider.popularSearches.isNotEmpty) ...[
            _buildPopularSearches(searchProvider, auraColor),
            const SizedBox(height: 30),
          ],
          
          // Historial de búsqueda
          if (searchProvider.searchHistory.isNotEmpty) ...[
            _buildSearchHistory(searchProvider, auraColor),
            const SizedBox(height: 30),
          ],
          
          // Categorías de búsqueda
          _buildSearchCategories(auraColor),
        ],
      ),
    );
  }

  Widget _buildPopularSearches(SearchProvider searchProvider, Color auraColor) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: auraColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Búsquedas Populares',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchProvider.popularSearches.take(8).map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search.query;
                    _performSearch(search.query);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: search.primaryType.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: search.primaryType.color.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          search.primaryType.icon,
                          color: search.primaryType.color,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          search.query,
                          style: TextStyle(
                            color: search.primaryType.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: search.primaryType.color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${search.frequency}',
                            style: TextStyle(
                              color: search.primaryType.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory(SearchProvider searchProvider, Color auraColor) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: auraColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Búsquedas Recientes',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => searchProvider.clearHistory(),
                  child: Text(
                    'Limpiar',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...searchProvider.searchHistory.take(5).map((history) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    _searchController.text = history.query;
                    _performSearch(history.query);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: auraColor.withOpacity(0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history.query,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${history.resultCount} resultados • ${_formatDate(history.timestamp)}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCategories(Color auraColor) {
    final categories = [
      {'type': SearchResultType.member, 'title': 'Hermanos', 'subtitle': 'Buscar miembros de la iglesia'},
      {'type': SearchResultType.event, 'title': 'Eventos', 'subtitle': 'Conferencias, retiros, actividades'},
      {'type': SearchResultType.media, 'title': 'Multimedia', 'subtitle': 'Música, predicaciones, videos'},
      {'type': SearchResultType.church, 'title': 'Iglesias', 'subtitle': 'Sedes VMF en Suecia'},
      {'type': SearchResultType.devotional, 'title': 'Devocionales', 'subtitle': 'Lecturas espirituales diarias'},
      {'type': SearchResultType.testimony, 'title': 'Testimonios', 'subtitle': 'Experiencias de fe'},
    ];

    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: auraColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Categorías',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final type = category['type'] as SearchResultType;
                
                return GestureDetector(
                  onTap: () {
                    final filter = SearchFilter(types: [type]);
                    context.read<SearchProvider>().applyFilter(filter);
                    _searchController.text = type.displayName.toLowerCase();
                    _performSearch(type.displayName.toLowerCase());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: type.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          type.icon,
                          color: type.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category['title'] as String,
                            style: TextStyle(
                              color: type.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
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
      ),
    );
  }

  Widget _buildResultsHeader(SearchProvider searchProvider, Color auraColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '${searchProvider.searchResults.length} resultados para "${searchProvider.currentQuery}"',
            style: TextStyle(
              color: auraColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, color: auraColor),
            color: const Color(0xFF1a1a1a),
            onSelected: (option) {
              final newFilter = searchProvider.currentFilter.copyWith(sortBy: option);
              searchProvider.applyFilter(newFilter);
            },
            itemBuilder: (context) => SortOption.values.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(option.icon, color: auraColor, size: 20),
                    const SizedBox(width: 12),
                    Text(option.displayName, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color auraColor) {
    return Container(
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        indicatorColor: auraColor,
        indicatorWeight: 3,
        labelColor: auraColor,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Hermanos'),
          Tab(text: 'Eventos'),
          Tab(text: 'Multimedia'),
        ],
      ),
    );
  }

  Widget _buildAllResults(SearchProvider searchProvider, Color auraColor) {
    if (searchProvider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: auraColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otras palabras clave',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchProvider.searchResults.length,
      itemBuilder: (context, index) {
        final result = searchProvider.searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildResultCard(result, auraColor),
        );
      },
    );
  }

  Widget _buildFilteredResults(SearchProvider searchProvider, SearchResultType type, Color auraColor) {
    final filteredResults = searchProvider.searchResults
        .where((result) => result.type == type)
        .toList();

    if (filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: 80,
              color: type.color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ${type.displayName.toLowerCase()}',
              style: TextStyle(
                color: type.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra búsqueda',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildResultCard(result, auraColor),
        );
      },
    );
  }

  Widget _buildResultCard(SearchResult result, Color auraColor) {
    return GlowContainer(
      glowColor: result.type.color,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: result.type.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                result.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: result.type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    result.type.icon,
                    color: result.type.color,
                    size: 30,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: result.type.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          result.type.displayName,
                          style: TextStyle(
                            color: result.type.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (result.relevanceScore > 0.8)
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    result.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    result.subtitle,
                    style: TextStyle(
                      color: result.type.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    result.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      if (result.location != null) ...[
                        Icon(
                          Icons.location_on,
                          color: Colors.grey[400],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.location!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (result.date != null) ...[
                        if (result.location != null) const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[400],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(result.date!),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Botón de acción
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: result.type.color,
                size: 20,
              ),
              onPressed: () => _openResult(result),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(Color auraColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterModal(auraColor),
    );
  }

  Widget _buildFilterModal(Color auraColor) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: auraColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Filtros de Búsqueda',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      searchProvider.applyFilter(SearchFilter());
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Tipos de contenido
              Text(
                'Tipos de Contenido',
                style: TextStyle(
                  color: auraColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SearchResultType.values.map((type) {
                  final isSelected = searchProvider.currentFilter.types.contains(type);
                  return FilterChip(
                    label: Text(type.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newTypes = List<SearchResultType>.from(searchProvider.currentFilter.types);
                      if (selected) {
                        newTypes.add(type);
                      } else {
                        newTypes.remove(type);
                      }
                      final newFilter = searchProvider.currentFilter.copyWith(types: newTypes);
                      searchProvider.applyFilter(newFilter);
                    },
                    selectedColor: type.color.withOpacity(0.3),
                    checkmarkColor: type.color,
                    labelStyle: TextStyle(
                      color: isSelected ? type.color : Colors.white,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Botón aplicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: auraColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openResult(SearchResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo: ${result.title}'),
        backgroundColor: result.type.color,
      ),
    );
    
    // Aquí iría la navegación específica según el tipo de resultado
    switch (result.type) {
      case SearchResultType.member:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(profileId: result.id)));
        break;
      case SearchResultType.event:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(eventId: result.id)));
        break;
      case SearchResultType.media:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => MediaPlayerScreen(mediaId: result.id)));
        break;
      default:
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}