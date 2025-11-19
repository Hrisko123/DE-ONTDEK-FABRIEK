import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodTruckPage(),
      ),
    );
  }

  void _navigateToHangout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HangoutQuizPage(),
      ),
    );
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
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
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
        fit: BoxFit.cover,        // or BoxFit.contain if you prefer
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
          
          // Toilet square 
          Positioned(
            top: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
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
                            color: Colors.black.withValues(alpha: 0.6),
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
          
          // Waste square 
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
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
          
          // Hang out square 
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
                child: GestureDetector(
                  onTap: _navigateToHangout,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 200, 230, 200),
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
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
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

// FOOD TRUCK MINI-GAME
class FoodTruckPage extends StatefulWidget {
  const FoodTruckPage({super.key});

  @override
  State<FoodTruckPage> createState() => _FoodTruckPageState();
}

class _FoodTruckPageState extends State<FoodTruckPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTruckTap(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name truck clicked!'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      appBar: AppBar(
        title: const Text('Food Truck Run'),
        backgroundColor: Colors.green.shade700,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final roadWidth = constraints.maxWidth - 48;
          final roadHeight = constraints.maxHeight * 0.4;
          final truckSize = roadHeight * 0.3;
          final travelDistance = roadWidth - truckSize;

          return Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final truckOneX = _controller.value * travelDistance;
                final truckTwoX = (1 - _controller.value) * travelDistance;

                return SizedBox(
                  width: roadWidth,
                  height: roadHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4E4E4E),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              5,
                              (_) => Container(
                                width: roadWidth * 0.6,
                                height: 4,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: roadHeight * 0.15,
                        left: truckOneX,
                        child: GestureDetector(
                          onTap: () => _handleTruckTap('Green'),
                          child: _TruckSquare(
                            size: truckSize,
                            color: Colors.greenAccent.shade200,
                            label: 'Truck 1',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: roadHeight * 0.15,
                        left: truckTwoX,
                        child: GestureDetector(
                          onTap: () => _handleTruckTap('Purple'),
                          child: _TruckSquare(
                            size: truckSize,
                            color: Colors.deepPurpleAccent.shade100,
                            label: 'Truck 2',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TruckSquare extends StatelessWidget {
  final double size;
  final Color color;
  final String label;

  const _TruckSquare({
    required this.size,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
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
      return Colors.green;        // very eco
    } else if (scoreChange >= 1) {
      return Colors.lightGreen;   // good 
    } else if (scoreChange == 0) {
      return Colors.amber;        // neutral
    } else if (scoreChange >= -2) {
      return Colors.orange;       // bad
    } else {
      return Colors.red;          // very bad
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
        const CircleAvatar(
          radius: 10,
          backgroundColor: Colors.white,
        ),
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
              child: Icon(
                Icons.music_note,
                color: Colors.white70,
                size: 20,
              ),
            ),
            const Positioned(
              top: 32,
              right: 60,
              child: Icon(
                Icons.music_note,
                color: Colors.white70,
                size: 18,
              ),
            ),
            const Positioned(
              top: 18,
              right: 40,
              child: Icon(
                Icons.music_note,
                color: Colors.white54,
                size: 16,
              ),
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
                          // Barra de color según lo eco que es (basado en scoreChange)
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
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

  const ResultPage({super.key, required this.score, required this.onMinigameCompleted});

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
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
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
      text: 'What is the most eco-friendly way to get to a festival?',
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
        'Leave it on the grass for staff.',
        'Return it to the bar / cup return point to be washed.',
        'Throw it in a random bin without checking.',
      ],
      ecoOptionIndex: 1,
    ),
    EcoQuestion(
      text: 'How do you charge your phone?',
      options: [
        'Plug into a random staff-only socket.',
        'Ask for a petrol generator just for you.',
        'Use the shared solar charging station.',
      ],
      ecoOptionIndex: 2,
    ),
    EcoQuestion(
      text: 'How do you keep the hangout area chill?',
      options: [
        'Sing and shout over the music all the time.',
        'Use headphones or move to a quieter corner.',
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
        'Use cosy LED string lights on green / solar power.',
        'Use big old floodlights that waste a lot of energy.',
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
  int _gardenStage = 0; // 0–8. Grows when eco option is selected.

  void _onOptionSelected(int optionIndex) {
    final question = _questions[_currentIndex];

    setState(() {
      // grow garden only for eco-friendly option
      if (optionIndex == question.ecoOptionIndex) {
        _gardenStage++;
      }

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        // finished all questions → simple dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Hangout garden'),
              content: const Text(
                  'Thanks! Your decisions helped the hangout garden grow 🌿'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    });
  }
// instant positive feedback - garden
  Widget _buildGarden() {
    final bool isLastQuestion =
        _currentIndex == _questions.length - 1;

    // Turn _gardenStage (0–8) into 4 visual levels
    int stage;
    if (_gardenStage <= 1) {
      stage = 0; // little sprout
    } else if (_gardenStage <= 3) {
      stage = 1; // small plant
    } else if (_gardenStage <= 6) {
      stage = 2; // small tree + some plants
    } else {
      stage = 3; // full garden
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFA8E6A3), // soft pastel green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade700, width: 2),
      ),
      child: Stack(
        children: [
          // soft hills line at bottom 
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade500,
                    Colors.green.shade700,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
            ),
          ),

          // little sprout / tree trunk
          if (stage >= 0)
            Align(
              alignment: const Alignment(0, 0.2),
              child: Container(
                width: 6,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.brown[700],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

          // first leaves
          if (stage >= 1)
            Align(
              alignment: const Alignment(0, 0.0),
              child: Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

          // extra small plants on the hill
          if (stage >= 2) ...[
            Positioned(
              bottom: 62,
              left: 60,
              child: Icon(Icons.grass,
                  color: Colors.green.shade900, size: 22),
            ),
            Positioned(
              bottom: 60,
              right: 60,
              child: Icon(Icons.grass,
                  color: Colors.green.shade900, size: 22),
            ),
            Positioned(
              bottom: 58,
              left: 120,
              child: Icon(Icons.local_florist,
                  color: Colors.pink.shade300, size: 22),
            ),
          ],
 //final animation (last question)
           if (stage >= 3 || (isLastQuestion && _gardenStage > 0)) ...[
            // sunshine
            Positioned(
              top: 18,
              left: 40,
              child: Icon(Icons.wb_sunny,
                  color: Colors.orange.shade300, size: 30),
            ),
            // sparkles
            Positioned(
              top: 24,
              right: 50,
              child: Icon(Icons.auto_awesome,
                  color: Colors.yellow.shade200, size: 26),
            ),
            Positioned(
              top: 50,
              right: 90,
              child: Icon(Icons.auto_awesome,
                  color: Colors.white70, size: 20),
            ),
            // ladybugs 
            Positioned(
              bottom: 72,
              left: 80,
              child: Icon(Icons.bug_report,
                  color: Colors.red.shade400, size: 20),
            ),
            Positioned(
              bottom: 70,
              right: 80,
              child: Icon(Icons.bug_report,
                  color: Colors.black87, size: 20),
            ),
            // butterflies
            Positioned(
              top: 70,
              left: 110,
              child: Icon(Icons.flutter_dash,
                  color: Colors.lightBlue.shade200, size: 26),
            ),
            Positioned(
              top: 80,
              right: 110,
              child: Icon(Icons.flutter_dash,
                  color: Colors.purple.shade200, size: 26),
            ),
          ],
        ],
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
    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF8BD28E), 
      appBar: AppBar(
        title: const Text('Hangout Park Eco Quiz'),
        backgroundColor: const Color(0xFF787878),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGarden(),
            const SizedBox(height: 16),
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // answer options
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
