import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advanced_events_provider.dart';
import '../widgets/advanced_event_card.dart';
import '../widgets/event_search_bar.dart';
import '../widgets/event_stats_widget.dart';
import '../widgets/event_filters_modal.dart';
import '../widgets/floating_create_event_button.dart';
import '../theme/app_theme.dart';
import 'advanced_event_detail_screen.dart';

class AdvancedEventsScreen extends StatefulWidget {
  const AdvancedEventsScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedEventsScreen> createState() => _AdvancedEventsScreenState();
}

class _AdvancedEventsScreenState extends State<AdvancedEventsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _fabAnimationController.forward();

    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdvancedEventsProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildStatsSection(),
          _buildSearchSection(),
          _buildTabSection(),
          _buildEventsGrid(),
        ],
      ),
      floatingActionButton: const FloatingCreateEventButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Eventos VMF',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.event,
              size: 60,
              color: Colors.white24,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFiltersModal,
        ),
        IconButton(
          icon: const Icon(Icons.analytics, color: Colors.white),
          onPressed: _showAnalytics,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Consumer<AdvancedEventsProvider>(
        builder: (context, provider, child) {
          return Container(
            margin: const EdgeInsets.all(16),
            child: EventStatsWidget(
              totalEvents: provider.totalEvents,
              upcomingEvents: provider.upcomingEvents,
              ongoingEvents: provider.ongoingEvents,
              totalAttendees: provider.totalAttendees,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Consumer<AdvancedEventsProvider>(
          builder: (context, provider, child) {
            return EventSearchBar(
              onSearch: provider.searchEvents,
              onClear: provider.clearFilters,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 50,
        child: Consumer<AdvancedEventsProvider>(
          builder: (context, provider, child) {
            return Row(
              children: [
                Expanded(
                  child: _buildFilterChip('Todos', provider.currentFilter == 'Todos', () {
                    provider.filterByStatus('Todos');
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Próximos', provider.currentFilter == 'Próximos', () {
                    provider.filterByStatus('Próximos');
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('En Curso', provider.currentFilter == 'En curso', () {
                    provider.filterByStatus('En curso');
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Destacados', provider.currentFilter == 'Destacados', () {
                    provider.clearFilters();
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsGrid() {
    return Consumer<AdvancedEventsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }

        if (provider.events.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final event = provider.events[index];
                return AdvancedEventCard(
                  event: event,
                  onTap: () => _navigateToEventDetail(event.id),
                );
              },
              childCount: provider.events.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay eventos disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer evento o ajusta los filtros',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateEventDialog,
            icon: const Icon(Icons.add),
            label: const Text('Crear Evento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _navigateToEventDetail(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedEventDetailScreen(eventId: eventId),
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EventFiltersModal(),
    );
  }

  void _showAnalytics() {
    final provider = Provider.of<AdvancedEventsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estadísticas Generales'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total de eventos', provider.totalEvents.toString()),
              _buildStatRow('Eventos próximos', provider.upcomingEvents.toString()),
              _buildStatRow('Eventos en curso', provider.ongoingEvents.toString()),
              _buildStatRow('Eventos pasados', provider.pastEvents.toString()),
              const Divider(),
              _buildStatRow('Total asistentes', provider.totalAttendees.toString()),
              _buildStatRow('Promedio por evento', provider.averageAttendance.toStringAsFixed(1)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Evento'),
        content: const Text(
          'La funcionalidad de creación de eventos estará disponible próximamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
