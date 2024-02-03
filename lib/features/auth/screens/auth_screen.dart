import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  const AuthScreen({super.key});
  void _loginWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication gAuth = await account!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TextButton.icon(
            onPressed: _loginWithGoogle,
            icon: const Icon(Icons.arrow_back_ios_sharp),
            label: const Text(
              'Login with Google',
            ),
          ),
        ),
      ),
    );
  }
}
