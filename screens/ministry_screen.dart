import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ministry_provider.dart';
import '../providers/aura_provider.dart';
import '../models/ministry_model.dart';
import '../widgets/glow_container.dart';
import '../utils/glow_styles.dart';

class MinistryScreen extends StatefulWidget {
  const MinistryScreen({super.key});

  @override
  State<MinistryScreen> createState() => _MinistryScreenState();
}

class _MinistryScreenState extends State<MinistryScreen>
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
    return Consumer2<MinistryProvider, AuraProvider>(
      builder: (context, ministryProvider, auraProvider, child) {
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
              'Ministerios VMF',
              style: GlowStyles.boldNeonText.copyWith(fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: auraColor),
                onPressed: () => _showFilterModal(auraColor, ministryProvider),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: auraColor),
                onPressed: () => ministryProvider.refreshData(),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatsCard(ministryProvider, auraColor),
              _buildTabBar(auraColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllMinistries(ministryProvider, auraColor),
                    _buildMyMinistries(ministryProvider, auraColor),
                    _buildRecruitingMinistries(ministryProvider, auraColor),
                    _buildUpcomingEvents(ministryProvider, auraColor),
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
                        content: Text('Función de crear ministerio próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  backgroundColor: auraColor,
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text(
                    'Nuevo Ministerio',
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

  Widget _buildStatsCard(MinistryProvider provider, Color auraColor) {
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
                  Icon(Icons.volunteer_activism, color: auraColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Estadísticas de Ministerios',
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
                      Icons.group,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Activos',
                      '${stats['active']}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Reclutando',
                      '${stats['recruiting']}',
                      Icons.person_add,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Mis Ministerios',
                      '${stats['myMinistries']}',
                      Icons.person,
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
          Tab(text: 'Todos'),
          Tab(text: 'Mis Ministerios'),
          Tab(text: 'Reclutando'),
          Tab(text: 'Eventos'),
        ],
      ),
    );
  }

  Widget _buildAllMinistries(MinistryProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraColor),
        ),
      );
    }

    if (provider.ministries.isEmpty) {
      return _buildEmptyState(
        'No hay ministerios disponibles',
        'Sé el primero en crear un ministerio',
        Icons.volunteer_activism,
        auraColor,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: auraColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.ministries.length,
        itemBuilder: (context, index) {
          final ministry = provider.ministries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMinistryCard(ministry, auraColor, provider),
          );
        },
      ),
    );
  }

  Widget _buildMyMinistries(MinistryProvider provider, Color auraColor) {
    final myMinistries = provider.getUserMinistries();

    if (myMinistries.isEmpty) {
      return _buildEmptyState(
        'No participas en ningún ministerio',
        'Únete a un ministerio que te apasione',
        Icons.add_circle_outline,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myMinistries.length,
      itemBuilder: (context, index) {
        final ministry = myMinistries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMinistryCard(ministry, auraColor, provider, showActions: true),
        );
      },
    );
  }

  Widget _buildRecruitingMinistries(MinistryProvider provider, Color auraColor) {
    final recruitingMinistries = provider.ministries
        .where((m) => m.isRecruiting)
        .toList();

    if (recruitingMinistries.isEmpty) {
      return _buildEmptyState(
        'No hay ministerios reclutando',
        'Todos los ministerios están completos',
        Icons.group_add,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recruitingMinistries.length,
      itemBuilder: (context, index) {
        final ministry = recruitingMinistries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMinistryCard(ministry, auraColor, provider),
        );
      },
    );
  }

  Widget _buildUpcomingEvents(MinistryProvider provider, Color auraColor) {
    final upcomingEvents = provider.getUpcomingEvents();

    if (upcomingEvents.isEmpty) {
      return _buildEmptyState(
        'No hay eventos próximos',
        'Los eventos se mostrarán aquí',
        Icons.event,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = upcomingEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildEventCard(event, auraColor),
        );
      },
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

  Widget _buildMinistryCard(
    Ministry ministry,
    Color auraColor,
    MinistryProvider provider, {
    bool showActions = false,
  }) {
    final isUserMember = ministry.members.contains(provider.currentUserId);
    final isUserLeader = ministry.leaderId == provider.currentUserId;
    
    return GestureDetector(
      onTap: () => _showMinistryDetail(ministry, auraColor, provider),
      child: GlowContainer(
        glowColor: ministry.category.color,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ministry.category.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del líder
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: ministry.category.color.withOpacity(0.3),
                    backgroundImage: ministry.leaderImageUrl != null
                        ? NetworkImage(ministry.leaderImageUrl!)
                        : null,
                    child: ministry.leaderImageUrl == null
                        ? Icon(
                            Icons.person,
                            color: ministry.category.color,
                            size: 30,
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ministry.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Líder: ${ministry.leaderName}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Badges de categoría y estado
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ministry.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ministry.category.icon,
                              color: ministry.category.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ministry.category.displayName,
                              style: TextStyle(
                                color: ministry.category.color,
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
                          color: ministry.status.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ministry.status.icon,
                              color: ministry.status.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ministry.status.displayName,
                              style: TextStyle(
                                color: ministry.status.color,
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
              
              const SizedBox(height: 16),
              
              // Descripción
              Text(
                ministry.description,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Información de miembros y próxima reunión
              Row(
                children: [
                  Icon(Icons.people, color: Colors.blue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${ministry.members.length}/${ministry.maxMembers} miembros',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  if (ministry.nextMeeting != null) ...[
                    Icon(Icons.schedule, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(ministry.nextMeeting!),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Footer con acciones
              Row(
                children: [
                  // Indicador de membresía
                  if (isUserMember || isUserLeader)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: auraColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUserLeader ? Icons.star : Icons.check,
                            color: auraColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isUserLeader ? 'Líder' : 'Miembro',
                            style: TextStyle(
                              color: auraColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Botón de acción
                  if (!isUserMember && !isUserLeader && ministry.isRecruiting)
                    GestureDetector(
                      onTap: () => provider.joinMinistry(ministry.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: ministry.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ministry.category.color,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add,
                              color: ministry.category.color,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Unirse',
                              style: TextStyle(
                                color: ministry.category.color,
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
              
              // Acciones adicionales para mis ministerios
              if (showActions && isUserMember && !isUserLeader) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => provider.leaveMinistry(ministry.id),
                    icon: Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                    label: const Text(
                      'Salir del Ministerio',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(MinistryEvent event, Color auraColor) {
    return GlowContainer(
      glowColor: event.type.color,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: event.type.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    event.type.icon,
                    color: event.type.color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.type.displayName,
                        style: TextStyle(
                          color: event.type.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  _formatDate(event.date),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              event.description,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                const SizedBox(width: 6),
                Text(
                  event.location,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(Color auraColor, MinistryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterModal(auraColor, provider),
    );
  }

  Widget _buildFilterModal(Color auraColor, MinistryProvider provider) {
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
                'Filtros',
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
          
          // Categorías
          Text(
            'Categorías',
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
            children: MinistryCategory.values.take(6).map((category) {
              final isSelected = provider.selectedCategories.contains(category);
              return FilterChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  final newCategories = List<MinistryCategory>.from(provider.selectedCategories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  provider.applyFilters(categories: newCategories);
                },
                selectedColor: category.color.withOpacity(0.3),
                checkmarkColor: category.color,
                labelStyle: TextStyle(
                  color: isSelected ? category.color : Colors.white,
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
  }

  void _showMinistryDetail(Ministry ministry, Color auraColor, MinistryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
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
                      backgroundColor: ministry.category.color.withOpacity(0.3),
                      backgroundImage: ministry.leaderImageUrl != null
                          ? NetworkImage(ministry.leaderImageUrl!)
                          : null,
                      child: ministry.leaderImageUrl == null
                          ? Icon(
                              ministry.category.icon,
                              color: ministry.category.color,
                              size: 30,
                            )
                          : null,
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ministry.name,
                            style: TextStyle(
                              color: auraColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ministry.category.displayName,
                            style: TextStyle(
                              color: ministry.category.color,
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
                      // Descripción
                      Text(
                        'Descripción',
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ministry.description,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Requisitos
                      if (ministry.requirements.isNotEmpty) ...[
                        Text(
                          'Requisitos',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...ministry.requirements.map((req) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: ministry.category.color)),
                              Expanded(
                                child: Text(
                                  req,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Actividades
                      if (ministry.activities.isNotEmpty) ...[
                        Text(
                          'Actividades',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...ministry.activities.map((activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: ministry.category.color)),
                              Expanded(
                                child: Text(
                                  activity,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == -1) {
      return 'Mañana ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7 && difference.inDays > -7) {
      final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return '${days[date.weekday - 1]} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}