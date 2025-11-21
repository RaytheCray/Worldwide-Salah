import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class QiblaScreen extends StatefulWidget {
  final String location;
  final double userLatitude;
  final double userLongitude;

  const QiblaScreen({
    super.key,
    required this.location,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _heading;
  double? _qiblaDirection;
  String _directionText = '';
  Stream<CompassEvent>? _compassStream;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _qiblaDirection = _calculateQiblaDirection(
      widget.userLatitude,
      widget.userLongitude,
    );
    
    // Delay compass initialization to avoid vsync timing conflicts
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _compassStream = FlutterCompass.events;
          _isInitialized = true;
        });
      }
    });
  }

  /// Calculate the bearing from user's location to Kaaba in Mecca
  double _calculateQiblaDirection(double latitude, double longitude) {
    // Kaaba coordinates in Mecca, Saudi Arabia
    const double meccaLat = 21.4225;
    const double meccaLon = 39.8262;

    // Convert degrees to radians
    double lat1 = latitude * math.pi / 180;
    double lon1 = longitude * math.pi / 180;
    double lat2 = meccaLat * math.pi / 180;
    double lon2 = meccaLon * math.pi / 180;

    double dLon = lon2 - lon1;

    // Calculate bearing using the formula
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);

    // Convert radians to degrees
    bearing = bearing * 180 / math.pi;

    // Normalize to 0-360
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 3958.8; // miles
    double dLat = (lat2 - lat1) * math.pi / 180;
    double dLon = (lon2 - lon1) * math.pi / 180;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  String _getDirectionText(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'South';
    if (bearing >= 202.5 && bearing < 247.5) return 'Southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'West';
    if (bearing >= 292.5 && bearing < 337.5) return 'Northwest';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance(
      widget.userLatitude,
      widget.userLongitude,
      21.4225,
      39.8262,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_isInitialized
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Initializing compass...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : StreamBuilder<CompassEvent>(
              stream: _compassStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Initializing compass...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.heading == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.explore_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Compass not available on this device',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Qibla direction: ${_qiblaDirection!.toStringAsFixed(1)}° (${_getDirectionText(_qiblaDirection!)})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                _heading = snapshot.data!.heading!;
                _directionText = _getDirectionText(_qiblaDirection!);

                // Calculate the angle to rotate the Qibla indicator
                double qiblaAngle = (_qiblaDirection! - _heading!) * (math.pi / 180);

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Qibla Direction',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Compass visualization
                          SizedBox(
                            height: 300,
                            width: 300,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Compass background circle
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.blue.shade600,
                                      width: 8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                ),
                                // Cardinal directions (rotate with heading)
                                Transform.rotate(
                                  angle: -_heading! * (math.pi / 180),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // North
                                      Positioned(
                                        top: 16,
                                        child: Text(
                                          'N',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                      // South
                                      Positioned(
                                        bottom: 16,
                                        child: Text(
                                          'S',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      // East
                                      Positioned(
                                        right: 16,
                                        child: Text(
                                          'E',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      // West
                                      Positioned(
                                        left: 16,
                                        child: Text(
                                          'W',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Qibla arrow pointing to Mecca
                                Transform.rotate(
                                  angle: qiblaAngle,
                                  child: Icon(
                                    Icons.navigation,
                                    color: Colors.green.shade600,
                                    size: 100,
                                  ),
                                ),
                                // Center dot
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Direction info
                          Text(
                            '${_qiblaDirection!.toStringAsFixed(1)}°',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _directionText,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  widget.location,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Distance to Mecca: ${distance.toStringAsFixed(0)} mi',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Instructions
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.green,
                                  size: 30,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'How to use:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '1. Hold your phone flat\n'
                                  '2. Rotate yourself until the green arrow points up\n'
                                  '3. You are now facing Qibla (Mecca)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}