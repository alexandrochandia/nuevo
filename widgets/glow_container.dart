import 'package:flutter/material.dart';

class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final BorderRadius? borderRadius;
  final double glowRadius;
  final double spreadRadius;

  const GlowContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.borderRadius,
    this.glowRadius = 10.0,
    this.spreadRadius = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: glowRadius,
            spreadRadius: spreadRadius,
          ),
          BoxShadow(
            color: glowColor.withOpacity(0.1),
            blurRadius: glowRadius * 2,
            spreadRadius: spreadRadius * 2,
          ),
        ],
      ),
      child: child,
    );
  }
}