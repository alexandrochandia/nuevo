import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aura_provider.dart';
import '../utils/glow_styles.dart';

class DevocionalDiarioScreen extends StatefulWidget {
  const DevocionalDiarioScreen({super.key});

  @override
  State<DevocionalDiarioScreen> createState() => _DevocionalDiarioScreenState();
}

class _DevocionalDiarioScreenState extends State<DevocionalDiarioScreen> {
  final List<Map<String, dynamic>> _devocionales = [
    {
      'title': 'La Fe que Mueve Montañas',
      'verse': 'Mateo 17:20',
      'verseText': 'Si tuviereis fe como un grano de mostaza...',
      'content': 'Hoy reflexionamos sobre el poder transformador de la fe. Aunque pequeña como un grano de mostaza, la fe genuina puede lograr lo imposible.',
      'date': '5 Enero 2025',
      'readTime': '3 min',
      'category': 'Fe',
      'isRead': false,
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
    },
    {
      'title': 'Amor Incondicional',
      'verse': 'Juan 3:16',
      'verseText': 'Porque de tal manera amó Dios al mundo...',
      'content': 'El amor de Dios trasciende nuestras limitaciones humanas. Es un amor que no depende de nuestras obras sino de Su gracia.',
      'date': '4 Enero 2025',
      'readTime': '4 min',
      'category': 'Amor',
      'isRead': true,
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
    },
    {
      'title': 'Esperanza en Tiempos Difíciles',
      'verse': 'Romanos 8:28',
      'verseText': 'Y sabemos que a los que aman a Dios...',
      'content': 'Cuando las circunstancias parecen adversas, recordamos que Dios tiene un propósito perfecto para nuestras vidas.',
      'date': '3 Enero 2025',
      'readTime': '5 min',
      'category': 'Esperanza',
      'isRead': true,
      'image': 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=400&h=300&fit=crop',
    },
  ];

  final List<String> _categorias = ['Todos', 'Fe', 'Amor', 'Esperanza', 'Sabiduría', 'Paz'];
  String _categoriaSeleccionada = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.grey[900]!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(auraProvider.currentAuraColor),
                  _buildDevocionalHoy(auraProvider.currentAuraColor),
                  _buildCategorias(auraProvider.currentAuraColor),
                  Expanded(
                    child: _buildDevocionales(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color auraColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 Devocional Diario',
                      style: GlowStyles.boldWhiteText.copyWith(
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      'Alimenta tu espíritu cada día',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.auto_stories,
                color: auraColor,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevocionalHoy(Color auraColor) {
    final devocionalHoy = _devocionales.first;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            auraColor.withOpacity(0.8),
            auraColor.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: auraColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              devocionalHoy['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: auraColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'HOY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  devocionalHoy['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  devocionalHoy['verse'],
                  style: TextStyle(
                    color: auraColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _leerDevocional(devocionalHoy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Leer Ahora'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias(Color auraColor) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          final isSelected = categoria == _categoriaSeleccionada;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _categoriaSeleccionada = categoria;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? auraColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? auraColor : Colors.white.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  categoria,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDevocionales() {
    final devocionesFiltrados = _categoriaSeleccionada == 'Todos' 
        ? _devocionales.skip(1).toList() // Saltar el primero (ya mostrado arriba)
        : _devocionales.where((d) => d['category'] == _categoriaSeleccionada).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: devocionesFiltrados.length,
      itemBuilder: (context, index) {
        final devocional = devocionesFiltrados[index];
        return _buildDevocionalCard(devocional);
      },
    );
  }

  Widget _buildDevocionalCard(Map<String, dynamic> devocional) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  devocional['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (devocional['isRead'])
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Provider.of<AuraProvider>(context).currentAuraColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        devocional['category'],
                        style: TextStyle(
                          color: Provider.of<AuraProvider>(context).currentAuraColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      devocional['date'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  devocional['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  devocional['verse'],
                  style: TextStyle(
                    color: Provider.of<AuraProvider>(context).currentAuraColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  devocional['content'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.white.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${devocional['readTime']} lectura',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _leerDevocional(devocional),
                      child: Text(
                        devocional['isRead'] ? 'Leer de nuevo' : 'Leer ahora',
                        style: TextStyle(
                          color: Provider.of<AuraProvider>(context).currentAuraColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _leerDevocional(Map<String, dynamic> devocional) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Provider.of<AuraProvider>(context).currentAuraColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  devocional['image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        devocional['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        devocional['verse'],
                        style: TextStyle(
                          color: Provider.of<AuraProvider>(context).currentAuraColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${devocional['verseText']}"',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            devocional['content'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  devocional['isRead'] = true;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Devocional marcado como leído'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Provider.of<AuraProvider>(context).currentAuraColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Marcar como Leído'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
