import 'package:flutter/material.dart';
import '../models/advanced_event_model.dart';
import '../theme/app_theme.dart';

class EventAgendaWidget extends StatefulWidget {
  final List<EventAgendaItem> agenda;

  const EventAgendaWidget({
    Key? key,
    required this.agenda,
  }) : super(key: key);

  @override
  State<EventAgendaWidget> createState() => _EventAgendaWidgetState();
}

class _EventAgendaWidgetState extends State<EventAgendaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedDay = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    if (widget.agenda.isNotEmpty) {
      _selectedDay = _formatDate(widget.agenda.first.startTime);
    }
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.agenda.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _animationController.value)),
            child: Column(
              children: [
                _buildHeader(),
                _buildDaySelector(),
                Expanded(
                  child: _buildAgendaList(),
                ),
              ],
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
            Icons.schedule_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay agenda disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La agenda del evento aparecerá aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agenda del Evento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.agenda.length} actividades programadas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _exportAgenda,
            icon: Icon(
              Icons.download,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _getUniqueDays();
    
    if (days.length <= 1) return const SizedBox.shrink();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _selectedDay == day;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppTheme.primaryColor 
                  : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected 
                    ? AppTheme.primaryColor 
                    : Colors.grey[300]!,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  _formatDayName(day),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgendaList() {
    final filteredAgenda = _getFilteredAgenda();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAgenda.length,
      itemBuilder: (context, index) {
        final item = filteredAgenda[index];
        final isLast = index == filteredAgenda.length - 1;
        
        return _buildAgendaItem(item, isLast);
      },
    );
  }

  Widget _buildAgendaItem(EventAgendaItem item, bool isLast) {
    final now = DateTime.now();
    final isUpcoming = item.startTime.isAfter(now);
    final isOngoing = now.isAfter(item.startTime) && now.isBefore(item.endTime);
    final isPast = item.endTime.isBefore(now);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineIndicator(isUpcoming, isOngoing, isPast, isLast),
          const SizedBox(width: 16),
          Expanded(
            child: _buildAgendaCard(item, isUpcoming, isOngoing, isPast),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(bool isUpcoming, bool isOngoing, bool isPast, bool isLast) {
    Color color;
    if (isOngoing) {
      color = Colors.green;
    } else if (isPast) {
      color = Colors.grey;
    } else {
      color = AppTheme.primaryColor;
    }

    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: isOngoing
            ? const Center(
                child: Icon(
                  Icons.play_arrow,
                  size: 8,
                  color: Colors.white,
                ),
              )
            : null,
        ),
        if (!isLast)
          Container(
            width: 2,
            height: 60,
            color: Colors.grey[300],
          ),
      ],
    );
  }

  Widget _buildAgendaCard(EventAgendaItem item, bool isUpcoming, bool isOngoing, bool isPast) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOngoing 
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.grey[300]!,
          width: isOngoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getIconColor(item.icon).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: _getIconColor(item.icon),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(isUpcoming, isOngoing, isPast),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.speaker,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                item.location,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (isOngoing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.live_tv,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'En vivo ahora',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getRemainingTime(item.endTime),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isUpcoming, bool isOngoing, bool isPast) {
    String text;
    Color color;
    IconData icon;

    if (isOngoing) {
      text = 'En vivo';
      color = Colors.green;
      icon = Icons.play_circle;
    } else if (isPast) {
      text = 'Finalizado';
      color = Colors.grey;
      icon = Icons.check_circle;
    } else {
      text = 'Próximo';
      color = Colors.blue;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueDays() {
    final Set<String> days = {};
    for (final item in widget.agenda) {
      days.add(_formatDate(item.startTime));
    }
    return days.toList()..sort();
  }

  List<EventAgendaItem> _getFilteredAgenda() {
    if (_selectedDay.isEmpty) return widget.agenda;
    
    return widget.agenda.where((item) {
      return _formatDate(item.startTime) == _selectedDay;
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDayName(String dateString) {
    final date = DateTime.parse(dateString);
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getRemainingTime(DateTime endTime) {
    final remaining = endTime.difference(DateTime.now());
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m restantes';
    } else {
      return '${remaining.inMinutes}m restantes';
    }
  }

  Color _getIconColor(IconData icon) {
    // Asignar colores basados en el tipo de actividad
    if (icon == Icons.music_note) return Colors.purple;
    if (icon == Icons.mic) return Colors.blue;
    if (icon == Icons.school) return Colors.green;
    if (icon == Icons.restaurant) return Colors.orange;
    if (icon == Icons.coffee) return Colors.brown;
    if (icon == Icons.group) return Colors.teal;
    return AppTheme.primaryColor;
  }

  void _exportAgenda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.download,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            const Text('Exportar Agenda'),
          ],
        ),
        content: const Text(
          'La funcionalidad de exportar agenda estará disponible próximamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
