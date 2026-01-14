import 'package:flutter/material.dart';
import 'QR.dart'; // 🔹 import QR.dart
import 'result_page.dart';

class FestivalNamePage extends StatefulWidget {
  const FestivalNamePage({super.key});

  @override
  State<FestivalNamePage> createState() => _FestivalNamePageState();
}

class _FestivalNamePageState extends State<FestivalNamePage> {
  final TextEditingController _controller = TextEditingController(
    text: 'EcoFest',
  );

  bool _showCrowd = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showCrowd = true);
    });
  }

  void _enterFestival() {
    final name = _controller.text.trim().isEmpty
        ? 'EcoFest'
        : _controller.text.trim();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // 🔹 FIXED: Gebruik de juiste class naam van QR.dart
        builder: (_) => QRScannerPage(festivalName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      'Name your festival',
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        final name = _controller.text.trim().isEmpty
                            ? 'EcoFest'
                            : _controller.text.trim();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ResultPage(
                              score: 8,
                              bandName: 'Test Band',
                              festivalName: name,
                              onMinigameCompleted: () {},
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'test outro',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              AnimatedOpacity(
                opacity: _showCrowd ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: Text(
                  '🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️',
                  style: TextStyle(fontSize: size.width * 0.085),
                ),
              ),

              const SizedBox(height: 40),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                onPressed: _enterFestival,
                child: const Text(
                  'Enter the festival',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
