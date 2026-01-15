import 'package:http/http.dart' as http;

class LedService {
  static const String _ledIp = 'http://172.20.10.6';

  static Future<void> updateLeds(int points) async {
    try {
      final url = Uri.parse('$_ledIp/set?punten=$points');
      print('🔄 Sending request to: $url');
      await http.get(url).timeout(const Duration(seconds: 5));
      print('✅ LED updated successfully: $points punten');
    } catch (e) {
      print('❌ LED update failed: $e');
    }
  }

  static Future<void> addPoints(int points) async {
    print('📊 Adding points: $points');
    await updateLeds(points);
  }

  static Future<void> resetPoints() async {
    print('🔄 Resetting points to 0');
    await updateLeds(0);
  }
}
