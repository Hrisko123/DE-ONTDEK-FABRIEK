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
  void _navigateToStage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const StagePage(),
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
            child: GestureDetector(
              onTap: _navigateToStage,
              child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  color: const Color.fromARGB(255, 120, 118, 118),
                ),
                child: Center(
                  child: Text(
                    'stage',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: const Color.fromARGB(255, 120, 118, 118),
              ),
              child: Center(
                child: Text(
                  'toilet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  color: const Color.fromARGB(255, 120, 118, 118),
                ),
                child: Center(
                  child: Text(
                    'waste',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  color: const Color.fromARGB(255, 120, 118, 118),
                ),
                child: Center(
                  child: Text(
                    'hang out',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: const Color.fromARGB(255, 120, 118, 118),
              ),
              child: Center(
                child: Text(
                  'food truck',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
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
  const StagePage({super.key});

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
  String _lightsType = 'basic';   // 'basic', 'led', 'mixed', 'halogen'
  String _powerType = 'grid';     // 'solar', 'greenGrid', 'grid', 'diesel'
  String _floorType = 'plastic';  // 'reusedWood', 'wood', 'plastic';
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
      final currentQuestion = _questions[_currentQuestionIndex];

      // 1) update score
      _ecoScore += option.scoreChange;

      // 2) update how the stage looks based on which question we are in
      if (currentQuestion.category == 'Lights') {
        // you currently have 2 options: index 0 = LED, 1 = Halogen
        _lightsType = (optionIndex == 0) ? 'led' : 'halogen';
      } else if (currentQuestion.category == 'Power') {
        // 0 = Solar, 1 = Diesel
        _powerType = (optionIndex == 0) ? 'solar' : 'diesel';
      } else if (currentQuestion.category == 'Materials') {
        // 0 = Reused wood, 1 = Plastic
        _floorType = (optionIndex == 0) ? 'reusedWood' : 'plastic';
      }

      // 3) next question 
      final bool isLastQuestion =
          _currentQuestionIndex == _questions.length - 1;

      if (!isLastQuestion) {
        _currentQuestionIndex++;
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultPage(score: _ecoScore),
          ),
        );
      }
    });
  }

  Widget _buildStage() {
    // Decide colors / shapes based on the type strings

    // Lights
    Color lightsColor;
    int lightsCount;
    switch (_lightsType) {
      case 'led':
        lightsColor = Colors.greenAccent;
        lightsCount = 6;
        break;
      case 'halogen':
        lightsColor = Colors.orange;
        lightsCount = 3;
        break;
      default:
        lightsColor = Colors.white;
        lightsCount = 4;
    }

    // Floor
    Color floorColor;
    String floorLabel;
    switch (_floorType) {
      case 'reusedWood':
        floorColor = Colors.brown.shade700;
        floorLabel = 'Reused wood';
        break;
      case 'plastic':
      default:
        floorColor = Colors.grey.shade700;
        floorLabel = 'Plastic panels';
        break;
    }

    // Power
    Color powerColor;
    String powerLabel;
    switch (_powerType) {
      case 'solar':
        powerColor = Colors.green.shade700;
        powerLabel = 'Solar';
        break;
      case 'diesel':
        powerColor = Colors.red.shade700;
        powerLabel = 'Diesel';
        break;
      default:
        powerColor = Colors.blueGrey;
        powerLabel = 'Grid';
    }

    return Center(
      child: Container(
        height: 220,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 20, 20, 20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Stack(
          children: [
            // Stage floor
            Positioned(
              bottom: 16,
              left: 32,
              right: 32,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: floorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    floorLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Lights row at the top
            Positioned(
              top: 24,
              left: 32,
              right: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  lightsCount,
                  (_) => Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: lightsColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Power box on the left
            Positioned(
              left: 16,
              bottom: 72,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: powerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    powerLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Stage label
            const Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'MAIN STAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            _buildStage(),
            // Progress text
            Text(
              'Decision ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Simple score display 
            Text(
              'Eco score: $_ecoScore',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Category title
            Text(
              current.category,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Question text
            Text(
              current.questionText,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // Options list
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
                width: 10,
                height: 80,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: const TextStyle(fontSize: 14),
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
          ],
        ),
      ),
    );
  }
}
class ResultPage extends StatelessWidget {
  final int score;

  const ResultPage({super.key, required this.score});

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
                // Back to festival map
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Back to festival map'),
            ),
          ],
        ),
      ),
    );
  }
}


