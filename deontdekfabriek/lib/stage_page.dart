import 'package:flutter/material.dart';

class StageOption {
  final String name;
  final String description;
  final int scoreChange;

  const StageOption({
    required this.name,
    required this.description,
    required this.scoreChange,
  });
}

class StageQuestion {
  final String category;
  final String questionText;
  final List<StageOption> options;

  const StageQuestion({
    required this.category,
    required this.questionText,
    required this.options,
  });
}

enum BandStyle { rock, techno, pop, dj }

// ─────────────────────────────────────────────────────────────
//  STAGE PAGE
// ─────────────────────────────────────────────────────────────

class StagePage extends StatefulWidget {
  final VoidCallback onMinigameCompleted;
  final String festivalName;

  const StagePage({
    super.key,
    required this.onMinigameCompleted,
    required this.festivalName,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage>
    with SingleTickerProviderStateMixin {
  // QUESTIONS
  final List<StageQuestion> _questions = const [
    StageQuestion(
      category: 'Lights',
      questionText: 'What kind of lights do you use on the main stage?',
      options: [
        StageOption(
          name: 'Only LED lights',
          description: 'Very efficient and long-lasting.',
          scoreChange: 4,
        ),
        StageOption(
          name: 'Mostly LED + some halogen',
          description: 'Better than nothing, but still wastes energy.',
          scoreChange: 1,
        ),
        StageOption(
          name: 'All halogen spotlights',
          description: 'Use a lot of electricity.',
          scoreChange: -2,
        ),
        StageOption(
          name: 'Huge floodlights all night',
          description: 'Looks cool but terrible for energy use.',
          scoreChange: -4,
        ),
      ],
    ),
    StageQuestion(
      category: 'Power',
      questionText: 'How do you power the stage?',
      options: [
        StageOption(
          name: 'Solar panels + batteries',
          description: 'Clean, quiet and renewable.',
          scoreChange: 4,
        ),
        StageOption(
          name: 'Green electricity from the grid',
          description: 'Contracted from renewable sources.',
          scoreChange: 2,
        ),
        StageOption(
          name: 'Normal grid electricity',
          description: 'Depends on how the country produces energy.',
          scoreChange: 0,
        ),
        StageOption(
          name: 'Diesel generator',
          description: 'Polluting and noisy.',
          scoreChange: -4,
        ),
      ],
    ),
    StageQuestion(
      category: 'Materials',
      questionText: 'Which material do you use for the stage floor?',
      options: [
        StageOption(
          name: 'Reused wooden pallets',
          description: 'Reusing materials from previous events.',
          scoreChange: 4,
        ),
        StageOption(
          name: 'New FSC-certified wood',
          description: 'New material but from sustainable forests.',
          scoreChange: 2,
        ),
        StageOption(
          name: 'Metal structure + recycled panels',
          description: 'Durable structure with recycled surface.',
          scoreChange: 1,
        ),
        StageOption(
          name: 'New plastic panels',
          description: 'Easy to clean but not eco-friendly.',
          scoreChange: -3,
        ),
      ],
    ),
  ];

  int _currentQuestionIndex = 0;
  int _ecoScore = 0;
  BandStyle _selectedBand = BandStyle.rock;

  bool _bounceSpeakers = false;

  late final AnimationController _crowdController;

  @override
  void initState() {
    super.initState();
    _crowdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _crowdController.dispose();
    super.dispose();
  }

  // ECO LEVEL
  int get ecoLevel {
    if (_ecoScore >= 6) return 2;
    if (_ecoScore >= 2) return 1;
    return 0;
  }

  Color get _stageMainColor {
    switch (_selectedBand) {
      case BandStyle.rock:
        return Colors.deepPurple.shade700;
      case BandStyle.techno:
        return Colors.blueGrey.shade900;
      case BandStyle.pop:
        return Colors.pinkAccent.shade200;
      case BandStyle.dj:
        return Colors.blueAccent.shade400;
    }
  }

  Color get _lightColor {
    if (ecoLevel == 2) return Colors.greenAccent;
    if (ecoLevel == 1) return Colors.amberAccent;
    return Colors.redAccent;
  }

  String get _bandName {
    switch (_selectedBand) {
      case BandStyle.rock:
        return 'Rock band';
      case BandStyle.techno:
        return 'Techno DJ';
      case BandStyle.pop:
        return 'Pop group';
      case BandStyle.dj:
        return 'Festival DJ';
    }
  }

  String get _bandEmoji {
    switch (_selectedBand) {
      case BandStyle.rock:
        return '🎸';
      case BandStyle.techno:
        return '🎧';
      case BandStyle.pop:
        return '🎤';
      case BandStyle.dj:
        return '🎛️';
    }
  }

  void _onOptionSelected(StageOption option) {
    setState(() {
      _ecoScore += option.scoreChange;
      _bounceSpeakers = !_bounceSpeakers;

      final bool isLast = _currentQuestionIndex == _questions.length - 1;

      if (!isLast) {
        _currentQuestionIndex++;
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              score: _ecoScore,
              bandName: _bandName,
              festivalName: widget.festivalName,
              onMinigameCompleted: widget.onMinigameCompleted,
            ),
          ),
        );
      }
    });
  }

  // BAND SELECTOR
  Widget _buildBandSelector() {
    return Wrap(
      spacing: 8,
      children: [
        _buildBandChip(BandStyle.rock, 'Rock', '🎸'),
        _buildBandChip(BandStyle.techno, 'Techno', '🎧'),
        _buildBandChip(BandStyle.pop, 'Pop', '🎤'),
        _buildBandChip(BandStyle.dj, 'DJ', '🎛️'),
      ],
    );
  }

  Widget _buildBandChip(BandStyle style, String label, String emoji) {
    final bool selected = _selectedBand == style;
    return ChoiceChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (_) => setState(() => _selectedBand = style),
    );
  }

  // SPEAKER ANIMATION
  Widget _buildSpeaker({double? left, double? right, required double bottom}) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      left: left,
      right: right,
      bottom: _bounceSpeakers ? bottom + 4 : bottom,
      child: Container(
        width: 34,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade700),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.circle,
                size: 14, color: Colors.grey.shade300.withOpacity(0.9)),
            const SizedBox(height: 6),
            Icon(Icons.circle,
                size: 20, color: Colors.grey.shade300.withOpacity(0.9)),
          ],
        ),
      ),
    );
  }

  // FULL ANIMATED STAGE
  Widget _buildAnimatedStage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.65;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              // BACK WALL
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _stageMainColor.withOpacity(0.9),
                        _stageMainColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black87, width: 2),
                  ),
                ),
              ),

              // LIGHT BEAMS
              Positioned(
                top: 0,
                left: width * 0.12,
                child: _LightBeam(
                  color: _lightColor.withOpacity(0.7),
                  reverse: false,
                ),
              ),
              Positioned(
                top: 0,
                right: width * 0.12,
                child: _LightBeam(
                  color: _lightColor.withOpacity(0.5),
                  reverse: true,
                ),
              ),

              // FESTIVAL NAME BANNER
              Positioned(
                top: 8,
                left: width * 0.15,
                right: width * 0.15,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.festivalName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),

              // SPEAKERS
              _buildSpeaker(left: 10, bottom: 40),
              _buildSpeaker(right: 10, bottom: 40),

              // STAGE FLOOR
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: height * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade700,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                ),
              ),

              // BAND
              Positioned(
                bottom: height * 0.25 + 10,
                left: 0,
                right: 0,
                child: _BandRow(
                  bandStyle: _selectedBand,
                  ecoLevel: ecoLevel,
                ),
              ),

              // MUSIC NOTES
              const Positioned(
                top: 30,
                left: 24,
                child: Icon(Icons.music_note, color: Colors.white70, size: 22),
              ),
              const Positioned(
                top: 40,
                right: 32,
                child:
                    Icon(Icons.music_note, color: Colors.white54, size: 18),
              ),

              // CROWD ANIMATION
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _crowdController,
                    builder: (context, child) {
                      final t = _crowdController.value;
                      final dy = (t - 0.5) * 6;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: Opacity(
                      opacity: 0.9,
                      child: Text(
                        ecoLevel == 2
                            ? '🙋‍♀️🙋‍♂️🙋‍♀️🎉🙋‍♂️🙋‍♀️🙋‍♂️'
                            : ecoLevel == 1
                                ? '🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️'
                                : '🙋‍♀️🙋‍♂️😐',
                        style: TextStyle(
                          fontSize: width * 0.16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // BAND NAME LABEL
              Positioned(
                left: 12,
                bottom: 6,
                child: Row(
                  children: [
                    Text(
                      _bandEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _bandName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      appBar: AppBar(
        title: const Text('Build your eco stage'),
        backgroundColor: const Color.fromARGB(255, 120, 118, 118),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAnimatedStage(),
            const SizedBox(height: 12),
            _buildBandSelector(),
            const SizedBox(height: 12),

            // QUESTION
            Text(
              current.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // OPTIONS
            Expanded(
              child: ListView.builder(
                itemCount: current.options.length,
                itemBuilder: (context, index) {
                  final option = current.options[index];
                  final color = option.scoreChange >= 3
                      ? Colors.green
                      : option.scoreChange >= 1
                          ? Colors.lightGreen
                          : option.scoreChange == 0
                              ? Colors.amber
                              : option.scoreChange >= -2
                                  ? Colors.orange
                                  : Colors.red;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _onOptionSelected(option),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 70,
                            color: color,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.description,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Text(
              'Decision ${_currentQuestionIndex + 1} of ${_questions.length}  |  Eco score: $_ecoScore',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RESULT PAGE
// ─────────────────────────────────────────────────────────────

class ResultPage extends StatelessWidget {
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

  String get _title {
    if (score >= 7) return 'Eco Hero Stage 🌱';
    if (score >= 2) return 'Nice Try Stage 🙂';
    return 'Eco Disaster Stage 😬';
  }

  String get _message {
    if (score >= 7) {
      return 'Great job! Your stage is very eco-friendly. The environment says thank you!';
    } else if (score >= 2) {
      return 'You made some good choices, but there is still room to improve your stage.';
    } else {
      return 'Your stage is not very eco-friendly. What could you change next time?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      appBar: AppBar(
        title: const Text('Stage result'),
        backgroundColor: const Color.fromARGB(255, 120, 118, 118),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              festivalName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Band: $bandName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Final eco score: $score',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                onMinigameCompleted();
                Navigator.of(context).pop(true); // back to stage
                Navigator.of(context).pop(true); // back to map
              },
              child: const Text('Back to festival map'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LIGHT BEAM WIDGET
// ─────────────────────────────────────────────────────────────

class _LightBeam extends StatelessWidget {
  final Color color;
  final bool reverse;

  const _LightBeam({
    required this.color,
    required this.reverse,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: reverse ? -0.45 : 0.45,
      child: Container(
        width: 60,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BAND ROW WIDGET
// ─────────────────────────────────────────────────────────────

class _BandRow extends StatelessWidget {
  final BandStyle bandStyle;
  final int ecoLevel;

  const _BandRow({
    required this.bandStyle,
    required this.ecoLevel,
  });

  Color get _memberColor {
    if (ecoLevel == 2) return Colors.greenAccent;
    if (ecoLevel == 1) return Colors.amberAccent;
    return Colors.redAccent.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final members = switch (bandStyle) {
      BandStyle.rock => 3,
      BandStyle.techno => 1,
      BandStyle.pop => 3,
      BandStyle.dj => 1,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(members, (index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 4),
            Container(
              width: 16,
              height: 26,
              decoration: BoxDecoration(
                color: _memberColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        );
      }),
    );
  }
}