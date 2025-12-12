import 'package:flutter/material.dart';
import 'stage_audio_controller.dart';
import 'festival_name_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global music engine BEFORE app builds
  await StageAudioController.instance.initialize();

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
