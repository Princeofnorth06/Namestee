//import 'package:flutter/cupertino.dart';
//import 'package:animate_do/animate_do.dart';
import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hiichat/api/api.dart';
import 'package:hiichat/helper/dialogs.dart';
import 'package:hiichat/main.dart';
//import 'package:hiichat/main.dart';
import 'package:hiichat/screens/home_screen.dart';
//import 'package:hiichat/screens/home_screen.dart';

//import 'package:flutter/widgets.dart';\

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser${user.user}');
        log('\nUserAdditionalInfo${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle :$e');
      Dialogs.showSnackbar(context,
          'Something went wrong!\n (Plz Check Your Internet Connection)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Namastee!',
        ),
      ),
      body: Spin(
        child: Stack(
          children: [
            Positioned(
              child: Image.asset('images/smartphone.png'),
              top: mq.height * 0.15,
              width: mq.width * 0.5,
              left: mq.width * 0.25,
            ),
            Positioned(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 251, 172, 62),
                    shape: StadiumBorder()),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.asset('images/google.png'),
                ),
                label: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(text: "SignIn with "),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18))
                      ]),
                ),
              ),
              bottom: mq.height * 0.15,
              width: mq.width * 0.6,
              left: mq.width * 0.2,
              height: mq.height * .07,
            )
          ],
        ),
      ),
    );
  }
}
