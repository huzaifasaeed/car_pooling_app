import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen/findaRide.dart';
import 'HomeScreen/homeScreen.dart';
import 'Profile/profile.dart';
import 'auth/otpHome.dart';
import 'auth/otpPage.dart';
import 'auth/registerUser.dart';
import 'sharedPreferences/sharedPreferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  var userName = MySharedPreferences.instance.setStringValue("userName", '');
  runApp(MyApp(screen: (userName == '') ? OtpHome() : HomeScreen()));
}

class MyApp extends StatelessWidget {
  final Widget? screen;
  MyApp({this.screen});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Share MyRide',
      //test phase
      home: screen,
      routes: {
        '/otphome': (context) => OtpHome(),
        '/otppage': (context) => OtpPage(),
        '/homescreen': (context) => HomeScreen(),
        '/register': (context) => SignUp(),
        '/profile': (context) => ProfilePage(),
        '/findaride': (context) => FindaRide(),
      },
    );
  }
}
