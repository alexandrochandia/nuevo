
import 'package:flutter/material.dart';

/// 🌟 Widget de borde con efecto de resplandor
/// Proporciona un efecto visual elegante para elementos seleccionados

class GlowBorder extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double borderWidth;
  final bool isGlowing;
  final BorderRadius? borderRadius;

  const GlowBorder({
    super.key,
    required this.child,
    this.glowColor = Colors.amber,
    this.glowRadius = 20.0,
    this.borderWidth = 2.0,
    this.isGlowing = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: isGlowing 
          ? Border.all(color: glowColor, width: borderWidth)
          : null,
        boxShadow: isGlowing ? [
          BoxShadow(
            color: glowColor.withOpacity(0.6),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: glowRadius * 1.5,
            spreadRadius: 4,
          ),
        ] : null,
      ),
      child: child,
    );
  }
}

/// 🎨 Widget de contenedor con efecto de resplandor animado
class AnimatedGlowBorder extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final bool isSelected;
  final Duration animationDuration;

  const AnimatedGlowBorder({
    super.key,
    required this.child,
    this.glowColor = Colors.amber,
    this.glowRadius = 15.0,
    this.isSelected = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedGlowBorder> createState() => _AnimatedGlowBorderState();
}

class _AnimatedGlowBorderState extends State<AnimatedGlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedGlowBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.8 * _animation.value),
                blurRadius: widget.glowRadius * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
