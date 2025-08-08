import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/testimonio_model.dart';
import '../providers/testimonio_provider.dart';
import '../providers/aura_provider.dart';

class VerTestimonioScreen extends StatefulWidget {
  final TestimonioModel testimonio;
  
  const VerTestimonioScreen({
    super.key,
    required this.testimonio,
  });

  @override
  State<VerTestimonioScreen> createState() => _VerTestimonioScreenState();
}

class _VerTestimonioScreenState extends State<VerTestimonioScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    return Consumer2<TestimonioProvider, AuraProvider>(
      builder: (context, testimonioProvider, auraProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
                const Color(0xFF0a0a0a),
                const Color(0xFF1a1a2e),
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(auraProvider, testimonioProvider),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBody(auraProvider, testimonioProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AuraProvider auraProvider, TestimonioProvider testimonioProvider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: _getTestimonioColor(widget.testimonio.tipo),
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
            color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTestimonioIcon(widget.testimonio.tipo),
              color: _getTestimonioColor(widget.testimonio.tipo),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _getTestimonioTypeText(widget.testimonio.tipo),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getTestimonioColor(widget.testimonio.tipo),
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: auraProvider.currentAuraColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () => _showShareOptions(context),
            icon: Icon(
              Icons.share_rounded,
              color: auraProvider.currentAuraColor,
              size: 20,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: auraProvider.currentAuraColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () => testimonioProvider.toggleFavorito(widget.testimonio.id!),
            icon: Icon(
              widget.testimonio.esFavorito == true ? Icons.bookmark : Icons.bookmark_border,
              color: widget.testimonio.esFavorito == true 
                  ? auraProvider.currentAuraColor 
                  : Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(AuraProvider auraProvider, TestimonioProvider testimonioProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(auraProvider),
          const SizedBox(height: 24),
          _buildContent(auraProvider),
          const SizedBox(height: 24),
          _buildInteractions(auraProvider, testimonioProvider),
          const SizedBox(height: 24),
          _buildMetadata(auraProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTestimonioColor(widget.testimonio.tipo),
                      _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  _getTestimonioIcon(widget.testimonio.tipo),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.testimonio.titulo ?? 'Testimonio sin título',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por ${widget.testimonio.usuarioNombre ?? 'Anónimo'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getTestimonioColor(widget.testimonio.tipo),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.testimonio.ubicacion != null || widget.testimonio.ministerio != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.testimonio.ubicacion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: auraProvider.currentAuraColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: auraProvider.currentAuraColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: auraProvider.currentAuraColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.testimonio.ubicacion!,
                          style: TextStyle(
                            fontSize: 12,
                            color: auraProvider.currentAuraColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.testimonio.ministerio != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.church_rounded,
                          size: 14,
                          color: _getTestimonioColor(widget.testimonio.tipo),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.testimonio.ministerio!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTestimonioColor(widget.testimonio.tipo),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.testimonio.tipo == TestimonioTipo.imagen && widget.testimonio.imagenUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.testimonio.imagenUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 48,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Imagen no disponible',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (widget.testimonio.tipo == TestimonioTipo.video && widget.testimonio.videoUrl != null) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reproducir video testimonio',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (widget.testimonio.tipo == TestimonioTipo.audio) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.2),
                    _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTestimonioColor(widget.testimonio.tipo),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
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
                          'Audio testimonio',
                          style: TextStyle(
                            color: _getTestimonioColor(widget.testimonio.tipo),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para reproducir',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.headphones_rounded,
                    color: _getTestimonioColor(widget.testimonio.tipo).withOpacity(0.7),
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (widget.testimonio.contenido != null && widget.testimonio.contenido!.isNotEmpty)
            Text(
              widget.testimonio.contenido!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractions(AuraProvider auraProvider, TestimonioProvider testimonioProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInteractionButton(
            icon: Icons.visibility_outlined,
            count: widget.testimonio.vistas ?? 0,
            label: 'Vistas',
            color: Colors.blue,
            onTap: null,
          ),
          _buildInteractionButton(
            icon: Icons.favorite_border,
            count: widget.testimonio.likes ?? 0,
            label: 'Me gusta',
            color: Colors.red,
            onTap: () => testimonioProvider.darLike(widget.testimonio.id!),
          ),
          _buildInteractionButton(
            icon: widget.testimonio.esFavorito == true ? Icons.bookmark : Icons.bookmark_border,
            count: null,
            label: 'Guardar',
            color: auraProvider.currentAuraColor,
            onTap: () => testimonioProvider.toggleFavorito(widget.testimonio.id!),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int? count,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          if (count != null)
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            'Publicado ${_formatFechaCompleta(widget.testimonio.fechaCreacion)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTestimonioColor(TestimonioTipo? tipo) {
    switch (tipo) {
      case TestimonioTipo.texto:
        return const Color(0xFF4ecdc4);
      case TestimonioTipo.imagen:
        return const Color(0xFF764ba2);
      case TestimonioTipo.video:
        return const Color(0xFFfc7c7c);
      case TestimonioTipo.audio:
        return const Color(0xFF4facfe);
      default:
        return const Color(0xFF4ecdc4);
    }
  }

  IconData _getTestimonioIcon(TestimonioTipo? tipo) {
    switch (tipo) {
      case TestimonioTipo.texto:
        return Icons.text_fields_rounded;
      case TestimonioTipo.imagen:
        return Icons.photo_rounded;
      case TestimonioTipo.video:
        return Icons.videocam_rounded;
      case TestimonioTipo.audio:
        return Icons.mic_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  String _getTestimonioTypeText(TestimonioTipo? tipo) {
    switch (tipo) {
      case TestimonioTipo.texto:
        return 'Testimonio en Texto';
      case TestimonioTipo.imagen:
        return 'Testimonio con Foto';
      case TestimonioTipo.video:
        return 'Testimonio en Video';
      case TestimonioTipo.audio:
        return 'Testimonio en Audio';
      default:
        return 'Testimonio';
    }
  }

  String _formatFechaCompleta(DateTime? fecha) {
    if (fecha == null) return 'fecha desconocida';
    
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    return 'el ${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Compartir Testimonio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Esta funcionalidad estará disponible próximamente',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}