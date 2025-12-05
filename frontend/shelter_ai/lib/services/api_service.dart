import 'dart:async';

class ApiService {
  // Mock refugees data
  static Future<List<Map<String, dynamic>>> getRefugees() async {
    // Return mock data immediately to avoid creating timers during tests.
    return [
      {'name': 'Amina', 'age': 29, 'needs': 'Médico'},
      {'name': 'Omar', 'age': 42, 'needs': 'Familiar'},
      {'name': 'Lina', 'age': 8, 'needs': 'Niña, escolar'},
    ];
  }

  // Mock shelters data
  static Future<List<Map<String, dynamic>>> getShelters() async {
    // Return mock data immediately to avoid creating timers during tests.
    return [
      {'name': 'Refugio Central', 'capacity': 120, 'occupancy': 72},
      {'name': 'Albergue Norte', 'capacity': 60, 'occupancy': 55},
      {'name': 'Centro Temporal', 'capacity': 40, 'occupancy': 12},
    ];
  }

  // Mock add refugee - in a real app this would POST to backend
  static Future<void> addRefugee(Map<String, dynamic> refugee) async {
    // For now we just print to console; replace with real API call.
    // ignore: avoid_print
    print('Adding refugee: $refugee');
  }
}
