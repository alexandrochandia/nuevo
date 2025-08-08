import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

/// Manejador global de errores para la aplicación Flutter
class ErrorHandler {
  
  /// Inicializa el manejador de errores global
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack, details.context);
    };

    // Manejo de errores en la plataforma
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack, 'Platform Error');
      return true;
    };
  }

  /// Log personalizado de errores
  static void _logError(dynamic error, StackTrace? stackTrace, dynamic context) {
    debugPrint('=== ERROR LOG ===');
    debugPrint('Context: $context');
    debugPrint('Error: $error');
    debugPrint('Stack Trace: $stackTrace');
    debugPrint('================');
  }

  /// Muestra un SnackBar de error
  static void showErrorSnackBar(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor ?? Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.red[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  static void showSuccessSnackBar(
    BuildContext context, 
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Muestra un diálogo de error detallado
  static void showErrorDialog(
    BuildContext context, 
    String title, 
    String message, {
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// Maneja errores de conexión de red
  static void handleNetworkError(BuildContext context, dynamic error) {
    String message = 'Error de conexión. Verifica tu internet.';
    
    if (error.toString().contains('timeout')) {
      message = 'Tiempo de espera agotado. Inténtalo de nuevo.';
    } else if (error.toString().contains('host')) {
      message = 'No se puede conectar al servidor.';
    }
    
    showErrorSnackBar(context, message);
  }

  /// Maneja errores de validación
  static void handleValidationError(BuildContext context, String field) {
    showErrorSnackBar(
      context, 
      'Por favor, completa el campo: $field',
      backgroundColor: Colors.orange[700],
    );
  }

  /// Maneja errores de permisos
  static void handlePermissionError(BuildContext context, String permission) {
    showErrorDialog(
      context,
      'Permisos Requeridos',
      'Esta función requiere permisos de $permission. Por favor, ve a Configuración y habilítalos.',
      buttonText: 'Entendido',
    );
  }

  /// Widget para mostrar estado de error
  static Widget errorStateWidget({
    required String message,
    String? title,
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.red,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Widget para mostrar estado de carga con timeout
  static Widget loadingStateWidget({
    String message = 'Cargando...',
    Duration timeout = const Duration(seconds: 30),
    VoidCallback? onTimeout,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar estado vacío
  static Widget emptyStateWidget({
    required String message,
    String? title,
    VoidCallback? onAction,
    String actionText = 'Agregar',
    IconData icon = Icons.inbox_outlined,
    Color iconColor = Colors.grey,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Maneja errores async de manera segura
  static Future<T?> safeAsyncCall<T>(
    Future<T> Function() asyncFunction, {
    String? errorMessage,
    T? defaultValue,
    Function(dynamic error)? onError,
  }) async {
    try {
      return await asyncFunction();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, 'SafeAsyncCall');
      onError?.call(error);
      return defaultValue;
    }
  }

  /// Wrapper para widgets que pueden fallar
  static Widget safeWidget({
    required Widget Function() builder,
    Widget? fallback,
    String? errorMessage,
  }) {
    try {
      return builder();
    } catch (error, stackTrace) {
      _logError(error, stackTrace, 'SafeWidget');
      return fallback ?? 
        errorStateWidget(
          message: errorMessage ?? 'Error al cargar este elemento',
          title: 'Ups!',
        );
    }
  }

  /// Maneja errores de formulario
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Maneja errores de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Maneja errores de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }
}

/// Extension para manejo de errores en widgets
extension ErrorHandling on Widget {
  /// Envuelve el widget con manejo de errores
  Widget withErrorHandling({
    Widget? fallback,
    String? errorMessage,
  }) {
    return ErrorHandler.safeWidget(
      builder: () => this,
      fallback: fallback,
      errorMessage: errorMessage,
    );
  }
}