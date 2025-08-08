import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/devotional_model.dart';
import '../providers/aura_provider.dart';
import '../providers/devotional_provider.dart';

class DevotionalDetailScreen extends StatefulWidget {
  final DevotionalModel devotional;

  const DevotionalDetailScreen({
    super.key,
    required this.devotional,
  });

  @override
  State<DevotionalDetailScreen> createState() => _DevotionalDetailScreenState();
}

class _DevotionalDetailScreenState extends State<DevotionalDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_scrollListener);
    _animationController.forward();

    // Incrementar vistas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevotionalProvider>().incrementViews(widget.devotional);
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auraProvider = Provider.of<AuraProvider>(context);
    final devotionalProvider = Provider.of<DevotionalProvider>(context);
    final auraColor = auraProvider.currentAuraColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f23),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context, auraColor, devotionalProvider),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(auraColor, devotionalProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color auraColor, DevotionalProvider provider) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF0f0f23),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.devotional.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareDevotional(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: () => provider.toggleFavorite(widget.devotional),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.devotional.isFavorite ? auraColor : Colors.transparent,
              ),
            ),
            child: Icon(
              widget.devotional.isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: widget.devotional.isFavorite ? auraColor : Colors.white,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Imagen de fondo
            Container(
              width: double.infinity,
              child: Image.network(
                widget.devotional.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: auraColor.withOpacity(0.2),
                  child: Icon(Icons.auto_stories, color: auraColor, size: 100),
                ),
              ),
            ),
            // Overlay degradado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    const Color(0xFF0f0f23),
                  ],
                ),
              ),
            ),
            // Contenido superpuesto
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(auraColor),
                  const SizedBox(height: 8),
                  Text(
                    widget.devotional.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.devotional.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color auraColor, DevotionalProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del autor y estadísticas
          _buildAuthorInfo(auraColor),
          const SizedBox(height: 24),
          
          // Versículo principal destacado
          _buildMainVerseSection(auraColor),
          const SizedBox(height: 32),
          
          // Reflexión
          _buildReflectionSection(auraColor),
          const SizedBox(height: 32),
          
          // Oración
          _buildPrayerSection(auraColor),
          const SizedBox(height: 32),
          
          // Tags
          _buildTagsSection(auraColor),
          const SizedBox(height: 32),
          
          // Acciones
          _buildActionButtons(auraColor, provider),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(Color auraColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: auraColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.devotional.category.emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            widget.devotional.category.displayName,
            style: const TextStyle(
              color: Color(0xFF0f0f23),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a3a).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: auraColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: auraColor.withOpacity(0.2),
            child: Icon(Icons.person, color: auraColor, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.devotional.author,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Publicado ${_formatDate(widget.devotional.date)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: auraColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.devotional.readTime} min',
                    style: TextStyle(
                      color: auraColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.visibility, color: Colors.white.withOpacity(0.6), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.devotional.views.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainVerseSection(Color auraColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            auraColor.withOpacity(0.1),
            auraColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: auraColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            color: auraColor,
            size: 30,
          ),
          const SizedBox(height: 16),
          Text(
            '"${widget.devotional.mainVerse}"',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.devotional.verseReference,
            style: TextStyle(
              color: auraColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _copyVerse(),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copiar Versículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: auraColor.withOpacity(0.2),
              foregroundColor: auraColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: auraColor.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: auraColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Reflexión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a3a).withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: auraColor.withOpacity(0.1)),
          ),
          child: Text(
            widget.devotional.reflection,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.8,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerSection(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite_outline, color: auraColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Oración',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                auraColor.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: auraColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                widget.devotional.prayer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 16,
                  height: 1.7,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _copyPrayer(),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar Oración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: auraColor.withOpacity(0.2),
                  foregroundColor: auraColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: auraColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.devotional.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: auraColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: auraColor.withOpacity(0.3)),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: auraColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color auraColor, DevotionalProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => provider.toggleFavorite(widget.devotional),
            icon: Icon(
              widget.devotional.isFavorite ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
            ),
            label: Text(widget.devotional.isFavorite ? 'Guardado' : 'Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.devotional.isFavorite 
                  ? auraColor.withOpacity(0.3) 
                  : auraColor.withOpacity(0.1),
              foregroundColor: auraColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(color: auraColor.withOpacity(0.5)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareDevotional(),
            icon: const Icon(Icons.share, size: 20),
            label: const Text('Compartir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: auraColor,
              foregroundColor: const Color(0xFF0f0f23),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
              shadowColor: auraColor.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'hoy';
    if (difference == 1) return 'ayer';
    if (difference < 7) return 'hace $difference días';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _copyVerse() {
    final text = '"${widget.devotional.mainVerse}"\n${widget.devotional.verseReference}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Versículo copiado al portapapeles'),
        backgroundColor: const Color(0xFF1a1a3a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyPrayer() {
    Clipboard.setData(ClipboardData(text: widget.devotional.prayer));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Oración copiada al portapapeles'),
        backgroundColor: const Color(0xFF1a1a3a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareDevotional() {
    final text = '''
📖 ${widget.devotional.title}

"${widget.devotional.mainVerse}"
${widget.devotional.verseReference}

${widget.devotional.subtitle}

🙏 Oración:
${widget.devotional.prayer}

📱 Descarga la app VMF Sweden para más devocionales diarios
''';
    
    // Aquí implementarías la funcionalidad de compartir real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Funcionalidad de compartir disponible pronto'),
        backgroundColor: const Color(0xFF1a1a3a),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}