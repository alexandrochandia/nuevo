import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Términos y Condiciones',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
          )
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            '''
TÉRMINOS Y CONDICIONES DE USO DE LA APLICACIÓN VMF

Última actualización: [Fecha actual]

1. ACEPTACIÓN DE LOS TÉRMINOS
Al acceder y utilizar esta aplicación, usted acepta quedar obligado por estos Términos y Condiciones, así como por nuestra Política de Privacidad. Si no está de acuerdo con alguna parte, no utilice la aplicación.

2. INFORMACIÓN DEL PROPIETARIO
Propietario y Creador:
Marjo Alexandro Araos Chandia
Box 164, 14559 Norsborg
Estocolmo, Suecia
alexandrochandia@outlook.com

Todos los derechos sobre esta aplicación, su diseño, código, contenido audiovisual y estructura pertenecen exclusivamente al propietario mencionado anteriormente.

3. DERECHOS DE AUTOR Y PROPIEDAD INTELECTUAL
Todo el contenido de esta app, incluidos textos, imágenes, ilustraciones, videos, animaciones, código fuente y diseño, está protegido por las leyes de propiedad intelectual internacionales.
Queda estrictamente prohibida la copia, reproducción, distribución, modificación, ingeniería inversa o reutilización del contenido sin autorización previa y por escrito del titular.

4. LICENCIA DE USO
Se concede al usuario una licencia personal, limitada, no exclusiva e intransferible para usar esta aplicación con fines legítimos conforme a estos términos. Esta licencia no implica ningún derecho de propiedad sobre el software.

5. CONDUCTA DEL USUARIO
Al usar esta app, usted se compromete a no:
- Utilizarla con fines ilegales o no autorizados.
- Interferir con el funcionamiento de la app o intentar hackearla.
- Subir o distribuir contenido ofensivo, ilegal o que infrinja derechos de terceros.

6. LIMITACIÓN DE RESPONSABILIDAD
La aplicación se entrega “tal cual”, sin garantías de ningún tipo.
El propietario no será responsable de daños indirectos, incidentales o derivados del uso o imposibilidad de uso de la app.

7. MODIFICACIONES
El propietario se reserva el derecho de modificar o actualizar estos Términos y Condiciones en cualquier momento, sin previo aviso. Los cambios serán efectivos una vez publicados en esta sección.

8. LEGISLACIÓN APLICABLE Y JURISDICCIÓN
Estos términos se rigen por las leyes del Reino de Suecia. Cualquier disputa relacionada será resuelta ante los tribunales competentes de Estocolmo.

9. CONTACTO
Para cualquier duda legal, solicitud o reclamo:
alexandrochandia@outlook.com
Box 164, 14559 Norsborg, Estocolmo, Suecia

10. PROTECCIÓN DE MARCA Y NOMBRE COMERCIAL
El nombre "VMF – Visión Mundial para la Familia", su logotipo, identidad visual y otros elementos distintivos son propiedad exclusiva de Marjo Alexandro Araos Chandia y están protegidos por leyes de marca comercial.

11. CONTENIDO GENERADO POR EL USUARIO
Usted conserva los derechos sobre cualquier contenido que cargue a la app (como fotos, textos, comentarios), pero al hacerlo, otorga al propietario una licencia no exclusiva y global para mostrarlo, reproducirlo y moderarlo según sea necesario.

12. REQUISITOS DE EDAD
Para utilizar esta aplicación, debe tener al menos 16 años o contar con el consentimiento de sus padres o tutores.

13. SERVICIOS DE TERCEROS
Esta aplicación puede incluir enlaces o integraciones con servicios de terceros (como Apple, Google, Facebook). El uso de estos servicios está regido por sus propios términos y políticas.
''',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ),
      ),
    );
  }
}