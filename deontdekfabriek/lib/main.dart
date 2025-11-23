import 'package:flutter/material.dart';
import 'FoodGame.dart';
import 'FestivalCleanerApp.dart';
import 'dart:math'; //for the hangout garden animation
import 'ToiletGame.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'De Ontdek Fabriek',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _minigameCompleted = false;

  Future<void> _navigateToStage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StagePage(
          onMinigameCompleted: () {
            setState(() {
              _minigameCompleted = true;
            });
          },
        ),
      ),
    );

    if (result == true || _minigameCompleted) {
      setState(() {
        _minigameCompleted = true;
      });
    }
  }

  void _navigateToFoodTruck() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FoodTruckPage()));
  }

  void _navigateToHangout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HangoutQuizPage()));
  }

  void _navigateToWaste() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FestivalCleanerApp()));
  }

  @override
  Widget build(BuildContext context) {
    final squareSize = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      body: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: ColorFiltered(
              colorFilter: _minigameCompleted
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                  : const ColorFilter.matrix([
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
              child: GestureDetector(
                onTap: _navigateToStage,
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // your drawing as background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/Images/Festival_Colour.png', // <- your colored stage image
                          fit: BoxFit.cover, // or BoxFit.contain if you prefer
                        ),
                      ),

                      // keep the stage label overlay
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'stage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: squareSize * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ToiletGamePage(),
                    ),
                  );
                },
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(255, 240, 240, 240),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/ToiletImage/Restroom.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return Container(
                              color: const Color.fromARGB(255, 240, 240, 240),
                              child: const Center(child: Icon(Icons.bathroom)),
                            );
                          },
                        ),
                      ),

                      // Label
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'toilet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: squareSize * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Waste square
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: GestureDetector(
                  onTap: _navigateToWaste,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 245, 245, 245),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'waste',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: squareSize * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

          // Hang out square
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: GestureDetector(
                  onTap: _navigateToHangout,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage("assets/garden/Hangout_minigame.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Label
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'hang out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: squareSize * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

          // Food truck square
          Positioned(
            bottom: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: GestureDetector(
                onTap: _navigateToFoodTruck,
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(255, 250, 250, 250),
                  ),
                  child: Stack(
                    children: [
                      // Label
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'food truck',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: squareSize * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//BUILD YOUR STAGE MINI-GAME
class StageOption {
  final String name;
  final String description;
  final int scoreChange; // how many eco points you win/lose

  const StageOption({
    required this.name,
    required this.description,
    required this.scoreChange,
  });
}

class StageQuestion {
  final String category; // "Lights", "Power"
  final String questionText;
  final List<StageOption> options;

  const StageQuestion({
    required this.category,
    required this.questionText,
    required this.options,
  });
}

class StagePage extends StatefulWidget {
  final VoidCallback onMinigameCompleted;

  const StagePage({super.key, required this.onMinigameCompleted});

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  // 3 decisions for the mini-game
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

  // Current visual configuration of the stage
  Color _colorForScore(int scoreChange) {
    if (scoreChange >= 3) {
      return Colors.green; // very eco
    } else if (scoreChange >= 1) {
      return Colors.lightGreen; // good
    } else if (scoreChange == 0) {
      return Colors.amber; // neutral
    } else if (scoreChange >= -2) {
      return Colors.orange; // bad
    } else {
      return Colors.red; // very bad
    }
  }

  void _onOptionSelected(int optionIndex, StageOption option) {
    setState(() {
      // 1) update score
      _ecoScore += option.scoreChange;

      // 2) next question
      final bool isLastQuestion =
          _currentQuestionIndex == _questions.length - 1;

      if (!isLastQuestion) {
        _currentQuestionIndex++;
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              score: _ecoScore,
              onMinigameCompleted: widget.onMinigameCompleted,
            ),
          ),
        );
      }
    });
  }

  Widget _bandMember(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // head
        const CircleAvatar(radius: 10, backgroundColor: Colors.white),
        const SizedBox(height: 4),
        // body
        Container(
          width: 14,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildStage() {
    return Center(
      child: Container(
        width: 260,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Stack(
          children: [
            // wall
            Positioned(
              left: 16,
              right: 16,
              top: 20,
              bottom: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // floor
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.brown[600],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
            ),

            // Band
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bandMember(const Color.fromARGB(255, 217, 96, 191)),
                  _bandMember(const Color.fromARGB(255, 85, 212, 231)),
                  _bandMember(const Color.fromARGB(255, 240, 193, 105)),
                ],
              ),
            ),

            // musical notes
            const Positioned(
              top: 24,
              left: 50,
              child: Icon(Icons.music_note, color: Colors.white70, size: 20),
            ),
            const Positioned(
              top: 32,
              right: 60,
              child: Icon(Icons.music_note, color: Colors.white70, size: 18),
            ),
            const Positioned(
              top: 18,
              right: 40,
              child: Icon(Icons.music_note, color: Colors.white54, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      appBar: AppBar(
        title: const Text('Stage mini game'),
        backgroundColor: const Color.fromARGB(255, 120, 118, 118),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini stage arriba
            _buildStage(),
            const SizedBox(height: 16),

            // Pregunta centrada (sin "Lights")
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  current.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de opciones
            Expanded(
              child: ListView.builder(
                itemCount: current.options.length,
                itemBuilder: (context, index) {
                  final option = current.options[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _onOptionSelected(index, option),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 63,
                            color: _colorForScore(option.scoreChange),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 10.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.description,
                                    style: const TextStyle(fontSize: 12),
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

            // Texto final: decisión + eco score, centrado y pequeño
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'Decision ${_currentQuestionIndex + 1} of ${_questions.length}   |   Eco score: $_ecoScore',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final VoidCallback onMinigameCompleted;

  const ResultPage({
    super.key,
    required this.score,
    required this.onMinigameCompleted,
  });

  String get _title {
    if (score >= 7) {
      return 'Eco Hero Stage 🌱';
    } else if (score >= 2) {
      return 'Nice Try Stage 🙂';
    } else {
      return 'Eco Disaster Stage 😬';
    }
  }

  String get _message {
    if (score >= 7) {
      return 'Great job! Your stage is very eco-friendly. The environment says thank you!';
    } else if (score >= 2) {
      return 'You made some good choices, but there is still room to improve your stage.';
    } else {
      return 'Your stage is not very eco-friendly.';
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
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Final eco score: $score',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Call the callback to mark minigame as completed
                onMinigameCompleted();
                // Back to festival map - pop twice (ResultPage -> StagePage -> MyHomePage)
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
              child: const Text('Back to festival map'),
            ),
          ],
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

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
              onPressed: () {
                setState(() {
                  _showIntro = false; // SWITCH TO QUESTIONS
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 64, 100, 81),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text(
                "Start",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
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
