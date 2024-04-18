import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/api/api.dart';
import 'package:hiichat/screens/auth/login_screen.dart';
import 'package:hiichat/screens/home_screen.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetoHome();
  }

  _navigatetoHome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {
      if (APIs.auth.currentUser != null) {
        log('\nUser:${APIs.auth.currentUser}');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZoomIn(
              child: SizedBox(
                child: getImageWidget(
                    'images/chat.png'), // Adjust the image path here
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            BounceInDown(
              child: const Text(
                '      Namaste\nFrom Namastee!',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
            ),
            BounceInUp(
                child: Text(
              '\t\t\t\t\t\t-Made By \n\t\tPRINCE DUBEY',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange),
            ))
          ],
        ),
      ),
    );
  }

  Widget getImageWidget(String imagePath) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        imagePath,
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      ),
    );
  }
}
