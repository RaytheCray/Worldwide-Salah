import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WorldwideSalahApp());
}

class WorldwideSalahApp extends StatelessWidget {
  const WorldwideSalahApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worldwide Salah',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'SF Pro',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}