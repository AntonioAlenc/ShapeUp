// lib/firebase_options.dart
// Arquivo equivalente ao gerado pelo FlutterFire (Android configurado).

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions não foi configurado para Web. '
        'Rode `flutterfire configure` para adicionar Web, ou use apenas Android.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foi configurado para esta plataforma. '
          'Rode `flutterfire configure` e inclua a(s) plataforma(s) desejada(s).',
        );
      default:
        throw UnsupportedError(
          'Plataforma não suportada pelo DefaultFirebaseOptions.',
        );
    }
  }

  // ---- Android ----
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqNNmYIixAwVSvmX44n1o9HIOYMHA-d90',
    appId: '1:86259693753:android:6c3ef3d90c51e11ecac368',
    messagingSenderId: '86259693753',
    projectId: 'shapeup-dev',
    storageBucket: 'shapeup-dev.firebasestorage.app',
  );
}
