import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WorldwideSalahApp());
}

class WorldwideSalahApp extends StatelessWidget {
  const WorldwideSalahApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worldwide Salah',
      theme: AppTheme.lightTheme, // Using centralized theme
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 