import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class NewUsersSwiperScreen extends StatefulWidget {
  const NewUsersSwiperScreen({super.key});

  @override
  State<NewUsersSwiperScreen> createState() => _NewUsersSwiperScreenState();
}

class _NewUsersSwiperScreenState extends State<NewUsersSwiperScreen>
    with TickerProviderStateMixin {
  final CardSwiperController _controller = CardSwiperController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Datos de usuarios nuevos simulados
  final List<Map<String, dynamic>> _newUsers = [
    {
      'name': 'María González',
      'age': 28,
      'location': 'Stockholm, Sweden',
      'bio': 'Buscando una comunidad de fe donde crecer espiritualmente. Me encanta la música cristiana y ayudar a otros.',
      'images': [
        'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=600&fit=crop',
      ],
      'interests': ['Música', 'Oración', 'Voluntariado'],
      'joinedDaysAgo': 2,
    },
    {
      'name': 'Carlos Andersson',
      'age': 32,
      'location': 'Göteborg, Sweden',
      'bio': 'Nuevo en Suecia, buscando una familia espiritual. Pastor en mi país de origen, ahora quiero servir aquí.',
      'images': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=600&fit=crop',
      ],
      'interests': ['Predicación', 'Estudios bíblicos', 'Deportes'],
      'joinedDaysAgo': 1,
    },
    {
      'name': 'Ana Pettersson',
      'age': 25,
      'location': 'Malmö, Sweden',
      'bio': 'Joven profesional buscando conexiones auténticas basadas en la fe. Me gusta organizar eventos comunitarios.',
      'images': [
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=600&fit=crop',
      ],
      'interests': ['Eventos', 'Fotografía', 'Cocina'],
      'joinedDaysAgo': 3,
    },
    {
      'name': 'David Eriksson',
      'age': 35,
      'location': 'Uppsala, Sweden',
      'bio': 'Padre de familia buscando una iglesia donde mis hijos puedan crecer en la fe. Ingeniero de software.',
      'images': [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=600&fit=crop',
      ],
      'interests': ['Familia', 'Tecnología', 'Lectura bíblica'],
      'joinedDaysAgo': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                'USUARIOS NUEVOS',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh users
              setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: CardSwiper(
                controller: _controller,
                cardsCount: _newUsers.length,
                numberOfCardsDisplayed: 2,
                backCardOffset: const Offset(0.0, -30.0),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  return _buildUserCard(_newUsers[index], percentThresholdX.toDouble(), percentThresholdY.toDouble());
                },
                onSwipe: (previousIndex, currentIndex, direction) {
                  HapticFeedback.mediumImpact();
                  _handleSwipe(direction, _newUsers[previousIndex]);
                  return true;
                },
                onEnd: () {
                  _showNoMoreUsersDialog();
                },
                allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                threshold: 50,
                maxAngle: 25,
                scale: 0.9,
              ),
            ),
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, double percentThresholdX, double percentThresholdY) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: PageView.builder(
                itemCount: user['images'].length,
                itemBuilder: (context, imageIndex) {
                  return Image.network(
                    user['images'][imageIndex],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.person, size: 100, color: Colors.white54),
                      );
                    },
                  );
                },
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Swipe direction indicator
            if (percentThresholdX.abs() > 0.1)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: percentThresholdX > 0 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Icon(
                      percentThresholdX > 0 ? Icons.favorite : Icons.close,
                      size: 100,
                      color: percentThresholdX > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            // User info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user['name']}, ${user['age']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Nuevo ${user['joinedDaysAgo']}d',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          user['location'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user['bio'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: user['interests'].map<Widget>((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Photo indicators
            if (user['images'].length > 1)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  children: List.generate(
                    user['images'].length,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < user['images'].length - 1 ? 4 : 0),
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onTap: () {
              HapticFeedback.mediumImpact();
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            color: Colors.blue,
            onTap: () {
              HapticFeedback.lightImpact();
              _showMessageDialog();
            },
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildActionButton(
                  icon: Icons.favorite,
                  color: Colors.green,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _controller.swipe(CardSwiperDirection.right);
                  },
                ),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.star,
            color: Color(0xFFD4AF37),
            onTap: () {
              HapticFeedback.lightImpact();
              _showSuperLikeDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  void _handleSwipe(CardSwiperDirection direction, Map<String, dynamic> user) {
    String action = '';
    switch (direction) {
      case CardSwiperDirection.left:
        action = 'rechazado';
        break;
      case CardSwiperDirection.right:
        action = 'le gustó';
        break;
      default:
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has $action a ${user['name']}'),
        backgroundColor: direction == CardSwiperDirection.right ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNoMoreUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          '¡No hay más usuarios!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Has visto todos los usuarios nuevos. Vuelve más tarde para ver más.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Enviar mensaje',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta función estará disponible próximamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuperLikeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Super Like',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¡Has enviado un Super Like! Esta persona será notificada de tu interés especial.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Genial',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }
}
