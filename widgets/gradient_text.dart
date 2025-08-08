import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final List<double>? stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientText({
    Key? key,
    required this.text,
    this.style,
    required this.colors,
    this.stops,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: style?.copyWith(
          color: Colors.white,
        ) ?? const TextStyle(color: Colors.white),
      ),
    );
  }
}

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientText({
    Key? key,
    required this.text,
    this.style,
    required this.colors,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _animation.value, 0.0),
              end: Alignment(1.0 + 2.0 * _animation.value, 0.0),
              colors: widget.colors,
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