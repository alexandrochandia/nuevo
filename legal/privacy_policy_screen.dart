
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 🔒 Pantalla de Política de Privacidad
/// Diseño profesional con iconos, colores elegantes y contenido jurídico completo
/// Cumple con estándares GDPR y legislación internacional de protección de datos

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                FontAwesomeIcons.userShield,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Política de Privacidad',
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
            // 🔐 Header con ícono y fecha
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
                    FontAwesomeIcons.shieldHalved,
                    color: Color(0xFF2196F3),
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'POLÍTICA DE PROTECCIÓN DE DATOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Última actualización: 22 de enero de 2025\nVersión 3.0 - Cumplimiento GDPR completo',
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

            // 🚨 Aviso GDPR
            _buildGDPRNotice(),

            const SizedBox(height: 24),

            // 🏢 Responsable del tratamiento
            _buildSection(
              icon: FontAwesomeIcons.building,
              title: 'RESPONSABLE DEL TRATAMIENTO',
              color: const Color(0xFF2196F3),
              content: 'Identidad: SHALOM INTERNATIONAL\n'
                  'Forma Jurídica: Ideell förening (Asociación sin fines de lucro)\n'
                  'Número de Organización: 802441-9650\n'
                  'Representante Legal: Alexandro Chandia Araos\n'
                  'Delegado de Protección de Datos (DPO): legal@vmfsweden.org\n'
                  'Domicilio: Oxholmsgränds 3, 127 48 Skärholmen, Estocolmo, Suecia\n'
                  'Teléfono de contacto: +46 (0) 8 XXX XXX (horario: L-V 9:00-17:00 CET)\n'
                  'Autoridad de Control: Integritetsskyddsmyndigheten (IMY) - Suecia',
            ),

            // 📊 Datos que recopilamos
            _buildSection(
              icon: FontAwesomeIcons.database,
              title: 'CATEGORÍAS DE DATOS RECOPILADOS',
              color: const Color(0xFF9C27B0),
              content: '1. DATOS DE IDENTIFICACIÓN:\n'
                  '• Nombre completo y apellidos\n'
                  '• Fecha de nacimiento y edad\n'
                  '• Dirección de correo electrónico\n'
                  '• Número de teléfono (opcional)\n'
                  '• Fotografía de perfil (con consentimiento explícito)\n\n'
                  '2. DATOS TÉCNICOS:\n'
                  '• Dirección IP y geolocalización aproximada\n'
                  '• Tipo y versión del navegador/dispositivo\n'
                  '• Sistema operativo y configuración de idioma\n'
                  '• Identificadores únicos del dispositivo\n'
                  '• Cookies y tecnologías similares\n\n'
                  '3. DATOS DE USO:\n'
                  '• Patrones de navegación y interacción\n'
                  '• Tiempo de sesión y frecuencia de uso\n'
                  '• Preferencias de configuración\n'
                  '• Historial de actividades en la aplicación',
            ),

            // ⚖️ Base legal
            _buildSection(
              icon: FontAwesomeIcons.gavel,
              title: 'BASE LEGAL DEL TRATAMIENTO',
              color: const Color(0xFF4CAF50),
              content: 'Conforme al Art. 6 del GDPR, el tratamiento se basa en:\n\n'
                  '1. CONSENTIMIENTO (Art. 6.1.a):\n'
                  '• Registro voluntario en la aplicación\n'
                  '• Aceptación explícita de esta política\n'
                  '• Consentimiento específico para fotografías\n\n'
                  '2. INTERÉS LEGÍTIMO (Art. 6.1.f):\n'
                  '• Mejora de servicios y funcionalidades\n'
                  '• Seguridad y prevención de fraudes\n'
                  '• Análisis estadístico anonimizado\n\n'
                  '3. CUMPLIMIENTO LEGAL (Art. 6.1.c):\n'
                  '• Conservación de registros contables\n'
                  '• Cumplimiento de obligaciones fiscales\n'
                  '• Cooperación con autoridades competentes',
            ),

            // 🎯 Finalidades del tratamiento
            _buildSection(
              icon: FontAwesomeIcons.bullseye,
              title: 'FINALIDADES DEL TRATAMIENTO',
              color: const Color(0xFFFF9800),
              content: '1. FUNCIONALIDAD DE LA APLICACIÓN:\n'
                  '• Creación y gestión de cuenta de usuario\n'
                  '• Personalización de la experiencia\n'
                  '• Facilitación de interacciones comunitarias\n'
                  '• Notificaciones relevantes y comunicaciones\n\n'
                  '2. MEJORA Y DESARROLLO:\n'
                  '• Análisis de uso y comportamiento (anonimizado)\n'
                  '• Desarrollo de nuevas funcionalidades\n'
                  '• Optimización del rendimiento\n'
                  '• Investigación y desarrollo tecnológico\n\n'
                  '3. SEGURIDAD Y CUMPLIMIENTO:\n'
                  '• Prevención de fraudes y uso indebido\n'
                  '• Mantenimiento de la seguridad de la plataforma\n'
                  '• Cumplimiento de obligaciones legales\n'
                  '• Respuesta a requerimientos judiciales',
            ),

            // 🔄 Transferencias internacionales
            _buildSection(
              icon: FontAwesomeIcons.globe,
              title: 'TRANSFERENCIAS INTERNACIONALES',
              color: const Color(0xFFE91E63),
              content: 'En cumplimiento del Capítulo V del GDPR:\n\n'
                  '1. PAÍSES DE DESTINO:\n'
                  '• Estados Unidos (proveedores de servicios cloud)\n'
                  '• Reino Unido (servicios de análisis)\n'
                  '• Otros países de la UE (socios tecnológicos)\n\n'
                  '2. GARANTÍAS APLICADAS:\n'
                  '• Cláusulas Contractuales Tipo (SCC) aprobadas por la CE\n'
                  '• Decisiones de Adecuación cuando estén disponibles\n'
                  '• Certificaciones de seguridad ISO 27001\n'
                  '• Evaluaciones de impacto específicas (DPIA)\n\n'
                  '3. DERECHOS DEL INTERESADO:\n'
                  '• Información sobre garantías específicas\n'
                  '• Copia de las medidas adecuadas adoptadas\n'
                  '• Derecho a oponerse a transferencias específicas',
            ),

            // ⏰ Plazos de conservación
            _buildSection(
              icon: FontAwesomeIcons.clock,
              title: 'PLAZOS DE CONSERVACIÓN',
              color: const Color(0xFF607D8B),
              content: 'Conforme al principio de limitación del plazo (Art. 5.1.e GDPR):\n\n'
                  '1. DATOS DE CUENTA ACTIVA:\n'
                  '• Durante la vigencia de la cuenta de usuario\n'
                  '• Hasta 12 meses después de la última actividad\n'
                  '• Eliminación automática tras inactividad prolongada\n\n'
                  '2. DATOS TÉCNICOS Y DE USO:\n'
                  '• Logs de servidor: 12 meses máximo\n'
                  '• Analytics anonimizados: 24 meses máximo\n'
                  '• Cookies: Según configuración del usuario\n\n'
                  '3. DATOS CONTABLES/LEGALES:\n'
                  '• Registros contables: 7 años (legislación sueca)\n'
                  '• Correspondencia legal: 5 años\n'
                  '• Datos anonimizados: Sin límite temporal',
            ),

            // 🔐 Medidas de seguridad
            _buildSection(
              icon: FontAwesomeIcons.lock,
              title: 'MEDIDAS DE SEGURIDAD TÉCNICAS',
              color: const Color(0xFFFF5722),
              content: 'Implementamos medidas técnicas y organizativas conforme al Art. 32 GDPR:\n\n'
                  '1. SEGURIDAD TÉCNICA:\n'
                  '• Cifrado AES-256 en tránsito y en reposo\n'
                  '• Autenticación multifactor (2FA) disponible\n'
                  '• Monitorización de seguridad 24/7\n'
                  '• Copias de seguridad cifradas y geo-distribuidas\n\n'
                  '2. MEDIDAS ORGANIZATIVAS:\n'
                  '• Políticas de acceso basadas en necesidad de conocer\n'
                  '• Formación regular del personal en protección de datos\n'
                  '• Procedimientos de respuesta a incidentes\n'
                  '• Auditorías de seguridad periódicas\n\n'
                  '3. CERTIFICACIONES:\n'
                  '• ISO 27001 (Sistemas de Gestión de Seguridad)\n'
                  '• SOC 2 Type II (proveedores de servicios)\n'
                  '• Evaluaciones de penetration testing anuales',
            ),

            // 👤 Derechos del interesado
            _buildSection(
              icon: FontAwesomeIcons.userCheck,
              title: 'DERECHOS DEL INTERESADO (GDPR)',
              color: const Color(0xFF3F51B5),
              content: 'Conforme al Capítulo III del GDPR, usted tiene derecho a:\n\n'
                  '1. DERECHO DE ACCESO (Art. 15):\n'
                  '• Confirmar si tratamos sus datos personales\n'
                  '• Obtener copia de los datos y información del tratamiento\n'
                  '• Tiempo de respuesta: Máximo 1 mes\n\n'
                  '2. DERECHO DE RECTIFICACIÓN (Art. 16):\n'
                  '• Corregir datos inexactos o incompletos\n'
                  '• Actualizar información desactualizada\n\n'
                  '3. DERECHO DE SUPRESIÓN (Art. 17):\n'
                  '• "Derecho al olvido" cuando se cumplan las condiciones\n'
                  '• Eliminación de datos innecesarios o ilícitos\n\n'
                  '4. DERECHOS ADICIONALES:\n'
                  '• Limitación del tratamiento (Art. 18)\n'
                  '• Portabilidad de datos (Art. 20)\n'
                  '• Oposición al tratamiento (Art. 21)\n'
                  '• No ser objeto de decisiones automatizadas (Art. 22)',
            ),

            // 🍪 Política de cookies
            _buildSection(
              icon: FontAwesomeIcons.cookie,
              title: 'POLÍTICA DE COOKIES Y TECNOLOGÍAS SIMILARES',
              color: const Color(0xFF795548),
              content: 'Utilizamos cookies conforme a la Directiva ePrivacy:\n\n'
                  '1. COOKIES ESENCIALES (Base legal: Interés legítimo):\n'
                  '• Cookies de sesión para funcionalidad básica\n'
                  '• Autenticación y seguridad del usuario\n'
                  '• No requieren consentimiento explícito\n\n'
                  '2. COOKIES ANALÍTICAS (Base legal: Consentimiento):\n'
                  '• Google Analytics (anonimizado)\n'
                  '• Métricas de uso y rendimiento\n'
                  '• Configurables desde ajustes de la aplicación\n\n'
                  '3. GESTIÓN DE COOKIES:\n'
                  '• Panel de control disponible en configuración\n'
                  '• Opción de aceptar/rechazar por categorías\n'
                  '• Información detallada sobre cada tipo\n'
                  '• Posibilidad de revocar consentimiento en cualquier momento',
            ),

            // 📞 Contacto y reclamaciones
            _buildSection(
              icon: FontAwesomeIcons.headset,
              title: 'CONTACTO Y EJERCICIO DE DERECHOS',
              color: const Color(0xFF009688),
              content: 'Para ejercer sus derechos o realizar consultas:\n\n'
                  '📧 DELEGADO DE PROTECCIÓN DE DATOS:\n'
                  '   Email: dpo@vmfsweden.org\n'
                  '   Asunto: [GDPR] - Tipo de solicitud\n\n'
                  '📮 DIRECCIÓN POSTAL:\n'
                  '   SHALOM INTERNATIONAL - Attn: DPO\n'
                  '   Oxholmsgränds 3, 127 48 Skärholmen\n'
                  '   Estocolmo, Suecia\n\n'
                  '⚖️ AUTORIDAD DE CONTROL:\n'
                  '   Integritetsskyddsmyndigheten (IMY)\n'
                  '   Box 8114, 104 20 Stockholm, Sverige\n'
                  '   Tel: +46 8 657 61 00\n'
                  '   Web: imy.se\n\n'
                  '🕐 PLAZOS DE RESPUESTA:\n'
                  '   • Solicitudes GDPR: Máximo 1 mes\n'
                  '   • Casos complejos: Hasta 3 meses (con notificación)\n'
                  '   • Consultas generales: 5-10 días hábiles',
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
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CUMPLIMIENTO GDPR CERTIFICADO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Conforme al Reglamento (UE) 2016/679 y legislación sueca\n'
                    'Auditoría de cumplimiento: Enero 2025\n'
                    'Próxima revisión: Enero 2026',
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

            const SizedBox(height: 20),

            // Botón de aceptar
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const FaIcon(
                  FontAwesomeIcons.check,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'He leído y acepto la Política de Privacidad',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGDPRNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.euroSign,
            color: Color(0xFF2196F3),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUMPLIMIENTO GDPR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Esta política cumple con el Reglamento General de Protección de Datos (UE) 2016/679. '
                  'Sus datos están protegidos conforme a los más altos estándares europeos de privacidad.',
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
    required Color color,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FaIcon(
                  icon,
                  color: color,
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
