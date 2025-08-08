
import 'package:flutter/material.dart';

/// Home background widget inspired by FluxStore
class HomeBackground extends StatelessWidget {
  final Map<String, dynamic>? config;

  const HomeBackground({super.key, this.config});

  @override
  Widget build(BuildContext context) {
    if (config == null) return const SizedBox.shrink();

    final type = config!['type'] ?? 'gradient';
    
    switch (type) {
      case 'gradient':
        return _buildGradientBackground();
      case 'image':
        return _buildImageBackground();
      case 'video':
        return _buildVideoBackground();
      case 'particles':
        return _buildParticlesBackground();
      default:
        return _buildGradientBackground();
    }
  }

  Widget _buildGradientBackground() {
    final colors = config!['colors'] as List<String>? ?? 
      ['#000000', '#1a1a1a', '#000000'];
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.map((color) => 
            Color(int.parse(color.replaceAll('#', '0xFF')))).toList(),
        ),
      ),
    );
  }

  Widget _buildImageBackground() {
    final imageUrl = config!['image'] as String?;
    if (imageUrl == null) return _buildGradientBackground();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBackground() {
    // For now, fallback to gradient
    // Could be implemented with video_player package
    return _buildGradientBackground();
  }

  Widget _buildParticlesBackground() {
    return Stack(
      children: [
        _buildGradientBackground(),
        Positioned.fill(
          child: CustomPaint(
            painter: ParticlesPainter(),
          ),
        ),
      ],
    );
  }
}

class ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw simple particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 47.0) % size.width;
      final y = (i * 73.0) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
