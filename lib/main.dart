import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TravelForumApp());
}

class TravelForumApp extends StatelessWidget {
  const TravelForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Forum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

