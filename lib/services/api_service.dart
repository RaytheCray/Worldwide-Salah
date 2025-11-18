import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Change this to your computer's IP address when testing on a device
  // Find your IP: Open PowerShell and type: ipconfig
  // Look for "IPv4 Address" under your active network
  static const String baseUrl = 'http://localhost:5000/api';
  
  // For physical device testing, use something like:
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  /// Get prayer times for a specific date
  Future<Map<String, dynamic>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required String date,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prayer-times'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'date': date,
          'method': method,
          'asr_method': asrMethod,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting prayer times: $e');
    }
  }

  /// Get prayer times for entire month
  Future<Map<String, dynamic>> getMonthlyPrayers({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/monthly-prayers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'year': year,
          'month': month,
          'method': method,
          'asr_method': asrMethod,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load monthly prayers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting monthly prayers: $e');
    }
  }

  /// Get Ramadan schedule
  Future<Map<String, dynamic>> getRamadanSchedule({
    required double latitude,
    required double longitude,
    required int year,
    String method = 'ISNA',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ramadan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'year': year,
          'method': method,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load Ramadan schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting Ramadan schedule: $e');
    }
  }

  /// Get Qibla direction
  Future<Map<String, dynamic>> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/qibla'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get Qibla direction: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting Qibla direction: $e');
    }
  }

  /// Get available calculation methods
  Future<Map<String, dynamic>> getCalculationMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/calculation-methods'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get calculation methods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting calculation methods: $e');
    }
  }

  /// Health check
  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}