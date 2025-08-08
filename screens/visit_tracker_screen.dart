import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/visit_provider.dart';
import '../providers/aura_provider.dart';
import '../models/visit_model.dart';
import '../widgets/glow_container.dart';
import '../utils/glow_styles.dart';

class VisitTrackerScreen extends StatefulWidget {
  const VisitTrackerScreen({super.key});

  @override
  State<VisitTrackerScreen> createState() => _VisitTrackerScreenState();
}

class _VisitTrackerScreenState extends State<VisitTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VisitProvider, AuraProvider>(
      builder: (context, visitProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: GlowStyles.neonBlue),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Gestión de Visitas VMF',
              style: GlowStyles.boldNeonText.copyWith(fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: auraColor),
                onPressed: () => _showFilterModal(auraColor, visitProvider),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: auraColor),
                onPressed: () => visitProvider.refreshData(),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatsCard(visitProvider, auraColor),
              _buildTabBar(auraColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllVisits(visitProvider, auraColor),
                    _buildRecentVisits(visitProvider, auraColor),
                    _buildPendingFollowUps(visitProvider, auraColor),
                    _buildStatistics(visitProvider, auraColor),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: auraColor.withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de registrar visita próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  backgroundColor: auraColor,
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.person_add, size: 24),
                  label: const Text(
                    'Registrar Visita',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(VisitProvider provider, Color auraColor) {
    final stats = provider.getStatistics();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlowContainer(
        glowColor: auraColor,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: auraColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Estadísticas de Visitas',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total',
                      '${stats['total']}',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Este Mes',
                      '${stats['thisMonth']}',
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Seguimientos',
                      '${stats['pendingFollowUp']}',
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Integrados',
                      '${stats['integrated']}',
                      Icons.check_circle,
                      auraColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
          Tab(text: 'Todas'),
          Tab(text: 'Recientes'),
          Tab(text: 'Seguimientos'),
          Tab(text: 'Estadísticas'),
        ],
      ),
    );
  }

  Widget _buildAllVisits(VisitProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraColor),
        ),
      );
    }

    if (provider.visits.isEmpty) {
      return _buildEmptyState(
        'No hay visitas registradas',
        'Comienza registrando la primera visita',
        Icons.person_add,
        auraColor,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: auraColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.visits.length,
        itemBuilder: (context, index) {
          final visit = provider.visits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildVisitCard(visit, auraColor, provider),
          );
        },
      ),
    );
  }

  Widget _buildRecentVisits(VisitProvider provider, Color auraColor) {
    final recentVisits = provider.getRecentVisits(limit: 20);

    if (recentVisits.isEmpty) {
      return _buildEmptyState(
        'No hay visitas recientes',
        'Las visitas recientes aparecerán aquí',
        Icons.schedule,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentVisits.length,
      itemBuilder: (context, index) {
        final visit = recentVisits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildVisitCard(visit, auraColor, provider),
        );
      },
    );
  }

  Widget _buildPendingFollowUps(VisitProvider provider, Color auraColor) {
    final pendingFollowUps = provider.getPendingFollowUps();

    if (pendingFollowUps.isEmpty) {
      return _buildEmptyState(
        'No hay seguimientos pendientes',
        '¡Excelente trabajo pastoral!',
        Icons.check_circle,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingFollowUps.length,
      itemBuilder: (context, index) {
        final visit = pendingFollowUps[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildVisitCard(visit, auraColor, provider, highlightFollowUp: true),
        );
      },
    );
  }

  Widget _buildStatistics(VisitProvider provider, Color auraColor) {
    final visitsByStatus = provider.getVisitsByStatus();
    final visitsByType = provider.getVisitsByType();
    final topChurches = provider.getTopChurches();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gráfico por estado
        _buildStatisticsCard(
          'Visitas por Estado',
          visitsByStatus.entries.map((entry) => _buildStatusBar(
            entry.key.displayName,
            entry.value,
            entry.key.color,
            visitsByStatus.values.reduce((a, b) => a > b ? a : b),
          )).toList(),
          auraColor,
        ),

        const SizedBox(height: 16),

        // Gráfico por tipo
        _buildStatisticsCard(
          'Visitas por Tipo',
          visitsByType.entries.map((entry) => _buildStatusBar(
            entry.key.displayName,
            entry.value,
            entry.key.color,
            visitsByType.values.reduce((a, b) => a > b ? a : b),
          )).toList(),
          auraColor,
        ),

        const SizedBox(height: 16),

        // Top iglesias
        _buildStatisticsCard(
          'Iglesias con Más Visitas',
          topChurches.map((church) => _buildStatusBar(
            church['name'],
            church['visits'],
            auraColor,
            topChurches.first['visits'],
          )).toList(),
          auraColor,
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(String title, List<Widget> children, Color auraColor) {
    return GlowContainer(
      glowColor: auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Text(
              title,
              style: TextStyle(
                color: auraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color, int maxValue) {
    final percentage = maxValue > 0 ? value / maxValue : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color auraColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: auraColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: auraColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(
    Visit visit,
    Color auraColor,
    VisitProvider provider, {
    bool highlightFollowUp = false,
  }) {
    final daysSinceVisit = DateTime.now().difference(visit.visitDate).inDays;
    
    return GestureDetector(
      onTap: () => _showVisitDetail(visit, auraColor, provider),
      child: GlowContainer(
        glowColor: highlightFollowUp ? Colors.orange : visit.visitorType.color,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (highlightFollowUp ? Colors.orange : visit.visitorType.color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información básica
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: visit.visitorType.color.withOpacity(0.3),
                    child: Icon(
                      visit.visitorType.icon,
                      color: visit.visitorType.color,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.visitorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          visit.churchLocation,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        if (visit.referredBy != null)
                          Text(
                            'Referido por: ${visit.referredBy}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Badges de tipo y estado
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: visit.visitorType.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              visit.visitorType.icon,
                              color: visit.visitorType.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              visit.visitorType.displayName,
                              style: TextStyle(
                                color: visit.visitorType.color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: visit.status.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              visit.status.icon,
                              color: visit.status.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              visit.status.displayName,
                              style: TextStyle(
                                color: visit.status.color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información de contacto y fecha
              Row(
                children: [
                  if (visit.visitorPhone != null) ...[
                    Icon(Icons.phone, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      visit.visitorPhone!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(visit.visitDate),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Icon(Icons.schedule, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Hace $daysSinceVisit días',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Intereses
              if (visit.interests.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: visit.interests.take(3).map((interest) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: auraColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 10,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Alertas de seguimiento
              if (highlightFollowUp) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Requiere seguimiento pastoral',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Footer con acciones
              Row(
                children: [
                  if (visit.followUps.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${visit.followUps.length} seguimiento${visit.followUps.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Botón de acción rápida
                  if (visit.wantsFollowUp && visit.status != VisitStatus.integrated)
                    GestureDetector(
                      onTap: () => _showQuickFollowUpModal(visit, auraColor, provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_comment,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Seguimiento',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal(Color auraColor, VisitProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterModal(auraColor, provider),
    );
  }

  Widget _buildFilterModal(Color auraColor, VisitProvider provider) {
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
                'Filtros de Visitas',
                style: TextStyle(
                  color: auraColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Limpiar', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Estados
          Text(
            'Estados',
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
            children: VisitStatus.values.map((status) {
              final isSelected = provider.selectedStatuses.contains(status);
              return FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  final newStatuses = List<VisitStatus>.from(provider.selectedStatuses);
                  if (selected) {
                    newStatuses.add(status);
                  } else {
                    newStatuses.remove(status);
                  }
                  provider.applyFilters(statuses: newStatuses);
                },
                selectedColor: status.color.withOpacity(0.3),
                checkmarkColor: status.color,
                labelStyle: TextStyle(
                  color: isSelected ? status.color : Colors.white,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Switch para seguimientos pendientes
          Row(
            children: [
              Text(
                'Solo seguimientos pendientes',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Switch(
                value: provider.showOnlyPendingFollowUp,
                onChanged: (value) {
                  provider.applyFilters(showOnlyPendingFollowUp: value);
                },
                activeColor: auraColor,
              ),
            ],
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
  }

  void _showVisitDetail(Visit visit, Color auraColor, VisitProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: visit.visitorType.color.withOpacity(0.3),
                      child: Icon(
                        visit.visitorType.icon,
                        color: visit.visitorType.color,
                        size: 30,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.visitorName,
                            style: TextStyle(
                              color: auraColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            visit.visitorType.displayName,
                            style: TextStyle(
                              color: visit.visitorType.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[400]),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Información de contacto
                      _buildDetailSection(
                        'Información de Contacto',
                        [
                          if (visit.visitorEmail != null)
                            _buildDetailItem('Email', visit.visitorEmail!, Icons.email),
                          if (visit.visitorPhone != null)
                            _buildDetailItem('Teléfono', visit.visitorPhone!, Icons.phone),
                          if (visit.visitorAddress != null)
                            _buildDetailItem('Dirección', visit.visitorAddress!, Icons.location_on),
                          _buildDetailItem('Iglesia', visit.churchLocation, Icons.church),
                          _buildDetailItem('Fecha de Visita', _formatDate(visit.visitDate), Icons.calendar_today),
                        ],
                        auraColor,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Información adicional
                      _buildDetailSection(
                        'Información Adicional',
                        [
                          if (visit.ageGroup != null)
                            _buildDetailItem('Grupo de Edad', visit.ageGroup!, Icons.cake),
                          if (visit.familyStatus != null)
                            _buildDetailItem('Estado Familiar', visit.familyStatus!.displayName, visit.familyStatus!.icon),
                          if (visit.referredBy != null)
                            _buildDetailItem('Referido por', visit.referredBy!, Icons.person),
                          _buildDetailItem('Primera vez', visit.isFirstTime ? 'Sí' : 'No', Icons.new_label),
                          _buildDetailItem('Quiere seguimiento', visit.wantsFollowUp ? 'Sí' : 'No', Icons.follow_the_signs),
                        ],
                        auraColor,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Intereses
                      if (visit.interests.isNotEmpty) ...[
                        _buildDetailSection(
                          'Intereses',
                          [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: visit.interests.map((interest) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: auraColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  interest,
                                  style: TextStyle(
                                    color: auraColor,
                                    fontSize: 12,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                          auraColor,
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Peticiones de oración
                      if (visit.prayerRequests.isNotEmpty) ...[
                        _buildDetailSection(
                          'Peticiones de Oración',
                          visit.prayerRequests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.favorite, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    request,
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                          auraColor,
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Notas
                      if (visit.notes != null) ...[
                        _buildDetailSection(
                          'Notas',
                          [
                            Text(
                              visit.notes!,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                          auraColor,
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Seguimientos
                      if (visit.followUps.isNotEmpty) ...[
                        _buildDetailSection(
                          'Historial de Seguimientos',
                          visit.followUps.map((followUp) => _buildFollowUpItem(followUp, auraColor)).toList(),
                          auraColor,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children, Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: auraColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 16),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpItem(FollowUp followUp, Color auraColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: followUp.type.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(followUp.type.icon, color: followUp.type.color, size: 16),
              const SizedBox(width: 8),
              Text(
                followUp.type.displayName,
                style: TextStyle(
                  color: followUp.type.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: followUp.result.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  followUp.result.displayName,
                  style: TextStyle(
                    color: followUp.result.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            followUp.content,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Por: ${followUp.performedByName}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(followUp.performedAt),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickFollowUpModal(Visit visit, Color auraColor, VisitProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seguimiento Rápido',
              style: TextStyle(
                color: auraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              visit.visitorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Opciones de seguimiento rápido
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickActionButton(
                  'Llamada',
                  Icons.phone,
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de llamada próximamente')),
                    );
                  },
                ),
                _buildQuickActionButton(
                  'WhatsApp',
                  Icons.chat,
                  Colors.teal,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de WhatsApp próximamente')),
                    );
                  },
                ),
                _buildQuickActionButton(
                  'Email',
                  Icons.email,
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de email próximamente')),
                    );
                  },
                ),
                _buildQuickActionButton(
                  'Visita',
                  Icons.home,
                  Colors.orange,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función de programar visita próximamente')),
                    );
                  },
                ),
                _buildQuickActionButton(
                  'Contactado',
                  Icons.check,
                  auraColor,
                  () {
                    provider.updateVisitStatus(visit.id, VisitStatus.contacted);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${visit.visitorName} marcado como contactado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  'Integrado',
                  Icons.group_add,
                  Colors.purple,
                  () {
                    provider.updateVisitStatus(visit.id, VisitStatus.integrated);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡${visit.visitorName} integrado exitosamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${days[date.weekday - 1]} ${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}