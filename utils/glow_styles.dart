import 'package:flutter/material.dart';

class GlowStyles {
  // Color azul neón principal
  static const Color neonBlue = Color(0xFF00D4FF);
  
  // Efectos glow muy finos y sutiles
  static List<BoxShadow> thinGlow([double intensity = 1.0]) {
    return [
      BoxShadow(
        color: neonBlue.withOpacity(intensity * 0.05),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> extraThinGlow([double intensity = 1.0]) {
    return [
      BoxShadow(
        color: neonBlue.withOpacity(intensity * 0.03),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ];
  }

  // Bordes finos
  static Border thinBorder([double opacity = 0.2]) {
    return Border.all(
      color: neonBlue.withOpacity(opacity),
      width: 0.5,
    );
  }

  static Border extraThinBorder([double opacity = 0.15]) {
    return Border.all(
      color: neonBlue.withOpacity(opacity),
      width: 0.3,
    );
  }

  // Estilos de texto negro y grueso
  static const TextStyle boldWhiteText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle boldNeonText = TextStyle(
    color: neonBlue,
    fontWeight: FontWeight.w900,
  );

  static TextStyle boldSecondaryText = TextStyle(
    color: Colors.white.withOpacity(0.7),
    fontWeight: FontWeight.w700,
  );

  // Sombras de texto muy sutiles
  static List<Shadow> subtleTextShadow([double opacity = 0.1]) {
    return [
      Shadow(
        color: neonBlue.withOpacity(opacity),
        blurRadius: 1,
      ),
    ];
  }
}