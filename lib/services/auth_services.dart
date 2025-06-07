import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:tugas_besar_mobile2/providers/user_provider.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  signInWithGoogle(BuildContext context) async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null; // User cancel

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final result = await _firebaseAuth.signInWithCredential(credential);

  // Set data ke provider setelah berhasil login
  final displayName = result.user?.displayName ?? 'Mahasiswa';
  Provider.of<UserProvider>(context, listen: false).setUsername(displayName);

  // Navigasi ke Home setelah berhasil login
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );

  return result;
}
}