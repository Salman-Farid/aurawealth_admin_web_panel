
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCh_gTalQ7Qv7KkS0N0SilKVHXcH7BRM5w',
    appId: '1:817794235254:web:7aa4d8cf5317fc05601857',
    messagingSenderId: '817794235254',
    projectId: 'aurawealth-c1e5e',
    authDomain: 'aurawealth-c1e5e.firebaseapp.com',
    storageBucket: 'aurawealth-c1e5e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCh_gTalQ7Qv7KkS0N0SilKVHXcH7BRM5w',
    appId: '1:817794235254:android:7aa4d8cf5317fc05601857',
    messagingSenderId: '817794235254',
    projectId: 'aurawealth-c1e5e',
    storageBucket: 'aurawealth-c1e5e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCh_gTalQ7Qv7KkS0N0SilKVHXcH7BRM5w',
    appId: '1:817794235254:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '817794235254',
    projectId: 'aurawealth-c1e5e',
    storageBucket: 'aurawealth-c1e5e.firebasestorage.app',
    iosBundleId: 'com.example.aurawealth',
  );
}
