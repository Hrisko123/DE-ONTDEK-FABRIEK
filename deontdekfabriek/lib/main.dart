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
          name: 'LED lights',
          description: 'Use much less energy and last longer.',
          scoreChange: 3,
        ),
        StageOption(
          name: 'Old halogen lights',
          description: 'Very bright but waste a lot of electricity.',
          scoreChange: -2,
        ),
      ],
    ),
    StageQuestion(
      category: 'Power',
      questionText: 'How do you power the stage?',
      options: [
        StageOption(
          name: 'Solar panels + batteries',
          description: 'Clean energy from the sun.',
          scoreChange: 3,
        ),
        StageOption(
          name: 'Diesel generator',
          description: 'Noisy and pollutes the air.',
          scoreChange: -3,
        ),
      ],
    ),
    StageQuestion(
      category: 'Materials',
      questionText: 'Which material do you use for the stage floor?',
      options: [
        StageOption(
          name: 'Reused wooden pallets',
          description: 'Reusing materials instead of buying new.',
          scoreChange: 3,
        ),
        StageOption(
          name: 'New plastic panels',
          description: 'Easy to clean but made from plastic.',
          scoreChange: -2,
        ),
      ],
    ),
  ];

  int _currentQuestionIndex = 0;
  int _ecoScore = 0;

  void _onOptionSelected(StageOption option) {
    setState(() {
      _ecoScore += option.scoreChange;

      final bool isLastQuestion =
          _currentQuestionIndex == _questions.length - 1;

      if (!isLastQuestion) {
        _currentQuestionIndex++;
      } else {
        // finished all questions → go to result page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultPage(score: _ecoScore),
          ),
        );
      }
    });
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
                    child: ListTile(
                      title: Text(option.name),
                      subtitle: Text(option.description),
                      onTap: () => _onOptionSelected(option),
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


