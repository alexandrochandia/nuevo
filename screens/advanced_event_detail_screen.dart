import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advanced_events_provider.dart';
import '../models/advanced_event_model.dart';
import '../widgets/ticket_selection_widget.dart';
import '../widgets/attendees_list_widget.dart';
import '../widgets/event_gallery_widget.dart';
import '../widgets/event_agenda_widget.dart';
import '../theme/app_theme.dart';

class AdvancedEventDetailScreen extends StatefulWidget {
  final String eventId;

  const AdvancedEventDetailScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<AdvancedEventDetailScreen> createState() => _AdvancedEventDetailScreenState();
}

class _AdvancedEventDetailScreenState extends State<AdvancedEventDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isCollapsed = _scrollController.offset > 200;
    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvancedEventsProvider>(
      builder: (context, provider, child) {
        final event = provider.getEventById(widget.eventId);
        
        if (event == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Evento no encontrado'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('El evento solicitado no existe.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(event),
              _buildEventInfo(event),
              _buildTabBar(),
              _buildTabContent(event),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(event),
        );
      },
    );
  }

  Widget _buildSliverAppBar(AdvancedEventModel event) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedOpacity(
          opacity: _isHeaderCollapsed ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            event.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              event.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            if (!_isHeaderCollapsed)
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareEvent(event),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () => _toggleFavorite(event),
        ),
      ],
    );
  }

  Widget _buildEventInfo(AdvancedEventModel event) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (event.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Destacado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.calendar_today, 'Fecha', _formatDateRange(event)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Ubicación', event.location),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, 'Organizador', event.organizer),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.people, 'Capacidad', '${event.totalSoldTickets}/${event.maxAttendees}'),
            const SizedBox(height: 20),
            _buildPriceRange(event),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange(AdvancedEventModel event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rango de precios',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.lowestPrice.toStringAsFixed(0)} - ${event.highestPrice.toStringAsFixed(0)} SEK',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (event.isSoldOut)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'AGOTADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Tickets'),
            Tab(text: 'Agenda'),
            Tab(text: 'Galería'),
            Tab(text: 'Asistentes'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(AdvancedEventModel event) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          TicketSelectionWidget(event: event),
          EventAgendaWidget(agenda: event.agenda),
          EventGalleryWidget(images: event.galleryImages),
          AttendeesListWidget(attendees: event.attendees, ticketTiers: event.ticketTiers),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(AdvancedEventModel event) {
    if (event.isSoldOut) return null;

    return FloatingActionButton.extended(
      onPressed: () => _showTicketPurchase(event),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.shopping_cart),
      label: const Text('Comprar Tickets'),
    );
  }

  String _formatDateRange(AdvancedEventModel event) {
    final start = event.startDate;
    final end = event.endDate;
    
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return '${start.day}/${start.month}/${start.year} ${_formatTime(start)} - ${_formatTime(end)}';
    } else {
      return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareEvent(AdvancedEventModel event) {
    // En producción, aquí se implementaría el compartir real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo: ${event.title}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _toggleFavorite(AdvancedEventModel event) {
    // En producción, aquí se implementaría la funcionalidad de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${event.title} agregado a favoritos'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showTicketPurchase(AdvancedEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar Tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: TicketSelectionWidget(event: event),
            ),
          ],
        ),
      ),
    );
  }
}
