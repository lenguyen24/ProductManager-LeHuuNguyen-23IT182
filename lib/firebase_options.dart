// File generated for Firebase configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBCXuL2eQNPcHfAlOvNTK9NcP-RJcbEkw',
    appId: '1:826216045115:web:ee9f5343173b00f22d5a1e',
    messagingSenderId: '826216045115',
    projectId: 'express-backend-demo',
    authDomain: 'express-backend-demo.firebaseapp.com',
    storageBucket: 'express-backend-demo.firebasestorage.app',
    measurementId: 'G-8GJCJFN9SW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkBi7TgMwhGnbOMvn3qyPTthJv4lBT0cw',
    appId: '1:826216045115:android:853322f42981e8902d5a1e',
    messagingSenderId: '826216045115',
    projectId: 'express-backend-demo',
    storageBucket: 'express-backend-demo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkBi7TgMwhGnbOMvn3qyPTthJv4lBT0cw',
    appId: '1:826216045115:ios:default',
    messagingSenderId: '826216045115',
    projectId: 'express-backend-demo',
    storageBucket: 'express-backend-demo.firebasestorage.app',
  );

  static const FirebaseOptions macos = ios;
}
