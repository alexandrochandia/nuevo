import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/casas_iglesias_provider.dart';
import '../../providers/aura_provider.dart';
import '../../widgets/iglesia_card.dart';
import '../../utils/glow_styles.dart';

class CasasIglesiasScreen extends StatefulWidget {
  const CasasIglesiasScreen({super.key});

  @override
  State<CasasIglesiasScreen> createState() => _CasasIglesiasScreenState();
}

class _CasasIglesiasScreenState extends State<CasasIglesiasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar datos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CasasIglesiasProvider>().cargarIglesias();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CasasIglesiasProvider, AuraProvider>(
      builder: (context, iglesiasProvider, auraProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0f0f23),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0f0f23),
                  const Color(0xFF1a1a2e),
                  const Color(0xFF0f0f23),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header personalizado
                  _buildHeader(auraProvider, iglesiasProvider),
                  
                  // Barra de búsqueda y filtros
                  _buildBarraBusquedaYFiltros(iglesiasProvider, auraProvider),
                  
                  // Tabs
                  _buildTabs(auraProvider),
                  
                  // Contenido principal
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTabTodasIglesias(iglesiasProvider),
                        _buildTabFavoritas(iglesiasProvider),
                        _buildTabMapa(iglesiasProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFab(auraProvider, iglesiasProvider),
        );
      },
    );
  }

  Widget _buildHeader(AuraProvider auraProvider, CasasIglesiasProvider iglesiasProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: GlowStyles.neonBlue,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encuentra tu familia espiritual 💫',
                      style: TextStyle(
                        color: auraProvider.selectedAuraColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${iglesiasProvider.iglesias.length} casas iglesias VMF',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: auraProvider.selectedAuraColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: auraProvider.selectedAuraColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.church,
                  color: auraProvider.selectedAuraColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarraBusquedaYFiltros(CasasIglesiasProvider provider, AuraProvider auraProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: auraProvider.selectedAuraColor.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _busquedaController,
              onChanged: provider.buscar,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar iglesias, ciudades, líderes...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: Icon(
                  Icons.search,
                  color: auraProvider.selectedAuraColor,
                ),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _busquedaController.clear();
                          provider.buscar('');
                        },
                        icon: const Icon(Icons.clear, color: Colors.white54),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filtros rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroChip(
                  'Tipo: ${_getTipoDisplay(provider.filtroTipo)}',
                  () => _mostrarFiltroTipo(provider, auraProvider),
                  auraProvider,
                ),
                const SizedBox(width: 8),
                _buildFiltroChip(
                  'Idioma: ${_getIdiomaDisplay(provider.filtroIdioma)}',
                  () => _mostrarFiltroIdioma(provider, auraProvider),
                  auraProvider,
                ),
                const SizedBox(width: 8),
                _buildFiltroChip(
                  'País: ${provider.filtroPais}',
                  () => _mostrarFiltroPais(provider, auraProvider),
                  auraProvider,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: provider.limpiarFiltros,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear, color: Colors.red, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Limpiar',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String texto, VoidCallback onTap, AuraProvider auraProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: auraProvider.selectedAuraColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: auraProvider.selectedAuraColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texto,
              style: TextStyle(
                color: auraProvider.selectedAuraColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: auraProvider.selectedAuraColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(AuraProvider auraProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: auraProvider.selectedAuraColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(
            icon: Icon(Icons.list, size: 20),
            text: 'Todas',
          ),
          Tab(
            icon: Icon(Icons.favorite, size: 20),
            text: 'Favoritas',
          ),
          Tab(
            icon: Icon(Icons.map, size: 20),
            text: 'Mapa',
          ),
        ],
      ),
    );
  }

  Widget _buildTabTodasIglesias(CasasIglesiasProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    if (provider.iglesias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron iglesias',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: provider.limpiarFiltros,
              child: const Text('Limpiar Filtros'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: provider.iglesias.length,
      itemBuilder: (context, index) {
        return IglesiaCard(iglesia: provider.iglesias[index]);
      },
    );
  }

  Widget _buildTabFavoritas(CasasIglesiasProvider provider) {
    if (provider.favoritas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin favoritas aún',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Marca iglesias como favoritas para verlas aquí',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: provider.favoritas.length,
      itemBuilder: (context, index) {
        return IglesiaCard(iglesia: provider.favoritas[index]);
      },
    );
  }

  Widget _buildTabMapa(CasasIglesiasProvider provider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Mapa Interactivo',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vista de mapa próximamente disponible',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFab(AuraProvider auraProvider, CasasIglesiasProvider provider) {
    return FloatingActionButton.extended(
      onPressed: provider.cambiarVista,
      backgroundColor: auraProvider.selectedAuraColor,
      icon: Icon(
        provider.vistaLista ? Icons.map : Icons.list,
        color: Colors.white,
      ),
      label: Text(
        provider.vistaLista ? 'Ver Mapa' : 'Ver Lista',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _mostrarFiltroTipo(CasasIglesiasProvider provider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltroModal(
        'Tipo de Reunión',
        provider.tiposReunion,
        provider.filtroTipo,
        (valor) => provider.cambiarFiltroTipo(valor),
        _getTipoDisplay,
        auraProvider,
      ),
    );
  }

  void _mostrarFiltroIdioma(CasasIglesiasProvider provider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltroModal(
        'Idioma',
        provider.idiomas,
        provider.filtroIdioma,
        (valor) => provider.cambiarFiltroIdioma(valor),
        _getIdiomaDisplay,
        auraProvider,
      ),
    );
  }

  void _mostrarFiltroPais(CasasIglesiasProvider provider, AuraProvider auraProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltroModal(
        'País',
        provider.paises,
        provider.filtroPais,
        (valor) => provider.cambiarFiltroPais(valor),
        (valor) => valor,
        auraProvider,
      ),
    );
  }

  Widget _buildFiltroModal(
    String titulo,
    List<String> opciones,
    String valorSeleccionado,
    Function(String) onChanged,
    String Function(String) displayText,
    AuraProvider auraProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: auraProvider.selectedAuraColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              titulo,
              style: TextStyle(
                color: auraProvider.selectedAuraColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...opciones.map((opcion) {
            return ListTile(
              title: Text(
                displayText(opcion),
                style: const TextStyle(color: Colors.white),
              ),
              leading: Radio<String>(
                value: opcion,
                groupValue: valorSeleccionado,
                onChanged: (valor) {
                  if (valor != null) {
                    onChanged(valor);
                    Navigator.pop(context);
                  }
                },
                activeColor: auraProvider.selectedAuraColor,
              ),
              onTap: () {
                onChanged(opcion);
                Navigator.pop(context);
              },
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getTipoDisplay(String tipo) {
    switch (tipo) {
      case 'todas':
        return 'Todas';
      case 'presencial':
        return '🏠 Presencial';
      case 'virtual':
        return '💻 Virtual';
      case 'hibrida':
        return '🔄 Híbrida';
      default:
        return tipo;
    }
  }

  String _getIdiomaDisplay(String idioma) {
    switch (idioma) {
      case 'todos':
        return 'Todos';
      case 'español':
        return '🇪🇸 Español';
      case 'sueco':
        return '🇸🇪 Svenska';
      case 'ingles':
        return '🇬🇧 English';
      default:
        return idioma;
    }
  }
}