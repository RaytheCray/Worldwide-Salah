import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../utils/prayer_calculator.dart';

class MonthlyTab extends StatefulWidget {
  const MonthlyTab({Key? key}) : super(key: key);

  @override
  State<MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<MonthlyTab> {
  int _selectedMonth = DateTime.now().month - 1;

  List<Map<String, dynamic>> _generateMonthlyData() {
    const year = 2025;
    final daysInMonth = DateTime(year, _selectedMonth + 2, 0).day;
    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final date = DateTime(year, _selectedMonth + 1, day);
      return {
        'day': day,
        'prayers': PrayerCalculator.calculatePrayerTimes(date),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthlyData = _generateMonthlyData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Timetable'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      isExpanded: true,
                      items: months
                          .asMap()
                          .entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(
                                  '${entry.value} 2025',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedMonth = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade700
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          '${months[_selectedMonth]} Prayer Times',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey.shade100,
                          ),
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Fajr',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Sunrise',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Dhuhr',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Asr',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Maghrib',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Isha',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                          rows: monthlyData.map((day) {
                            return DataRow(
                              cells: [
                                DataCell(Text(
                                  '${day['day']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                                ...((day['prayers'] as List<PrayerTime>)
                                    .map((prayer) => DataCell(
                                          Text(
                                            prayer.formattedTime,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ))
                                    .toList()),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}