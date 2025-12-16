import 'package:flutter/material.dart';
import 'dart:math';

class ReactiveSpeaker extends StatelessWidget {
  final double bass;
  final double mid;
  final double treble;
  final bool beat;
  final String asset;
  final double size;

  const ReactiveSpeaker({
    super.key,
    required this.bass,
    required this.mid,
    required this.treble,
    required this.beat,
    required this.asset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Bass bounce (0 → 1 scale)
    final bounce = 1 + bass * 0.25;

    // Glow intensity
    final glow = bass * 0.9 + (beat ? 0.3 : 0);

    // Treble sparkle
    final sparkleOpacity = treble * 0.6;

    return Transform.scale(
      scale: bounce,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // GLOW
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(glow),
                  blurRadius: 25 * glow,
                  spreadRadius: 10 * glow,
                )
              ],
            ),
          ),

          // SPEAKER IMAGE
          Image.asset(
            asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),

          // SPARKLE EFFECT (high frequencies)
          if (sparkleOpacity > 0.1)
            Positioned(
              top: 6,
              right: 6,
              child: Opacity(
                opacity: sparkleOpacity,
                child: Icon(
                  Icons.blur_on,
                  size: 14 + treble * 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
