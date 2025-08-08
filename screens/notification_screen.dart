import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/aura_provider.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../widgets/glow_container.dart';
import '../utils/glow_styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotificationProvider, AuraProvider>(
      builder: (context, notificationProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;
        
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(auraColor, notificationProvider),
          body: Column(
            children: [
              _buildSearchAndFilters(auraColor, notificationProvider),
              _buildTabBar(auraColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllNotificationsTab(notificationProvider, auraColor),
                    _buildUnreadNotificationsTab(notificationProvider, auraColor),
                    _buildCategoriesTab(notificationProvider, auraColor),
                    _buildSettingsTab(notificationProvider, auraColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Color auraColor, NotificationProvider provider) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: GlowStyles.neonBlue),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificaciones VMF',
            style: GlowStyles.boldWhiteText.copyWith(fontSize: 20),
          ),
          Text(
            '${provider.unreadCount} sin leer • ${provider.totalCount} total',
            style: TextStyle(
              color: auraColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        if (provider.unreadCount > 0)
          IconButton(
            icon: Icon(Icons.done_all, color: auraColor),
            onPressed: () => provider.markAllAsRead(),
            tooltip: 'Marcar todas como leídas',
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: auraColor),
          color: const Color(0xFF1a1a1a),
          onSelected: (value) {
            switch (value) {
              case 'clear_filters':
                provider.clearFilters();
                break;
              case 'refresh':
                provider.refresh();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear_filters',
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: auraColor, size: 20),
                  const SizedBox(width: 12),
                  const Text('Limpiar filtros', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: auraColor, size: 20),
                  const SizedBox(width: 12),
                  const Text('Actualizar', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(Color auraColor, NotificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: auraColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          GlowContainer(
            glowColor: auraColor,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: auraColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar notificaciones...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: auraColor),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: auraColor),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
          ),
          
          if (provider.searchQuery.isNotEmpty || 
              provider.selectedType != null || 
              provider.selectedCategory != null) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(auraColor, provider),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters(Color auraColor, NotificationProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (provider.searchQuery.isNotEmpty)
          _buildFilterChip(
            label: 'Búsqueda: "${provider.searchQuery}"',
            onDeleted: () {
              _searchController.clear();
              provider.setSearchQuery('');
            },
            auraColor: auraColor,
          ),
        if (provider.selectedType != null)
          _buildFilterChip(
            label: 'Tipo: ${provider.selectedType!.displayName}',
            onDeleted: () => provider.setTypeFilter(null),
            auraColor: auraColor,
          ),
        if (provider.selectedCategory != null)
          _buildFilterChip(
            label: 'Categoría: ${provider.selectedCategory!.displayName}',
            onDeleted: () => provider.setCategoryFilter(null),
            auraColor: auraColor,
          ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required Color auraColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: auraColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: auraColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(
              Icons.close,
              size: 16,
              color: auraColor,
            ),
          ),
        ],
      ),
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
          Tab(text: 'Sin Leer'),
          Tab(text: 'Categorías'),
          Tab(text: 'Configuración'),
        ],
      ),
    );
  }

  Widget _buildAllNotificationsTab(NotificationProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: auraColor),
      );
    }

    if (provider.notifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: 'No hay notificaciones',
        subtitle: provider.searchQuery.isNotEmpty || 
                 provider.selectedType != null || 
                 provider.selectedCategory != null
            ? 'No se encontraron notificaciones con los filtros aplicados'
            : 'Las notificaciones aparecerán aquí cuando las recibas',
        auraColor: auraColor,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: auraColor,
      backgroundColor: const Color(0xFF1a1a1a),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(
              notification: notification,
              auraColor: auraColor,
              onTap: () => _showNotificationDetail(notification, auraColor),
              onMarkAsRead: () => provider.markAsRead(notification.id),
              onDelete: () => provider.deleteNotification(notification.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnreadNotificationsTab(NotificationProvider provider, Color auraColor) {
    final unreadNotifications = provider.notifications.where((n) => !n.isRead).toList();

    if (unreadNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.done_all,
        title: '¡Todo al día!',
        subtitle: 'No tienes notificaciones sin leer',
        auraColor: auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unreadNotifications.length,
      itemBuilder: (context, index) {
        final notification = unreadNotifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NotificationCard(
            notification: notification,
            auraColor: auraColor,
            onTap: () => _showNotificationDetail(notification, auraColor),
            onMarkAsRead: () => provider.markAsRead(notification.id),
            onDelete: () => provider.deleteNotification(notification.id),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(NotificationProvider provider, Color auraColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCategorySection('Tipos de Notificación', NotificationType.values, auraColor, provider),
        const SizedBox(height: 24),
        _buildCategorySection('Categorías', NotificationCategory.values, auraColor, provider),
      ],
    );
  }

  Widget _buildCategorySection(String title, List<dynamic> items, Color auraColor, NotificationProvider provider) {
    return Column(
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
        ...items.map((item) {
          int count = 0;
          if (item is NotificationType) {
            count = provider.getNotificationsByType(item).length;
          } else if (item is NotificationCategory) {
            count = provider.getNotificationsByCategory(item).length;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlowContainer(
              glowColor: auraColor,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (item is NotificationType ? item.color : (item as NotificationCategory).color).withOpacity(0.2),
                  child: Icon(
                    item is NotificationType ? item.icon : Icons.category,
                    color: item is NotificationType ? item.color : (item as NotificationCategory).color,
                    size: 20,
                  ),
                ),
                title: Text(
                  item is NotificationType ? item.displayName : (item as NotificationCategory).displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: auraColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: auraColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  if (item is NotificationType) {
                    provider.setTypeFilter(item);
                  } else if (item is NotificationCategory) {
                    provider.setCategoryFilter(item);
                  }
                  _tabController.animateTo(0);
                },
                tileColor: const Color(0xFF1a1a1a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: auraColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSettingsTab(NotificationProvider provider, Color auraColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsSection('Filtros', [
          _buildSettingsTile(
            icon: Icons.visibility_off,
            title: 'Solo mostrar no leídas',
            subtitle: 'Ocultar notificaciones ya leídas',
            trailing: Switch(
              value: provider.showOnlyUnread,
              onChanged: provider.setShowOnlyUnread,
              activeColor: auraColor,
            ),
            auraColor: auraColor,
          ),
        ]),
        
        const SizedBox(height: 24),
        
        _buildSettingsSection('Acciones', [
          _buildSettingsTile(
            icon: Icons.done_all,
            title: 'Marcar todas como leídas',
            subtitle: 'Marca todas las notificaciones como leídas',
            onTap: provider.unreadCount > 0 ? () => provider.markAllAsRead() : null,
            auraColor: auraColor,
          ),
          _buildSettingsTile(
            icon: Icons.refresh,
            title: 'Actualizar notificaciones',
            subtitle: 'Buscar nuevas notificaciones',
            onTap: () => provider.refresh(),
            auraColor: auraColor,
          ),
          _buildSettingsTile(
            icon: Icons.clear_all,
            title: 'Limpiar filtros',
            subtitle: 'Remover todos los filtros aplicados',
            onTap: () => provider.clearFilters(),
            auraColor: auraColor,
          ),
        ]),
        
        const SizedBox(height: 24),
        
        _buildSettingsSection('Estadísticas', [
          _buildStatisticsTile('Total de notificaciones', provider.totalCount.toString(), auraColor),
          _buildStatisticsTile('Sin leer', provider.unreadCount.toString(), auraColor),
          _buildStatisticsTile('Leídas', (provider.totalCount - provider.unreadCount).toString(), auraColor),
        ]),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: context.read<AuraProvider>().currentAuraColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required Color auraColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowContainer(
        glowColor: auraColor,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: auraColor),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          trailing: trailing,
          onTap: onTap,
          tileColor: const Color(0xFF1a1a1a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: auraColor.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsTile(String title, String value, Color auraColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowContainer(
        glowColor: auraColor,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: auraColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: auraColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color auraColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: auraColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: auraColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(VMFNotification notification, Color auraColor) {
    // Marcar como leída al abrir
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationDetailModal(
        notification: notification,
        auraColor: auraColor,
      ),
    );
  }
}

class NotificationDetailModal extends StatelessWidget {
  final VMFNotification notification;
  final Color auraColor;

  const NotificationDetailModal({
    super.key,
    required this.notification,
    required this.auraColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: auraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: auraColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: notification.type.color.withOpacity(0.2),
                  child: Icon(
                    notification.type.icon,
                    color: notification.type.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.type.displayName,
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDateTime(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: auraColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        notification.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: auraColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            color: auraColor.withOpacity(0.5),
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (notification.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      notification.subtitle!,
                      style: TextStyle(
                        color: auraColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    notification.body,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        notification.category.displayName,
                        notification.category.color,
                      ),
                      _buildBadge(
                        notification.priority.displayName,
                        notification.priority.color,
                      ),
                      if (notification.isPersistent)
                        _buildBadge('Persistente', auraColor),
                      if (notification.isScheduled)
                        _buildBadge('Programada', auraColor),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Actions
          if (notification.actionUrl != null || notification.deepLink != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: auraColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Aquí puedes agregar navegación según actionUrl o deepLink
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Navegando a: ${notification.actionUrl ?? notification.deepLink}'),
                        backgroundColor: auraColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: auraColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver Detalles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}