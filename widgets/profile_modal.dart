import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/profile_modal_provider.dart';
// Screen imports for navigation
import '../screens/testimonios_avanzados_screen.dart';
import '../screens/livestream_screen.dart';
import '../screens/galeria_screen.dart';
import '../screens/devotional_detail_screen.dart';
import '../screens/vmf_chat_screen.dart';
import '../screens/visit_tracker_screen.dart';
import '../models/devotional_model.dart';

class ProfileModal extends StatefulWidget {
  const ProfileModal({super.key});

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _slideController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileModalProvider>(
      builder: (context, provider, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Background blur
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              
              // Modal content
              Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.black.withOpacity(0.6),
                                    Colors.black.withOpacity(0.9),
                                  ],
                                ),
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: _buildModalContent(provider),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalContent(ProfileModalProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(provider),
          const SizedBox(height: 20),
          _buildRealTimeStats(provider),
          const SizedBox(height: 24),
          _buildPersonalSections(provider),
          const SizedBox(height: 24),
          
          // Bottom actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileModalProvider provider) {
    return Row(
      children: [
        // Avatar with animated glow
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD4AF37).withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFFD4AF37).withOpacity(_glowAnimation.value),
                    width: 3,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 16),
        
        // Profile info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name with verified badge
              Row(
                children: [
                  const Text(
                    'alexandro chandia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Profile completion
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progreso del Perfil: ${provider.profileCompletion.toInt()}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: provider.profileCompletion / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Edit profile button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRealTimeStats(ProfileModalProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.1),
            const Color(0xFFD4AF37).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                '🔴 LIVE',
                '${provider.onlineUsers} online',
                isLive: true,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                '👀 Visitantes',
                '${provider.todayVisitors} hoy',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                '💬 Mensajes',
                '${provider.unreadMessages} sin leer',
                hasNotification: provider.unreadMessages > 0,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                '🛍️ Pedidos',
                '${provider.pendingOrders} pendientes',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isLive = false, bool hasNotification = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isLive ? Colors.red : Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasNotification) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalSections(ProfileModalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal'),
        const SizedBox(height: 12),
        _buildPersonalSection(
          '🧪 Mis Testimonios',
          '${provider.myTestimonies}',
          () => _navigateToSection('testimonies'),
        ),
        _buildPersonalSection(
          '🎥 Mis Videos en Vivo',
          '${provider.myLiveVideos}',
          () => _navigateToSection('live_videos'),
        ),
        _buildPersonalSection(
          '🛍️ Mis Compras',
          '${provider.pendingOrders}',
          () => _navigateToSection('purchases'),
        ),
        _buildPersonalSection(
          '📸 Mi Galería',
          '${provider.myGalleryItems}',
          () => _navigateToSection('gallery'),
        ),
        _buildPersonalSection(
          '🙏 Devocionales Guardados',
          '${provider.savedDevotionals}',
          () => _navigateToSection('devotionals'),
        ),
        _buildPersonalSection(
          '💬 Mis Chats',
          '${provider.myChats}',
          () => _navigateToSection('chats'),
        ),
        _buildPersonalSection(
          '👀 Visitantes Recientes',
          '${provider.todayVisitors}',
          () => _navigateToSection('visitors'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPersonalSection(String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            '🎨 Personalizar Aura',
            () => _showAuraCustomization(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            '🚪 Cerrar Sesión',
            () => _showLogoutConfirmation(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Navigation method for personal sections
  void _navigateToSection(String section) {
    Navigator.pop(context); // Close modal first
    
    switch (section) {
      case 'testimonies':
        print('✅ Navigating to Mis Testimonios');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TestimoniosAvanzadosScreen(),
          ),
        );
        break;
      case 'live_videos':
        print('🎥 Navigating to Mis Videos en Vivo');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LiveStreamScreen(),
          ),
        );
        break;
      case 'purchases':
        print('🛍️ Navigating to Mis Compras');
        // Navigate to store with user's purchase history filter
        Navigator.pushNamed(context, '/store-onboarding');
        break;
      case 'gallery':
        print('✅ Navigating to Mi Galería');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GaleriaScreen(),
          ),
        );
        break;
      case 'devotionals':
        print('✅ Navigating to Devocionales Guardados');
        // Crear un devocional temporal para navegación
        final tempDevotional = DevotionalModel(
          id: 'saved',
          title: 'Mis Devocionales Guardados',
          subtitle: 'Devocionales guardados',
          mainVerse: 'Salmos 119:105',
          verseReference: 'Lámpara es a mis pies tu palabra, y lumbrera a mi camino.',
          reflection: 'Aquí encontrarás todos tus devocionales guardados.',
          prayer: 'Señor, ayúdanos a crecer en tu palabra.',
          date: DateTime.now(),
          imageUrl: '',
          category: DevotionalCategory.daily,
          readTime: 5,
          tags: ['guardados', 'personal'],
          author: 'VMF Sweden',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevotionalDetailScreen(
              devotional: tempDevotional,
            ),
          ),
        );
        break;
      case 'chats':
        print('✅ Navigating to Mis Chats');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VMFChatScreen(),
          ),
        );
        break;
      case 'visitors':
        print('✅ Navigating to Visitantes Recientes');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VisitTrackerScreen(),
          ),
        );
        break;
      default:
        print('❌ Unknown section: $section');
    }
  }

  // Show aura customization modal
  void _showAuraCustomization() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            '🎨 Personalizar Aura VMF',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona el color de tu aura personal:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              // Color options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorOption(const Color(0xFFD4AF37), 'Dorado'),
                  _buildColorOption(Colors.blue, 'Azul'),
                  _buildColorOption(Colors.purple, 'Púrpura'),
                  _buildColorOption(Colors.green, 'Verde'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Save aura color preference
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aura personalizada guardada'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Helper method for color options
  Widget _buildColorOption(Color color, String name) {
    return GestureDetector(
      onTap: () {
        // TODO: Handle color selection
        print('Selected color: $name');
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            '🚪 Cerrar Sesión',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close modal
                
                try {
                  // TODO: Implement actual logout logic
                  // await Supabase.instance.client.auth.signOut();
                  print('User logged out successfully');
                  
                  // TODO: Navigate to login screen
                  // Navigator.pushNamedAndRemoveUntil(
                  //   context,
                  //   '/login',
                  //   (route) => false,
                  // );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada exitosamente'),
                      backgroundColor: Color(0xFFD4AF37),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
