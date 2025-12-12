import 'package:shared_preferences/shared_preferences.dart';

class StageSave {
  static Future<void> saveChoices({
    required String performer,
    required String power,
    required String lights,
    required String floor,
    required String speakers,
    required int backdrop,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("stage_performer", performer);
    await prefs.setString("stage_power", power);
    await prefs.setString("stage_lights", lights);
    await prefs.setString("stage_floor", floor);
    await prefs.setString("stage_speakers", speakers);
    await prefs.setInt("stage_backdrop", backdrop);
  }

  static Future<Map<String, dynamic>> loadChoices() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "performer": prefs.getString("stage_performer"),
      "power": prefs.getString("stage_power"),
      "lights": prefs.getString("stage_lights"),
      "floor": prefs.getString("stage_floor"),
      "speakers": prefs.getString("stage_speakers"),
      "backdrop": prefs.getInt("stage_backdrop"),
    };
  }
}
