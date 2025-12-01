import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  try {
    // permission_handler maps Permission.notification to the correct Android/iOS permission
    final status = await Permission.notification.status;
    if (status.isGranted) return; // already granted

    final result = await Permission.notification.request();
    if (result.isGranted) {
      debugPrint('Notification permission granted');
    } else {
      debugPrint('Notification permission denied: $result');
      // Optionally you can show UI explaining why the permission is useful
    }
  } catch (e) {
    // Defensive: if permission_handler isn't available or throws, don't crash the app
    debugPrint('Error requesting notification permission: $e');
  }
}

Future<void> main() async {
  debugPrint = (String? message, {int? wrapWidth}) {
    debugPrint('🔍 DEBUG: $message');
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Request notification permission as early as possible so plugins that post
  // notifications won't crash if they run during initialization.
  await requestNotificationPermission();

  runApp(const WorldwideSalahApp());
}

class WorldwideSalahApp extends StatelessWidget {
  const WorldwideSalahApp({super.key});

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
