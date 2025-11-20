class Mosque {
  final int id;
  final String name;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final double? distance; // in kilometers

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.distance,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['mosque_id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'],
      website: json['website'],
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }

  String get distanceText {
    if (distance == null) return '';
    return '${distance!.toStringAsFixed(1)} km away';
  }
}