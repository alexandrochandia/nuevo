import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:convert';
import '../../utils/overflow_utils.dart';
import '../../utils/error_handler.dart';
import '../../widgets/professional_register_button.dart';
import '../../widgets/professional_progress_indicator.dart';
import 'registration_controller.dart';
import 'dart:math' as math;

/// Pantalla profesional para subida de fotos del perfil
class RegisterPhotosScreen extends StatefulWidget {
  const RegisterPhotosScreen({super.key});

  @override
  State<RegisterPhotosScreen> createState() => _RegisterPhotosScreenState();
}

class _RegisterPhotosScreenState extends State<RegisterPhotosScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _uploadController;
  late AnimationController _photoController;

  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _uploadAnimation;
  late Animation<double> _photoAnimation;

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _loadExistingData();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _uploadController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _photoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _uploadAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _uploadController,
      curve: Curves.elasticOut,
    ));

    _photoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _photoController,
      curve: Curves.linear,
    ));
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _photoController.repeat();
    });
  }

  void _loadExistingData() {
    final controller = context.read<RegistrationController>();
    final existingPhotos = controller.getData<List<String>>('photos');
    if (existingPhotos != null && existingPhotos.isNotEmpty) {
      // Convertir base64 strings de vuelta a Files si es necesario
      // Por ahora solo actualizamos el contador
      setState(() {
        // _selectedImages = existingPhotos.map((base64) => File.fromRawPath(base64.codeUnits)).toList();
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _uploadController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Header sin botón atrás
                      _buildAnimatedHeader(controller),

                      // Contenido principal
                      _buildMainContent(controller),

                      // Botones de acción
                      _buildActionButtons(controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader(RegistrationController controller) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _headerAnimation.value,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - _headerAnimation.value)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Espacio vacío donde estaba el botón atrás
                  const SizedBox(width: 48),

                  // Progreso
                  ProfessionalProgressIndicator(
                    currentStep: controller.currentStep + 1,
                    totalSteps: RegistrationController.totalSteps,
                    progress: controller.progress,
                    size: 50,
                  ),

                  // Coins
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.black, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${(controller.progress * 50).round()}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(RegistrationController controller) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _contentAnimation.value)),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Hero section con círculo de foto principal
                _buildHeroSection(),

                const SizedBox(height: 20),

                // Grid de fotos adicionales (más pequeño y compacto)
                _buildPhotosGrid(),

                const SizedBox(height: 16),

                // Tips compactos
                _buildPhotoTips(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Círculo principal para mostrar la primera foto
        AnimatedBuilder(
          animation: _photoAnimation,
          builder: (context, child) {
            return GestureDetector(
              onTap: _showImageSourceModal,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedImages.isNotEmpty 
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFD4AF37).withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _selectedImages.isNotEmpty
                    ? ClipOval(
                        child: Image.file(
                          _selectedImages[0],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD4AF37),
                              const Color(0xFFD4AF37).withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 32,
                            ),
                            // Efecto de flash
                            Positioned.fill(
                              child: Opacity(
                                opacity: (math.sin(_photoAnimation.value * math.pi * 4) + 1) * 0.3,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Título
        Text(
          '¡Muestra tu mejor versión!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Descripción
        Text(
          _selectedImages.isEmpty 
              ? 'Toca el círculo para agregar tu foto principal'
              : 'Agrega más fotos para completar tu perfil',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotosGrid() {
    if (_selectedImages.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fotos adicionales:',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: math.min(_selectedImages.length - 1 + 3, 5), // Máximo 5 fotos adicionales
              itemBuilder: (context, index) {
                if (index < _selectedImages.length - 1) {
                  // Mostrar fotos adicionales (índice + 1 porque la primera está en el círculo)
                  return _buildAdditionalPhotoSlot(image: _selectedImages[index + 1], index: index + 1);
                } else {
                  // Mostrar slot vacío para agregar más
                  return _buildEmptyPhotoSlot();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPhotoSlot({required File image, required int index}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Botón de eliminar
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoSlot() {
    return GestureDetector(
      onTap: _showImageSourceModal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Patrón de puntos para simular borde punteado
            Positioned.fill(
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                ),
              ),
            ),
            // Icono centrado
            const Center(
              child: Icon(
                Icons.add_a_photo,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFD4AF37),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Tips para mejores fotos:',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '• Sonríe naturalmente  • Usa buena iluminación  • Muestra tu personalidad',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(RegistrationController controller) {
    final hasPhotos = _selectedImages.isNotEmpty;

    return Column(
      children: [
        // Contador y estado
        if (hasPhotos)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedImages.length} ${_selectedImages.length == 1 ? 'foto' : 'fotos'} agregada${_selectedImages.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Gana ${_selectedImages.length * 5} coins',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Botón principal
        ProfessionalRegisterButton(
          text: hasPhotos ? 'Continuar' : 'Agregar Foto Principal',
          onPressed: hasPhotos ? () => _handleNext(controller) : _showImageSourceModal,
          isEnabled: true,
          isLoading: _isUploading || controller.isLoading,
          loadingText: _isUploading ? 'Subiendo fotos...' : 'Guardando...',
          icon: hasPhotos ? null : Icons.add_a_photo,
          trailingIcon: hasPhotos ? Icons.arrow_forward : null,
          showGlow: hasPhotos,
        ),

        if (_selectedImages.isNotEmpty && _selectedImages.length < 6) ...[
          const SizedBox(height: 12),

          // Botón para agregar más fotos
          SecondaryRegisterButton(
            text: 'Agregar más fotos',
            onPressed: _showImageSourceModal,
            icon: Icons.add_photo_alternate,
          ),
        ],
      ],
    );
  }

  void _showImageSourceModal() {
    if (_selectedImages.length >= 6) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Máximo 6 fotos permitidas',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Seleccionar Imagen',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Opciones
              _buildSourceOption(
                icon: Icons.camera_alt,
                title: 'Cámara',
                subtitle: 'Tomar una foto nueva',
                onTap: () => _pickImage(ImageSource.camera),
              ),

              _buildSourceOption(
                icon: Icons.photo_library,
                title: 'Galería',
                subtitle: 'Elegir de la galería',
                onTap: () => _pickImage(ImageSource.gallery),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFD4AF37),
                    size: 24,
                  ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Cerrar modal

    try {
      // Verificar permisos
      if (source == ImageSource.camera) {
        final cameraPermission = await Permission.camera.request();
        if (!cameraPermission.isGranted) {
          _showPermissionDeniedDialog('Cámara');
          return;
        }
      } else {
        // Para galería, usar permission_handler más específico
        PermissionStatus photosPermission;
        if (Platform.isIOS) {
          photosPermission = await Permission.photos.request();
        } else {
          // Android 13+ usa diferentes permisos
          photosPermission = await Permission.storage.request();
          if (photosPermission.isDenied) {
            photosPermission = await Permission.manageExternalStorage.request();
          }
        }

        if (!photosPermission.isGranted) {
          _showPermissionDeniedDialog('Galería');
          return;
        }
      }

      setState(() {
        _isUploading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null && _selectedImages.length < 6) {
        setState(() {
          _selectedImages.add(File(image.path));
        });

        // Actualizar controlador
        await _updateController();

        // Animación de éxito
        _uploadController.forward().then((_) {
          _uploadController.reverse();
        });

        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            '¡Foto agregada exitosamente! +5 coins',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Error al seleccionar imagen: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _updateController() async {
    final controller = context.read<RegistrationController>();

    // Convertir imágenes a base64 para almacenamiento
    List<String> base64Images = [];
    for (File image in _selectedImages) {
      try {
        final bytes = await image.readAsBytes();
        final base64 = base64Encode(bytes);
        base64Images.add(base64);
      } catch (e) {
        print('Error converting image to base64: $e');
      }
    }

    await controller.updateData('photos', base64Images);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });

    _updateController();

    if (mounted) {
      ErrorHandler.showSuccessSnackBar(
        context,
        'Foto eliminada',
      );
    }
  }

  void _showPermissionDeniedDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Permiso de $type Requerido',
          style: const TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Text(
          'Para subir fotos necesitamos acceso a tu $type. Por favor habilita el permiso en configuración.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Configuración',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(RegistrationController controller) async {
    if (!mounted) return;

    if (_selectedImages.isEmpty) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Debes agregar al menos una foto para continuar.',
      );
      return;
    }

    try {
      // Asegurar que los datos están actualizados
      await _updateController();

      // Avanzar al siguiente paso
      final success = await controller.nextStep();

      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(
          context, 
          '¡Fotos guardadas! +${_selectedImages.length * 5} coins'
        );

        // Navegar al siguiente paso usando go_router
        context.go('/register-final');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Error al guardar las fotos. Inténtalo de nuevo.',
        );
      }
    }
  }
}

// Custom painter para borde punteado
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final dashEnd = math.min(distance + dashWidth, pathMetric.length);
        dashPath.addPath(
          pathMetric.extractPath(distance, dashEnd),
          Offset.zero,
        );
        distance = dashEnd + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget de botón secundario
class SecondaryRegisterButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryRegisterButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}