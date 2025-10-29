import 'package:flutter/material.dart';
import '../models/prayer_time.dart';

class PrayerCalculator {
  // Simplified prayer time calculation for demo
  // In production, you would use the 'adhan' package for accurate calculations
  static List<PrayerTime> calculatePrayerTimes(DateTime date) {
    return [
      PrayerTime('Fajr', const TimeOfDay(hour: 5, minute: 30)),
      PrayerTime('Sunrise', const TimeOfDay(hour: 6, minute: 45)),
      PrayerTime('Dhuhr', const TimeOfDay(hour: 12, minute: 30)),
      PrayerTime('Asr', const TimeOfDay(hour: 15, minute: 45)),
      PrayerTime('Maghrib', const TimeOfDay(hour: 18, minute: 30)),
      PrayerTime('Isha', const TimeOfDay(hour: 19, minute: 45)),
    ];
  }

  static PrayerTime getNextPrayer() {
    final prayers = calculatePrayerTimes(DateTime.now());
    final now = TimeOfDay.now();
    
    for (var prayer in prayers) {
      if (isTimeBefore(now, prayer.time)) {
        return prayer;
      }
    }
    return prayers.first;
  }

  static bool isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute < time2.minute) return true;
    return false;
  }

  static String getTimeUntilNextPrayer() {
    final next = getNextPrayer();
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
}