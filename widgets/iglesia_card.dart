import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/iglesia_model.dart';
import '../providers/aura_provider.dart';
import '../providers/casas_iglesias_provider.dart';
import '../screens/iglesia_detail_screen.dart';

class IglesiaCard extends StatelessWidget {
  final IglesiaModel iglesia;

  const IglesiaCard({
    super.key,
    required this.iglesia,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                auraProvider.selectedAuraColor.withOpacity(0.1),
                auraProvider.selectedAuraColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: auraProvider.selectedAuraColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: auraProvider.selectedAuraColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _navegarADetalle(context),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de cabecera
                  _buildImagenCabecera(auraProvider),
                  
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título e idioma
                        _buildTituloEIdioma(auraProvider),
                        
                        const SizedBox(height: 8),
                        
                        // Ubicación
                        _buildUbicacion(),
                        
                        const SizedBox(height: 8),
                        
                        // Horario y tipo
                        _buildHorarioYTipo(),
                        
                        const SizedBox(height: 12),
                        
                        // Líder y miembros
                        _buildLiderYMiembros(),
                        
                        const SizedBox(height: 12),
                        
                        // Servicios
                        _buildServicios(auraProvider),
                        
                        const SizedBox(height: 16),
                        
                        // Botones de acción
                        _buildBotonesAccion(context, auraProvider),
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

  Widget _buildImagenCabecera(AuraProvider auraProvider) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        image: DecorationImage(
          image: NetworkImage(iglesia.imagenUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Badge de tipo de reunión
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: auraProvider.selectedAuraColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  iglesia.tipoReunionDisplay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Botón de favorito
            Positioned(
              top: 12,
              right: 12,
              child: Consumer<CasasIglesiasProvider>(
                builder: (context, provider, child) {
                  return GestureDetector(
                    onTap: () => provider.toggleFavorita(iglesia.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        iglesia.esFavorita ? Icons.favorite : Icons.favorite_border,
                        color: iglesia.esFavorita ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Estado activo
            if (iglesia.esActiva)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🟢 Activa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloEIdioma(AuraProvider auraProvider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            iglesia.nombre,
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: auraProvider.selectedAuraColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            iglesia.idiomaDisplay,
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUbicacion() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            iglesia.direccionCompleta,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHorarioYTipo() {
    return Row(
      children: [
        const Icon(
          Icons.schedule,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          iglesia.horarioCompleto,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        if (iglesia.esVirtual) ...[
          const SizedBox(width: 12),
          const Icon(
            Icons.videocam,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'Online',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLiderYMiembros() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  iglesia.liderNombre,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const Icon(
              Icons.people,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${iglesia.cantidadMiembros} miembros',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicios(AuraProvider auraProvider) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: iglesia.servicios.take(4).map((servicio) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: auraProvider.selectedAuraColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _getServicioDisplay(servicio),
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBotonesAccion(BuildContext context, AuraProvider auraProvider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navegarADetalle(context),
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('Ver Detalles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: auraProvider.selectedAuraColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _contactarLider(context),
            icon: const Icon(Icons.message, size: 16),
            label: const Text('Contactar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: auraProvider.selectedAuraColor,
              side: BorderSide(color: auraProvider.selectedAuraColor),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (iglesia.esVirtual && iglesia.enlaceZoom != null) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _unirseVirtual(),
            icon: const Icon(Icons.videocam, size: 16),
            label: const Text('Unirse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getServicioDisplay(String servicio) {
    switch (servicio) {
      case 'culto':
        return '⛪ Culto';
      case 'oracion':
        return '🙏 Oración';
      case 'estudio':
        return '📖 Estudio';
      case 'jovenes':
        return '👥 Jóvenes';
      case 'niños':
        return '👶 Niños';
      case 'matrimonios':
        return '💑 Matrimonios';
      case 'familias':
        return '👨‍👩‍👧‍👦 Familias';
      case 'musica':
        return '🎵 Música';
      case 'evangelismo':
        return '📢 Evangelismo';
      case 'adoracion':
        return '🎼 Adoración';
      case 'intercesion':
        return '🔥 Intercesión';
      case 'sanidad':
        return '✨ Sanidad';
      case 'conferencias':
        return '🎤 Conferencias';
      case 'internacional':
        return '🌍 Internacional';
      default:
        return servicio;
    }
  }

  void _navegarADetalle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IglesiaDetailScreen(iglesia: iglesia),
      ),
    );
  }

  void _contactarLider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContactModal(context),
    );
  }

  Widget _buildContactModal(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, auraProvider, child) {
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Contactar a ${iglesia.liderNombre}',
                  style: TextStyle(
                    color: auraProvider.selectedAuraColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildContactOption(
                  icon: Icons.phone,
                  title: 'Llamar',
                  subtitle: iglesia.liderTelefono,
                  onTap: () => _llamar(iglesia.liderTelefono),
                  auraProvider: auraProvider,
                ),
                _buildContactOption(
                  icon: Icons.message,
                  title: 'WhatsApp',
                  subtitle: iglesia.liderWhatsapp,
                  onTap: () => _abrirWhatsApp(iglesia.liderWhatsapp),
                  auraProvider: auraProvider,
                ),
                _buildContactOption(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: iglesia.liderEmail,
                  onTap: () => _enviarEmail(iglesia.liderEmail),
                  auraProvider: auraProvider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AuraProvider auraProvider,
  }) {
    return ListTile(
      leading: Icon(icon, color: auraProvider.selectedAuraColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: auraProvider.selectedAuraColor.withOpacity(0.1),
    );
  }

  void _llamar(String telefono) async {
    final url = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _abrirWhatsApp(String whatsapp) async {
    final url = Uri.parse('https://wa.me/${whatsapp.replaceAll('+', '').replaceAll(' ', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _enviarEmail(String email) async {
    final url = Uri.parse('mailto:$email?subject=Consulta sobre VMF ${iglesia.ciudad}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _unirseVirtual() async {
    if (iglesia.enlaceZoom != null) {
      final url = Uri.parse(iglesia.enlaceZoom!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }
}