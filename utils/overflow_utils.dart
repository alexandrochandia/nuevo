import 'package:flutter/material.dart';

class OverflowUtils {
  // Método para calcular altura responsiva
  static double responsiveHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (height / 812.0) * screenHeight; // Base: iPhone X height
  }

  // Método para calcular ancho responsivo
  static double responsiveWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (width / 375.0) * screenWidth; // Base: iPhone X width
  }

  // Widget Row responsivo con breakpoints
  static Widget responsiveRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    int? maxItemsPerRow,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile: Stack vertical
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
        } else {
          // Tablet/Desktop: Row horizontal
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
        }
      },
    );
  }

  // Método para detectar si es pantalla pequeña
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Padding responsivo
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.all(16);
    } else if (width < 1024) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Font size responsivo
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375.0; // Base: iPhone X width
    scaleFactor = scaleFactor.clamp(0.8, 1.5); // Limitar escala
    return baseFontSize * scaleFactor;
  }

  // Obtener ancho de pantalla
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Obtener altura de pantalla
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Widget que maneja automáticamente el overflow en texto
  static Widget responsiveText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

  /// Widget que crea un Row responsive que se convierte en Column en pantallas pequeñas
  static Widget responsiveRow2({
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    double breakpoint = 600.0,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );
        } else {
          return Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );
        }
      },
    );
  }

  /// Widget que crea un texto responsive basado en el tamaño de pantalla
  static Widget adaptiveText(
    String text, {
    required double minFontSize,
    required double maxFontSize,
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = (constraints.maxWidth / 20).clamp(minFontSize, maxFontSize);
        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        );
      },
    );
  }

  /// Widget que crea un GridView responsivo
  static Widget responsiveGrid({
    required List<Widget> children,
    double minItemWidth = 150.0,
    double spacing = 8.0,
    double aspectRatio = 1.0,
    ScrollPhysics? physics,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / minItemWidth).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;
        if (crossAxisCount > 4) crossAxisCount = 4;

        return GridView.builder(
          physics: physics ?? const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  /// Widget que maneja padding responsivo
  static EdgeInsets responsivePadding2(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return const EdgeInsets.all(12);
    } else if (screenWidth < 800) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Widget que crea un Container con tamaño máximo para prevenir overflow
  static Widget constrainedContainer({
    required Widget child,
    double? maxWidth,
    double? maxHeight,
    EdgeInsets? padding,
    BoxDecoration? decoration,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  /// Widget que maneja Flexible con overflow
  static Widget safeFlexible({
    required Widget child,
    int flex = 1,
    FlexFit fit = FlexFit.loose,
  }) {
    return Flexible(
      flex: flex,
      fit: fit,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 0),
        child: child,
      ),
    );
  }

  /// Widget que maneja Expanded con overflow
  static Widget safeExpanded({
    required Widget child,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 0),
        child: child,
      ),
    );
  }

  /// Crea un SingleChildScrollView que maneja overflow horizontal
  static Widget horizontalScrollView({
    required Widget child,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics ?? const ClampingScrollPhysics(),
      padding: padding,
      child: child,
    );
  }

  /// Crea un ListView responsive con separadores
  static Widget responsiveListView({
    required List<Widget> children,
    EdgeInsets? padding,
    double separatorHeight = 8.0,
    ScrollPhysics? physics,
  }) {
    return ListView.separated(
      physics: physics ?? const ClampingScrollPhysics(),
      padding: padding,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: separatorHeight),
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Crea un Wrap responsivo
  static Widget responsiveWrap({
    required List<Widget> children,
    double spacing = 8.0,
    double runSpacing = 8.0,
    WrapAlignment alignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Maneja imágenes que podrían causar overflow
  static Widget safeNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width ?? double.infinity,
          maxHeight: height ?? double.infinity,
        ),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? 
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? 
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              );
          },
        ),
      ),
    );
  }

  /// Crea un Card responsive
  static Widget responsiveCard({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? elevation,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          margin: margin ?? EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 16 : 8,
            vertical: 8,
          ),
          elevation: elevation,
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(
              constraints.maxWidth > 600 ? 16 : 12,
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Maneja AppBar responsive
  static PreferredSizeWidget responsiveAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
  }) {
    return AppBar(
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Text(
            title,
            style: TextStyle(
              fontSize: constraints.maxWidth > 600 ? 20 : 18,
            ),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
    );
  }

  /// Widget para manejar bottom navigation responsive
  static Widget responsiveBottomNav({
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BottomNavigationBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          type: constraints.maxWidth > 400 
            ? BottomNavigationBarType.fixed 
            : BottomNavigationBarType.shifting,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          selectedFontSize: constraints.maxWidth > 400 ? 12 : 10,
          unselectedFontSize: constraints.maxWidth > 400 ? 10 : 8,
        );
      },
    );
  }

  /// Crea un FormField con manejo de overflow
  static Widget responsiveFormField({
    required String label,
    required String hintText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: constraints.maxWidth > 400 ? 16 : 14,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                constraints.maxWidth > 400 ? 12 : 8
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 400 ? 16 : 12,
              vertical: constraints.maxWidth > 400 ? 16 : 12,
            ),
          ),
        );
      },
    );
  }

  /// Obtiene el tamaño de fuente responsive
  static double getResponsiveFontSize2(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseFontSize * 0.85;
    } else if (screenWidth < 400) {
      return baseFontSize * 0.9;
    } else if (screenWidth > 800) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }

  /// Obtiene espaciado responsive
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSpacing * 0.75;
    } else if (screenWidth < 400) {
      return baseSpacing * 0.85;
    } else if (screenWidth > 800) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }
}

/// Extension para facilitar el uso de overflow utilities
extension OverflowExtensions on Widget {
  /// Envuelve el widget en un Container con constraints para prevenir overflow
  Widget preventOverflow({double? maxWidth, double? maxHeight}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }

  /// Envuelve el widget en un Flexible con overflow protection
  Widget flexibleSafe({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return OverflowUtils.safeFlexible(
      flex: flex,
      fit: fit,
      child: this,
    );
  }

  /// Envuelve el widget en un Expanded con overflow protection
  Widget expandedSafe({int flex = 1}) {
    return OverflowUtils.safeExpanded(
      flex: flex,
      child: this,
    );
  }

  /// Envuelve el widget en un SingleChildScrollView horizontal
  Widget scrollableHorizontal({EdgeInsets? padding}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: padding,
      child: this,
    );
  }
}