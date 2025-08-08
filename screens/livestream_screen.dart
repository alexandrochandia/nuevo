import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/livestream_provider.dart';
import '../providers/aura_provider.dart';
import '../models/livestream_model.dart';
import '../widgets/livestream_card.dart';
import '../utils/livestream_utils.dart';
import 'livestream_player_screen.dart';
import '../utils/glow_styles.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen>
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
    return Consumer2<LiveStreamProvider, AuraProvider>(
      builder: (context, livestreamProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(livestreamProvider, auraProvider),
                _buildSearchBar(livestreamProvider, auraProvider),
                _buildStatsCards(livestreamProvider, auraProvider),
                _buildTabBar(auraProvider),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllStreamsTab(livestreamProvider, auraProvider),
                      _buildLiveTab(livestreamProvider, auraProvider),
                      _buildUpcomingTab(livestreamProvider, auraProvider),
                      _buildPastTab(livestreamProvider, auraProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(livestreamProvider, auraProvider),
        );
      },
    );
  }

  Widget _buildHeader(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            auraProvider.currentAuraColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.live_tv,
                color: GlowStyles.neonBlue,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transmisiones VMF',
                      style: GlowStyles.boldWhiteText.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Cultos y eventos en vivo',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => livestreamProvider.refreshStreams(),
                icon: Icon(
                  Icons.refresh,
                  color: auraProvider.currentAuraColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: livestreamProvider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Buscar transmisiones...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(
            Icons.search,
            color: auraProvider.currentAuraColor,
          ),
          suffixIcon: livestreamProvider.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    livestreamProvider.setSearchQuery('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStatsCards(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'En Vivo',
              livestreamProvider.liveStreamCount.toString(),
              Icons.radio_button_checked,
              Colors.red,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              'Espectadores',
              livestreamProvider.totalViewers.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              'Próximos',
              livestreamProvider.upcomingStreams.length.toString(),
              Icons.schedule,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: auraProvider.currentAuraColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: auraProvider.currentAuraColor,
        unselectedLabelColor: Colors.grey[400],
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'En Vivo'),
          Tab(text: 'Próximos'),
          Tab(text: 'Pasados'),
        ],
      ),
    );
  }

  Widget _buildAllStreamsTab(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    final streams = livestreamProvider.filteredStreams;
    
    return _buildStreamsList(streams, livestreamProvider, auraProvider);
  }

  Widget _buildLiveTab(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    final streams = livestreamProvider.liveStreams;
    
    if (streams.isEmpty) {
      return _buildEmptyState(
        'No hay transmisiones en vivo',
        'Las transmisiones aparecerán aquí cuando estén activas',
        Icons.live_tv,
      );
    }
    
    return _buildStreamsList(streams, livestreamProvider, auraProvider);
  }

  Widget _buildUpcomingTab(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    final streams = livestreamProvider.upcomingStreams;
    
    if (streams.isEmpty) {
      return _buildEmptyState(
        'No hay transmisiones programadas',
        'Las próximas transmisiones aparecerán aquí',
        Icons.schedule,
      );
    }
    
    return _buildStreamsList(streams, livestreamProvider, auraProvider);
  }

  Widget _buildPastTab(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    final streams = livestreamProvider.pastStreams;
    
    if (streams.isEmpty) {
      return _buildEmptyState(
        'No hay transmisiones pasadas',
        'Las grabaciones aparecerán aquí después de los eventos',
        Icons.history,
      );
    }
    
    return _buildStreamsList(streams, livestreamProvider, auraProvider);
  }

  Widget _buildStreamsList(List<LiveStreamModel> streams, LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    if (livestreamProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: auraProvider.currentAuraColor,
        ),
      );
    }

    if (streams.isEmpty) {
      return _buildEmptyState(
        'No se encontraron transmisiones',
        'Intenta cambiar los filtros de búsqueda',
        Icons.search_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: streams.length,
      itemBuilder: (context, index) {
        final stream = streams[index];
        return LiveStreamCard(
          stream: stream,
          onTap: () => _openStreamPlayer(stream, livestreamProvider),
          onLongPress: () => _showStreamOptions(context, stream, livestreamProvider, auraProvider),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: auraProvider.currentAuraColor.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showFilterOptions(context, livestreamProvider, auraProvider),
        backgroundColor: auraProvider.currentAuraColor,
        child: const Icon(
          Icons.filter_list,
          color: Colors.white,
        ),
      ),
    );
  }

  void _openStreamPlayer(LiveStreamModel stream, LiveStreamProvider livestreamProvider) {
    livestreamProvider.setCurrentStream(stream);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveStreamPlayerScreen(stream: stream),
      ),
    );
  }

  void _showStreamOptions(BuildContext context, LiveStreamModel stream, 
      LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: auraProvider.currentAuraColor.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.share, color: auraProvider.currentAuraColor),
                title: const Text('Compartir', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar compartir
                },
              ),
              if (stream.isUpcoming)
                ListTile(
                  leading: Icon(Icons.notifications, color: auraProvider.currentAuraColor),
                  title: const Text('Recordatorio', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar recordatorio
                  },
                ),
              if (stream.hasEnded && stream.recordingUrl != null)
                ListTile(
                  leading: Icon(Icons.play_circle, color: auraProvider.currentAuraColor),
                  title: const Text('Ver grabación', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar reproducción de grabación
                  },
                ),
              ListTile(
                leading: Icon(Icons.info, color: auraProvider.currentAuraColor),
                title: const Text('Detalles', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showStreamDetails(context, stream, auraProvider);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context, LiveStreamProvider livestreamProvider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: auraProvider.currentAuraColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Filtros de Transmisión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Transmisión',
                            style: TextStyle(
                              color: auraProvider.currentAuraColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: LiveStreamType.values.map((type) {
                              final isSelected = livestreamProvider.selectedType == type;
                              return FilterChip(
                                label: Text(
                                  type.displayName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    livestreamProvider.setTypeFilter(selected ? type : null);
                                  });
                                },
                                selectedColor: auraProvider.currentAuraColor,
                                backgroundColor: Colors.grey[800],
                                side: BorderSide(
                                  color: isSelected 
                                      ? auraProvider.currentAuraColor 
                                      : Colors.grey[600]!,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Estado',
                            style: TextStyle(
                              color: auraProvider.currentAuraColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: LiveStreamStatus.values.map((status) {
                              final isSelected = livestreamProvider.selectedStatus == status;
                              return FilterChip(
                                label: Text(
                                  status.displayName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setModalState(() {
                                    livestreamProvider.setStatusFilter(selected ? status : null);
                                  });
                                },
                                selectedColor: auraProvider.currentAuraColor,
                                backgroundColor: Colors.grey[800],
                                side: BorderSide(
                                  color: isSelected 
                                      ? auraProvider.currentAuraColor 
                                      : Colors.grey[600]!,
                                ),
                              );
                            }).toList(),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    livestreamProvider.clearFilters();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Limpiar'),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: auraProvider.currentAuraColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Aplicar'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStreamDetails(BuildContext context, LiveStreamModel stream, AuraProvider auraProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: auraProvider.currentAuraColor.withOpacity(0.3)),
        ),
        title: Text(
          stream.title,
          style: TextStyle(
            color: auraProvider.currentAuraColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pastor: ${stream.pastor}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${LiveStreamUtils.getTypeDisplayName(stream.type)}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Estado: ${LiveStreamUtils.getStatusDisplayName(stream.status)}',
                style: TextStyle(
                  color: LiveStreamUtils.getStatusColor(stream.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                stream.description,
                style: const TextStyle(color: Colors.white70),
              ),
              if (stream.tags?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (stream.tags ?? []).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: auraProvider.currentAuraColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: auraProvider.currentAuraColor.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        color: auraProvider.currentAuraColor,
                        fontSize: 12,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: auraProvider.currentAuraColor),
            ),
          ),
        ],
      ),
    );
  }


}