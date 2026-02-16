import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static const bool enableFirebase = true;

  static Future<void> initialize() async {
    if (!enableFirebase) return;
    if (kIsWeb) {
      await Firebase.initializeApp(options: _webOptions);
    } else {
      await Firebase.initializeApp();
    }
  }

  static const FirebaseOptions _webOptions = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );
}
