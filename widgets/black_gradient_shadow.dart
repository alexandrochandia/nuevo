import 'package:flutter/material.dart';

class BlackGradientShadow extends StatelessWidget {
  final Widget child;
  final double opacity;
  final List<Color>? gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final double blurRadius;
  final Offset offset;

  const BlackGradientShadow({
    Key? key,
    required this.child,
    this.opacity = 0.5,
    this.gradientColors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.blurRadius = 8.0,
    this.offset = const Offset(0, 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(opacity),
            blurRadius: blurRadius,
            offset: offset,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: gradientColors ?? [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class AnimatedBlackGradientShadow extends StatefulWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  final bool animate;

  const AnimatedBlackGradientShadow({
    Key? key,
    required this.child,
    this.opacity = 0.5,
    this.duration = const Duration(seconds: 2),
    this.animate = true,
  }) : super(key: key);

  @override
  State<AnimatedBlackGradientShadow> createState() => _AnimatedBlackGradientShadowState();
}

class _AnimatedBlackGradientShadowState extends State<AnimatedBlackGradientShadow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat(reverse: true);
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
        return BlackGradientShadow(
          opacity: widget.opacity * (widget.animate ? _animation.value : 1.0),
          child: widget.child,
        );
      },
    );
  }
}

class GradientShadowContainer extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final double intensity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientShadowContainer({
    Key? key,
    required this.child,
    required this.primaryColor,
    this.intensity = 0.3,
    this.borderRadius,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(intensity),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.1),
              primaryColor.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}