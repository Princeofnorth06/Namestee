import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hiichat/firebase_options.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

import 'package:hiichat/screens/splash_screen.dart';

//import 'package:hiichat/screens/home_screen.dart';
late Size mq;

Size getMediaQuerySize(BuildContext context) {
  return MediaQuery.of(context).size;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await _initializeFirebase();
  runApp(const MyApp());
}

// Variant: profile
// Config: debug
// Store: C:\Users\Lenovo\.android\debug.keystore
// Alias: AndroidDebugKey
// MD5: 1C:B0:67:10:60:65:AB:24:D2:34:85:62:9A:58:BE:40
// SHA1: 0F:93:CB:17:98:04:8E:B9:D4:9E:85:D1:B5:E6:89:A8:13:CA:86:C0
// SHA-256: C5:34:3F:BB:DA:1D:9C:EF:BC:76:10:6E:A4:3C:76:84:96:CF:15:FB:4D:E4:FD:57:59:20:E3:B8:D4:B8:8B:14
// Valid until: Sunday, 11 May 2053
// ----------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    mq = getMediaQuerySize(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namastee',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 243, 156, 6),
          ),
          useMaterial3: true,
        ),
        home: Splash());
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For showing channel notificaton',
    id: 'chat',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log("Notification channel result $result");
}
