import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/offering_provider.dart';
import '../providers/aura_provider.dart';
import '../models/offering_model.dart';
import '../widgets/offering_card.dart';
import 'gift_wallet_screen.dart';
import 'withdrawals_screen.dart';
import '../utils/glow_styles.dart';

class CoinWalletScreen extends StatefulWidget {
  const CoinWalletScreen({super.key});

  @override
  State<CoinWalletScreen> createState() => _CoinWalletScreenState();
}

class _CoinWalletScreenState extends State<CoinWalletScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'sv_SE', symbol: 'kr');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OfferingProvider, AuraProvider>(
      builder: (context, offeringProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: GlowStyles.neonBlue,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Billetera VMF',
              style: GlowStyles.boldNeonText.copyWith(
                fontSize: 24,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: auraProvider.currentAuraColor,
                ),
                onPressed: () => offeringProvider.refreshData(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Resumen', icon: Icon(Icons.dashboard)),
                Tab(text: 'Historial', icon: Icon(Icons.history)),
                Tab(text: 'Estadísticas', icon: Icon(Icons.analytics)),
                Tab(text: 'Configuración', icon: Icon(Icons.settings)),
              ],
              labelColor: auraProvider.currentAuraColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: auraProvider.currentAuraColor,
            ),
          ),
          body: offeringProvider.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: auraProvider.currentAuraColor,
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSummaryTab(offeringProvider, auraProvider),
                    _buildHistoryTab(offeringProvider, auraProvider),
                    _buildStatisticsTab(offeringProvider, auraProvider),
                    _buildSettingsTab(offeringProvider, auraProvider),
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
                      color: auraProvider.currentAuraColor.withOpacity(_glowAnimation.value * 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () => _showOfferingModal(context, offeringProvider, auraProvider),
                  backgroundColor: auraProvider.currentAuraColor,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Nueva Ofrenda',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(OfferingProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWalletCard(provider, auraProvider),
          const SizedBox(height: 24),
          _buildQuickActions(auraProvider),
          const SizedBox(height: 24),
          _buildMonthlyProgress(provider, auraProvider),
          const SizedBox(height: 24),
          _buildRecentTransactions(provider, auraProvider),
        ],
      ),
    );
  }

  Widget _buildWalletCard(OfferingProvider provider, AuraProvider auraProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            auraProvider.currentAuraColor.withOpacity(0.8),
            auraProvider.currentAuraColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: auraProvider.currentAuraColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Balance Total',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(provider.wallet?.totalDonated ?? 0.0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.green[300],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '+15% este mes', // Placeholder - calcular crecimiento real
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: GlowStyles.boldNeonText.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Nueva Ofrenda',
                subtitle: 'Agregar donación',
                color: auraProvider.currentAuraColor,
                onTap: () {
                  // Implementar nueva ofrenda
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función próximamente disponible')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.card_giftcard,
                title: 'Regalos',
                subtitle: 'Ver billetera de regalos',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GiftWalletScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.money_off,
                title: 'Retiros',
                subtitle: 'Historial de retiros',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WithdrawalsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress(OfferingProvider provider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso Mensual',
                style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
              ),
              Text(
                '${(provider.getProgressTowardsGoal() * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: auraProvider.currentAuraColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: provider.getProgressTowardsGoal(),
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(auraProvider.currentAuraColor),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currencyFormat.format(provider.totalDonatedThisMonth),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                _currencyFormat.format(provider.wallet?.monthlyGoal ?? 0.0),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(OfferingProvider provider, AuraProvider auraProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transacciones Recientes',
          style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.recentTransactions.length.clamp(0, 5),
          itemBuilder: (context, index) {
            final offering = provider.recentTransactions[index];
            return OfferingCard(
              offering: offering,
              auraColor: auraProvider.currentAuraColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryTab(OfferingProvider provider, AuraProvider auraProvider) {
    return const Center(
      child: Text(
        'Historial próximamente disponible',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildStatisticsTab(OfferingProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDonationsByTypeChart(provider, auraProvider),
          const SizedBox(height: 24),
          _buildYearlyComparison(provider, auraProvider),
        ],
      ),
    );
  }

  Widget _buildDonationsByTypeChart(OfferingProvider provider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donaciones por Tipo',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Diezmos', _currencyFormat.format(provider.donationsByType[OfferingType.diezmo] ?? 0.0), Icons.church, auraProvider.currentAuraColor),
              _buildStatCard('Ofrendas', _currencyFormat.format(provider.donationsByType[OfferingType.ofrenda] ?? 0.0), Icons.volunteer_activism, Colors.green),
              _buildStatCard('Misiones', _currencyFormat.format(provider.donationsByType[OfferingType.mision] ?? 0.0), Icons.star, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyComparison(OfferingProvider provider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparación Anual',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Este Año', _currencyFormat.format(provider.totalDonatedThisYear), Icons.calendar_today, auraProvider.currentAuraColor),
              _buildStatCard('Este Mes', _currencyFormat.format(provider.totalDonatedThisMonth), Icons.history, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(OfferingProvider provider, AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGoalSetting(provider, auraProvider),
          const SizedBox(height: 24),
          _buildNotificationSettings(auraProvider),
        ],
      ),
    );
  }

  Widget _buildGoalSetting(OfferingProvider provider, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meta Mensual',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            'Meta actual: ${_currencyFormat.format(provider.wallet?.monthlyGoal ?? 0.0)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _showGoalDialog(provider, auraProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: auraProvider.currentAuraColor,
            ),
            child: const Text('Cambiar Meta'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificaciones',
            style: GlowStyles.boldNeonText.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Recordatorios de Ofrenda', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Recibir recordatorios semanales', style: TextStyle(color: Colors.white70)),
            value: true,
            activeColor: auraProvider.currentAuraColor,
            onChanged: (value) {
              // Implementar cambio de configuración
            },
          ),
          SwitchListTile(
            title: const Text('Metas Alcanzadas', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Notificar cuando alcances tus metas', style: TextStyle(color: Colors.white70)),
            value: true,
            activeColor: auraProvider.currentAuraColor,
            onChanged: (value) {
              // Implementar cambio de configuración
            },
          ),
        ],
      ),
    );
  }

  void _showOfferingModal(BuildContext context, OfferingProvider provider, AuraProvider auraProvider) {
    // Implementar modal de nueva ofrenda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modal de nueva ofrenda próximamente disponible')),
    );
  }

  void _showGoalDialog(OfferingProvider provider, AuraProvider auraProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Cambiar Meta Mensual', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa tu nueva meta mensual:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ejemplo: 1000',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: auraProvider.currentAuraColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: auraProvider.currentAuraColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meta actualizada correctamente')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: auraProvider.currentAuraColor),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
