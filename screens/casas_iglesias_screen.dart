import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'dart:async';
import '../providers/aura_provider.dart';

class CasasIglesiasScreen extends StatefulWidget {
  const CasasIglesiasScreen({super.key});

  @override
  State<CasasIglesiasScreen> createState() => _CasasIglesiasScreenState();
}

class _CasasIglesiasScreenState extends State<CasasIglesiasScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isMapView = true;
  bool _isLoadingLocation = false;
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final churchProvider = Provider.of<ChurchProvider>(context, listen: false);
    
    // Cargar iglesias
    await churchProvider.loadChurches();
    
    // Obtener ubicación actual
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      _currentPosition = await LocationService.getCurrentPosition();
      if (_currentPosition == null) {
        _currentPosition = LocationService.getDefaultPosition();
      }
    } catch (e) {
      _currentPosition = LocationService.getDefaultPosition();
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  Set<Marker> _createMarkers() {
    final churchProvider = Provider.of<ChurchProvider>(context, listen: false);
    final auraProvider = Provider.of<AuraProvider>(context, listen: false);
    
    Set<Marker> markers = {};

    // Marker para ubicación actual
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Markers para iglesias
    for (var church in churchProvider.churches) {
      markers.add(
        Marker(
          markerId: MarkerId(church.id),
          position: LatLng(church.latitude, church.longitude),
          infoWindow: InfoWindow(
            title: church.name,
            snippet: '${church.city} - ${church.pastor}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () => _showChurchBottomSheet(church),
        ),
      );
    }

    return markers;
  }

  void _showChurchBottomSheet(ChurchModel church) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ChurchCard(
                      church: church,
                      distance: _currentPosition != null
                          ? LocationService.calculateDistance(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              church.latitude,
                              church.longitude,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChurchDetailScreen(church: church),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChurchProvider, AuraProvider>(
      builder: (context, churchProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0f0f23),
          body: Column(
            children: [
              // Header personalizado
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1a1a2e),
                      Color(0xFF16213e),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: auraProvider.currentAuraColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Título y botón de retroceso
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: auraProvider.currentAuraColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '⛪ Casas Iglesias VMF',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Google Auth Button
                        StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (context, snapshot) {
                            final user = snapshot.data;
                            if (user != null) {
                              return PopupMenuButton<String>(
                                icon: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: user.photoURL != null 
                                    ? NetworkImage(user.photoURL!) 
                                    : null,
                                  child: user.photoURL == null 
                                    ? Icon(Icons.person, color: auraProvider.currentAuraColor, size: 20)
                                    : null,
                                ),
                                onSelected: (value) async {
                                  if (value == 'logout') {
                                    await GoogleAuthService.signOut();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Sesión cerrada'),
                                          backgroundColor: auraProvider.currentAuraColor,
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'profile',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, color: auraProvider.currentAuraColor),
                                        const SizedBox(width: 8),
                                        Text(user.displayName ?? 'Usuario'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        Icon(Icons.logout, color: auraProvider.currentAuraColor),
                                        const SizedBox(width: 8),
                                        const Text('Cerrar Sesión'),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  color: auraProvider.currentAuraColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: auraProvider.currentAuraColor.withOpacity(0.3),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.login, color: auraProvider.currentAuraColor),
                                  onPressed: () async {
                                    final user = await GoogleAuthService.signInWithGoogle();
                                    if (user != null && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Bienvenido ${user.displayName ?? 'Usuario'}'),
                                          backgroundColor: auraProvider.currentAuraColor,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          onPressed: () => churchProvider.refreshChurches(),
                          icon: Icon(
                            Icons.refresh,
                            color: auraProvider.currentAuraColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Barra de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: auraProvider.currentAuraColor.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar iglesias por nombre o ciudad...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: Icon(
                            Icons.search,
                            color: auraProvider.currentAuraColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) => churchProvider.setSearchQuery(value),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Filtros y tab selector
                    Row(
                      children: [
                        // Filtro de idioma
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: auraProvider.currentAuraColor.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: churchProvider.selectedLanguage,
                            dropdownColor: const Color(0xFF1a1a2e),
                            style: const TextStyle(color: Colors.white),
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('🌍 Todos')),
                              DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
                              DropdownMenuItem(value: 'sv', child: Text('🇸🇪 Sueco')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                churchProvider.setLanguageFilter(value);
                              }
                            },
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Selector de vista
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _buildViewToggle(
                                icon: Icons.map,
                                isSelected: _isMapView,
                                onTap: () => setState(() => _isMapView = true),
                                auraColor: auraProvider.currentAuraColor,
                              ),
                              _buildViewToggle(
                                icon: Icons.list,
                                isSelected: !_isMapView,
                                onTap: () => setState(() => _isMapView = false),
                                auraColor: auraProvider.currentAuraColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Contenido principal
              Expanded(
                child: churchProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _isMapView
                        ? _buildMapView()
                        : _buildListView(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color auraColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? auraColor.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? auraColor : Colors.white54,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Obteniendo ubicación...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : const LatLng(59.3293, 18.0686), // Stockholm por defecto
        zoom: 10,
      ),
      markers: _createMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildListView() {
    final churchProvider = Provider.of<ChurchProvider>(context);
    
    if (churchProvider.churches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.church,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron iglesias',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: churchProvider.churches.length,
      itemBuilder: (context, index) {
        final church = churchProvider.churches[index];
        final distance = _currentPosition != null
            ? LocationService.calculateDistance(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                church.latitude,
                church.longitude,
              )
            : null;

        return ChurchCard(
          church: church,
          distance: distance,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChurchDetailScreen(church: church),
            ),
          ),
        );
      },
    );
  }
}