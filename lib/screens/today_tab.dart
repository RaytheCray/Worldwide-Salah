// FIXED VERSION - lib/screens/today_tab.dart
// This file now properly passes location parameters to PrayerCalculator

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../utils/prayer_calculator.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({super.key});

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  List<PrayerTime>? _todayPrayers;
  PrayerTime? _nextPrayer;
  String _timeRemaining = '';
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentPosition != null) {
        _updateTimeRemaining();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      await _loadTodayPrayers();
      await _updateNextPrayer();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Location timeout');
        },
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodayPrayers() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ FIXED: Now passing required latitude and longitude
      final prayers = await PrayerCalculator.calculatePrayerTimes(
        DateTime.now(),
        latitude: _currentPosition!.latitude,   // ✅ ADDED
        longitude: _currentPosition!.longitude, // ✅ ADDED
        method: 'ISNA',
        asrMethod: 'standard',
      );

      setState(() {
        _todayPrayers = prayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNextPrayer() async {
    if (_currentPosition == null) return;

    try {
      // ✅ FIXED: Now passing required latitude and longitude
      final next = await PrayerCalculator.getNextPrayer(
        latitude: _currentPosition!.latitude,   // ✅ ADDED
        longitude: _currentPosition!.longitude, // ✅ ADDED
        method: 'ISNA',
        asrMethod: 'standard',
      );

      setState(() {
        _nextPrayer = next;
      });
    } catch (e) {
      debugPrint('Error updating next prayer: $e');
    }
  }

  Future<void> _updateTimeRemaining() async {
    if (_currentPosition == null) return;

    try {
      // ✅ FIXED: Now passing required latitude and longitude
      final remaining = await PrayerCalculator.getTimeUntilNextPrayer(
        latitude: _currentPosition!.latitude,   // ✅ ADDED
        longitude: _currentPosition!.longitude, // ✅ ADDED
        method: 'ISNA',
        asrMethod: 'standard',
      );

      if (mounted) {
        setState(() {
          _timeRemaining = remaining;
        });
      }
    } catch (e) {
      debugPrint('Error updating time remaining: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: _initializeData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_todayPrayers == null || _todayPrayers!.isEmpty) {
      return const Center(
        child: Text('No prayer times available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadTodayPrayers();
        await _updateNextPrayer();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Next Prayer Card
              if (_nextPrayer != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Next Prayer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _nextPrayer!.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _nextPrayer!.formattedTime,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_timeRemaining.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'In $_timeRemaining',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Today's Prayer Times
              const Text(
                "Today's Prayer Times",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Prayer Times List
              ..._todayPrayers!.map((prayer) {
                final isPast = prayer.isPast(TimeOfDay.now());
                final isNext = _nextPrayer?.name == prayer.name;
                
                return Card(
                  color: isNext 
                      ? Colors.blue.shade50 
                      : isPast 
                          ? Colors.grey.shade100 
                          : null,
                  child: ListTile(
                    leading: Icon(
                      _getPrayerIcon(prayer.name),
                      color: isNext 
                          ? Colors.blue 
                          : isPast 
                              ? Colors.grey 
                              : Colors.black87,
                    ),
                    title: Text(
                      prayer.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                        color: isPast ? Colors.grey : Colors.black87,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          prayer.formattedTime,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isNext 
                                ? Colors.blue 
                                : isPast 
                                    ? Colors.grey 
                                    : Colors.black87,
                          ),
                        ),
                        if (isNext) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 16),
              
              // Location Info
              if (_currentPosition != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                                'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.brightness_2;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.wb_twilight;
      case 'maghrib':
        return Icons.brightness_3;
      case 'isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}