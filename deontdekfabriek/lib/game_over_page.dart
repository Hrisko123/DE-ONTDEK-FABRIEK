import 'package:flutter/material.dart';
import 'result_page.dart';
import 'result_page_bad.dart';

class GameOverPage extends StatefulWidget {
  final int ecoScore;
  final String bandName;
  final String festivalName;
  final VoidCallback onMinigameCompleted;
  final bool isGoodEnding; // true for good ending, false for bad ending

  const GameOverPage({
    super.key,
    required this.ecoScore,
    required this.bandName,
    required this.festivalName,
    required this.onMinigameCompleted,
    required this.isGoodEnding,
  });

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  void _proceedToOutro() {
    if (widget.isGoodEnding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: widget.ecoScore,
            bandName: widget.bandName,
            festivalName: widget.festivalName,
            onMinigameCompleted: widget.onMinigameCompleted,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultPageBad(
            score: widget.ecoScore,
            bandName: widget.bandName,
            festivalName: widget.festivalName,
            onMinigameCompleted: widget.onMinigameCompleted,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142), // Light green like starting page
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'The game is over',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Text(
                'You have ${widget.ecoScore} eco score',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Text(
                'Now let\'s see what the community thinks about the event',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _proceedToOutro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                child: const Text('Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
