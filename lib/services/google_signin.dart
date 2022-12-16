import 'package:autoversa/screens/auth_screens/signup_via_gmail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin(context) async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;
      print("jhjhj");
      print(_user);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignupViaGmail(
                    name: _user!.displayName.toString(),
                    email: _user!.email.toString(),
                  )));
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future logout(context) async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
