import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Indicador de progreso profesional y elegante para el registro
class ProfessionalProgressIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final double progress; // 0.0 a 1.0
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final double size;
  final bool showStepNumbers;
  final bool animated;
  final Duration animationDuration;
  final List<String>? stepLabels;

  const ProfessionalProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
    this.primaryColor = const Color(0xFFD4AF37),
    this.secondaryColor = const Color(0xFFFFD700),
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.size = 120.0,
    this.showStepNumbers = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.stepLabels,
  });

  @override
  State<ProfessionalProgressIndicator> createState() => _ProfessionalProgressIndicatorState();
}

class _ProfessionalProgressIndicatorState extends State<ProfessionalProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));
  }

  void _startAnimations() {
    if (widget.animated) {
      _progressController.forward();
      _pulseController.repeat(reverse: true);
      _sparkleController.repeat();
    }
  }

  @override
  void didUpdateWidget(ProfessionalProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _progressAnimation,
          _pulseAnimation,
          _sparkleAnimation,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: ProfessionalProgressPainter(
              progress: _progressAnimation.value,
              currentStep: widget.currentStep,
              totalSteps: widget.totalSteps,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              backgroundColor: widget.backgroundColor,
              pulseValue: _pulseAnimation.value,
              sparkleValue: _sparkleAnimation.value,
              showStepNumbers: widget.showStepNumbers,
            ),
            child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showStepNumbers) ...[
                    Text(
                      '${widget.currentStep}',
                      style: TextStyle(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                    Text(
                      'de ${widget.totalSteps}',
                      style: TextStyle(
                        fontSize: widget.size * 0.08,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${(widget.progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.12,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                    Text(
                      'Completado',
                      style: TextStyle(
                        fontSize: widget.size * 0.07,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfessionalProgressPainter extends CustomPainter {
  final double progress;
  final int currentStep;
  final int totalSteps;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final double pulseValue;
  final double sparkleValue;
  final bool showStepNumbers;

  ProfessionalProgressPainter({
    required this.progress,
    required this.currentStep,
    required this.totalSteps,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.pulseValue,
    required this.sparkleValue,
    required this.showStepNumbers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    _drawBackground(canvas, center, radius);
    _drawProgress(canvas, center, radius);
    _drawGlow(canvas, center, radius);
    _drawSparkles(canvas, center, radius);
    if (showStepNumbers) {
      _drawStepIndicators(canvas, center, radius);
    }
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final backgroundPaint = Paint()
      ..color = backgroundColor.withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
  }

  void _drawProgress(Canvas canvas, Offset center, double radius) {
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  void _drawGlow(Canvas canvas, Offset center, double radius) {
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.3 * pulseValue)
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final rect = Rect.fromCircle(center: center, radius: radius);
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center, double radius) {
    if (progress > 0.5) {
      final sparklePaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi * 2 / 8) + (sparkleValue * math.pi * 2);
        final sparkleRadius = radius + 15;
        final sparklePosition = Offset(
          center.dx + math.cos(angle) * sparkleRadius,
          center.dy + math.sin(angle) * sparkleRadius,
        );

        final sparkleSize = 2 + (3 * math.sin(sparkleValue * math.pi * 4 + i));
        if (sparkleSize > 0) {
          canvas.drawCircle(sparklePosition, sparkleSize, sparklePaint);
        }
      }
    }
  }

  void _drawStepIndicators(Canvas canvas, Offset center, double radius) {
    final stepPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalSteps; i++) {
      final angle = (i * 2 * math.pi / totalSteps) - (math.pi / 2);
      final stepPosition = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      if (i < currentStep) {
        stepPaint.color = primaryColor;
      } else if (i == currentStep - 1) {
        stepPaint.color = secondaryColor;
      } else {
        stepPaint.color = backgroundColor;
      }

      canvas.drawCircle(stepPosition, 6, stepPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// Indicador de progreso lineal profesional
class LinearProgressIndicator extends StatefulWidget {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final bool animated;

  const LinearProgressIndicator({
    super.key,
    required this.progress,
    this.primaryColor = const Color(0xFFD4AF37),
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.height = 8.0,
    this.borderRadius,
    this.showPercentage = false,
    this.animated = true,
  });

  @override
  State<LinearProgressIndicator> createState() => _LinearProgressIndicatorState();
}

class _LinearProgressIndicatorState extends State<LinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.primaryColor, widget.primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showPercentage) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Widget de pasos con indicadores visuales
class StepIndicators extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final bool showLabels;
  final List<String>? labels;

  const StepIndicators({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = const Color(0xFFD4AF37),
    this.inactiveColor = const Color(0xFF404040),
    this.size = 12.0,
    this.showLabels = false,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? size * 1.5 : size,
                height: size,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(size / 2),
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
              ),
              if (showLabels && labels != null && index < labels!.length) ...[
                const SizedBox(height: 8),
                Text(
                  labels![index],
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? activeColor : inactiveColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}