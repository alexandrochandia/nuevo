import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_request_provider.dart';
import '../providers/aura_provider.dart';
import '../models/prayer_request_model.dart';
import '../widgets/glow_container.dart';
import '../utils/glow_styles.dart';

class PrayerRequestScreen extends StatefulWidget {
  const PrayerRequestScreen({super.key});

  @override
  State<PrayerRequestScreen> createState() => _PrayerRequestScreenState();
}

class _PrayerRequestScreenState extends State<PrayerRequestScreen>
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
    return Consumer2<PrayerRequestProvider, AuraProvider>(
      builder: (context, prayerProvider, auraProvider, child) {
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
              'Peticiones de Oración',
              style: GlowStyles.boldNeonText.copyWith(fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list, color: auraColor),
                onPressed: () => _showFilterModal(auraColor, prayerProvider),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: auraColor),
                onPressed: () => prayerProvider.refreshData(),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatsCard(prayerProvider, auraColor),
              _buildTabBar(auraColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllRequests(prayerProvider, auraColor),
                    _buildActiveRequests(prayerProvider, auraColor),
                    _buildMyRequests(prayerProvider, auraColor),
                    _buildUrgentRequests(prayerProvider, auraColor),
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
                        content: Text('Función de crear petición próximamente'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  backgroundColor: auraColor,
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text(
                    'Nueva Petición',
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

  Widget _buildStatsCard(PrayerRequestProvider provider, Color auraColor) {
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
                    'Estadísticas de Oración',
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
                      Icons.forum,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Activas',
                      '${stats['active']}',
                      Icons.radio_button_checked,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Respondidas',
                      '${stats['answered']}',
                      Icons.check_circle,
                      Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Mis Peticiones',
                      '${stats['myRequests']}',
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
          Tab(text: 'Todas'),
          Tab(text: 'Activas'),
          Tab(text: 'Mis Peticiones'),
          Tab(text: 'Urgentes'),
        ],
      ),
    );
  }

  Widget _buildAllRequests(PrayerRequestProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraColor),
        ),
      );
    }

    if (provider.prayerRequests.isEmpty) {
      return _buildEmptyState(
        'No hay peticiones de oración',
        'Sé el primero en compartir una petición',
        Icons.forum,
        auraColor,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: auraColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.prayerRequests.length,
        itemBuilder: (context, index) {
          final request = provider.prayerRequests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPrayerRequestCard(request, auraColor, provider),
          );
        },
      ),
    );
  }

  Widget _buildActiveRequests(PrayerRequestProvider provider, Color auraColor) {
    final activeRequests = provider.prayerRequests
        .where((r) => r.status == PrayerStatus.active)
        .toList();

    if (activeRequests.isEmpty) {
      return _buildEmptyState(
        'No hay peticiones activas',
        'Todas las peticiones han sido respondidas',
        Icons.check_circle,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeRequests.length,
      itemBuilder: (context, index) {
        final request = activeRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPrayerRequestCard(request, auraColor, provider),
        );
      },
    );
  }

  Widget _buildMyRequests(PrayerRequestProvider provider, Color auraColor) {
    final myRequests = provider.getMyRequests();

    if (myRequests.isEmpty) {
      return _buildEmptyState(
        'No tienes peticiones',
        'Comparte tu primera petición de oración',
        Icons.add_circle_outline,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myRequests.length,
      itemBuilder: (context, index) {
        final request = myRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPrayerRequestCard(request, auraColor, provider, showActions: true),
        );
      },
    );
  }

  Widget _buildUrgentRequests(PrayerRequestProvider provider, Color auraColor) {
    final urgentRequests = provider.getUrgentRequests();

    if (urgentRequests.isEmpty) {
      return _buildEmptyState(
        'No hay peticiones urgentes',
        'Todas las peticiones urgentes han sido atendidas',
        Icons.emergency,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: urgentRequests.length,
      itemBuilder: (context, index) {
        final request = urgentRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPrayerRequestCard(request, auraColor, provider),
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

  Widget _buildPrayerRequestCard(
    PrayerRequest request,
    Color auraColor,
    PrayerRequestProvider provider, {
    bool showActions = false,
  }) {
    final hasUserPrayed = request.prayerPartners.contains(provider.currentUserId);
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ver detalles: ${request.title}'),
            backgroundColor: request.category.color,
          ),
        );
      },
      child: GlowContainer(
        glowColor: request.category.color,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: request.category.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar y info del usuario
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: request.category.color.withOpacity(0.3),
                    backgroundImage: request.requesterImageUrl != null
                        ? NetworkImage(request.requesterImageUrl!)
                        : null,
                    child: request.requesterImageUrl == null
                        ? Icon(
                            request.isAnonymous ? Icons.person : Icons.account_circle,
                            color: request.category.color,
                            size: 24,
                          )
                        : null,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.requesterName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(request.createdAt),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Badges de categoría y urgencia
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: request.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              request.category.icon,
                              color: request.category.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.category.displayName,
                              style: TextStyle(
                                color: request.category.color,
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
                          color: request.urgency.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              request.urgency.icon,
                              color: request.urgency.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.urgency.displayName,
                              style: TextStyle(
                                color: request.urgency.color,
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
              
              // Título y descripción
              Text(
                request.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                request.description,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Tags
              if (request.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: request.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Footer con acciones
              Row(
                children: [
                  // Contador de oraciones
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasUserPrayed ? auraColor.withOpacity(0.2) : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasUserPrayed ? Icons.favorite : Icons.favorite_border,
                          color: hasUserPrayed ? auraColor : Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${request.prayerCount} oraciones',
                          style: TextStyle(
                            color: hasUserPrayed ? auraColor : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: request.status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          request.status.icon,
                          color: request.status.color,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          request.status.displayName,
                          style: TextStyle(
                            color: request.status.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Botón de orar
                  if (request.status == PrayerStatus.active)
                    GestureDetector(
                      onTap: hasUserPrayed ? null : () => provider.prayForRequest(request.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: hasUserPrayed 
                              ? Colors.grey[700] 
                              : auraColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasUserPrayed ? Colors.grey[600]! : auraColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasUserPrayed ? Icons.check : Icons.favorite,
                              color: hasUserPrayed ? Colors.grey[400] : auraColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasUserPrayed ? 'Orado' : 'Orar',
                              style: TextStyle(
                                color: hasUserPrayed ? Colors.grey[400] : auraColor,
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
              
              // Acciones adicionales para mis peticiones
              if (showActions && request.requesterId == provider.currentUserId) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editPrayerRequest(request, provider),
                        icon: Icon(Icons.edit, color: auraColor, size: 18),
                        label: Text(
                          'Editar',
                          style: TextStyle(color: auraColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: auraColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: request.status == PrayerStatus.active
                            ? () => _markAsAnswered(request, provider)
                            : null,
                        icon: Icon(Icons.check_circle, color: Colors.green, size: 18),
                        label: const Text(
                          'Respondida',
                          style: TextStyle(color: Colors.green),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal(Color auraColor, PrayerRequestProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterModal(auraColor, provider),
    );
  }

  Widget _buildFilterModal(Color auraColor, PrayerRequestProvider provider) {
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
            children: PrayerCategory.values.map((category) {
              final isSelected = provider.currentFilter.categories.contains(category);
              return FilterChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  final newCategories = List<PrayerCategory>.from(provider.currentFilter.categories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  final newFilter = provider.currentFilter.copyWith(categories: newCategories);
                  provider.applyFilter(newFilter);
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

  void _editPrayerRequest(PrayerRequest request, PrayerRequestProvider provider) {
    // Aquí iría la navegación a la pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar petición: ${request.title}'),
        backgroundColor: request.category.color,
      ),
    );
  }

  void _markAsAnswered(PrayerRequest request, PrayerRequestProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('Marcar como Respondida', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Quieres marcar esta petición como respondida por Dios?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updatePrayerRequest(
                request.id,
                status: PrayerStatus.answered,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gloria a Dios! Petición marcada como respondida'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}