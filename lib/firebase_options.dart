// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyDJZrCOlk_urWnJ6OUkZZ61O2KgMVc5R58',
    appId: '1:1023973905794:web:56eae4795ff51fde5cab9b',
    messagingSenderId: '1023973905794',
    projectId: 'olx-clone-2c457',
    authDomain: 'olx-clone-2c457.firebaseapp.com',
    storageBucket: 'olx-clone-2c457.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCVezfn8cgTN8AMqqUuDJJ2HAml7KAYQ_o',
    appId: '1:1023973905794:android:12a9ead98b8c0bbc5cab9b',
    messagingSenderId: '1023973905794',
    projectId: 'olx-clone-2c457',
    storageBucket: 'olx-clone-2c457.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACn1_RBEIpXPN8cvIoUtKNcdOUNWJzed0',
    appId: '1:1023973905794:ios:400fa78a6258d3705cab9b',
    messagingSenderId: '1023973905794',
    projectId: 'olx-clone-2c457',
    storageBucket: 'olx-clone-2c457.appspot.com',
    iosBundleId: 'com.example.tabeebyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACn1_RBEIpXPN8cvIoUtKNcdOUNWJzed0',
    appId: '1:1023973905794:ios:3dfa12eaec0a19ea5cab9b',
    messagingSenderId: '1023973905794',
    projectId: 'olx-clone-2c457',
    storageBucket: 'olx-clone-2c457.appspot.com',
    iosBundleId: 'com.example.tabeebyApp.RunnerTests',
  );
}