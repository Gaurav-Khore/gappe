import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gappe/screens/home.dart';
import 'package:gappe/screens/map.dart';
import 'package:gappe/screens/msg.dart';
import 'package:gappe/screens/pro.dart';
import 'package:gappe/screens/reg.dart';
import 'package:gappe/screens/user.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget exp = SplashScreenView(
      colors: [
        Colors.green,
        Colors.white,
        Colors.deepOrange,
        Colors.deepOrange,
        Colors.white,
        Colors.green,
      ],
      imageSize: 250,
      imageSrc: 'images/chat1.png',
      text: "   GAPPE",
      textType: TextType.ColorizeAnimationText,
      textStyle: TextStyle(
        fontSize: 35.0,
        fontFamily: "PermanentMarker",
      ),
      home: Log(),
      duration: 6000,
      backgroundColor: Colors.black.withOpacity(0.5),
    );
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage("images/introbg.jpg"),
                fit: BoxFit.cover),
          ),
          child: exp),
      routes: {
        "log": (context) => Log(),
        "home": (context) => Home(),
        "adduser": (context) => AddUser(),
        "reg": (context) => Reg(),
        "msg": (context) => Msg(),
        "pro": (context) => Profile(),
        "map": (context) => MyMap(),
      },
    );
  }
}
