import 'package:flutter/material.dart';

// Stijl voor de "Start" knop gebruikt in ToiletGame.dart
final ButtonStyle kStartButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF4CAF50), // groene knop
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
);
