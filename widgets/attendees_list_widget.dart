import 'package:flutter/material.dart';
import '../models/advanced_event_model.dart';
import '../theme/app_theme.dart';

class AttendeesListWidget extends StatefulWidget {
  final List<AttendeeInfo> attendees;
  final List<TicketTier> ticketTiers;

  const AttendeesListWidget({
    Key? key,
    required this.attendees,
    required this.ticketTiers,
  }) : super(key: key);

  @override
  State<AttendeesListWidget> createState() => _AttendeesListWidgetState();
}

class _AttendeesListWidgetState extends State<AttendeesListWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attendees.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildHeader(),
        _buildSearchAndFilters(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAttendeesList(_getFilteredAttendees()),
              _buildAttendeesList(_getCheckedInAttendees()),
              _buildStatistics(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay asistentes registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los asistentes aparecerán aquí cuando compren tickets',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final checkedInCount = widget.attendees.where((a) => a.isCheckedIn).length;
    final totalCount = widget.attendees.length;
    
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
              Icons.people,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCount Asistentes Registrados',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$checkedInCount registrados • ${totalCount - checkedInCount} pendientes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${((checkedInCount / totalCount) * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar asistente...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos'),
                ...widget.ticketTiers.map((tier) => _buildFilterChip(tier.name)),
                _buildFilterChip('Registrados'),
                _buildFilterChip('Pendientes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? filter : 'Todos';
          });
        },
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
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
        tabs: const [
          Tab(text: 'Todos'),
          Tab(text: 'Registrados'),
          Tab(text: 'Estadísticas'),
        ],
      ),
    );
  }

  Widget _buildAttendeesList(List<AttendeeInfo> attendees) {
    if (attendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron asistentes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendees.length,
      itemBuilder: (context, index) {
        final attendee = attendees[index];
        final tier = widget.ticketTiers.firstWhere(
          (t) => t.id == attendee.ticketTierId,
          orElse: () => widget.ticketTiers.first,
        );
        
        return _buildAttendeeCard(attendee, tier);
      },
    );
  }

  Widget _buildAttendeeCard(AttendeeInfo attendee, TicketTier tier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: attendee.isCheckedIn 
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: attendee.isCheckedIn 
            ? Colors.green 
            : AppTheme.primaryColor.withValues(alpha: 0.2),
          child: Icon(
            attendee.isCheckedIn ? Icons.check : Icons.person,
            color: attendee.isCheckedIn 
              ? Colors.white 
              : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          attendee.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              attendee.email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tier.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tier.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                if (attendee.isCheckedIn) ...[
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(attendee.checkInTime!),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: attendee.isCheckedIn 
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                attendee.isCheckedIn ? 'Registrado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: attendee.isCheckedIn ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              attendee.qrCode,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        onTap: () => _showAttendeeDetails(attendee, tier),
      ),
    );
  }

  Widget _buildStatistics() {
    final totalAttendees = widget.attendees.length;
    final checkedIn = widget.attendees.where((a) => a.isCheckedIn).length;
    final pending = totalAttendees - checkedIn;
    
    // Estadísticas por tipo de ticket
    final Map<String, int> ticketStats = {};
    for (final attendee in widget.attendees) {
      final tier = widget.ticketTiers.firstWhere(
        (t) => t.id == attendee.ticketTierId,
        orElse: () => widget.ticketTiers.first,
      );
      ticketStats[tier.name] = (ticketStats[tier.name] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Resumen General',
            [
              _buildStatRow('Total de asistentes', totalAttendees.toString()),
              _buildStatRow('Registrados', checkedIn.toString()),
              _buildStatRow('Pendientes', pending.toString()),
              _buildStatRow('Tasa de registro', '${((checkedIn / totalAttendees) * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Por Tipo de Ticket',
            ticketStats.entries.map((entry) {
              final percentage = ((entry.value / totalAttendees) * 100).round();
              return _buildStatRow('${entry.key}', '${entry.value} ($percentage%)');
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  List<AttendeeInfo> _getFilteredAttendees() {
    List<AttendeeInfo> filtered = widget.attendees;

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((attendee) =>
        attendee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        attendee.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Aplicar filtro
    if (_selectedFilter != 'Todos') {
      if (_selectedFilter == 'Registrados') {
        filtered = filtered.where((a) => a.isCheckedIn).toList();
      } else if (_selectedFilter == 'Pendientes') {
        filtered = filtered.where((a) => !a.isCheckedIn).toList();
      } else {
        // Filtrar por tipo de ticket
        final tier = widget.ticketTiers.firstWhere(
          (t) => t.name == _selectedFilter,
          orElse: () => widget.ticketTiers.first,
        );
        filtered = filtered.where((a) => a.ticketTierId == tier.id).toList();
      }
    }

    return filtered;
  }

  List<AttendeeInfo> _getCheckedInAttendees() {
    return widget.attendees.where((a) => a.isCheckedIn).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAttendeeDetails(AttendeeInfo attendee, TicketTier tier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(attendee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', attendee.email),
            _buildDetailRow('Teléfono', attendee.phone),
            _buildDetailRow('Tipo de ticket', tier.name),
            _buildDetailRow('Código QR', attendee.qrCode),
            _buildDetailRow('Fecha de compra', _formatDateTime(attendee.purchaseDate)),
            _buildDetailRow('Estado', attendee.isCheckedIn ? 'Registrado' : 'Pendiente'),
            if (attendee.isCheckedIn)
              _buildDetailRow('Hora de registro', _formatDateTime(attendee.checkInTime!)),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
