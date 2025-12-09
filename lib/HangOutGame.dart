import 'package:flutter/material.dart';
import 'dart:math';
import 'ui_styles.dart'; // for kStartButtonStyle
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui'; 

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

class _HangoutQuizPageState extends State<HangoutQuizPage>
    with SingleTickerProviderStateMixin {
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
  bool _muted = false; 

  late final AnimationController _ecoPulseCtrl;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _ecoPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // loop the eco highlight
  }

  @override
  void dispose() {
    _ecoPulseCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ---------- sound helpers ----------
Future<void> _playSfx(String fileName) async {
  if (_muted) return; // if muted, do nothing

  try {
    await _audioPlayer.play(
      AssetSource('audio/$fileName'),
    );
  } catch (e) {
    // ignore for now
  }
}

  void _playStageSound() {
    // clamp just in case, but you have 8 questions max
    final s = _gardenStage.clamp(1, 8);

    switch (s) {
      case 1: // first eco choice – grass appears
        _playSfx('grass.mp3');
        break;
      case 2: // flowers sprout
        _playSfx('blooming.mp3');
        break;
      case 3: // butterflies
        _playSfx('bubbles.mp3');
        break;
      case 4: // bees low
        _playSfx('bees.mp3');
        break;
      case 5: // bees high / extra life
        _playSfx('droplet.mp3');
        break;
      case 6: // magical glow
        _playSfx('glow.mp3');
        break;
      case 7: // fireflies / sparkles
        _playSfx('twinkle.mp3');
        break;
      case 8: // final full garden
        _playSfx('music.mp3');
        break;
      default:
        break;
    }
  }

  // ---------- logic on tap ----------
  void _onOptionSelected(int optionIndex) {
    final question = _questions[_currentIndex];
    final bool isEco = optionIndex == question.ecoOptionIndex;

    setState(() {
      if (isEco) {
        _gardenStage++; // garden grows only on eco answers
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

    // Sounds happen after the UI updates
    if (isEco) {
      _playStageSound(); // play sound based on current stage
    }
  }

  //intro screen
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

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 143, 172, 122),
        appBar: AppBar(
          title: const Text('Hangout Park Eco Quiz'),
          backgroundColor: const Color.fromARGB(255, 64, 100, 81),
          actions: [
            IconButton(
              icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
              onPressed: () {
                setState(() {
                  _muted = !_muted; // toggle true/false
                });
                if (_muted) {
                  _audioPlayer.stop(); // stop any sound already playing
                }
              },
            ),
          ],
        ),

        body: _buildIntro(),
      );
    }

final question = _questions[_currentIndex];

return Scaffold(
  backgroundColor: const Color(0xFF7FB26B),
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    elevation: 0,
    backgroundColor: Colors.black.withOpacity(0.20),
    title: const Text(
      'Hangout Park Eco Quiz',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
        onPressed: () {
          setState(() => _muted = !_muted);
          if (_muted) _audioPlayer.stop();
        },
      ),
    ],
  ),

  // ---------- BODY WITH BIGGER CARD + FLOATING MUTE ----------
  body: Stack(
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth  = constraints.maxWidth.clamp(600.0, 900.0);

          // 👇 taller card than before (and still safe on small screens)
          final cardHeight =
              (constraints.maxHeight * 0.90).clamp(650.0, 790.0);

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                  Color(0xFF81C784),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: cardWidth,
                  maxHeight: cardHeight,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ---------- BIG GARDEN & MUTE BUTTON ----------
                        SizedBox(
                          height: cardHeight * 0.56,   // 🔹 same garden height as before
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: AnimatedGarden(stage: _gardenStage),
                              ),

                              // MUTE BUTTON ON TOP-RIGHT OF THE GARDEN
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _muted = !_muted);
                                    if (_muted) _audioPlayer.stop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _muted ? Icons.volume_off : Icons.volume_up,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                          // ---------- QUESTION COUNTER ----------
                          Text(
                            'Question ${_currentIndex + 1} of ${_questions.length}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // ---------- QUESTION TEXT ----------
                          Text(
                            question.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ---------- ANSWERS----------
                          Expanded(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                question.options.length,
                                (index) {
                                  final text   = question.options[index];
                                  final ecoIdx = question.ecoOptionIndex;
                                  final isEco  = index == ecoIdx;

                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 3),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        onTap: () => _onOptionSelected(index),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 160),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            color: isEco
                                                ? Colors.greenAccent
                                                    .withOpacity(0.12)
                                                : Colors.black
                                                    .withOpacity(0.22),
                                            border: Border.all(
                                              color: isEco
                                                  ? Colors.greenAccent
                                                      .withOpacity(0.9)
                                                  : Colors.white24,
                                              width: isEco ? 2.0 : 1.2,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              if (isEco)
                                                AnimatedBuilder(
                                                  animation: _ecoPulseCtrl,
                                                  builder:
                                                      (context, child) {
                                                    final t =
                                                        _ecoPulseCtrl.value;
                                                    final scaleY = 1 +
                                                        sin(t * 2 * pi) *
                                                            0.25;
                                                    return Transform.scale(
                                                      scaleY: scaleY,
                                                      child: Container(
                                                        width: 8,
                                                        height:
                                                            double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4),
                                                          color: Colors
                                                              .greenAccent
                                                              .shade400,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              else
                                                Container(
                                                  width: 6,
                                                  height: double.infinity,
                                                  decoration:
                                                      BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(4),
                                                    color: Colors.white
                                                        .withOpacity(0.35),
                                                  ),
                                                ),

                                              const SizedBox(width: 14),

                                              Expanded(
                                                child: Text(
                                                  text,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  ),
);
  }
}

// animated garden
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
  final s = widget.stage.clamp(0, 8); // 8 visual stages max

  final showGrassLines   = s >= 1; // stage 1 - grass
  final showFlowersSmall = s >= 2; // stage 2 - flowers
  final showButterflies  = s >= 3; // stage 3 - butterflies
  final showBeesLow      = s >= 4; // stage 4 - bees low
  final showBeesHigh     = s >= 5; // stage 5 - bees high 
  final showGlow         = s >= 6; // stage 6 - glow overlay
  final showFireflies    = s >= 7; // stage 7 - fireflies
  final showCenterAura   = s >= 8; // stage 8 - strong center aura

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
            // STAGE 4: bees low
            if (showBeesLow)
              _BeeLayer(
                controller: _butterflyCtrl,
                baseY: 0.45,
                spreadY: 0.10,
                count: 6,
                size: 12,
                asset: "assets/garden/bee.png", 
              ),

            // STAGE 5: bees high
            if (showBeesHigh)
              _BeeLayer(
                controller: _butterflyCtrl,
                baseY: 0.15,
                spreadY: 0.08,
                count: 5,
                size: 10,
                asset: "assets/garden/bee.png", 
              ),

            // STAGE 6: magical global glow
            if (showGlow)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _butterflyCtrl,
                    builder: (context, _) {
                      final t = (sin(_butterflyCtrl.value * 2 * pi) + 1) / 2;
                      return Container(
                        color: Colors.yellow.withOpacity(0.05 + 0.07 * t),
                      );
                    },
                  ),
                ),
              ),

              // STAGE 7: fireflies
            if (showFireflies)
              _FireflyLayer(
                controller: _butterflyCtrl,
                count: 10,
                size: 9,
              ),

            // STAGE 8: strong center aura
            if (showCenterAura)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _butterflyCtrl,
                    builder: (context, _) {
                      final t = (sin(_butterflyCtrl.value * 2 * pi) + 1) / 2;
                      return Center(
                        child: Container(
                          width: 220 + 40 * t,
                          height: 220 + 40 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.yellowAccent.withOpacity(0.25 + 0.2 * t),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

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

class _BeeLayer extends StatelessWidget {
  final AnimationController controller;
  final double baseY;
  final double spreadY;
  final int count;
  final double size;
  final String asset;

  const _BeeLayer({
    required this.controller,
    required this.baseY,
    required this.spreadY,
    required this.count,
    required this.size,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value * 2 * pi;

            return Stack(
              children: List.generate(count, (i) {
                final phase = t + i * 0.7;
                final x = -0.9 + (i / (count - 1)) * 1.8; // spread width
                final y = baseY + sin(phase) * spreadY;
                final opacity = 0.4 + 0.5 * (sin(phase * 3) + 1) / 2;

                return Align(
                  alignment: Alignment(x, y),
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      width: size * 1.5,
                      height: size * 3.0,
                      child: Image.asset(
                        asset,      
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _FireflyLayer extends StatelessWidget {
  final AnimationController controller;
  final int count;
  final double size;

  const _FireflyLayer({
    required this.controller,
    required this.count,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value * 2 * pi;

            return Stack(
              children: List.generate(count, (i) {
                final phase = t + i * 0.9;
                final x = -0.9 + (i / (count - 1)) * 1.8;
                final y = 0.25 + sin(phase * 1.2) * 0.25;
                final opacity = 0.3 + 0.7 * (sin(phase * 2.5) + 1) / 2;

                return Align(
                  alignment: Alignment(x, y),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.greenAccent.withOpacity(opacity * 0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
