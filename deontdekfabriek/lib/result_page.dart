import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final String bandName;
  final String festivalName;
  final VoidCallback onMinigameCompleted;

  const ResultPage({
    super.key,
    required this.score,
    required this.bandName,
    required this.festivalName,
    required this.onMinigameCompleted,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with TickerProviderStateMixin {
  late AnimationController spotlightCtrl;
  late AnimationController shakeCtrl;
  late AnimationController revealCtrl;
  late ConfettiController confettiCtrl;

  bool spotlightFinished = false;

  @override
  void initState() {
    super.initState();

    // Spotlight sweeps for 5 seconds
    spotlightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    // Shake
    shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Card reveal (fade + scale)
    revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Confetti
    confettiCtrl = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    // When spotlight finishes:
    spotlightCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => spotlightFinished = true);
        revealCtrl.forward();
        shakeCtrl.forward();
        confettiCtrl.play();
      }
    });
  }

  @override
  void dispose() {
    spotlightCtrl.dispose();
    shakeCtrl.dispose();
    revealCtrl.dispose();
    confettiCtrl.dispose();
    super.dispose();
  }

  // Shake offset
  Offset _shake() {
    if (!spotlightFinished) return Offset.zero;
    final t = shakeCtrl.value;
    return Offset(
      sin(t * pi * 10) * 6,
      cos(t * pi * 12) * 4,
    );
  }

  // Title logic
  String get title {
    if (widget.score >= 8) return "Eco Hero Stage 🌱";
    if (widget.score >= 3) return "Nice Try Stage 🙂";
    return "Eco Disaster Stage 😬";
  }

  // Message logic
  String get message {
    if (widget.score >= 8) {
      return "Your stage is super eco-friendly! Amazing choices!";
    } else if (widget.score >= 3) {
      return "Good job! Some eco improvements are still possible.";
    } else {
      return "Your stage is NOT eco-friendly.\nTry choosing greener options next time!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Stage Result"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),

          // 🔥 SPOTLIGHT LAYER (always drawn, on top of everything)
          AnimatedBuilder(
            animation: spotlightCtrl,
            builder: (_, __) => Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: SpotlightPainter(
                    progress: spotlightCtrl.value,
                    reveal: spotlightFinished,
                  ),
                ),
              ),
            ),
          ),

          // CONFETTI
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.03,
              numberOfParticles: 25,
              gravity: 0.35,
            ),
          ),

          // CARD + SHAKE + FADE + SCALE
          AnimatedBuilder(
            animation: Listenable.merge([shakeCtrl, revealCtrl]),
            builder: (_, child) {
              final scale = 0.7 + revealCtrl.value * 0.3;
              final opacity = revealCtrl.value;

              return Transform.translate(
                offset: _shake(),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildCard(),
          ),
        ],
      ),
    );
  }

  // CARD CONTENT
  Widget _buildCard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(26),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.festivalName,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Text("Performer: ${widget.bandName}",
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            Text("Eco Score: ${widget.score}",
                style: const TextStyle(fontSize: 20, color: Colors.white)),

            const SizedBox(height: 20),

            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              ),
              onPressed: () {
                widget.onMinigameCompleted();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Back to Festival Map"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// SPOTLIGHT PAINTER
// ---------------------------------------------------------------
class SpotlightPainter extends CustomPainter {
  final double progress;
  final bool reveal;

  SpotlightPainter({required this.progress, required this.reveal});

  @override
  void paint(Canvas canvas, Size size) {
    // Required for BlendMode.clear to work on iOS
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Full darkness overlay
    final dark = Paint()..color = Colors.black.withOpacity(0.90);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      dark,
    );

    double radius = size.width * 0.33;

    // Spotlight wandering path
    double x = lerpDouble(-150, size.width + 150, progress)!;
    double y = size.height * 0.35 + sin(progress * 6) * 60;

    // When spotlight finds the score area → lock center + expand
    if (reveal) {
      x = size.width / 2;
      y = size.height * 0.55;
      radius = size.width * 0.45;
    }

    // Clear hole
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(Offset(x, y), radius, clear);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
