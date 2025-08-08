import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/testimonio_model.dart';
import '../providers/testimonio_provider.dart';
import '../providers/aura_provider.dart';

class CrearTestimonioTextoScreen extends StatefulWidget {
  const CrearTestimonioTextoScreen({super.key});

  @override
  State<CrearTestimonioTextoScreen> createState() => _CrearTestimonioTextoScreenState();
}

class _CrearTestimonioTextoScreenState extends State<CrearTestimonioTextoScreen>
    with TickerProviderStateMixin {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _ministerioController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  final List<Color> _backgroundColors = [
    const Color(0xFF4ecdc4),
    const Color(0xFF764ba2),
    const Color(0xFFfc7c7c),
    const Color(0xFF4facfe),
    const Color(0xFFf093fb),
    const Color(0xFF6a11cb),
  ];
  
  int _selectedColorIndex = 0;

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
    _contenidoController.dispose();
    _ubicacionController.dispose();
    _ministerioController.dispose();
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
                _backgroundColors[_selectedColorIndex].withOpacity(0.3),
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
            color: auraProvider.currentAuraColor.withOpacity(0.3),
            width: 1,
          ),
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
      title: Text(
        'Testimonio en Texto',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: auraProvider.currentAuraColor,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                auraProvider.currentAuraColor,
                auraProvider.currentAuraColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: auraProvider.currentAuraColor.withOpacity(0.3),
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
          _buildColorSelector(auraProvider),
          const SizedBox(height: 24),
          _buildTextEditor(auraProvider),
          const SizedBox(height: 24),
          _buildAdditionalFields(auraProvider),
          const SizedBox(height: 30),
          _buildPreview(auraProvider),
        ],
      ),
    );
  }

  Widget _buildColorSelector(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza el fondo:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: auraProvider.currentAuraColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _backgroundColors.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedColorIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _backgroundColors[index],
                          _backgroundColors[index].withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: _backgroundColors[index].withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEditor(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: auraProvider.currentAuraColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Título del testimonio:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: auraProvider.currentAuraColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tituloController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Ej: "Dios sanó mi corazón"',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: auraProvider.currentAuraColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Comparte tu testimonio:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: auraProvider.currentAuraColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contenidoController,
            maxLines: 8,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            decoration: InputDecoration(
              hintText: 'Cuenta cómo Dios obró en tu vida...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: auraProvider.currentAuraColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: auraProvider.currentAuraColor,
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
          color: auraProvider.currentAuraColor.withOpacity(0.3),
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
              color: auraProvider.currentAuraColor,
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
                    labelStyle: TextStyle(color: auraProvider.currentAuraColor.withOpacity(0.7)),
                    hintText: 'Estocolmo, Suecia',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: auraProvider.currentAuraColor.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: auraProvider.currentAuraColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: auraProvider.currentAuraColor,
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
                    labelStyle: TextStyle(color: auraProvider.currentAuraColor.withOpacity(0.7)),
                    hintText: 'Ministerio de Sanidad',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: auraProvider.currentAuraColor.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: auraProvider.currentAuraColor.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: auraProvider.currentAuraColor,
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

  Widget _buildPreview(AuraProvider auraProvider) {
    if (_contenidoController.text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _backgroundColors[_selectedColorIndex],
            _backgroundColors[_selectedColorIndex].withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _backgroundColors[_selectedColorIndex].withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista Previa:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          if (_tituloController.text.isNotEmpty) ...[
            Text(
              _tituloController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            _contenidoController.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarTestimonio() async {
    if (_tituloController.text.trim().isEmpty || _contenidoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el título y contenido'),
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
      contenido: _contenidoController.text.trim(),
      ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
      ministerio: _ministerioController.text.trim().isEmpty ? null : _ministerioController.text.trim(),
      tipo: TestimonioTipo.texto,
      fechaCreacion: DateTime.now(),
      usuarioNombre: 'Usuario VMF', // TODO: Obtener del usuario actual
    );

    final success = await context.read<TestimonioProvider>().crearTestimonio(testimonio);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Testimonio compartido exitosamente!'),
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