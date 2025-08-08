import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/aura_provider.dart';
import '../providers/vmf_stories_provider.dart';
import '../models/vmf_story_model.dart';
import '../utils/glow_styles.dart';

class VMFCameraScreen extends StatefulWidget {
  const VMFCameraScreen({super.key});

  @override
  State<VMFCameraScreen> createState() => _VMFCameraScreenState();
}

class _VMFCameraScreenState extends State<VMFCameraScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  
  File? _selectedFile;
  VMFStoryType _selectedType = VMFStoryType.video;
  VMFStoryCategory _selectedCategory = VMFStoryCategory.testimonio;
  bool _isUploading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'category': VMFStoryCategory.testimonio,
      'name': 'Testimonio',
      'icon': '🙏',
      'color': Colors.blue,
    },
    {
      'category': VMFStoryCategory.predicacion,
      'name': 'Predicación',
      'icon': '📖',
      'color': Colors.purple,
    },
    {
      'category': VMFStoryCategory.alabanza,
      'name': 'Alabanza',
      'icon': '🎵',
      'color': Colors.orange,
    },
    {
      'category': VMFStoryCategory.juventud,
      'name': 'Juventud',
      'icon': '🌱',
      'color': Colors.green,
    },
    {
      'category': VMFStoryCategory.oracion,
      'name': 'Oración',
      'icon': '🕊️',
      'color': Colors.cyan,
    },
    {
      'category': VMFStoryCategory.eventos,
      'name': 'Eventos',
      'icon': '📅',
      'color': Colors.amber,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        final auraColor = auraProvider.currentAuraColor;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Crear Historia VMF',
              style: TextStyle(
                color: auraColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.close, color: auraColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_selectedFile != null)
                TextButton(
                  onPressed: _isUploading ? null : _publishStory,
                  child: _isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(auraColor),
                          ),
                        )
                      : Text(
                          'Publicar',
                          style: TextStyle(
                            color: auraColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Camera section
                _buildCameraSection(auraColor),
                
                const SizedBox(height: 30),
                
                // Type selection
                _buildTypeSelection(auraColor),
                
                const SizedBox(height: 30),
                
                // Category selection
                _buildCategorySelection(auraColor),
                
                const SizedBox(height: 30),
                
                // Description input
                _buildDescriptionInput(auraColor),
                
                const SizedBox(height: 30),
                
                // Preview section
                if (_selectedFile != null)
                  _buildPreviewSection(auraColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraSection(Color auraColor) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: _selectedFile != null
          ? _buildSelectedFilePreview()
          : _buildCameraOptions(auraColor),
    );
  }

  Widget _buildSelectedFilePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _selectedFile!,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFile = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraOptions(Color auraColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: auraColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: auraColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: auraColor.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: auraColor,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Crear Historia VMF',
          style: TextStyle(
            color: auraColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Comparte tu testimonio o momento espiritual',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCameraOption(
              icon: Icons.camera_alt,
              label: 'Cámara',
              onTap: () => _pickImage(ImageSource.camera),
              auraColor: auraColor,
            ),
            _buildCameraOption(
              icon: Icons.photo_library,
              label: 'Galería',
              onTap: () => _pickImage(ImageSource.gallery),
              auraColor: auraColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color auraColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: auraColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: auraColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: auraColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: auraColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Historia',
          style: TextStyle(
            color: auraColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeOption(
              type: VMFStoryType.image,
              icon: Icons.image,
              label: 'Imagen',
              auraColor: auraColor,
            ),
            const SizedBox(width: 12),
            _buildTypeOption(
              type: VMFStoryType.video,
              icon: Icons.videocam,
              label: 'Video',
              auraColor: auraColor,
            ),
            const SizedBox(width: 12),
            _buildTypeOption(
              type: VMFStoryType.text,
              icon: Icons.text_fields,
              label: 'Texto',
              auraColor: auraColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required VMFStoryType type,
    required IconData icon,
    required String label,
    required Color auraColor,
  }) {
    final isSelected = _selectedType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? auraColor.withOpacity(0.2) : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? auraColor : Colors.grey[700]!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? auraColor : Colors.white60,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? auraColor : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            color: auraColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat['category'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['category'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? auraColor.withOpacity(0.2) : Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? auraColor : Colors.grey[700]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['icon'], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      cat['name'],
                      style: TextStyle(
                        color: isSelected ? auraColor : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(Color auraColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            color: auraColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: auraColor.withOpacity(0.3)),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 200,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Comparte tu testimonio o reflexión...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(color: auraColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: auraColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista Previa',
            style: TextStyle(
              color: auraColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: auraColor.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : 'Sin descripción',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: auraColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _categories.firstWhere((cat) => cat['category'] == _selectedCategory)['name'],
                        style: TextStyle(
                          color: auraColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _publishStory() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una imagen o video'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create story model
      final story = VMFStoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        userName: 'Usuario VMF',
        userProfileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        type: _selectedType,
        content: _selectedFile!.path, // In real app, upload to server first
        thumbnail: _selectedFile!.path,
        duration: const Duration(seconds: 30),
        viewByUserIds: [],
        createdAt: DateTime.now(),
        description: _descriptionController.text,
        hashtags: ['#vmfsweden', '#testimonio'],
        category: _selectedCategory,
        isVerified: false,
        views: 0,
        likes: 0,
        isLiked: false,
      );

      // Add to provider
      final success = await context.read<VMFStoriesProvider>().addStory(story);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historia publicada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al publicar historia');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}