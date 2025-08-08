
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 📄 Pantalla de Términos y Condiciones
/// Diseño profesional con íconos, colores elegantes y contenido jurídico completo
/// Cumple con estándares legales internacionales y GDPR

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // 🎨 Negro elegante profesional
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE8E8E8)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const FaIcon(
                FontAwesomeIcons.fileContract,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Términos y Condiciones',
                style: TextStyle(
                  color: Color(0xFFE8E8E8),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 Header con ícono y fecha
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333), width: 1),
              ),
              child: const Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.scaleBalanced,
                    color: Color(0xFF4CAF50),
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ACUERDO LEGAL VINCULANTE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Última actualización: 22 de enero de 2025\nVersión 2.1 - Vigente desde el 01/01/2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B0B0),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⚠️ Aviso importante
            _buildWarningSection(),

            const SizedBox(height: 24),

            // 📖 Introducción
            _buildSection(
              icon: FontAwesomeIcons.bookOpen,
              title: 'INTRODUCCIÓN Y ACEPTACIÓN',
              content: 'Al acceder, descargar, instalar o utilizar la aplicación VMF (en adelante "la Aplicación"), '
                  'el usuario (en adelante "Usted" o "Usuario") acepta quedar legalmente vinculado por estos '
                  'Términos y Condiciones (en adelante "los Términos"). Si no está de acuerdo con alguna parte '
                  'de estos términos, debe cesar inmediatamente el uso de la Aplicación.\n\n'
                  'Estos términos constituyen un contrato legalmente vinculante entre Usted y SHALOM INTERNATIONAL '
                  '(en adelante "la Empresa", "Nosotros" o "VMF").',
            ),

            // 🏢 Información de la entidad
            _buildSection(
              icon: FontAwesomeIcons.building,
              title: 'ENTIDAD RESPONSABLE',
              content: 'Denominación Social: SHALOM INTERNATIONAL\n'
                  'Forma Jurídica: Ideell förening (Asociación sin fines de lucro)\n'
                  'Número de Organización: 802441-9650\n'
                  'Fecha de Registro: 26 de junio de 2008\n'
                  'Código SNI: 00009 - Actividad Principal\n'
                  'Representante Legal: Alexandro Chandia Araos\n'
                  'Domicilio Social: Oxholmsgränds 3, 127 48 Skärholmen, Estocolmo, Suecia\n'
                  'Apartado Postal: Box 164\n'
                  'Jurisdicción: Reino de Suecia - Unión Europea',
            ),

            // 📱 Uso de la aplicación
            _buildSection(
              icon: FontAwesomeIcons.mobileScreen,
              title: 'USO AUTORIZADO DE LA APLICACIÓN',
              content: '1.1 LICENCIA DE USO: Se otorga una licencia limitada, no exclusiva, '
                  'no transferible y revocable para usar la Aplicación exclusivamente para '
                  'fines personales y comunitarios relacionados con VMF.\n\n'
                  '1.2 RESTRICCIONES: Queda prohibido:\n'
                  '• Realizar ingeniería inversa, descompilar o desensamblar la Aplicación\n'
                  '• Crear obras derivadas basadas en la Aplicación\n'
                  '• Redistribuir, vender o comercializar la Aplicación\n'
                  '• Utilizar la Aplicación para actividades ilícitas o no autorizadas\n'
                  '• Interferir con la seguridad o funcionamiento de la Aplicación\n\n'
                  '1.3 EDAD MÍNIMA: Los usuarios deben tener al menos 16 años o la edad '
                  'mínima requerida en su jurisdicción para prestar consentimiento legal.',
            ),

            // 🔒 Protección de datos
            _buildSection(
              icon: FontAwesomeIcons.shieldHalved,
              title: 'PROTECCIÓN DE DATOS PERSONALES',
              content: '2.1 CUMPLIMIENTO GDPR: En cumplimiento del Reglamento (UE) 2016/679 (GDPR) '
                  'y la legislación sueca de protección de datos, nos comprometemos a proteger '
                  'su información personal.\n\n'
                  '2.2 DATOS RECOPILADOS: Podemos recopilar:\n'
                  '• Información de registro (nombre, email, fecha de nacimiento)\n'
                  '• Datos de uso y analytics de la aplicación\n'
                  '• Fotografías de perfil (con consentimiento explícito)\n'
                  '• Metadatos técnicos del dispositivo\n\n'
                  '2.3 BASE LEGAL: El tratamiento se basa en el consentimiento del usuario '
                  'y el interés legítimo de la organización.\n\n'
                  '2.4 DERECHOS DEL USUARIO: Conforme al GDPR, tiene derecho a:\n'
                  '• Acceso, rectificación y supresión de sus datos\n'
                  '• Portabilidad y limitación del tratamiento\n'
                  '• Oposición al tratamiento automatizado\n'
                  '• Retirar el consentimiento en cualquier momento',
            ),

            // 🚫 Prohibiciones y conducta
            _buildSection(
              icon: FontAwesomeIcons.ban,
              title: 'PROHIBICIONES Y CÓDIGO DE CONDUCTA',
              content: '3.1 ACTIVIDADES PROHIBIDAS: Está estrictamente prohibido:\n'
                  '• Acoso, intimidación o discriminación hacia otros usuarios\n'
                  '• Publicar contenido ofensivo, difamatorio o inapropiado\n'
                  '• Infringir derechos de propiedad intelectual de terceros\n'
                  '• Distribuir malware, virus o código malicioso\n'
                  '• Realizar actividades comerciales no autorizadas\n'
                  '• Suplantar identidad o proporcionar información falsa\n\n'
                  '3.2 CONSECUENCIAS: El incumplimiento puede resultar en:\n'
                  '• Suspensión temporal o permanente de la cuenta\n'
                  '• Eliminación de contenido infractor\n'
                  '• Acciones legales según la legislación aplicable\n\n'
                  '3.3 MODERACIÓN: Nos reservamos el derecho de moderar contenido '
                  'y tomar medidas disciplinarias sin previo aviso.',
            ),

            // ⚖️ Responsabilidad legal
            _buildSection(
              icon: FontAwesomeIcons.gavel,
              title: 'LIMITACIÓN DE RESPONSABILIDAD',
              content: '4.1 EXENCIÓN DE GARANTÍAS: La Aplicación se proporciona "tal como está" '
                  'sin garantías expresas o implícitas de ningún tipo.\n\n'
                  '4.2 LIMITACIÓN DE DAÑOS: En ningún caso seremos responsables por daños '
                  'indirectos, incidentales, especiales, consecuenciales o punitivos.\n\n'
                  '4.3 RESPONSABILIDAD MÁXIMA: Nuestra responsabilidad total no excederá '
                  'el importe pagado por el Usuario en los últimos 12 meses.\n\n'
                  '4.4 FUERZA MAYOR: No seremos responsables por incumplimientos debido a '
                  'circunstancias fuera de nuestro control razonable.',
            ),

            // 📄 Modificaciones
            _buildSection(
              icon: FontAwesomeIcons.fileEdit,
              title: 'MODIFICACIONES DE LOS TÉRMINOS',
              content: '5.1 DERECHO DE MODIFICACIÓN: Nos reservamos el derecho de modificar '
                  'estos términos en cualquier momento mediante notificación a través de la Aplicación.\n\n'
                  '5.2 NOTIFICACIÓN: Los cambios sustanciales serán notificados con al menos '
                  '30 días de antelación a través del email registrado.\n\n'
                  '5.3 ACEPTACIÓN: El uso continuado después de la notificación constituye '
                  'aceptación de los términos modificados.\n\n'
                  '5.4 RECHAZO: Si no acepta las modificaciones, debe cesar el uso de la Aplicación.',
            ),

            // 🌍 Jurisdicción
            _buildSection(
              icon: FontAwesomeIcons.globe,
              title: 'LEY APLICABLE Y JURISDICCIÓN',
              content: '6.1 LEY APLICABLE: Estos términos se rigen por las leyes del Reino de Suecia '
                  'y la legislación de la Unión Europea.\n\n'
                  '6.2 JURISDICCIÓN: Cualquier disputa será resuelta por los tribunales competentes '
                  'de Estocolmo, Suecia.\n\n'
                  '6.3 RESOLUCIÓN ALTERNATIVA: Priorizamos la mediación y arbitraje antes de '
                  'proceder a instancias judiciales.\n\n'
                  '6.4 IDIOMA: En caso de discrepancias entre versiones idiomáticas, '
                  'prevalecerá la versión en inglés.',
            ),

            // 📞 Contacto
            _buildSection(
              icon: FontAwesomeIcons.addressCard,
              title: 'CONTACTO Y CONSULTAS LEGALES',
              content: 'Para consultas relacionadas con estos términos:\n\n'
                  '📧 Email Legal: legal@vmfsweden.org\n'
                  '📮 Dirección Postal: SHALOM INTERNATIONAL\n'
                  '    Oxholmsgränds 3, 127 48 Skärholmen\n'
                  '    Estocolmo, Suecia\n'
                  '📋 Referencia: Términos VMF App v2.1\n\n'
                  'Tiempo de respuesta: 5-10 días hábiles\n'
                  'Horario de atención legal: Lunes a Viernes 09:00-17:00 CET',
            ),

            const SizedBox(height: 30),

            // Footer legal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: const Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.certificate,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'DOCUMENTO LEGALMENTE VINCULANTE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Validez legal conforme a la legislación sueca y europea\n'
                    'Firma electrónica: Aceptación mediante uso de la aplicación\n'
                    'Archivo: T&C_VMF_v2.1_2025.pdf',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888888),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1810),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            color: Color(0xFFFF9800),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVISO LEGAL IMPORTANTE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Este es un documento legal vinculante. Lea cuidadosamente antes de aceptar. '
                  'Su uso de la aplicación constituye aceptación plena de estos términos.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE8E8E8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FaIcon(
                  icon,
                  color: const Color(0xFF4CAF50),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8E8E8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFB8B8B8),
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
