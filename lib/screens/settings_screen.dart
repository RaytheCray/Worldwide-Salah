import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String location;
  final String calculationMethod;
  final String asrMethod;
  final Function(String) onLocationChanged;
  final Function(String) onCalculationMethodChanged;
  final Function(String) onAsrMethodChanged;

  const SettingsScreen({
    Key? key,
    required this.location,
    required this.calculationMethod,
    required this.asrMethod,
    required this.onLocationChanged,
    required this.onCalculationMethodChanged,
    required this.onAsrMethodChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _locationController;
  late String _selectedCalculationMethod;
  late String _selectedAsrMethod;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.location);
    _selectedCalculationMethod = widget.calculationMethod;
    _selectedAsrMethod = widget.asrMethod;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade600,
        actions: [
          TextButton(
            onPressed: () {
              widget.onLocationChanged(_locationController.text);
              widget.onCalculationMethodChanged(_selectedCalculationMethod);
              widget.onAsrMethodChanged(_selectedAsrMethod);
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter city or address',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: ListTile(
                    leading:
                        Icon(Icons.my_location, color: Colors.blue.shade600),
                    title: const Text('Use Current Location'),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      // TODO: Implement GPS location with geolocator package
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('GPS location feature coming soon!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calculation Method',
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
                    child: DropdownButton<String>(
                      value: _selectedCalculationMethod,
                      isExpanded: true,
                      items: ['ISNA', 'MWL', 'Egyptian', 'Karachi', 'Makkah']
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(
                                  method,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCalculationMethod = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asr Calculation',
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
                    child: DropdownButton<String>(
                      value: _selectedAsrMethod,
                      isExpanded: true,
                      items: ['Standard', 'Hanafi']
                          .map((method) => DropdownMenuItem(
                                value: method,
                                child: Text(
                                  method,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedAsrMethod = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}