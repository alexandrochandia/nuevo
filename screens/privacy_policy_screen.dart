import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Política de Privacidad',
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
POLÍTICA DE PRIVACIDAD – APLICACIÓN VMF

Última actualización: [Fecha actual]

Esta Política de Privacidad describe cómo recopilamos, usamos y protegemos la información personal que usted proporciona al utilizar la aplicación "VMF – Visión Mundial para la Familia".

1. RESPONSABLE DEL TRATAMIENTO
El responsable de los datos personales recopilados a través de esta app es:
Marjo Alexandro Araos Chandia
Box 164, 14559 Norsborg, Estocolmo, Suecia
alexandrochandia@outlook.com

2. INFORMACIÓN QUE RECOPILAMOS
- Datos personales como nombre, correo electrónico, número de teléfono (si aplica).
- Información de ubicación (con permiso del usuario).
- Preferencias de idioma y opciones seleccionadas dentro de la app.
- Información del dispositivo: modelo, sistema operativo, versión de la app.

3. USO DE LOS DATOS
Utilizamos sus datos personales para:
- Proporcionar acceso a las funcionalidades de la app.
- Mejorar la experiencia del usuario.
- Gestionar la autenticación y el inicio de sesión.
- Enviar notificaciones relacionadas con el servicio.

4. COMPARTICIÓN DE DATOS
No compartimos sus datos personales con terceros sin su consentimiento, salvo en los siguientes casos:
- Cumplimiento legal o requerimiento de una autoridad competente.
- Proveedores de servicios tecnológicos bajo acuerdos de confidencialidad.

5. SEGURIDAD DE LOS DATOS
Aplicamos medidas de seguridad técnicas y organizativas para proteger su información. Sin embargo, ningún sistema es 100% infalible.

6. CONSERVACIÓN DE DATOS
Conservamos sus datos únicamente durante el tiempo necesario para cumplir los fines para los cuales fueron recopilados.

7. DERECHOS DEL USUARIO
Usted puede acceder, corregir o eliminar su información personal. También puede retirar su consentimiento o limitar el tratamiento contactándonos por correo electrónico.

8. DATOS DE MENORES
Esta app no está dirigida a menores de 16 años. No recopilamos información personal de menores intencionadamente.

9. CAMBIOS EN ESTA POLÍTICA
Nos reservamos el derecho de modificar esta política en cualquier momento. Las modificaciones se notificarán dentro de la app.

10. CONTACTO
Para ejercer sus derechos o hacer consultas relacionadas con la privacidad:
alexandrochandia@outlook.com

Al usar esta aplicación, usted acepta esta Política de Privacidad.
''',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ),
      ),
    );
  }
}