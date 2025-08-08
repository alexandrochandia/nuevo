import 'package:flutter/material.dart';

class CustomShimmerFillText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color shimmerColor;
  final Duration duration;

  const CustomShimmerFillText({
    Key? key,
    required this.text,
    this.style,
    required this.shimmerColor,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<CustomShimmerFillText> createState() => _CustomShimmerFillTextState();
}

class _CustomShimmerFillTextState extends State<CustomShimmerFillText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(-0.5 + _animation.value, 0.0),
              colors: [
                widget.style?.color ?? Colors.white,
                widget.shimmerColor,
                widget.style?.color ?? Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style?.copyWith(
              color: Colors.white,
            ) ?? const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}