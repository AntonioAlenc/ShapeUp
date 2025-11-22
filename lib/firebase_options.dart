

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqNNmYIixAwVSvmX44n1o9HIOYMHA-d90',
    appId: '1:86259693753:android:6c3ef3d90c51e11ecac368',
    messagingSenderId: '86259693753',
    projectId: 'shapeup-dev',
    storageBucket: 'shapeup-dev.firebasestorage.app',
  );

  // ---- Android ----

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDIWGu8dl4utzg86TF0FnoegGnVRt2xwh8',
    appId: '1:86259693753:web:d7e16405df059fc4cac368',
    messagingSenderId: '86259693753',
    projectId: 'shapeup-dev',
    authDomain: 'shapeup-dev.firebaseapp.com',
    storageBucket: 'shapeup-dev.firebasestorage.app',
    measurementId: 'G-1X6F4Q27K6',
  );

}