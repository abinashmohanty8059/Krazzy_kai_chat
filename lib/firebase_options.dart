
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyD2mzsTsVJ1KG6eA6kpJ2QL6HPmikes7G0',
    appId: '1:345586298738:web:682123d1b6b2625e9e77eb',
    messagingSenderId: '345586298738',
    projectId: 'krazzy-kai',
    authDomain: 'krazzy-kai.firebaseapp.com',
    storageBucket: 'krazzy-kai.firebasestorage.app',
    measurementId: 'G-ESCCV9SK45',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDETLZZZraA-fE6dbqaTgCAM1qTBQ7DX5A',
    appId: '1:345586298738:android:120e799b2d011a879e77eb',
    messagingSenderId: '345586298738',
    projectId: 'krazzy-kai',
    storageBucket: 'krazzy-kai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDacY_PD3vpMKjvhDFEMZ4VYPo1SnibmEQ',
    appId: '1:345586298738:ios:40dfdcfdd0588cad9e77eb',
    messagingSenderId: '345586298738',
    projectId: 'krazzy-kai',
    storageBucket: 'krazzy-kai.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDacY_PD3vpMKjvhDFEMZ4VYPo1SnibmEQ',
    appId: '1:345586298738:ios:40dfdcfdd0588cad9e77eb',
    messagingSenderId: '345586298738',
    projectId: 'krazzy-kai',
    storageBucket: 'krazzy-kai.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );
}
