import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for each supported platform.
///
/// !!! IMPORTANT !!!
/// -----------------
/// Ganti placeholder `YOUR_*` dengan nilai asli dari Firebase console
/// atau jalankan `flutterfire configure` agar file ini ter-generate otomatis.
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
        throw UnsupportedError('Firebase tidak dikonfigurasi untuk macOS.');
      case TargetPlatform.windows:
        throw UnsupportedError('Firebase tidak dikonfigurasi untuk Windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase tidak dikonfigurasi untuk Linux.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase tidak dikonfigurasi untuk Fuchsia.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzDcXl-xlDKY9OFrRpHVZUi4lACOFeWXM',
    appId: '1:825340640317:android:e4cfb78139a7616b04fe54',
    messagingSenderId: '825340640317',
    projectId: 'loginwith-bad4d',
    storageBucket: 'loginwith-bad4d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );
}
