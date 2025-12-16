import 'package:http/http.dart' as http;

class LedService {
  static const String _ledIp = 'http://172.20.10.6';

  static Future<void> updateLeds(int points) async {
    try {
      final url = Uri.parse('$_ledIp/set?punten=$points');
      await http.get(url).timeout(const Duration(seconds: 5));
      print('✅ LED updated: $points punten');
    } catch (e) {
      print('❌ LED update failed: $e');
    }
  }
}
