import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../models/prayer_times.dart' as prayer_model;
import '../models/mosque.dart' as mosque_model;

List<mosque_model.Mosque> _nearbyMosques = [];
prayer_model.PrayerTimes? _prayerTimes;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Get location and load data
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Load prayer times and mosques
      await Future.wait([
        _loadPrayerTimes(),
        _loadNearbyMosques(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (_currentPosition == null) return;

    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await _api.getPrayerTimes(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      date: dateString,
      method: 'ISNA', // You can make this configurable
      asrMethod: 'standard',
    );

    if (response['success'] == true) {
      setState(() {
        _prayerTimes = PrayerTimes.fromJson(response);
      });
    } else {
      setState(() {
        _errorMessage = response['error'] ?? 'Failed to load prayer times';
      });
    }
  }

  Future<void> _loadNearbyMosques() async {
    if (_currentPosition == null) return;

    final response = await _api.getNearbyMosques(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      radius: 10.0,
    );

    if (response['success'] == true) {
      final mosquesList = response['mosques'] as List;
      setState(() {
        _nearbyMosques = mosquesList
            .map((json) => mosque_model.Mosque.fromJson(json))
            .toList();
      });
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
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Retry'),
          ),
        ],
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

            // Nearby mosques
            if (_nearbyMosques.isNotEmpty) ...[
              Text(
                'Nearby Mosques',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              _buildMosquesList(),
            ],
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
                if (mosque.address != null) Text(mosque.address!),
                if (mosque.distance != null)
                  Text(
                    '${mosque.distance!.toStringAsFixed(1)} km away',
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
              if (mosque.address != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(mosque.address!)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (mosque.phone != null) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 8),
                    Text(mosque.phone!),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (mosque.website != null) ...[
                Row(
                  children: [
                    const Icon(Icons.web, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(mosque.website!)),
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