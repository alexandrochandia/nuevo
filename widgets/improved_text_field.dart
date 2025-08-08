import 'package:flutter/material.dart';
import '../utils/overflow_utils.dart';

/// Widget de TextField mejorado con manejo de overflow y errores
class ImprovedTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;

  const ImprovedTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.textStyle,
    this.decoration,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
  });

  @override
  State<ImprovedTextField> createState() => _ImprovedTextFieldState();
}

class _ImprovedTextFieldState extends State<ImprovedTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    final focusNode = widget.focusNode ?? _focusNode;
    focusNode.addListener(() {
      setState(() {
        _isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final fontSize = isSmallScreen ? 14.0 : 16.0;
        final labelFontSize = isSmallScreen ? 12.0 : 14.0;
        final borderRadius = widget.borderRadius ?? (isSmallScreen ? 8.0 : 12.0);
        final contentPadding = widget.contentPadding ?? EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 12 : 16,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: _isFocused 
                    ? (widget.focusedBorderColor ?? Colors.blue)
                    : Colors.white70,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // TextField
            TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode ?? _focusNode,
              validator: widget.validator,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              textInputAction: widget.textInputAction,
              style: widget.textStyle ?? TextStyle(
                fontSize: fontSize,
                color: widget.enabled ? Colors.white : Colors.white38,
              ),
              decoration: widget.decoration ?? InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: fontSize * 0.9,
                  color: Colors.white38,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: widget.fillColor ?? Colors.white.withOpacity(0.1),
                
                // Border states
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.white24,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? Colors.white24,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(
                    color: widget.focusedBorderColor ?? Colors.blue,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                
                contentPadding: contentPadding,
                
                // Error handling
                errorStyle: TextStyle(
                  fontSize: labelFontSize * 0.9,
                  color: Colors.red[300],
                ),
                errorMaxLines: 2,
                
                // Counter style
                counterStyle: TextStyle(
                  fontSize: labelFontSize * 0.8,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget de TextField de búsqueda mejorado
class ImprovedSearchField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final Widget? prefixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;

  const ImprovedSearchField({
    super.key,
    this.hintText = 'Buscar...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.prefixIcon,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
  });

  @override
  State<ImprovedSearchField> createState() => _ImprovedSearchFieldState();
}

class _ImprovedSearchFieldState extends State<ImprovedSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final fontSize = isSmallScreen ? 14.0 : 16.0;
        final borderRadius = widget.borderRadius ?? (isSmallScreen ? 8.0 : 12.0);
        final contentPadding = widget.contentPadding ?? EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        );

        return TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: fontSize * 0.9,
              color: Colors.white38,
            ),
            prefixIcon: widget.prefixIcon ?? const Icon(
              Icons.search,
              color: Colors.white54,
            ),
            suffixIcon: _hasText
              ? IconButton(
                  onPressed: _clearText,
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white54,
                  ),
                  iconSize: isSmallScreen ? 18 : 20,
                )
              : null,
            filled: true,
            fillColor: widget.fillColor ?? Colors.white.withOpacity(0.1),
            
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.white24,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: widget.borderColor ?? Colors.white24,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
            
            contentPadding: contentPadding,
            isDense: true,
          ),
        );
      },
    );
  }
}

/// Widget de TextField para passwords con toggle de visibilidad
class ImprovedPasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;

  const ImprovedPasswordField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
  });

  @override
  State<ImprovedPasswordField> createState() => _ImprovedPasswordFieldState();
}

class _ImprovedPasswordFieldState extends State<ImprovedPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ImprovedTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      fillColor: widget.fillColor,
      borderColor: widget.borderColor,
      focusedBorderColor: widget.focusedBorderColor,
      borderRadius: widget.borderRadius,
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
      suffixIcon: IconButton(
        onPressed: _toggleVisibility,
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.white54,
        ),
      ),
    );
  }
}