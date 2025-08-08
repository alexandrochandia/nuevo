import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../providers/aura_provider.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';
import '../utils/glow_styles.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventsProvider, AuraProvider>(
      builder: (context, eventsProvider, auraProvider, child) {
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
                  _buildSearchBar(eventsProvider, auraProvider),
                  _buildFilterChips(eventsProvider, auraProvider),
                  Expanded(
                    child: _buildEventsList(eventsProvider, auraProvider),
                  ),
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
                  color: GlowStyles.neonBlue,
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
                    'Eventos VMF',
                    style: GlowStyles.boldNeonText.copyWith(
                      fontSize: 28,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: GlowStyles.neonBlue.withOpacity(0.1),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Conecta con tu comunidad espiritual',
                    style: GlowStyles.boldSecondaryText.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(EventsProvider eventsProvider, AuraProvider auraProvider) {
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
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => eventsProvider.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Buscar eventos...',
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
    );
  }

  Widget _buildFilterChips(EventsProvider eventsProvider, AuraProvider auraProvider) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip(
            'Todos',
            eventsProvider.selectedFilter == null,
            () => eventsProvider.setFilter(null),
            auraProvider,
          ),
          ...EventType.values.map(
            (type) => _buildFilterChip(
              _getEventTypeText(type),
              eventsProvider.selectedFilter == type,
              () => eventsProvider.setFilter(type),
              auraProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    AuraProvider auraProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? auraProvider.currentAuraColor.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? auraProvider.currentAuraColor
                  : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? auraProvider.currentAuraColor
                  : Colors.white.withOpacity(0.8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(EventsProvider eventsProvider, AuraProvider auraProvider) {
    if (eventsProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraProvider.currentAuraColor),
        ),
      );
    }

    if (eventsProvider.events.isEmpty) {
      return Center(
        child: Text(
          'No hay eventos disponibles',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: eventsProvider.events.length,
      itemBuilder: (context, index) {
        final event = eventsProvider.events[index];
        return _buildEventCard(event, auraProvider);
      },
    );
  }

  Widget _buildEventCard(EventModel event, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: auraProvider.currentAuraColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventImage(event),
          _buildEventContent(event, auraProvider),
        ],
      ),
    );
  }

  Widget _buildEventImage(EventModel event) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(event.imagenUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 15,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: event.estadoColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              event.estadoTexto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 15,
          right: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: event.tipoColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              event.tipoTexto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventContent(EventModel event, AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.titulo,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: auraProvider.currentAuraColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.descripcionCorta,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(event.fechaInicio),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.ubicacion,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: auraProvider.currentAuraColor.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver Detalles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.culto:
        return 'Cultos';
      case EventType.conferencia:
        return 'Conferencias';
      case EventType.retiro:
        return 'Retiros';
      case EventType.seminario:
        return 'Seminarios';
      case EventType.mision:
        return 'Misiones';
      case EventType.juvenil:
        return 'Juveniles';
      case EventType.familiar:
        return 'Familiares';
      case EventType.especial:
        return 'Especiales';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}