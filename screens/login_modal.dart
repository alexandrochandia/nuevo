import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void mostrarModalLogin(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Wrap(
          children: [
            _botonLogin(context, CupertinoIcons.person_solid, "Iniciar sesión con Apple"),
            _botonLogin(context, Icons.facebook, "Iniciar sesión con Facebook"),
            _botonLogin(context, Icons.phone_android, "Iniciar sesión con número de teléfono"),
            _botonLogin(context, Icons.email, "Iniciar sesión con correo electrónico"),
            _botonLogin(context, Icons.g_mobiledata, "Iniciar sesión con Google"),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _botonLogin(BuildContext context, IconData icono, String texto) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: ElevatedButton.icon(
      icon: Icon(icono, color: Colors.black),
      label: Text(
        texto,
        style: const TextStyle(color: Colors.black),
      ),
      onPressed: () {
        print("Presionado: $texto");
        // Aquí podés integrar la lógica de autenticación real
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size.fromHeight(50),
        elevation: 0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
  );
}
