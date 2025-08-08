import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aura_provider.dart';

class FloatingAssistant extends StatefulWidget {
  const FloatingAssistant({super.key});

  @override
  State<FloatingAssistant> createState() => _FloatingAssistantState();
}

class _FloatingAssistantState extends State<FloatingAssistant>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _showAssistantMenu();
    }
  }

  void _showAssistantMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAssistantMenu(),
    );
  }

  Widget _buildAssistantMenu() {
    final auraColor = context.read<AuraProvider>().currentAuraColor;
    
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: auraColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: auraColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Text(
            'Asistente VMF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Menu Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuOption(
                  '🙏',
                  'Oración Rápida',
                  'Envía una petición de oración',
                  () {},
                ),
                _buildMenuOption(
                  '📞',
                  'Contactar Pastor',
                  'Habla con un líder espiritual',
                  () {},
                ),
                _buildMenuOption(
                  '📖',
                  'Versículo del Día',
                  'Recibe inspiración divina',
                  () {},
                ),
                _buildMenuOption(
                  '❓',
                  'Ayuda',
                  'Aprende a usar la app',
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(String emoji, String title, String subtitle, VoidCallback onTap) {
    final auraColor = context.read<AuraProvider>().currentAuraColor;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: auraColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: auraColor,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = context.watch<AuraProvider>().currentAuraColor;
    
    return Positioned(
      bottom: 30,
      right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _bounceAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              width: 99,
              height: 99,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: auraColor.withOpacity(_glowAnimation.value),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: auraColor.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: _handleTap,
                  child: Center(
                    child: Text(
                      '👩‍🚀',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}