import 'package:flutter/material.dart';

/// Gedeelde start-knop stijl voor alle minigames
final ButtonStyle kStartButtonStyle = ElevatedButton.styleFrom(
  backgroundColor:
      const Color.fromARGB(255, 120, 200, 140), // lichtere groen tint
  foregroundColor: Colors.white, // tekstkleur wit
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);
