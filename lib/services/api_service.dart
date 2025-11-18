import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Update this based on your environment
  // For local development with emulator: http://localhost:5000/api
  // For local development with physical device: http://YOUR_IP:5000/api
  // For production: https://your-backend-url.com/api
  
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );
  
  // Alternative: Hardcode for testing
  // static const String baseUrl = 'http://192.168.1.100:5000/api';
  
  // Timeout duration for API calls
  static const Duration timeoutDuration = Duration(seconds: 10);

  /// Get prayer times for a specific date
  Future<Map<String, dynamic>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required String date,
    String method = 'ISNA',
    String asrMethod = 'standard',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/prayer-times'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'date': date,
              'method': method,
              'asr_method': asrMethod,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load prayer times: ${response.statusCode} - ${response.body}');
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
      final response = await http
          .post(
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
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load monthly prayers: ${response.statusCode} - ${response.body}');
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
      final response = await http
          .post(
            Uri.parse('$baseUrl/ramadan'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'year': year,
              'method': method,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load Ramadan schedule: ${response.statusCode} - ${response.body}');
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
      final response = await http
          .post(
            Uri.parse('$baseUrl/qibla'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to get Qibla direction: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting Qibla direction: $e');
    }
  }

  /// Get available calculation methods
  Future<Map<String, dynamic>> getCalculationMethods() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/calculation-methods'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to get calculation methods: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting calculation methods: $e');
    }
  }

  /// Health check
  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // Server is not reachable
      return false;
    }
  }

  /// Test connection to server
  Future<String> testConnection() async {
    try {
      final isHealthy = await checkServerHealth();
      if (isHealthy) {
        return 'Connected to server at $baseUrl';
      } else {
        return 'Server responded but health check failed';
      }
    } catch (e) {
      return 'Cannot connect to server: $e';
    }
  }
}