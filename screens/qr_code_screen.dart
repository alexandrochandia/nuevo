import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_code_provider.dart';
import '../providers/aura_provider.dart';
import '../models/qr_code_model.dart';
import '../widgets/glow_container.dart';
import 'scan_qr_code_screen.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen>
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
    return Consumer2<QRCodeProvider, AuraProvider>(
      builder: (context, qrProvider, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'QR Codes VMF',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: auraColor),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanQRCodeScreen(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list, color: auraColor),
                onPressed: () => _showFilterModal(auraColor, qrProvider),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: auraColor),
                onPressed: () => qrProvider.refreshData(),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildStatsCard(qrProvider, auraColor),
              _buildTabBar(auraColor),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllQRCodes(qrProvider, auraColor),
                    _buildActiveQRCodes(qrProvider, auraColor),
                    _buildRecentScans(qrProvider, auraColor),
                    _buildStatistics(qrProvider, auraColor),
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
                  onPressed: () => _showCreateQRModal(auraColor, qrProvider),
                  backgroundColor: auraColor,
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.qr_code, size: 24),
                  label: const Text(
                    'Crear QR',
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

  Widget _buildStatsCard(QRCodeProvider provider, Color auraColor) {
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
                  Icon(Icons.qr_code, color: auraColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Estadísticas QR VMF',
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
                      'Total QRs',
                      '${stats['totalQRs']}',
                      Icons.qr_code,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Activos',
                      '${stats['activeQRs']}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Escaneos',
                      '${stats['totalScans']}',
                      Icons.scanner,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Esta Semana',
                      '${stats['thisWeekScans']}',
                      Icons.trending_up,
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
          Tab(text: 'Activos'),
          Tab(text: 'Escaneos'),
          Tab(text: 'Estadísticas'),
        ],
      ),
    );
  }

  Widget _buildAllQRCodes(QRCodeProvider provider, Color auraColor) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(auraColor),
        ),
      );
    }

    if (provider.qrCodes.isEmpty) {
      return _buildEmptyState(
        'No hay códigos QR',
        'Crea tu primer código QR para eventos VMF',
        Icons.qr_code,
        auraColor,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshData,
      color: auraColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.qrCodes.length,
        itemBuilder: (context, index) {
          final qr = provider.qrCodes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildQRCard(qr, auraColor, provider),
          );
        },
      ),
    );
  }

  Widget _buildActiveQRCodes(QRCodeProvider provider, Color auraColor) {
    final activeQRs = provider.qrCodes.where((qr) => qr.isActive && !qr.isExpired).toList();

    if (activeQRs.isEmpty) {
      return _buildEmptyState(
        'No hay QRs activos',
        'Los códigos QR activos aparecerán aquí',
        Icons.check_circle,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeQRs.length,
      itemBuilder: (context, index) {
        final qr = activeQRs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildQRCard(qr, auraColor, provider),
        );
      },
    );
  }

  Widget _buildRecentScans(QRCodeProvider provider, Color auraColor) {
    final recentScans = provider.getRecentScans(limit: 50);

    if (recentScans.isEmpty) {
      return _buildEmptyState(
        'No hay escaneos recientes',
        'Los escaneos recientes aparecerán aquí',
        Icons.scanner,
        auraColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentScans.length,
      itemBuilder: (context, index) {
        final scan = recentScans[index];
        final qr = provider.getQRCodeById(scan.qrCodeId);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildScanCard(scan, qr, auraColor),
        );
      },
    );
  }

  Widget _buildStatistics(QRCodeProvider provider, Color auraColor) {
    final qrsByType = provider.getQRsByType();
    final mostScanned = provider.getMostScannedQRs(limit: 10);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gráfico por tipo
        _buildStatisticsCard(
          'QRs por Tipo',
          qrsByType.entries.map((entry) => _buildTypeBar(
            entry.key.displayName,
            entry.value,
            entry.key.color,
            qrsByType.values.isNotEmpty ? qrsByType.values.reduce((a, b) => a > b ? a : b) : 1,
          )).toList(),
          auraColor,
        ),

        const SizedBox(height: 16),

        // QRs más escaneados
        _buildStatisticsCard(
          'QRs Más Escaneados',
          mostScanned.map((qr) => _buildPopularQRItem(qr, auraColor)).toList(),
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

  Widget _buildTypeBar(String label, int value, Color color, int maxValue) {
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

  Widget _buildPopularQRItem(QRCodeData qr, Color auraColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: qr.type.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              qr.type.icon,
              color: qr.type.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qr.title,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  qr.type.displayName,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: auraColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${qr.scanCount} escaneos',
              style: TextStyle(
                color: auraColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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

  Widget _buildQRCard(QRCodeData qr, Color auraColor, QRCodeProvider provider) {
    final daysSinceCreated = DateTime.now().difference(qr.createdAt).inDays;
    final isExpired = qr.isExpired;
    final isActive = qr.isActive;
    
    return GestureDetector(
      onTap: () => _showQRDetail(qr, auraColor, provider),
      child: GlowContainer(
        glowColor: isExpired ? Colors.red : (isActive ? qr.type.color : Colors.grey),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isExpired ? Colors.red : (isActive ? qr.type.color : Colors.grey)).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: qr.type.color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      qr.type.icon,
                      color: qr.type.color,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          qr.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          qr.type.displayName,
                          style: TextStyle(
                            color: qr.type.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (qr.churchLocation != null)
                          Text(
                            qr.churchLocation!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Estado
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.red.withOpacity(0.2) : 
                                 (isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isExpired ? 'Expirado' : (isActive ? 'Activo' : 'Inactivo'),
                          style: TextStyle(
                            color: isExpired ? Colors.red : (isActive ? Colors.green : Colors.grey),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: auraColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${qr.scanCount} escaneos',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información adicional
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Creado por ${qr.createdByName}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Icon(Icons.calendar_today, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Hace $daysSinceCreated días',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Expiración
              if (qr.expiresAt != null) ...[
                Row(
                  children: [
                    Icon(
                      isExpired ? Icons.error : Icons.schedule,
                      color: isExpired ? Colors.red : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isExpired ? 'Expirado' : 'Expira: ${_formatDate(qr.expiresAt!)}',
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Escaneos recientes
              if (qr.scans.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.scanner, color: Colors.grey[400], size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Último escaneo: ${_formatDate(qr.scans.last.scannedAt)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Acciones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showQRDetail(qr, auraColor, provider),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver QR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: auraColor,
                        side: BorderSide(color: auraColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  OutlinedButton.icon(
                    onPressed: () => _shareQR(qr),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  IconButton(
                    onPressed: () => _showQRActions(qr, auraColor, provider),
                    icon: const Icon(Icons.more_vert),
                    color: Colors.grey[400],
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanCard(QRCodeScan scan, QRCodeData? qr, Color auraColor) {
    return GlowContainer(
      glowColor: scan.result.color,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scan.result.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scan.result.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                scan.result.icon,
                color: scan.result.color,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    qr?.title ?? 'QR Desconocido',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Escaneado por ${scan.scannedByName}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  if (scan.location != null)
                    Text(
                      scan.location!,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scan.result.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    scan.result.displayName,
                    style: TextStyle(
                      color: scan.result.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(scan.scannedAt),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(Color auraColor, QRCodeProvider provider) {
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
            Row(
              children: [
                Icon(Icons.filter_list, color: auraColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Filtros de QR',
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
            
            // Tipos
            Text(
              'Tipos de QR',
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
              children: QRCodeType.values.map((type) {
                final isSelected = provider.selectedTypes.contains(type);
                return FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newTypes = List<QRCodeType>.from(provider.selectedTypes);
                    if (selected) {
                      newTypes.add(type);
                    } else {
                      newTypes.remove(type);
                    }
                    provider.applyFilters(types: newTypes);
                  },
                  selectedColor: type.color.withOpacity(0.3),
                  checkmarkColor: type.color,
                  labelStyle: TextStyle(
                    color: isSelected ? type.color : Colors.white,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Switches
            Row(
              children: [
                Text(
                  'Solo activos',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: provider.showOnlyActive,
                  onChanged: (value) {
                    provider.applyFilters(showOnlyActive: value);
                  },
                  activeColor: auraColor,
                ),
              ],
            ),
            
            Row(
              children: [
                Text(
                  'Solo expirados',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: provider.showOnlyExpired,
                  onChanged: (value) {
                    provider.applyFilters(showOnlyExpired: value);
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
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
      ),
    );
  }

  void _showCreateQRModal(Color auraColor, QRCodeProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crear Nuevo QR',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Selecciona el tipo de QR',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: QRCodeType.values.map((type) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateQRForm(type, auraColor, provider);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: type.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type.icon,
                          color: type.color,
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            color: type.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateQRForm(QRCodeType type, Color auraColor, QRCodeProvider provider) {
    // Implementar formulario específico para cada tipo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Formulario para ${type.displayName} próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showQRDetail(QRCodeData qr, Color auraColor, QRCodeProvider provider) {
    // Implementar pantalla de detalle del QR
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalle de ${qr.title} próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showQRActions(QRCodeData qr, Color auraColor, QRCodeProvider provider) {
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
              'Acciones para ${qr.title}',
              style: TextStyle(
                color: auraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edición próximamente')),
                );
              },
            ),
            
            ListTile(
              leading: Icon(
                qr.isActive ? Icons.pause : Icons.play_arrow,
                color: qr.isActive ? Colors.orange : Colors.green,
              ),
              title: Text(
                qr.isActive ? 'Desactivar' : 'Activar',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                provider.toggleActiveStatus(qr.id);
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.share, color: Colors.blue),
              title: const Text('Compartir', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _shareQR(qr);
              },
            ),
            
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(qr, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareQR(QRCodeData qr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo ${qr.title}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmDelete(QRCodeData qr, QRCodeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${qr.title}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteQRCode(qr.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR eliminado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
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

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}