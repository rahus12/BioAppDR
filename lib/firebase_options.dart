// File generated manually for Firebase configuration.
// TODO: Replace ALL placeholder values below with your actual Firebase config values.
//
// You can find these in the Firebase Console:
//   1. Go to https://console.firebase.google.com
//   2. Select your project
//   3. Click the gear icon (⚙️) → Project settings
//   4. Under "Your apps", find the config for each platform
//
// For Android: Register an Android app with package name "com.example.bioappdr"
//   and download google-services.json to android/app/
// For iOS: Register an iOS app with bundle ID "com.example.bioappdr"
//   and download GoogleService-Info.plist to ios/Runner/

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ========================================================================
  // TODO: Replace these placeholder values with your actual Firebase config.
  // You shared:
  //   apiKey, authDomain, projectId, storageBucket,
  //   messagingSenderId, appId, measurementId
  //
  // For Android/iOS appId: you need the platform-specific App ID from
  // Firebase Console → Project Settings → Your apps → each platform's config
  // ========================================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCxVL6EL_aHonRwn4O3qiFu_mwRImVyxtE",
    authDomain: "fih-bilingual-science.firebaseapp.com",
    projectId: "fih-bilingual-science",
    storageBucket: "fih-bilingual-science.firebasestorage.app",
    messagingSenderId: "721841305201",
    appId: "1:721841305201:web:35862093e50d183550cdd0",
    measurementId: "G-8LMEQGJRQ4"
  );

  // For Android: use the SAME apiKey, messagingSenderId, projectId
  // but use the ANDROID-specific appId from Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCxVL6EL_aHonRwn4O3qiFu_mwRImVyxtE",
    appId: "1:721841305201:web:35862093e50d183550cdd0",
    messagingSenderId: "721841305201",
    projectId: "fih-bilingual-science",
    storageBucket: "fih-bilingual-science.firebasestorage.app",
  );

  // For iOS: use the SAME apiKey, messagingSenderId, projectId
  // but use the iOS-specific appId and iosBundleId
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCxVL6EL_aHonRwn4O3qiFu_mwRImVyxtE",
    appId: "1:721841305201:web:35862093e50d183550cdd0",
    messagingSenderId: "721841305201",
    projectId: "fih-bilingual-science",
    storageBucket: "fih-bilingual-science.firebasestorage.app",
    iosBundleId: "com.example.bioappdr",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyCxVL6EL_aHonRwn4O3qiFu_mwRImVyxtE",
    appId: "1:721841305201:web:35862093e50d183550cdd0",
    messagingSenderId: "721841305201",
    projectId: "fih-bilingual-science",
    storageBucket: "fih-bilingual-science.firebasestorage.app",
    iosBundleId: "com.example.bioappdr",
  );
}
