import 'package:flutter/material.dart';
import '../services/api_service.dart';

// Single prayer entry (name + TimeOfDay)
class PrayerTime {
  final String name;
  final TimeOfDay time;

  PrayerTime(this.name, this.time);

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  // true if this prayer's time is earlier than `now`
  bool isPast(TimeOfDay now) {
    final int t = time.hour * 60 + time.minute;
    final int n = now.hour * 60 + now.minute;
    return t < n;
  }
}

class PrayerCalculator {
  static final ApiService _apiService = ApiService();
  
  // Cache for prayer times to avoid repeated API calls
  static List<PrayerTime>? _cachedPrayers;
  static String? _cachedDate;
  static double? _cachedLat;
  static double? _cachedLon;

  /// Calculate prayer times using the backend API
  static Future<List<PrayerTime>> calculatePrayerTimes(
    DateTime date, {
    double latitude = 40.7128,  // Default: New York
    double longitude = -74.0060,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    final dateString = ApiService.formatDate(date);
    
    // Check cache first
    if (_cachedPrayers != null &&
        _cachedDate == dateString &&
        _cachedLat == latitude &&
        _cachedLon == longitude) {
      debugPrint('📦 Using cached prayer times for $dateString');
      return _cachedPrayers!;
    }

    try {
      debugPrint('🌐 Fetching prayer times from backend for $dateString...');
      
      final response = await _apiService.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: dateString,
        method: method,
        asrMethod: asrMethod,
      );

      if (response['success'] == true) {
        final times = response['times'] as Map<String, dynamic>;
        
        final prayers = [
          PrayerTime('Fajr', ApiService.parseTime(times['fajr'])),
          PrayerTime('Sunrise', ApiService.parseTime(times['sunrise'])),
          PrayerTime('Dhuhr', ApiService.parseTime(times['dhuhr'])),
          PrayerTime('Asr', ApiService.parseTime(times['asr'])),
          PrayerTime('Maghrib', ApiService.parseTime(times['maghrib'])),
          PrayerTime('Isha', ApiService.parseTime(times['isha'])),
        ];

        // Cache the results
        _cachedPrayers = prayers;
        _cachedDate = dateString;
        _cachedLat = latitude;
        _cachedLon = longitude;

        debugPrint('✅ Prayer times loaded successfully (cached: ${response['cached']})');
        return prayers;
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      debugPrint('❌ Error fetching prayer times: $e');
      debugPrint('⚠️ Falling back to default times');
      
      // Fallback to hardcoded times if API fails
      return _getDefaultPrayerTimes();
    }
  }

  /// Get next upcoming prayer
  static Future<PrayerTime> getNextPrayer({
    double latitude = 40.7128,
    double longitude = -74.0060,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    final prayers = await calculatePrayerTimes(
      DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      method: method,
      asrMethod: asrMethod,
    );
    
    final now = TimeOfDay.now();
    
    // Find the next prayer
    for (var prayer in prayers) {
      if (prayer.name != 'Sunrise' && isTimeBefore(now, prayer.time)) {
        return prayer;
      }
    }
    
    // If all prayers have passed, return Fajr for tomorrow
    return prayers.first;
  }

  /// Check if time1 is before time2
  static bool isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute < time2.minute) return true;
    return false;
  }

  /// Get time remaining until next prayer
  static Future<String> getTimeUntilNextPrayer({
    double latitude = 40.7128,
    double longitude = -74.0060,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    final next = await getNextPrayer(
      latitude: latitude,
      longitude: longitude,
      method: method,
      asrMethod: asrMethod,
    );
    
    final now = DateTime.now();
    var nextDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      next.time.hour,
      next.time.minute,
    );

    if (nextDateTime.isBefore(now)) {
      nextDateTime = nextDateTime.add(const Duration(days: 1));
    }

    final diff = nextDateTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return '${hours}h ${minutes}m ${seconds}s';
  }

  /// Get monthly prayer times from backend
  static Future<List<Map<String, dynamic>>> getMonthlyPrayerTimes({
    required int year,
    required int month,
    double latitude = 40.7128,
    double longitude = -74.0060,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    try {
      debugPrint('🌐 Fetching monthly prayers for $year-$month...');
      
      final response = await _apiService.getMonthlyPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        year: year,
        month: month,
        method: method,
        asrMethod: asrMethod,
      );

      if (response['success'] == true) {
        final prayers = response['prayers'] as List;
        
        return prayers.map((day) {
          final times = day['times'] as Map<String, dynamic>;
          return {
            'day': day['day'],
            'date': day['date'],
            'prayers': [
              PrayerTime('Fajr', ApiService.parseTime(times['fajr'])),
              PrayerTime('Sunrise', ApiService.parseTime(times['sunrise'])),
              PrayerTime('Dhuhr', ApiService.parseTime(times['dhuhr'])),
              PrayerTime('Asr', ApiService.parseTime(times['asr'])),
              PrayerTime('Maghrib', ApiService.parseTime(times['maghrib'])),
              PrayerTime('Isha', ApiService.parseTime(times['isha'])),
            ],
          };
        }).toList();
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      debugPrint('❌ Error fetching monthly prayers: $e');
      throw Exception('Failed to load monthly prayer times');
    }
  }

  /// Get Ramadan schedule from backend
  static Future<Map<String, dynamic>> getRamadanSchedule({
    required int year,
    double latitude = 40.7128,
    double longitude = -74.0060,
    String method = 'ISNA',
  }) async {
    try {
      debugPrint('🌙 Fetching Ramadan schedule for $year...');
      
      final response = await _apiService.getRamadanSchedule(
        latitude: latitude,
        longitude: longitude,
        year: year,
        method: method,
      );

      if (response['success'] == true) {
        debugPrint('✅ Ramadan schedule loaded');
        debugPrint('   Start: ${response['start_date']}');
        debugPrint('   End: ${response['end_date']}');
        return response;
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      debugPrint('❌ Error fetching Ramadan schedule: $e');
      throw Exception('Failed to load Ramadan schedule');
    }
  }

  /// Get Qibla direction from backend
  static Future<double> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    try {
      debugPrint('🧭 Calculating Qibla direction...');
      
      final response = await _apiService.getQiblaDirection(
        latitude: latitude,
        longitude: longitude,
      );

      if (response['success'] == true) {
        final direction = response['qibla_direction'] as double;
        debugPrint('✅ Qibla direction: ${direction.toStringAsFixed(1)}°');
        return direction;
      } else {
        throw Exception('API returned success: false');
      }
    } catch (e) {
      debugPrint('❌ Error calculating Qibla direction: $e');
      throw Exception('Failed to calculate Qibla direction');
    }
  }

  /// Clear cached prayer times
  static void clearCache() {
    _cachedPrayers = null;
    _cachedDate = null;
    _cachedLat = null;
    _cachedLon = null;
    debugPrint('🗑️ Prayer times cache cleared');
  }

  /// Test backend connection
  static Future<bool> testBackendConnection() async {
    try {
      return await _apiService.checkServerHealth();
    } catch (e) {
      return false;
    }
  }

  /// Get default/fallback prayer times when API is unavailable
  static List<PrayerTime> _getDefaultPrayerTimes() {
    debugPrint('⚠️ Using default prayer times (API unavailable)');
    return [
      PrayerTime('Fajr', const TimeOfDay(hour: 5, minute: 30)),
      PrayerTime('Sunrise', const TimeOfDay(hour: 6, minute: 45)),
      PrayerTime('Dhuhr', const TimeOfDay(hour: 12, minute: 30)),
      PrayerTime('Asr', const TimeOfDay(hour: 15, minute: 45)),
      PrayerTime('Maghrib', const TimeOfDay(hour: 18, minute: 30)),
      PrayerTime('Isha', const TimeOfDay(hour: 19, minute: 45)),
    ];
  }
}