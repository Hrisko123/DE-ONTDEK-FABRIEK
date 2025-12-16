import 'package:shared_preferences/shared_preferences.dart';

class SavedStageState {
  static Future<void> save({
    required String performerImage,
    required String bandName,
    required int lights,
    required int power,
    required int floor,
    required int speakers,
    required int backdropIndex,
    required bool hasPerformer,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("stage_performerImage", performerImage);
    prefs.setString("stage_band", bandName);
    prefs.setInt("stage_lights", lights);
    prefs.setInt("stage_power", power);
    prefs.setInt("stage_floor", floor);
    prefs.setInt("stage_speakers", speakers);
    prefs.setInt("stage_backdrop", backdropIndex);
    prefs.setBool("stage_hasPerformer", hasPerformer);
  }

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "performerImage": prefs.getString("stage_performerImage") ?? "assets/stage/microphone.png",
      "band": prefs.getString("stage_band"),
      "lights": prefs.getInt("stage_lights"),
      "power": prefs.getInt("stage_power"),
      "floor": prefs.getInt("stage_floor"),
      "speakers": prefs.getInt("stage_speakers"),
      "backdrop": prefs.getInt("stage_backdrop"),
      "hasPerformer": prefs.getBool("stage_hasPerformer") ?? false,
    };
  }
}
