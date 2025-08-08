import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/testimonio_model.dart';
import '../providers/testimonio_provider.dart';
import '../providers/aura_provider.dart';

class CrearTestimonioMultimediaScreen extends StatefulWidget {
  final TestimonioTipo tipo;
  
  const CrearTestimonioMultimediaScreen({
    super.key,
    required this.tipo,
  });

  @override
  State<CrearTestimonioMultimediaScreen> createState() => _CrearTestimonioMultimediaScreenState();
}

class _CrearTestimonioMultimediaScreenState extends State<CrearTestimonioMultimediaScreen>
    with TickerProviderStateMixin {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _ministerioController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  String? _selectedMediaPath;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _ministerioController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String get _tipoTexto {
    switch (widget.tipo) {
      case TestimonioTipo.imagen:
        return 'Foto';
      case TestimonioTipo.video:
        return 'Video';
      case TestimonioTipo.audio:
        return 'Audio';
      default:
        return 'Media';
    }
  }

  IconData get _tipoIcon {
    switch (widget.tipo) {
      case TestimonioTipo.imagen:
        return Icons.photo_camera_rounded;
      case TestimonioTipo.video:
        return Icons.videocam_rounded;
      case TestimonioTipo.audio:
        return Icons.mic_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }

  Color get _tipoColor {
    switch (widget.tipo) {
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
                _tipoColor.withOpacity(0.2),
                const Color(0xFF0a0a0a),
                const Color(0xFF1a1a2e),
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(auraProvider),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBody(auraProvider),
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
            color: _tipoColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: _tipoColor,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Testimonio con $_tipoTexto',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _tipoColor,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _tipoColor,
                _tipoColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _tipoColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isLoading ? null : _guardarTestimonio,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(AuraProvider auraProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMediaSection(auraProvider),
          const SizedBox(height: 24),
          _buildTextFields(auraProvider),
          const SizedBox(height: 24),
          _buildAdditionalFields(auraProvider),
          const SizedBox(height: 30),
          _buildGuidelinesCard(auraProvider),
        ],
      ),
    );
  }

  Widget _buildMediaSection(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _tipoColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _tipoColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _tipoColor,
                  _tipoColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _tipoColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              _tipoIcon,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedMediaPath != null
                ? 'Archivo seleccionado'
                : 'Seleccionar $_tipoTexto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _selectedMediaPath != null ? Colors.green : _tipoColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getMediaInstructions(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _selectMedia,
            icon: Icon(_tipoIcon),
            label: Text('Seleccionar $_tipoTexto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _tipoColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          if (_selectedMediaPath != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Archivo listo para subir',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextFields(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _tipoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del testimonio:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _tipoColor,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _tituloController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Título del testimonio',
              labelStyle: TextStyle(color: _tipoColor.withOpacity(0.7)),
              hintText: 'Ej: "Dios me sanó a través de la oración"',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _tipoColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _tipoColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _tipoColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descripcionController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              labelStyle: TextStyle(color: _tipoColor.withOpacity(0.7)),
              hintText: 'Describe brevemente tu testimonio...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _tipoColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _tipoColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _tipoColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalFields(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _tipoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información adicional (opcional):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _tipoColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ubicacionController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    labelStyle: TextStyle(color: _tipoColor.withOpacity(0.7)),
                    hintText: 'Estocolmo, Suecia',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _tipoColor.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _tipoColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _tipoColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ministerioController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Ministerio',
                    labelStyle: TextStyle(color: _tipoColor.withOpacity(0.7)),
                    hintText: 'Ministerio de Sanidad',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _tipoColor.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _tipoColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _tipoColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelinesCard(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _tipoColor.withOpacity(0.1),
            _tipoColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _tipoColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _tipoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Consejos para tu testimonio:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _tipoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getGuidelines().map((guideline) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: _tipoColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        guideline,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _getMediaInstructions() {
    switch (widget.tipo) {
      case TestimonioTipo.imagen:
        return 'Selecciona una foto que represente tu testimonio. Puede ser de la situación, un momento especial, o simplemente una imagen inspiradora.';
      case TestimonioTipo.video:
        return 'Graba un video contando tu testimonio. Mantén buena iluminación y habla claramente para que otros puedan escuchar tu historia.';
      case TestimonioTipo.audio:
        return 'Graba tu voz contando tu testimonio. Busca un lugar silencioso y habla con claridad para compartir tu experiencia.';
      default:
        return 'Selecciona el archivo multimedia para tu testimonio.';
    }
  }

  List<String> _getGuidelines() {
    final baseGuidelines = [
      'Sé auténtico y habla desde el corazón',
      'Enfócate en cómo Dios obró en tu situación',
      'Mantén un mensaje de esperanza y fe',
      'Respeta la privacidad de otras personas mencionadas',
    ];

    switch (widget.tipo) {
      case TestimonioTipo.imagen:
        return [
          ...baseGuidelines,
          'Asegúrate de que la imagen sea clara y apropiada',
          'Evita imágenes con información personal visible',
        ];
      case TestimonioTipo.video:
        return [
          ...baseGuidelines,
          'Graba en posición horizontal para mejor visualización',
          'Mantén el video entre 2-5 minutos para mayor impacto',
          'Verifica que el audio se escuche claramente',
        ];
      case TestimonioTipo.audio:
        return [
          ...baseGuidelines,
          'Graba en un ambiente silencioso',
          'Habla lentamente y con claridad',
          'Mantén la duración entre 2-3 minutos',
        ];
      default:
        return baseGuidelines;
    }
  }

  Future<void> _selectMedia() async {
    // Implementación usando image_picker para imágenes y simulación para otros tipos
    try {
      if (widget.tipo == TestimonioTipo.imagen) {
        // Para imágenes, usar image_picker que es más estable
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
                  'Seleccionar Imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _tipoColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMediaOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Cámara',
                      onTap: () => _pickImage(true),
                    ),
                    _buildMediaOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Galería',
                      onTap: () => _pickImage(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      } else {
        // Para video y audio, simulación funcional
        setState(() {
          _selectedMediaPath = 'testimonio_${widget.tipo.toString().split('.').last}_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension()}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo $_tipoTexto seleccionado correctamente'),
            backgroundColor: _tipoColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: _tipoColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _tipoColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: _tipoColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: _tipoColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(bool fromCamera) async {
    Navigator.of(context).pop(); // Cerrar modal
    
    try {
      // Simulación de selección de imagen
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _selectedMediaPath = fromCamera 
            ? 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg'
            : 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagen seleccionada desde ${fromCamera ? 'cámara' : 'galería'}'),
          backgroundColor: _tipoColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getFileExtension() {
    switch (widget.tipo) {
      case TestimonioTipo.imagen:
        return 'jpg';
      case TestimonioTipo.video:
        return 'mp4';
      case TestimonioTipo.audio:
        return 'mp3';
      default:
        return 'file';
    }
  }

  Future<void> _guardarTestimonio() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el título del testimonio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMediaPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona un archivo de $_tipoTexto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final testimonio = TestimonioModel(
      titulo: _tituloController.text.trim(),
      contenido: _descripcionController.text.trim().isEmpty 
          ? 'Testimonio compartido con $_tipoTexto' 
          : _descripcionController.text.trim(),
      ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
      ministerio: _ministerioController.text.trim().isEmpty ? null : _ministerioController.text.trim(),
      tipo: widget.tipo,
      fechaCreacion: DateTime.now(),
      usuarioNombre: 'Usuario VMF', // TODO: Obtener del usuario actual
      imagenUrl: widget.tipo == TestimonioTipo.imagen ? _selectedMediaPath : null,
      videoUrl: widget.tipo == TestimonioTipo.video ? _selectedMediaPath : null,
    );

    final success = await context.read<TestimonioProvider>().crearTestimonio(testimonio);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Testimonio con $_tipoTexto compartido exitosamente!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al compartir el testimonio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}