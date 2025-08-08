import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/iglesia_model.dart';
import '../providers/aura_provider.dart';
import '../providers/casas_iglesias_provider.dart';

class IglesiaDetailScreen extends StatelessWidget {
  final IglesiaModel iglesia;

  const IglesiaDetailScreen({
    super.key,
    required this.iglesia,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuraProvider, CasasIglesiasProvider>(
      builder: (context, auraProvider, iglesiasProvider, child) {
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
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, auraProvider, iglesiasProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoPrincipal(auraProvider),
                        const SizedBox(height: 24),
                        _buildSeccionLider(auraProvider),
                        const SizedBox(height: 24),
                        _buildSeccionDetalles(auraProvider),
                        const SizedBox(height: 24),
                        _buildSeccionServicios(auraProvider),
                        const SizedBox(height: 24),
                        _buildSeccionTestimonios(auraProvider),
                        const SizedBox(height: 24),
                        _buildBotonesAccion(context, auraProvider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuraProvider auraProvider, CasasIglesiasProvider iglesiasProvider) {
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
      actions: [
        IconButton(
          onPressed: () => iglesiasProvider.toggleFavorita(iglesia.id),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              iglesia.esFavorita ? Icons.favorite : Icons.favorite_border,
              color: iglesia.esFavorita ? Colors.red : Colors.white,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              iglesia.imagenUrl,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: auraProvider.selectedAuraColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          iglesia.tipoReunionDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: iglesia.esActiva ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          iglesia.esActiva ? '🟢 Activa' : '🔴 Inactiva',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    iglesia.nombre,
                    style: TextStyle(
                      color: auraProvider.selectedAuraColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    iglesia.direccionCompleta,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
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

  Widget _buildInfoPrincipal(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            iglesia.descripcion,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.schedule,
                  'Horario',
                  iglesia.horarioCompleto,
                  auraProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  Icons.language,
                  'Idioma',
                  iglesia.idiomaDisplay,
                  auraProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.people,
                  'Miembros',
                  '${iglesia.cantidadMiembros} personas',
                  auraProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  Icons.public,
                  'País',
                  iglesia.pais,
                  auraProvider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String titulo, String valor, AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: auraProvider.selectedAuraColor, size: 16),
              const SizedBox(width: 4),
              Text(
                titulo,
                style: TextStyle(
                  color: auraProvider.selectedAuraColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionLider(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin,
                color: auraProvider.selectedAuraColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Líder de la Casa Iglesia',
                style: TextStyle(
                  color: auraProvider.selectedAuraColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            iglesia.liderNombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactoItem(Icons.phone, iglesia.liderTelefono, () => _llamar(iglesia.liderTelefono)),
          const SizedBox(height: 8),
          _buildContactoItem(Icons.email, iglesia.liderEmail, () => _enviarEmail(iglesia.liderEmail)),
          const SizedBox(height: 8),
          _buildContactoItem(Icons.message, 'WhatsApp', () => _abrirWhatsApp(iglesia.liderWhatsapp)),
        ],
      ),
    );
  }

  Widget _buildContactoItem(IconData icon, String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionDetalles(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles Adicionales',
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (iglesia.sitioWeb != null)
            _buildDetalleItem(
              Icons.web,
              'Sitio Web',
              iglesia.sitioWeb!,
              () => _abrirSitioWeb(iglesia.sitioWeb!),
            ),
          if (iglesia.enlaceZoom != null)
            _buildDetalleItem(
              Icons.videocam,
              'Enlace Zoom',
              'Unirse a reunión virtual',
              () => _unirseZoom(iglesia.enlaceZoom!),
            ),
          _buildDetalleItem(
            Icons.calendar_today,
            'Creada',
            _formatearFecha(iglesia.fechaCreacion),
            null,
          ),
          _buildDetalleItem(
            Icons.access_time,
            'Última Reunión',
            _formatearFecha(iglesia.ultimaReunion),
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(IconData icon, String titulo, String valor, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionServicios(AuraProvider auraProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ministerios y Servicios',
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: iglesia.servicios.map((servicio) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: auraProvider.selectedAuraColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getServicioDisplay(servicio),
                  style: TextStyle(
                    color: auraProvider.selectedAuraColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTestimonios(AuraProvider auraProvider) {
    if (iglesia.testimonios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Testimonios',
            style: TextStyle(
              color: auraProvider.selectedAuraColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...iglesia.testimonios.map((testimonio) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    color: auraProvider.selectedAuraColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      testimonio,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context, AuraProvider auraProvider) {
    return Column(
      children: [
        if (iglesia.esVirtual && iglesia.enlaceZoom != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _unirseZoom(iglesia.enlaceZoom!),
              icon: const Icon(Icons.videocam),
              label: const Text('Unirse a Reunión Virtual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (iglesia.esVirtual && iglesia.enlaceZoom != null)
          const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _contactarLider(context),
                icon: const Icon(Icons.message),
                label: const Text('Contactar Líder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: auraProvider.selectedAuraColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _abrirDirecciones(),
                icon: const Icon(Icons.directions),
                label: const Text('Cómo Llegar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: auraProvider.selectedAuraColor,
                  side: BorderSide(color: auraProvider.selectedAuraColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
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

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays < 1) {
      return 'Hoy';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 30) {
      return 'Hace ${(diferencia.inDays / 7).floor()} semanas';
    } else if (diferencia.inDays < 365) {
      return 'Hace ${(diferencia.inDays / 30).floor()} meses';
    } else {
      return 'Hace ${(diferencia.inDays / 365).floor()} años';
    }
  }

  void _contactarLider(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<AuraProvider>(
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
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: const Text('Llamar', style: TextStyle(color: Colors.white)),
                    subtitle: Text(iglesia.liderTelefono, style: const TextStyle(color: Colors.white70)),
                    onTap: () => _llamar(iglesia.liderTelefono),
                  ),
                  ListTile(
                    leading: const Icon(Icons.message, color: Colors.green),
                    title: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                    subtitle: Text(iglesia.liderWhatsapp, style: const TextStyle(color: Colors.white70)),
                    onTap: () => _abrirWhatsApp(iglesia.liderWhatsapp),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text('Email', style: TextStyle(color: Colors.white)),
                    subtitle: Text(iglesia.liderEmail, style: const TextStyle(color: Colors.white70)),
                    onTap: () => _enviarEmail(iglesia.liderEmail),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

  void _abrirSitioWeb(String sitioWeb) async {
    final url = Uri.parse(sitioWeb);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _unirseZoom(String enlaceZoom) async {
    final url = Uri.parse(enlaceZoom);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _abrirDirecciones() async {
    final query = Uri.encodeComponent(iglesia.direccionCompleta);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}