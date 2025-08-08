import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vmf_post_model.dart';
import '../controllers/vmf_create_content_controller.dart';

class VMFCreateContentScreen extends StatelessWidget {
  const VMFCreateContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VMFCreateContentController());
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          'Crear contenido',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.canPublish.value
                ? () => controller.publishContent()
                : null,
            child: Text(
              'Publicar',
              style: TextStyle(
                color: controller.canPublish.value
                    ? const Color(0xFFD4AF37)
                    : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de tipo de contenido
            _buildContentTypeSelector(controller),
            
            const SizedBox(height: 24),
            
            // Área de video/imagen
            _buildMediaSection(controller),
            
            const SizedBox(height: 24),
            
            // Campo de descripción
            _buildDescriptionField(controller),
            
            const SizedBox(height: 24),
            
            // Campo de hashtags
            _buildHashtagsField(controller),
            
            const SizedBox(height: 24),
            
            // Configuración de música (opcional)
            _buildMusicSection(controller),
            
            const SizedBox(height: 24),
            
            // Configuración de privacidad
            _buildPrivacySection(controller),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTypeSelector(VMFCreateContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de contenido',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: VMFPostType.values.map((type) {
            final isSelected = controller.selectedType.value == type;
            return GestureDetector(
              onTap: () => controller.selectedType.value = type,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(int.parse(type.color.replaceAll('#', '0xFF')))
                          .withOpacity(0.3)
                      : Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Color(int.parse(type.color.replaceAll('#', '0xFF')))
                        : Colors.grey[700]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Color(int.parse(type.color.replaceAll('#', '0xFF')))
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildMediaSection(VMFCreateContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.selectedVideo.value != null) {
            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          color: Color(0xFFD4AF37),
                          size: 50,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video seleccionado',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => controller.removeVideo(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return GestureDetector(
            onTap: () => _showMediaPicker(controller),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[700]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_camera_back_outlined,
                    color: Color(0xFFD4AF37),
                    size: 50,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Seleccionar video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para elegir desde galería o grabar',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDescriptionField(VMFCreateContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.descriptionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Comparte tu testimonio, reflexión o mensaje...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildHashtagsField(VMFCreateContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hashtags',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.hashtagsController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '#testimonio #fe #bendicion',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.tag,
              color: Color(0xFFD4AF37),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Separa los hashtags con espacios',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMusicSection(VMFCreateContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Música de fondo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Opcional',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showMusicPicker(controller),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Obx(() {
              if (controller.selectedMusic.value != null) {
                return Row(
                  children: [
                    const Icon(
                      Icons.music_note,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.selectedMusic.value!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.removeMusic(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                );
              }
              
              return const Row(
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Agregar música de fondo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(VMFCreateContentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Obx(() => SwitchListTile(
                title: const Text(
                  'Permitir comentarios',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Los usuarios podrán comentar tu contenido',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                value: controller.allowComments.value,
                onChanged: (value) => controller.allowComments.value = value,
                activeColor: const Color(0xFFD4AF37),
              )),
              
              Divider(color: Colors.grey[700], height: 1),
              
              Obx(() => SwitchListTile(
                title: const Text(
                  'Permitir descargas',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Los usuarios podrán descargar tu video',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                value: controller.allowDownloads.value,
                onChanged: (value) => controller.allowDownloads.value = value,
                activeColor: const Color(0xFFD4AF37),
              )),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tu contenido será revisado antes de publicarse para mantener un ambiente seguro y edificante.',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMediaPicker(VMFCreateContentController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Seleccionar video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFFD4AF37)),
              title: const Text('Grabar video', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                controller.pickVideo(ImageSource.camera);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.video_library, color: Color(0xFFD4AF37)),
              title: const Text('Elegir de galería', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                controller.pickVideo(ImageSource.gallery);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMusicPicker(VMFCreateContentController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Música de fondo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                children: [
                  'Himno de la Fe',
                  'Alabanza Eterna',
                  'Paz en el Alma',
                  'Gracia Divina',
                  'Esperanza Viva',
                ].map((music) => ListTile(
                  leading: const Icon(Icons.music_note, color: Color(0xFFD4AF37)),
                  title: Text(music, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    controller.selectMusic(music);
                    Get.back();
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
