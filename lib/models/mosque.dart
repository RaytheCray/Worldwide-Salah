class Mosque {
  final int mosqueId;
  final String name;
  final String? address;
  final String? city;
  final String? country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final double? distance; // Distance in kilometers

  Mosque({
    required this.mosqueId,
    required this.name,
    this.address,
    this.city,
    this.country,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.distance,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse distance (can be String or double)
    double? parseDistance(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('⚠️ Mosque: Could not parse distance "$value": $e');
          return null;
        }
      }
      return null;
    }

    return Mosque(
      mosqueId: json['mosque_id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] is String) 
          ? double.parse(json['latitude']) 
          : (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] is String)
          ? double.parse(json['longitude'])
          : (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      distance: parseDistance(json['distance']), // ✅ FIXED: Handles String or double
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mosque_id': mosqueId,
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'distance': distance,
    };
  }

  @override
  String toString() {
    return 'Mosque(id: $mosqueId, name: $name, distance: ${distance?.toStringAsFixed(1)}km)';
  }
}