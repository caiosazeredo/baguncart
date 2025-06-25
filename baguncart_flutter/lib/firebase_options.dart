import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAerSAfXfd4IzUKHGPc5odXn1EnrbmJgI',
    appId: '1:587878214908:web:0777c106114999ed64fb79',
    messagingSenderId: '587878214908',
    projectId: 'baguncart-fdc3e',
    authDomain: 'baguncart-fdc3e.firebaseapp.com',
    databaseURL: 'https://baguncart-fdc3e-default-rtdb.firebaseio.com',
    storageBucket: 'baguncart-fdc3e.firebasestorage.app',
    measurementId: 'G-DKSWWT3C9J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAerSAfXfd4IzUKHGPc5odXn1EnrbmJgI',
    appId: '1:587878214908:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '587878214908',
    projectId: 'baguncart-fdc3e',
    databaseURL: 'https://baguncart-fdc3e-default-rtdb.firebaseio.com',
    storageBucket: 'baguncart-fdc3e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAerSAfXfd4IzUKHGPc5odXn1EnrbmJgI',
    appId: '1:587878214908:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '587878214908',
    projectId: 'baguncart-fdc3e',
    databaseURL: 'https://baguncart-fdc3e-default-rtdb.firebaseio.com',
    storageBucket: 'baguncart-fdc3e.firebasestorage.app',
    iosBundleId: 'com.example.baguncartFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAerSAfXfd4IzUKHGPc5odXn1EnrbmJgI',
    appId: '1:587878214908:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '587878214908',
    projectId: 'baguncart-fdc3e',
    databaseURL: 'https://baguncart-fdc3e-default-rtdb.firebaseio.com',
    storageBucket: 'baguncart-fdc3e.firebasestorage.app',
    iosBundleId: 'com.example.baguncartFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAerSAfXfd4IzUKHGPc5odXn1EnrbmJgI',
    appId: '1:587878214908:web:0777c106114999ed64fb79',
    messagingSenderId: '587878214908',
    projectId: 'baguncart-fdc3e',
    authDomain: 'baguncart-fdc3e.firebaseapp.com',
    databaseURL: 'https://baguncart-fdc3e-default-rtdb.firebaseio.com',
    storageBucket: 'baguncart-fdc3e.firebasestorage.app',
    measurementId: 'G-DKSWWT3C9J',
  );
}