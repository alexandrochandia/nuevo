import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/aura_provider.dart';

class ModernCasasIglesiasScreen extends StatefulWidget {
  const ModernCasasIglesiasScreen({super.key});

  @override
  State<ModernCasasIglesiasScreen> createState() => _ModernCasasIglesiasScreenState();
}

class _ModernCasasIglesiasScreenState extends State<ModernCasasIglesiasScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  bool _isMapView = true;
  bool _showFavorites = false;
  List<Map<String, dynamic>> _favoriteChurches = [];

  // Datos mock de iglesias en Suecia
  final List<Map<String, dynamic>> _mockChurches = [
    {
      'id': '1',
      'name': 'Iglesia Evangélica Sueca',
      'city': 'Estocolmo',
      'denomination': 'Evangélica',
      'distance': '2.5 km',
      'rating': 4.8,
      'schedule': 'Domingos 10:00 AM',
      'image': 'https://images.unsplash.com/photo-1520637736862-4d197d17c55a?w=400',
      'isFavorite': false,
    },
    {
      'id': '2',
      'name': 'Iglesia Pentecostal de Gotemburgo',
      'city': 'Gotemburgo',
      'denomination': 'Pentecostal',
      'distance': '150 km',
      'rating': 4.6,
      'schedule': 'Domingos 11:00 AM',
      'image': 'https://images.unsplash.com/photo-1438032005730-c779502df39b?w=400',
      'isFavorite': false,
    },
    {
      'id': '3',
      'name': 'Iglesia Bautista de Malmö',
      'city': 'Malmö',
      'denomination': 'Bautista',
      'distance': '300 km',
      'rating': 4.7,
      'schedule': 'Domingos 9:30 AM',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'isFavorite': false,
    },
  ];

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Todas', 'icon': '🏛️'},
    {'id': 'evangelica', 'name': 'Evangélica', 'icon': '✝️'},
    {'id': 'pentecostal', 'name': 'Pentecostal', 'icon': '🔥'},
    {'id': 'bautista', 'name': 'Bautista', 'icon': '💧'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String churchId) {
    setState(() {
      final churchIndex = _mockChurches.indexWhere((church) => church['id'] == churchId);
      if (churchIndex != -1) {
        _mockChurches[churchIndex]['isFavorite'] = !_mockChurches[churchIndex]['isFavorite'];
        
        if (_mockChurches[churchIndex]['isFavorite']) {
          _favoriteChurches.add(_mockChurches[churchIndex]);
        } else {
          _favoriteChurches.removeWhere((church) => church['id'] == churchId);
        }
      }
    });
    HapticFeedback.mediumImpact();
  }

  List<Map<String, dynamic>> _getFilteredChurches() {
    List<Map<String, dynamic>> filtered = _mockChurches;
    
    if (_selectedCategory != 'all') {
      filtered = filtered.where((church) => 
        church['denomination'].toString().toLowerCase() == _selectedCategory
      ).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((church) => 
        church['name'].toString().toLowerCase().contains(searchTerm) ||
        church['city'].toString().toLowerCase().contains(searchTerm)
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Color(0xFF1A1A1A), Colors.black],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildModernHeader(auraProvider.currentAuraColor),
                      ),
                      Expanded(
                        child: _isMapView
                            ? _buildMapView(auraProvider.currentAuraColor)
                            : _buildListView(),
                      ),
                    ],
                  ),
                  _buildFavoritesFloatingButton(auraProvider.currentAuraColor),
                  if (_showFavorites) _buildFavoritesPanel(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: auraColor.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              Expanded(
                child: Text(
                  '🏛️ Casas Iglesias',
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: auraColor.withOpacity(0.3), blurRadius: 8)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: auraColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.search, color: Colors.white54),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Buscar iglesias...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtros por categoría
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['id'];
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category['id']!);
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? auraColor.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? auraColor : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category['icon']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            category['name']!,
                            style: TextStyle(
                              color: isSelected ? auraColor : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Toggles de vista
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildViewToggle(
                    icon: Icons.map,
                    label: 'Mapa',
                    isSelected: _isMapView,
                    onTap: () => setState(() => _isMapView = true),
                    auraColor: auraColor,
                  ),
                ),
                Expanded(
                  child: _buildViewToggle(
                    icon: Icons.list,
                    label: 'Lista',
                    isSelected: !_isMapView,
                    onTap: () => setState(() => _isMapView = false),
                    auraColor: auraColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color auraColor,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? auraColor.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? auraColor : Colors.white54, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? auraColor : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(Color auraColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E7D32).withOpacity(0.3),
                    const Color(0xFF1565C0).withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: auraColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.map, color: auraColor, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            '🗺️ Vista de Mapa',
                            style: TextStyle(
                              color: auraColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mapa interactivo próximamente',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._buildMockMapMarkers(auraColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMockMapMarkers(Color auraColor) {
    return [
      Positioned(
        top: 100,
        left: 150,
        child: _buildMapMarker('Estocolmo', auraColor),
      ),
      Positioned(
        top: 200,
        left: 80,
        child: _buildMapMarker('Gotemburgo', auraColor),
      ),
      Positioned(
        bottom: 150,
        left: 100,
        child: _buildMapMarker('Malmö', auraColor),
      ),
    ];
  }

  Widget _buildMapMarker(String name, Color auraColor) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 $name'),
            backgroundColor: auraColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: auraColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: auraColor.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    final filteredChurches = _getFilteredChurches();
    
    if (filteredChurches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.church, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text('No se encontraron iglesias', style: TextStyle(fontSize: 18, color: Colors.white70)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredChurches.length,
      itemBuilder: (context, index) {
        final church = filteredChurches[index];
        return _buildChurchCard(church);
      },
    );
  }

  Widget _buildChurchCard(Map<String, dynamic> church) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HapticFeedback.mediumImpact(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(church['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              church['distance'] as String,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              church['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleFavorite(church['id'] as String),
                            child: Icon(
                              church['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                              color: church['isFavorite'] ? Colors.red : const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${church['city']} • ${church['denomination']}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        church['schedule'] as String,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesFloatingButton(Color auraColor) {
    return Positioned(
      top: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          setState(() => _showFavorites = !_showFavorites);
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: auraColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: auraColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 24),
              if (_favoriteChurches.isNotEmpty)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _favoriteChurches.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesPanel() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 12),
                    const Text(
                      'Mis Favoritas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showFavorites = false),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _favoriteChurches.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 60, color: Colors.white54),
                            SizedBox(height: 16),
                            Text(
                              'No tienes iglesias favoritas',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favoriteChurches.length,
                        itemBuilder: (context, index) {
                          final church = _favoriteChurches[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    church['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        church['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        church['city'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _toggleFavorite(church['id']),
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
