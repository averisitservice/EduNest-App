import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBREQeNFvEeqHL_j9x-75-EOQvX_e7hS3o',
    appId: '1:83267417494:web:70ea57eca8163c9b1f19b7',
    messagingSenderId: '83267417494',
    projectId: 'edunest-29546',
    authDomain: 'edunest-29546.firebaseapp.com',
    storageBucket: 'edunest-29546.firebasestorage.app',
    measurementId: 'G-S5YW9MY3FX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZ6gphWLU1W4hDTxTMp55lzZDK8hCCsTg',
    appId: '1:83267417494:android:6046f9bec4880b2d1f19b7',
    messagingSenderId: '83267417494',
    projectId: 'edunest-29546',
    storageBucket: 'edunest-29546.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAoZtoP4XNMk8jt16JeRa7VhkuyCu0iWc',
    appId: '1:83267417494:ios:69e3e94c70b648b91f19b7',
    messagingSenderId: '83267417494',
    projectId: 'edunest-29546',
    storageBucket: 'edunest-29546.firebasestorage.app',
    iosBundleId: 'com.example.edunest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDAoZtoP4XNMk8jt16JeRa7VhkuyCu0iWc',
    appId: '1:83267417494:ios:69e3e94c70b648b91f19b7',
    messagingSenderId: '83267417494',
    projectId: 'edunest-29546',
    storageBucket: 'edunest-29546.firebasestorage.app',
    iosBundleId: 'com.example.edunest',
  );
}
