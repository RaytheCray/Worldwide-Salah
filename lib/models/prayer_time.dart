// lib/models/prayer_times.dart

class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String method;
  final String asrMethod;
  final bool cached;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.method,
    required this.asrMethod,
    this.cached = false,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json['times']['fajr'],
      sunrise: json['times']['sunrise'],
      dhuhr: json['times']['dhuhr'],
      asr: json['times']['asr'],
      maghrib: json['times']['maghrib'],
      isha: json['times']['isha'],
      date: json['date'],
      method: json['method'],
      asrMethod: json['asr_method'],
      cached: json['cached'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'times': {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      },
      'date': date,
      'method': method,
      'asr_method': asrMethod,
      'cached': cached,
    };
  }
}

// lib/models/mosque.dart

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
  final double? distance; // in kilometers

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
    return Mosque(
      mosqueId: json['mosque_id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      phone: json['phone'],
      website: json['website'],
      distance: json['distance']?.toDouble(),
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
}

// lib/models/user.dart

class User {
  final int userId;
  final String email;
  final String? fullName;

  User({
    required this.userId,
    required this.email,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      email: json['email'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
    };
  }
}

// lib/models/user_preferences.dart

class UserPreferences {
  final String calculationMethod;
  final String asrMethod;
  final String theme;
  final String language;
  final bool notificationsEnabled;
  final bool adhanEnabled;

  UserPreferences({
    required this.calculationMethod,
    required this.asrMethod,
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.adhanEnabled,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final prefs = json['preferences'];
    return UserPreferences(
      calculationMethod: prefs['calculation_method'],
      asrMethod: prefs['asr_method'],
      theme: prefs['theme'],
      language: prefs['language'],
      notificationsEnabled: prefs['notifications_enabled'],
      adhanEnabled: prefs['adhan_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculation_method': calculationMethod,
      'asr_method': asrMethod,
      'theme': theme,
      'language': language,
      'notifications_enabled': notificationsEnabled,
      'adhan_enabled': adhanEnabled,
    };
  }
}

// lib/models/ramadan_day.dart

class RamadanDay {
  final String date;
  final int day;
  final String suhoorEnd; // Fajr time
  final String iftar;     // Maghrib time

  RamadanDay({
    required this.date,
    required this.day,
    required this.suhoorEnd,
    required this.iftar,
  });

  factory RamadanDay.fromJson(Map<String, dynamic> json) {
    return RamadanDay(
      date: json['date'],
      day: json['day'],
      suhoorEnd: json['suhoor_end'],
      iftar: json['iftar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'suhoor_end': suhoorEnd,
      'iftar': iftar,
    };
  }
}