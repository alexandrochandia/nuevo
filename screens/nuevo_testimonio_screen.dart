import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/testimonio_model.dart';
import '../providers/testimonio_provider.dart';
import '../providers/aura_provider.dart';
import 'crear_testimonio_texto_screen.dart';
import 'crear_testimonio_multimedia_screen.dart';

class NuevoTestimonioScreen extends StatefulWidget {
  const NuevoTestimonioScreen({super.key});

  @override
  State<NuevoTestimonioScreen> createState() => _NuevoTestimonioScreenState();
}

class _NuevoTestimonioScreenState extends State<NuevoTestimonioScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0a0a0a),
                const Color(0xFF1a1a2e),
                const Color(0xFF16213e),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(auraProvider),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBody(auraProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AuraProvider auraProvider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: auraProvider.currentAuraColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: auraProvider.currentAuraColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: auraProvider.currentAuraColor,
            size: 20,
          ),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e).withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: auraProvider.currentAuraColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          'Compartir Testimonio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: auraProvider.currentAuraColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildWelcomeSection(auraProvider),
          const SizedBox(height: 40),
          _buildOptionsGrid(auraProvider),
          const SizedBox(height: 30),
          _buildInspirationalQuote(auraProvider),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: auraProvider.currentAuraColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 60,
            color: auraProvider.currentAuraColor,
          ),
          const SizedBox(height: 16),
          Text(
            '¡Comparte tu testimonio!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: auraProvider.currentAuraColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu historia puede transformar vidas. Deja que otros vean el poder de Dios a través de tu experiencia.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(AuraProvider auraProvider) {
    final opciones = [
      {
        'title': 'Testimonio en Texto',
        'subtitle': 'Comparte tu historia con palabras',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFF4ecdc4),
        'onTap': () => _navigateToTextTestimony(),
      },
      {
        'title': 'Con Foto',
        'subtitle': 'Añade una imagen especial',
        'icon': Icons.photo_camera_rounded,
        'color': const Color(0xFF764ba2),
        'onTap': () => _navigateToPhotoTestimony(),
      },
      {
        'title': 'Con Video',
        'subtitle': 'Graba tu testimonio en video',
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFFfc7c7c),
        'onTap': () => _navigateToVideoTestimony(),
      },
      {
        'title': 'Audio',
        'subtitle': 'Graba tu voz y comparte',
        'icon': Icons.mic_rounded,
        'color': const Color(0xFF4facfe),
        'onTap': () => _navigateToAudioTestimony(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: opciones.length,
      itemBuilder: (context, index) {
        final opcion = opciones[index];
        return _buildOptionCard(opcion, auraProvider);
      },
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> opcion, AuraProvider auraProvider) {
    return GestureDetector(
      onTap: opcion['onTap'],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (opcion['color'] as Color).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (opcion['color'] as Color).withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    opcion['color'] as Color,
                    (opcion['color'] as Color).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (opcion['color'] as Color).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                opcion['icon'],
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              opcion['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              opcion['subtitle'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspirationalQuote(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            auraProvider.currentAuraColor.withOpacity(0.1),
            auraProvider.currentAuraColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 32,
            color: auraProvider.currentAuraColor.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            '"Que den gracias al Señor por su amor, por sus maravillas en favor de los hombres"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Salmos 107:15',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: auraProvider.currentAuraColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTextTestimony() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CrearTestimonioTextoScreen(),
      ),
    );
  }

  void _navigateToPhotoTestimony() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CrearTestimonioMultimediaScreen(
          tipo: TestimonioTipo.imagen,
        ),
      ),
    );
  }

  void _navigateToVideoTestimony() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CrearTestimonioMultimediaScreen(
          tipo: TestimonioTipo.video,
        ),
      ),
    );
  }

  void _navigateToAudioTestimony() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CrearTestimonioMultimediaScreen(
          tipo: TestimonioTipo.audio,
        ),
      ),
    );
  }
}