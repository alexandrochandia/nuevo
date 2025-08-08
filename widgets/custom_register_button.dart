
import 'package:flutter/material.dart';

class CustomRegisterButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool showGlow;

  const CustomRegisterButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = false,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: showGlow && isEnabled ? [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled 
              ? const Color(0xFFD4AF37)  // Dorado brillante cuando activo
              : const Color(0xFF404040), // Gris oscuro cuando inactivo
          disabledBackgroundColor: const Color(0xFF404040),
          foregroundColor: isEnabled ? Colors.black : Colors.grey[600],
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
