import 'package:flutter/material.dart';
import 'dart:math';
import 'ui_styles.dart'; // for kStartButtonStyle

// HANGOUT AREA MINI-GAME

class EcoQuestion {
  final String text;
  final List<String> options;
  final int ecoOptionIndex;

  const EcoQuestion({
    required this.text,
    required this.options,
    required this.ecoOptionIndex,
  });
}

class HangoutQuizPage extends StatefulWidget {
  const HangoutQuizPage({super.key});

  @override
  State<HangoutQuizPage> createState() => _HangoutQuizPageState();
}

class _HangoutQuizPageState extends State<HangoutQuizPage> {
  final List<EcoQuestion> _questions = const [
    EcoQuestion(
      text: 'How are you getting to the festival?',
      options: [
        'By car with friends',
        'By public transport',
        'By bike or walking',
      ],
      ecoOptionIndex: 0,
    ),
    EcoQuestion(
      text: 'What do you do with your empty drink cup?',
      options: [
        'Leave it on the grass for staff to pick up',
        'Return it to the bar for recycling',
        'Throw it in a random bin.',
      ],
      ecoOptionIndex: 1,
    ),
    EcoQuestion(
      text: 'How do you charge your phone?',
      options: [
        'Plug into a random staff-only socket.',
        'I dont charge it at all',
        'Use the shared solar charging station.',
      ],
      ecoOptionIndex: 2,
    ),
    EcoQuestion(
      text: 'How do you keep the hangout area chill?',
      options: [
        'Sing and shout over the music all the time.',
        'Talk to your friends and enjoy the music',
        'Blast your own speaker loudly next to people relaxing.',
      ],
      ecoOptionIndex: 1,
    ),
    EcoQuestion(
      text: 'You see a cigarette butt on the ground. What do you do?',
      options: [
        'Put it in a pocket ashtray or cigarette bin.',
        'Ignore it, it\'s just one.',
        'Push it into the soil with your shoe.',
      ],
      ecoOptionIndex: 0,
    ),
    EcoQuestion(
      text: 'Snack time! What do you choose?',
      options: [
        'Take food and throw half away.',
        'Many tiny snacks, each wrapped in plastic.',
        'Food with minimal or reusable packaging.',
      ],
      ecoOptionIndex: 2,
    ),
    EcoQuestion(
      text: 'How do you light the hangout area at night?',
      options: [
        'Leave all lights on even when nobody is there.',
        'Use cosy LED string lights powered by solar power.',
        'Use big old floodlights',
      ],
      ecoOptionIndex: 1,
    ),
    EcoQuestion(
      text: 'You are leaving the hangout park. What do you do?',
      options: [
        'Hide trash under the grass or behind trees.',
        'Leave cups and blankets behind for cleaners.',
        'Take your things, sort waste and leave it clean.',
      ],
      ecoOptionIndex: 2,
    ),
  ];

  int _currentIndex = 0;
  int _gardenStage = 0; // grows only when eco option is selected
  bool _showIntro = true;

  void _onOptionSelected(int optionIndex) {
    final question = _questions[_currentIndex];

    setState(() {
      if (optionIndex == question.ecoOptionIndex) {
        _gardenStage++;
      }

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Hangout garden'),
              content: const Text(
                'Thanks! Your eco decisions helped the hangout garden grow 🌿',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to main page'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  // INTRO SCREEN WIDGET
  Widget _buildIntro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to the Hangout Area!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "For each eco-friendly choice, watch the garden bloom",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: kStartButtonStyle,
              onPressed: () {
                setState(() {
                  _showIntro = false; // SWITCH TO QUESTIONS
                });
              },
              child: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForOption(int optionIndex, int ecoIndex) {
    return optionIndex == ecoIndex
        ? Colors.green.shade400
        : Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 143, 172, 122),
        appBar: AppBar(
          title: const Text('Hangout Intro'),
          backgroundColor: const Color.fromARGB(255, 64, 100, 81),
        ),
        body: _buildIntro(),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 143, 172, 122),
      appBar: AppBar(
        title: const Text('Hangout Park Eco Quiz'),
        backgroundColor: const Color.fromARGB(255, 64, 100, 81),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: AnimatedGarden(stage: _gardenStage),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final text = question.options[index];
                  final ecoIndex = question.ecoOptionIndex;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _onOptionSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 60,
                              color: _colorForOption(index, ecoIndex),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ANIMATED GARDEN WIDGET
class AnimatedGarden extends StatefulWidget {
  final int stage; // number of eco-friendly picks
  const AnimatedGarden({super.key, required this.stage});

  @override
  State<AnimatedGarden> createState() => _AnimatedGardenState();
}

class _AnimatedGardenState extends State<AnimatedGarden>
    with TickerProviderStateMixin {
  late final AnimationController _butterflyCtrl;

  @override
  void initState() {
    super.initState();
    _butterflyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _butterflyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stage.clamp(0, 99);

    final showGrassLines = s >= 1; // first eco pick
    final showFlowersSmall = s >= 2; // second eco pick
    final showButterflies = s >= 3; // third eco pick+

    return Container(
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // BASE BACKGROUND
            Positioned.fill(
              child: Image.asset(
                "assets/garden/Hangout_minigame.jpg",
                fit: BoxFit.cover,
              ),
            ),

            // STAGE 1: grass lines sprout upward
            Positioned.fill(
              child: _OverlaySprout(
                visible: showGrassLines,
                asset: "assets/garden/grass_lines.png",
                durationMs: 900,
                curve: Curves.easeOutCubic,
              ),
            ),

            // STAGE 2: flower patch
            if (showFlowersSmall) ...[
              // LEFT SIDE
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                left: -52,
                bottom: 115, // upper-left bush flower
                scale: 0.28,
                durationMs: 850,
              ),
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                left: 22,
                bottom: 62, // mid-left bush flower
                scale: 0.22,
                durationMs: 950,
              ),
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                left: 48,
                bottom: 8, // bottom-left big flower
                scale: 0.30,
                durationMs: 1050,
              ),
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                left: 110,
                bottom: 18, // tiny left-bottom scatter
                scale: 0.16,
                durationMs: 1150,
              ),

              // RIGHT SIDE
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                right: 18,
                bottom: 112, // upper-right bush flower
                scale: 0.26,
                durationMs: 900,
              ),
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                right: 28,
                bottom: 66, // mid-right bush flower
                scale: 0.22,
                durationMs: 1000,
              ),
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                right: 44,
                bottom: 14, // bottom-right big flower
                scale: 0.28,
                durationMs: 1100,
              ),

              // BOTTOM / CENTER SCATTER
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                left: 200,
                bottom: 6, // small center-bottom flower
                scale: 0.18,
                durationMs: 1200,
              ),
              _FlowerPatch(
                visible: showFlowersSmall,
                asset: "assets/garden/flowers_small.png",
                right: 120,
                bottom: 4, // tiny right-bottom scatter near corner
                scale: 0.14,
                durationMs: 1300,
              ),
            ],

            // STAGE 3: butterflies float
            if (showButterflies) ...[
              _FlyingButterfly(
                controller: _butterflyCtrl,
                asset: "assets/garden/butterfly_1.png",
                baseX: 0.2,
                baseY: 0.2,
                ampX: 0.10,
                ampY: 0.05,
                size: 45,
              ),
              _FlyingButterfly(
                controller: _butterflyCtrl,
                asset: "assets/garden/butterfly_1.png",
                baseX: 0.78,
                baseY: 0.42,
                ampX: 0.08,
                ampY: 0.07,
                size: 36,
                phase: pi / 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Reveal overlay from bottom
class _OverlaySprout extends StatelessWidget {
  final bool visible;
  final String asset;
  final int durationMs;
  final Curve curve;

  const _OverlaySprout({
    required this.visible,
    required this.asset,
    required this.durationMs,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: visible ? 1 : 0),
      duration: Duration(milliseconds: durationMs),
      curve: curve,
      builder: (context, t, child) {
        final clampedT = t.clamp(0.0, 1.0); // prevents opacity crash

        return ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: clampedT,
            child: Opacity(
              opacity: clampedT,
              child: Transform.scale(
                scale: 0.95 + 0.05 * t,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Image.asset(asset, fit: BoxFit.cover),
    );
  }
}

// Small flower cluster that sprouts + fades in near bottom
class _FlowerPatch extends StatelessWidget {
  final bool visible;
  final String asset;
  final double? left;
  final double? right;
  final double bottom;
  final double scale;
  final int durationMs;

  const _FlowerPatch({
    required this.visible,
    required this.asset,
    this.left,
    this.right,
    required this.bottom,
    required this.scale,
    required this.durationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      bottom: bottom,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: visible ? 1 : 0),
        duration: Duration(milliseconds: durationMs),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          final clampedT = t.clamp(0.0, 1.0);
          return Opacity(
            opacity: clampedT,
            child: Transform.scale(
              scale: (0.7 + 0.3 * clampedT) * scale, // sprout + small
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
        child: Image.asset(asset),
      ),
    );
  }
}

// Butterfly float + gentle flap
class _FlyingButterfly extends StatelessWidget {
  final AnimationController controller;
  final String asset;
  final double baseX, baseY, ampX, ampY;
  final double size;
  final double phase;

  const _FlyingButterfly({
    required this.controller,
    required this.asset,
    required this.baseX,
    required this.baseY,
    required this.ampX,
    required this.ampY,
    required this.size,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final v = controller.value * 2 * pi + phase;
        final dx = sin(v) * ampX;
        final dy = cos(v) * ampY;
        final flap = 0.92 + (sin(v * 2) * 0.07);

        return Positioned.fill(
          child: Align(
            alignment: Alignment(baseX + dx, baseY + dy),
            child: Transform.scale(scale: flap, child: child),
          ),
        );
      },
      child: Image.asset(asset, width: size),
    );
  }
}
