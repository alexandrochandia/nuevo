import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase VMF Sweden inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar Firebase VMF Sweden: $e');
    }
  }
}