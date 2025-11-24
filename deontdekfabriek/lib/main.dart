import 'package:flutter/material.dart';
import 'FoodGame.dart';
import 'FestivalCleanerApp.dart';
import 'dart:math'; //for the hangout garden animation
import 'festival_name_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'De Ontdek Fabriek',
      home: const FestivalNamePage(),
    );
  }
}