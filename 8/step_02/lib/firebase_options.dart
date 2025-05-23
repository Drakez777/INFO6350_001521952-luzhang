// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBG_aQS-jjxUvAyqzRV-JHp99-2CieNCvU',
    appId: '1:919251165088:web:19511a3ac3d4f2cd068ec5',
    messagingSenderId: '919251165088',
    projectId: 'fir-flutter-codelab-c3f35',
    authDomain: 'fir-flutter-codelab-c3f35.firebaseapp.com',
    storageBucket: 'fir-flutter-codelab-c3f35.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBK-HSU3g6uaQakgXtgun2kT0bwploMZU',
    appId: '1:919251165088:android:c110a268bea84978068ec5',
    messagingSenderId: '919251165088',
    projectId: 'fir-flutter-codelab-c3f35',
    storageBucket: 'fir-flutter-codelab-c3f35.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQ-B7A07dNCeX7q1vv2YnMCKmsk4DDn9M',
    appId: '1:919251165088:ios:a5e26e57740eed59068ec5',
    messagingSenderId: '919251165088',
    projectId: 'fir-flutter-codelab-c3f35',
    storageBucket: 'fir-flutter-codelab-c3f35.firebasestorage.app',
    iosBundleId: 'com.example.gtkFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQ-B7A07dNCeX7q1vv2YnMCKmsk4DDn9M',
    appId: '1:919251165088:ios:a5e26e57740eed59068ec5',
    messagingSenderId: '919251165088',
    projectId: 'fir-flutter-codelab-c3f35',
    storageBucket: 'fir-flutter-codelab-c3f35.firebasestorage.app',
    iosBundleId: 'com.example.gtkFlutter',
  );
}
