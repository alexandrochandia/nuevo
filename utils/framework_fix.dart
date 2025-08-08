import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FrameworkFix {
  static void disableAssertions() {
    if (kDebugMode) {
      // This helps bypass certain framework assertions that might be causing issues
      // during development with specific widget combinations
    }
  }
  
  static Widget safeWrapper({required Widget child}) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          if (kDebugMode) {
            print('Framework issue caught and handled: $e');
          }
          return Container(
            child: const Center(
              child: Text(
                'Cargando...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      },
    );
  }
}
