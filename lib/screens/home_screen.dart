import 'package:flutter/material.dart';
import 'dart:async';
import 'today_tab.dart';
import 'monthly_tab.dart';
import 'mosques_tab.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  String _location = 'New York, NY';
  final double _latitude = 40.7128;
  final double _longitude = -74.0060;
  String _calculationMethod = 'ISNA';
  String _asrMethod = 'Standard';
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedTab == 0
          ? TodayTab(
              location: _location,
              currentTime: _currentTime,
              onSettingsTap: () => _showSettings(),
              onQiblaTap: () => _showQibla(),
            )
          : _selectedTab == 1
              ? const MonthlyTab()
              : MosquesTab(location: _location),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.access_time, 'Today'),
              _buildNavItem(1, Icons.calendar_today, 'Monthly'),
              _buildNavItem(2, Icons.location_on, 'Mosques'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          location: _location,
          calculationMethod: _calculationMethod,
          asrMethod: _asrMethod,
          onLocationChanged: (val) => setState(() => _location = val),
          onCalculationMethodChanged: (val) =>
              setState(() => _calculationMethod = val),
          onAsrMethodChanged: (val) => setState(() => _asrMethod = val),
        ),
      ),
    );
  }

  void _showQibla() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QiblaScreen(
          location: _location,
          userLatitude: _latitude,
          userLongitude: _longitude,
        ),
      ),
    );
  }
}