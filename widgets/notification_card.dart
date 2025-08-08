import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'glow_container.dart';

class NotificationCard extends StatelessWidget {
  final VMFNotification notification;
  final Color auraColor;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.auraColor,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      glowColor: notification.isRead 
          ? auraColor.withOpacity(0.3) 
          : auraColor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead 
                ? auraColor.withOpacity(0.2) 
                : auraColor.withOpacity(0.5),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: Stack(
          children: [
            // Indicator de no leída
            if (!notification.isRead)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: auraColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        // Icono del tipo
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: notification.type.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            notification.type.icon,
                            color: notification.type.color,
                            size: 20,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Información principal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.type.displayName,
                                      style: TextStyle(
                                        color: auraColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(notification.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 4),
                              
                              Text(
                                notification.title,
                                style: TextStyle(
                                  color: notification.isRead 
                                      ? Colors.grey[300] 
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Botón de opciones
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          color: const Color(0xFF2a2a2a),
                          onSelected: (value) {
                            switch (value) {
                              case 'mark_read':
                                onMarkAsRead?.call();
                                break;
                              case 'delete':
                                _showDeleteConfirmation(context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (!notification.isRead)
                              PopupMenuItem(
                                value: 'mark_read',
                                child: Row(
                                  children: [
                                    Icon(Icons.done, color: auraColor, size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Marcar como leída',
                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red[400], size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red[400], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subtítulo si existe
                    if (notification.subtitle != null) ...[
                      Text(
                        notification.subtitle!,
                        style: TextStyle(
                          color: auraColor.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Cuerpo de la notificación
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: notification.isRead 
                            ? Colors.grey[400] 
                            : Colors.grey[300],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Imagen si existe
                    if (notification.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          notification.imageUrl!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: auraColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: auraColor.withOpacity(0.5),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Footer con badges
                    Row(
                      children: [
                        // Badge de categoría
                        _buildBadge(
                          notification.category.displayName,
                          notification.category.color,
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Badge de prioridad si es alta o urgente
                        if (notification.priority == NotificationPriority.high ||
                            notification.priority == NotificationPriority.urgent)
                          _buildBadge(
                            notification.priority.displayName,
                            notification.priority.color,
                          ),
                        
                        // Badge de persistente
                        if (notification.isPersistent) ...[
                          const SizedBox(width: 8),
                          _buildBadge('Persistente', auraColor),
                        ],
                        
                        // Badge de programada
                        if (notification.isScheduled) ...[
                          const SizedBox(width: 8),
                          _buildBadge('Programada', auraColor),
                        ],
                        
                        const Spacer(),
                        
                        // Indicador de acción disponible
                        if (notification.actionUrl != null || notification.deepLink != null)
                          Icon(
                            Icons.arrow_forward_ios,
                            color: auraColor.withOpacity(0.7),
                            size: 14,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Overlay para notificaciones programadas futuras
            if (notification.isScheduled && 
                notification.scheduledFor != null && 
                notification.scheduledFor!.isAfter(DateTime.now()))
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: auraColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Programada para ${_formatDateTime(notification.scheduledFor!)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: auraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Text(
          'Eliminar Notificación',
          style: TextStyle(
            color: auraColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta notificación? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }
}