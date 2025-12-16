import 'package:flutter/material.dart';
import 'stage_audio_controller.dart';
import 'festival_name_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StageAudioController.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'De Ontdek Fabriek',
      debugShowCheckedModeBanner: false,
      home: const FestivalNamePage(),
    );
  }
}