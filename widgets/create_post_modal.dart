
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spiritual_posts_provider.dart';
import '../models/spiritual_post_model.dart';
import '../services/supabase_service.dart';

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({Key? key}) : super(key: key);

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _bibleVerseController = TextEditingController();
  final TextEditingController _bibleReferenceController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  
  String _selectedPostType = 'reflection';
  List<String> _tags = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _postTypes = [
    {'type': 'reflection', 'label': 'Reflexión', 'icon': '💭'},
    {'type': 'prayer', 'label': 'Oración', 'icon': '🙏'},
    {'type': 'testimony', 'label': 'Testimonio', 'icon': '✨'},
    {'type': 'verse', 'label': 'Versículo', 'icon': '📖'},
    {'type': 'announcement', 'label': 'Anuncio', 'icon': '📢'},
    {'type': 'music', 'label': 'Música', 'icon': '🎵'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _bibleVerseController.dispose();
    _bibleReferenceController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A24),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF4C46E5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Crear Post Espiritual',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _createPost,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Publicar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de tipo de post
                  const Text(
                    'Tipo de Contenido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Grid de tipos de post
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _postTypes.length,
                    itemBuilder: (context, index) {
                      final type = _postTypes[index];
                      final isSelected = _selectedPostType == type['type'];
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPostType = type['type'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF6C63FF).withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                type['icon'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type['label'],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF6C63FF)
                                      : Colors.grey[400],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),

                  // Campo de contenido
                  const Text(
                    'Contenido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Comparte tu mensaje espiritual...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A3A),
                    ),
                  ),

                  // Campos de versículo bíblico (si aplica)
                  if (_selectedPostType == 'verse') ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Versículo Bíblico',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bibleVerseController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe el versículo...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2A3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bibleReferenceController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Referencia (ej: Juan 3:16)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2A3A),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Tags
                  const Text(
                    'Etiquetas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tagController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Agregar etiqueta y presionar Enter',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A3A),
                    ),
                    onSubmitted: _addTag,
                  ),
                  
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeTag(tag),
                                child: const Icon(
                                  Icons.close,
                                  color: Color(0xFF6C63FF),
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTag(String value) {
    if (value.isNotEmpty && !_tags.contains(value)) {
      setState(() {
        _tags.add(value);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El contenido no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final post = SpiritualPostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: 'Usuario VMF', // TODO: Obtener del provider de usuario
        content: _contentController.text.trim(),
        postType: _selectedPostType,
        bibleVerse: _selectedPostType == 'verse' 
            ? _bibleVerseController.text.trim().isNotEmpty 
                ? _bibleVerseController.text.trim()
                : null
            : null,
        bibleReference: _selectedPostType == 'verse'
            ? _bibleReferenceController.text.trim().isNotEmpty
                ? _bibleReferenceController.text.trim()
                : null
            : null,
        tags: _tags,
        createdAt: DateTime.now(),
      );

      final success = await context.read<SpiritualPostsProvider>().createPost(post);
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al crear el post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
