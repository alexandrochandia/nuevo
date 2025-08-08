import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/testimonio_model.dart';
import '../providers/testimonio_provider.dart';
import '../providers/aura_provider.dart';
import 'nuevo_testimonio_screen.dart';
import 'ver_testimonio_screen.dart';
import '../utils/glow_styles.dart';

class TestimoniosAvanzadosScreen extends StatefulWidget {
  const TestimoniosAvanzadosScreen({super.key});

  @override
  State<TestimoniosAvanzadosScreen> createState() => _TestimoniosAvanzadosScreenState();
}

class _TestimoniosAvanzadosScreenState extends State<TestimoniosAvanzadosScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    
    // Cargar testimonios al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestimonioProvider>().cargarTestimonios();
    });
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
                const Color(0xFF0a0a0a),
                const Color(0xFF1a1a2e),
                const Color(0xFF16213e),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(auraProvider, testimonioProvider),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBody(testimonioProvider, auraProvider),
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(auraProvider),
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
          'Testimonios VMF',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: auraProvider.currentAuraColor,
            letterSpacing: 0.5,
          ),
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
          child: PopupMenuButton<TestimonioTipo?>(
            icon: Icon(
              Icons.filter_list_rounded,
              color: auraProvider.currentAuraColor,
              size: 20,
            ),
            color: const Color(0xFF1a1a2e),
            onSelected: (tipo) {
              testimonioProvider.setFiltroTipo(tipo);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, color: auraProvider.currentAuraColor, size: 20),
                    const SizedBox(width: 8),
                    const Text('Todos', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TestimonioTipo.texto,
                child: Row(
                  children: [
                    const Icon(Icons.text_fields, color: Color(0xFF4ecdc4), size: 20),
                    const SizedBox(width: 8),
                    const Text('Texto', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TestimonioTipo.imagen,
                child: Row(
                  children: [
                    const Icon(Icons.photo, color: Color(0xFF764ba2), size: 20),
                    const SizedBox(width: 8),
                    const Text('Imágenes', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TestimonioTipo.video,
                child: Row(
                  children: [
                    const Icon(Icons.videocam, color: Color(0xFFfc7c7c), size: 20),
                    const SizedBox(width: 8),
                    const Text('Videos', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TestimonioTipo.audio,
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Color(0xFF4facfe), size: 20),
                    const SizedBox(width: 8),
                    const Text('Audio', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(TestimonioProvider testimonioProvider, AuraProvider auraProvider) {
    if (testimonioProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(auraProvider.currentAuraColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando testimonios...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final testimonios = testimonioProvider.testimoniosFiltrados;

    if (testimonios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64,
                    color: auraProvider.currentAuraColor.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay testimonios aún',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: auraProvider.currentAuraColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sé el primero en compartir tu testimonio de fe',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => testimonioProvider.cargarTestimonios(),
      color: auraProvider.currentAuraColor,
      backgroundColor: const Color(0xFF1a1a2e),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: testimonios.length,
        itemBuilder: (context, index) {
          return _buildTestimonioCard(testimonios[index], auraProvider, testimonioProvider);
        },
      ),
    );
  }

  Widget _buildTestimonioCard(TestimonioModel testimonio, AuraProvider auraProvider, TestimonioProvider testimonioProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTestimonioColor(testimonio.tipo).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTestimonioColor(testimonio.tipo).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _verTestimonio(testimonio, testimonioProvider),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTestimonioHeader(testimonio, auraProvider),
                const SizedBox(height: 16),
                _buildTestimonioContent(testimonio, auraProvider),
                const SizedBox(height: 16),
                _buildTestimonioFooter(testimonio, auraProvider, testimonioProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonioHeader(TestimonioModel testimonio, AuraProvider auraProvider) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTestimonioColor(testimonio.tipo),
                _getTestimonioColor(testimonio.tipo).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _getTestimonioColor(testimonio.tipo).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(
            _getTestimonioIcon(testimonio.tipo),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testimonio.titulo ?? 'Testimonio sin título',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    testimonio.usuarioNombre ?? 'Anónimo',
                    style: TextStyle(
                      fontSize: 14,
                      color: auraProvider.currentAuraColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (testimonio.ubicacion != null) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        testimonio.ubicacion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTestimonioColor(testimonio.tipo).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getTestimonioColor(testimonio.tipo).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getTestimonioTypeText(testimonio.tipo),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _getTestimonioColor(testimonio.tipo),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonioContent(TestimonioModel testimonio, AuraProvider auraProvider) {
    if (testimonio.tipo == TestimonioTipo.imagen && testimonio.imagenUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: testimonio.imagenUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
            ),
          ),
          if (testimonio.contenido != null && testimonio.contenido!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              testimonio.contenido!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    return Text(
      testimonio.contenido ?? 'Sin contenido',
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.8),
        height: 1.4,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTestimonioFooter(TestimonioModel testimonio, AuraProvider auraProvider, TestimonioProvider testimonioProvider) {
    return Row(
      children: [
        if (testimonio.ministerio != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: auraProvider.currentAuraColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: auraProvider.currentAuraColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              testimonio.ministerio!,
              style: TextStyle(
                fontSize: 10,
                color: auraProvider.currentAuraColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            _formatFechaRelativa(testimonio.fechaCreacion),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 16,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${testimonio.vistas ?? 0}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => testimonioProvider.darLike(testimonio.id!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${testimonio.likes ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => testimonioProvider.toggleFavorito(testimonio.id!),
              child: Icon(
                testimonio.esFavorito == true ? Icons.bookmark : Icons.bookmark_border,
                size: 16,
                color: testimonio.esFavorito == true 
                    ? auraProvider.currentAuraColor 
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(AuraProvider auraProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            auraProvider.currentAuraColor,
            auraProvider.currentAuraColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: auraProvider.currentAuraColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NuevoTestimonioScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
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
        return 'TEXTO';
      case TestimonioTipo.imagen:
        return 'FOTO';
      case TestimonioTipo.video:
        return 'VIDEO';
      case TestimonioTipo.audio:
        return 'AUDIO';
      default:
        return 'TEXTO';
    }
  }

  String _formatFechaRelativa(DateTime? fecha) {
    if (fecha == null) return 'Fecha desconocida';
    
    final now = DateTime.now();
    final difference = now.difference(fecha);
    
    if (difference.inDays > 7) {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Recién publicado';
    }
  }

  void _verTestimonio(TestimonioModel testimonio, TestimonioProvider testimonioProvider) {
    testimonioProvider.incrementarVistas(testimonio.id!);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerTestimonioScreen(testimonio: testimonio),
      ),
    );
  }
}