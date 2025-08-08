import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveWorshipMapBox extends StatefulWidget {
  const LiveWorshipMapBox({super.key});

  @override
  State<LiveWorshipMapBox> createState() => _LiveWorshipMapBoxState();
}

class _LiveWorshipMapBoxState extends State<LiveWorshipMapBox> {
  GoogleMapController? _mapController;
  
  // Coordenadas de Estocolmo (ejemplo)
  static const LatLng _worshipLocation = LatLng(59.3293, 18.0686);
  
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('worship_location'),
      position: _worshipLocation,
      infoWindow: InfoWindow(
        title: 'Culto VMF Sweden',
        snippet: 'Próximo culto: Domingo 19:00',
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 200;
        return Container(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 160 : 180,
            maxHeight: isSmallScreen ? 180 : 220,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF2D2D2D),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: isSmallScreen ? 10 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Mapa
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: _worshipLocation,
                zoom: 12,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
            ),
            
            // Overlay con información
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            // Información del culto
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '📍 Próximo Culto',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Estocolmo • Domingo 19:00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Abrir en Google Maps
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Ir',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
}
