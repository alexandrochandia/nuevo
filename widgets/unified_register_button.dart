
import 'package:flutter/material.dart';

class UnifiedRegisterButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback? onPressed;

  const UnifiedRegisterButton({
    Key? key,
    required this.text,
    required this.isActive,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFFFF8DC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
        border: isActive
            ? Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.7),
                width: 1.5,
              )
            : Border.all(
                color: Colors.grey[700]!,
                width: 1,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: isActive ? onPressed : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.grey[500],
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  shadows: isActive
                      ? [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
