import 'package:flutter/material.dart';

class PrayerTime {
  final String name;
  final TimeOfDay time;

  PrayerTime(this.name, this.time);

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool isPast(TimeOfDay now) {
    if (now.hour > time.hour) return true;
    if (now.hour == time.hour && now.minute > time.minute) return true;
    return false;
  }
}