import 'package:flutter/material.dart';

/// Shared button style for "Start" buttons in mini games.
final ButtonStyle kStartButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color.fromARGB(255, 64, 100, 81),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
);

