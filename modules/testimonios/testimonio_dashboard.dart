import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestimonioDashboard extends StatefulWidget {
  const TestimonioDashboard({super.key});

  @override
  State<TestimonioDashboard> createState() => _TestimonioDashboardState();
}

class _TestimonioDashboardState extends State<TestimonioDashboard> {
  Map<String, int> stats = {
    'total': 0,
    'thisMonth': 0,
    'pending': 0,
    'approved': 0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final supabase = Supabase.instance.client;

      // Total testimonios
      final totalResponse = await supabase
          .from('testimonios')
          .select()
          .count(CountOption.exact);

      // Testimonios este mes
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final thisMonthResponse = await supabase
          .from('testimonios')
          .select()
          .gte('created_at', firstDayOfMonth.toIso8601String())
          .count(CountOption.exact);

      // Testimonios pendientes
      final pendingResponse = await supabase
          .from('testimonios')
          .select()
          .eq('approved', false)
          .count(CountOption.exact);

      // Testimonios aprobados
      final approvedResponse = await supabase
          .from('testimonios')
          .select()
          .eq('approved', true)
          .count(CountOption.exact);

      setState(() {
        stats = {
          'total': totalResponse.count,
          'thisMonth': thisMonthResponse.count,
          'pending': pendingResponse.count,
          'approved': approvedResponse.count,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: Colors.amber,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.chartLine,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dashboard VMF Sweden',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administra y visualiza todos los testimonios de la comunidad VMF',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Estadísticas principales
            const Text(
              'Estadísticas Generales',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  'Total Testimonios',
                  stats['total'].toString(),
                  FontAwesomeIcons.comments,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Este Mes',
                  stats['thisMonth'].toString(),
                  FontAwesomeIcons.calendar,
                  Colors.green,
                ),
                _buildStatCard(
                  'Pendientes',
                  stats['pending'].toString(),
                  FontAwesomeIcons.clock,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Aprobados',
                  stats['approved'].toString(),
                  FontAwesomeIcons.check,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Acciones rápidas
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildQuickActionCard(
              'Revisar Testimonios Pendientes',
              'Aprobar o rechazar nuevos testimonios',
              FontAwesomeIcons.tasks,
              Colors.orange,
                  () {
                // Cambiar a la pestaña de lista
                final parentState = context.findAncestorStateOfType<State>();
                if (parentState != null && parentState.mounted) {
                  (parentState as dynamic).setState(() {
                    (parentState as dynamic)._selectedIndex = 1;
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            _buildQuickActionCard(
              'Ver Todos los Testimonios',
              'Navegar por todos los testimonios',
              FontAwesomeIcons.eye,
              Colors.blue,
                  () {
                // Cambiar a la pestaña de lista
                final parentState = context.findAncestorStateOfType<State>();
                if (parentState != null && parentState.mounted) {
                  (parentState as dynamic).setState(() {
                    (parentState as dynamic)._selectedIndex = 1;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}