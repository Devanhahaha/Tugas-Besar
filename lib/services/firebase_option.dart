import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => android;

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsgvA1CF583ewFBaQTY9wJcxd7Czp3lfw',
    appId: '1:617712857594:android:0010fe07f018499494b443',
    messagingSenderId: '617712857594',
    projectId: 'mobile2-57dcf',
    storageBucket: 'mobile2-57dcf.firebasestorage.app',
  );
}
