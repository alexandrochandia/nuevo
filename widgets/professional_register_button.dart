import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Botón de registro profesional con animaciones y estados avanzados
class ProfessionalRegisterButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final double height;
  final double? width;
  final Color primaryColor;
  final Color secondaryColor;
  final Color disabledColor;
  final Color textColor;
  final double borderRadius;
  final bool showGlow;
  final bool showRipple;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final Duration animationDuration;
  final String? loadingText;

  const ProfessionalRegisterButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.height = 56.0,
    this.width,
    this.primaryColor = const Color(0xFFD4AF37),
    this.secondaryColor = const Color(0xFFFFD700),
    this.disabledColor = const Color(0xFF404040),
    this.textColor = Colors.black,
    this.borderRadius = 28.0,
    this.showGlow = true,
    this.showRipple = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.loadingText,
  });

  @override
  State<ProfessionalRegisterButton> createState() => _ProfessionalRegisterButtonState();
}

class _ProfessionalRegisterButtonState extends State<ProfessionalRegisterButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late AnimationController _loadingController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _loadingAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    if (widget.showGlow && widget.isEnabled) {
      _glowController.repeat(reverse: true);
    }

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(ProfessionalRegisterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.showGlow && widget.isEnabled && !oldWidget.isEnabled) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _glowController.stop();
    }

    if (widget.isLoading && !oldWidget.isLoading) {
      _loadingController.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _loadingController.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  Color get _buttonColor {
    if (!widget.isEnabled || widget.isLoading) {
      return widget.disabledColor;
    }
    return widget.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.showGlow && widget.isEnabled && !widget.isLoading ? [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.4 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 4 * _glowAnimation.value,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.isEnabled && !widget.isLoading
                      ? LinearGradient(
                          colors: [_buttonColor, widget.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isEnabled && !widget.isLoading ? null : _buttonColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  splashColor: widget.showRipple 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  highlightColor: widget.showRipple 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  child: Container(
                    padding: widget.padding,
                    child: _buildButtonContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: LoadingSpinnerPainter(
                    progress: _loadingAnimation.value,
                    color: widget.textColor,
                  ),
                );
              },
            ),
          ),
          if (widget.loadingText != null) ...[
            const SizedBox(width: 12),
            Text(
              widget.loadingText!,
              style: widget.textStyle?.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ) ?? TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: widget.isEnabled ? widget.textColor : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
        
        Flexible(
          child: Text(
            widget.text,
            style: widget.textStyle?.copyWith(
              color: widget.isEnabled ? widget.textColor : Colors.grey[600],
            ) ?? TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: widget.isEnabled ? widget.textColor : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 12),
          Icon(
            widget.trailingIcon,
            color: widget.isEnabled ? widget.textColor : Colors.grey[600],
            size: 20,
          ),
        ],
      ],
    );
  }
}

/// Botón secundario con estilo outline
class SecondaryRegisterButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final IconData? icon;
  final double height;
  final Color borderColor;
  final Color textColor;
  final Color backgroundColor;
  final double borderWidth;
  final double borderRadius;

  const SecondaryRegisterButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.icon,
    this.height = 56.0,
    this.borderColor = const Color(0xFFD4AF37),
    this.textColor = const Color(0xFFD4AF37),
    this.backgroundColor = Colors.transparent,
    this.borderWidth = 2.0,
    this.borderRadius = 28.0,
  });

  @override
  State<SecondaryRegisterButton> createState() => _SecondaryRegisterButtonState();
}

class _SecondaryRegisterButtonState extends State<SecondaryRegisterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isEnabled ? widget.borderColor : Colors.grey[600]!,
                width: widget.borderWidth,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: widget.backgroundColor,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                onTap: widget.isEnabled ? widget.onPressed : null,
                onTapDown: (details) {
                  if (widget.isEnabled) _controller.forward();
                },
                onTapUp: (details) {
                  if (widget.isEnabled) _controller.reverse();
                },
                onTapCancel: () {
                  if (widget.isEnabled) _controller.reverse();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.isEnabled ? widget.textColor : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isEnabled ? widget.textColor : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter para el spinner de carga personalizado
class LoadingSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  LoadingSpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;
    
    // Dibujar círculo base
    paint.color = color.withOpacity(0.2);
    canvas.drawCircle(center, radius, paint);
    
    // Dibujar progreso
    paint.color = color;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * 0.75; // 75% del círculo
    final rotationAngle = progress * 2 * math.pi;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// Botón flotante con animaciones avanzadas
class FloatingRegisterButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final bool showPulse;

  const FloatingRegisterButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_forward,
    this.backgroundColor = const Color(0xFFD4AF37),
    this.iconColor = Colors.black,
    this.size = 60.0,
    this.showPulse = true,
  });

  @override
  State<FloatingRegisterButton> createState() => _FloatingRegisterButtonState();
}

class _FloatingRegisterButtonState extends State<FloatingRegisterButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(0.4 * _pulseAnimation.value),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                _bounceController.forward().then((_) {
                  _bounceController.reverse();
                });
                widget.onPressed?.call();
              },
              backgroundColor: widget.backgroundColor,
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.size * 0.4,
              ),
            ),
          ),
        );
      },
    );
  }
}