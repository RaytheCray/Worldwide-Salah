import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../models/prayer_times.dart' as prayer_model;
import '../models/mosque.dart' as mosque_model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  prayer_model.PrayerTimes? _prayerTimes;
  List<mosque_model.Mosque> _nearbyMosques = [];
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;
  bool _mosquesLoading = false;
  String? _mosqueError;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 HomeScreen: initState called');
    
    // Add a safety timeout to prevent infinite loading
    Future.delayed(const Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        debugPrint('⏰ HomeScreen: Loading timeout triggered, forcing stop');
        setState(() {
          _isLoading = false;
          if (_errorMessage == null) {
            _errorMessage = 'Loading timed out. Please try again.';
          }
        });
      }
    });
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('📱 HomeScreen: Initializing app...');
    // Get location and load data
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    debugPrint('📍 HomeScreen: Getting current location...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mosqueError = null;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ HomeScreen: Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied. Please enable location access in settings.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied. Please enable in device settings.');
      }

      // Get current position with timeout
      debugPrint('🌍 HomeScreen: Fetching GPS coordinates...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('GPS timeout. Please check your location settings.');
        },
      );

      debugPrint('✅ HomeScreen: Location obtained - Lat: ${position.latitude}, Lng: ${position.longitude}');
      
      setState(() {
        _currentPosition = position;
      });

      // Load prayer times (REQUIRED - blocks loading screen)
      debugPrint('📿 HomeScreen: Loading prayer times...');
      await _loadPrayerTimes();
      debugPrint('✅ HomeScreen: Prayer times loaded successfully');
      
      // Load mosques (OPTIONAL - runs in background, doesn't block UI)
      debugPrint('🕌 HomeScreen: Loading nearby mosques in background...');
      _loadNearbyMosques().catchError((e) {
        debugPrint('⚠️ HomeScreen: Mosque loading failed (non-critical): $e');
        if (mounted) {
          setState(() {
            _mosqueError = 'Could not load nearby mosques';
          });
        }
      });
      
    } catch (e) {
      debugPrint('❌ HomeScreen: Error in getCurrentLocation: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // CRITICAL: Always stop loading, even if there's an error
      debugPrint('🏁 HomeScreen: Stopping loading screen');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (_currentPosition == null) {
      debugPrint('⚠️ HomeScreen: Cannot load prayer times - no position');
      return;
    }

    try {
      final today = DateTime.now();
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      debugPrint('🔄 HomeScreen: Requesting prayer times for $dateString');
      final response = await _api.getPrayerTimes(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        date: dateString,
        method: 'ISNA', // You can make this configurable
        asrMethod: 'standard',
      );

      if (response['success'] == true) {
        debugPrint('✅ HomeScreen: Prayer times API returned success');
        setState(() {
          _prayerTimes = prayer_model.PrayerTimes.fromJson(response);
        });
      } else {
        debugPrint('❌ HomeScreen: Prayer times API returned error: ${response['error']}');
        throw Exception(response['error'] ?? 'Failed to load prayer times');
      }
    } catch (e) {
      debugPrint('❌ HomeScreen: Error loading prayer times: $e');
      // Re-throw so the error can be caught in _getCurrentLocation
      rethrow;
    }
  }

  Future<void> _loadNearbyMosques() async {
    if (_currentPosition == null) {
      debugPrint('⚠️ HomeScreen: Cannot load mosques - no position');
      return;
    }

    setState(() {
      _mosquesLoading = true;
      _mosqueError = null;
    });

    try {
      debugPrint('🔄 HomeScreen: Requesting nearby mosques (radius: 50km)');
      final response = await _api.getNearbyMosques(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radius: 50.0, // ✅ INCREASED from 10km to 50km for better coverage
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Mosque search timed out');
        },
      );

      if (response['success'] == true) {
        final mosquesList = response['mosques'] as List;
        debugPrint('✅ HomeScreen: Found ${mosquesList.length} mosques nearby');
        
        if (mounted) {
          setState(() {
            _nearbyMosques = mosquesList
                .map((json) => mosque_model.Mosque.fromJson(json))
                .toList();
            _mosquesLoading = false;
          });
        }
        
        if (mosquesList.isEmpty) {
          debugPrint('ℹ️ HomeScreen: No mosques found in 50km radius');
        }
      } else {
        debugPrint('❌ HomeScreen: Mosque API returned error: ${response['error']}');
        throw Exception(response['error'] ?? 'Failed to load mosques');
      }
    } catch (e) {
      debugPrint('❌ HomeScreen: Error loading mosques: $e');
      if (mounted) {
        setState(() {
          _nearbyMosques = [];
          _mosquesLoading = false;
          _mosqueError = 'Unable to load nearby mosques';
        });
      }
      // Don't rethrow - mosque loading is optional
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worldwide Salah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _getCurrentLocation,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _getCurrentLocation,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location info
            if (_currentPosition != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Current Location'),
                  subtitle: Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                    'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Prayer times
            if (_prayerTimes != null) ...[
              Text(
                'Prayer Times',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              _buildPrayerTimesCard(),
              const SizedBox(height: 24),
            ],

            // Nearby mosques section
            Text(
              'Nearby Mosques',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            // Mosque loading state
            if (_mosquesLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 16),
                      Text('Loading nearby mosques...'),
                    ],
                  ),
                ),
              )
            // Mosque error state
            else if (_mosqueError != null)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _mosqueError!,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Empty mosque list
            else if (_nearbyMosques.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'No mosques found within 50 km',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Mosque list
            else
              _buildMosquesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPrayerTimeRow('Fajr', _prayerTimes!.fajr),
            _buildPrayerTimeRow('Sunrise', _prayerTimes!.sunrise),
            _buildPrayerTimeRow('Dhuhr', _prayerTimes!.dhuhr),
            _buildPrayerTimeRow('Asr', _prayerTimes!.asr),
            _buildPrayerTimeRow('Maghrib', _prayerTimes!.maghrib),
            _buildPrayerTimeRow('Isha', _prayerTimes!.isha),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Method: ${_prayerTimes!.method}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_prayerTimes!.cached)
                  const Chip(
                    label: Text('Cached', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.green,
                    labelPadding: EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosquesList() {
    return Column(
      children: _nearbyMosques.map((mosque) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.mosque),
            title: Text(mosque.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mosque.address case final address?) Text(address),
                if (mosque.distance case final distance?)
                  Text(
                    '${distance.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to mosque details
              _showMosqueDetails(mosque);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showMosqueDetails(mosque_model.Mosque mosque) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mosque.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (mosque.address case final address?) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(address)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (mosque.phone case final phone?) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(phone),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (mosque.website case final website?) ...[
                Row(
                  children: [
                    const Icon(Icons.web, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(website)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}