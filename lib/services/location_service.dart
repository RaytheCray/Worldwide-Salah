import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async'; // for TimeoutException
import 'package:flutter/foundation.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  /// Get current location with full error handling
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled. Please enable location services in your device settings.');
      }

      // Check permissions
      if (!await checkPermissions()) {
        throw Exception('Location permissions denied. Please grant location permissions in app settings.');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      debugPrint('Location timeout: Taking too long to get location');
      return null;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address string with available components
        List<String> addressParts = [];
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        if (place.administrativeArea != null && 
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        if (addressParts.isEmpty) {
          return 'Unknown location';
        }
        
        return addressParts.join(', ');
      }
      return 'Unknown location';
    } catch (e) {
      debugPrint('Error getting address: $e');
      return 'Unknown location';
    }
  }

  /// Get coordinates from address (forward geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location loc = locations[0];
        return Position(
          latitude: loc.latitude,
          longitude: loc.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Get detailed location information
  Future<Map<String, dynamic>> getDetailedLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isEmpty) {
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': 'Unknown location',
          'city': null,
          'state': null,
          'country': null,
          'postalCode': null,
        };
      }
      
      Placemark place = placemarks[0];
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': getAddressFromCoordinates(position.latitude, position.longitude),
        'city': place.locality,
        'state': place.administrativeArea,
        'country': place.country,
        'postalCode': place.postalCode,
        'street': place.street,
        'subLocality': place.subLocality,
      };
    } catch (e) {
      debugPrint('Error getting detailed location: $e');
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': 'Unknown location',
        'city': null,
        'state': null,
        'country': null,
        'postalCode': null,
      };
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    ) / 1000; // Convert meters to kilometers
  }

  /// Calculate distance between two coordinates in miles
  double calculateDistanceInMiles(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return calculateDistance(startLat, startLon, endLat, endLon) * 0.621371;
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permissions)
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Get location permission status as a readable string
  Future<String> getPermissionStatus() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission denied';
      case LocationPermission.deniedForever:
        return 'Location permission permanently denied';
      case LocationPermission.whileInUse:
        return 'Location permission granted while app is in use';
      case LocationPermission.always:
        return 'Location permission always granted';
      default:
        return 'Unknown permission status';
    }
  }

  /// Check if location is within a certain radius of a point (in kilometers)
  bool isWithinRadius({
    required double centerLat,
    required double centerLon,
    required double pointLat,
    required double pointLon,
    required double radiusKm,
  }) {
    final distance = calculateDistance(centerLat, centerLon, pointLat, pointLon);
    return distance <= radiusKm;
  }
}