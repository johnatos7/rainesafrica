import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for the Raines Africa app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAp8v4_h-wPFf16ztiB_QowFF4jR81vCYA',
    appId: '1:468162941654:android:c1e2c37b79038b5c596f77',
    messagingSenderId: '468162941654',
    projectId: 'raines-africa-eb63a',
    storageBucket: 'raines-africa-eb63a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMv5_g6Zv8bHofnGi3IDH9VU2-Fan6TKc',
    appId: '1:468162941654:ios:5837bb4a653e42dd596f77',
    messagingSenderId: '468162941654',
    projectId: 'raines-africa-eb63a',
    storageBucket: 'raines-africa-eb63a.firebasestorage.app',
    iosBundleId: 'africa.raines',
  );
}
