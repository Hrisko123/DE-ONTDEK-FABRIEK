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
                  // Two toilet huts
                  Positioned(
                    left: squareSize * 0.1,
                    bottom: squareSize * 0.15,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Roof
                        Container(
                          width: squareSize * 0.32,
                          height: squareSize * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.brown[800],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: ClipPath(
                            clipper: TriangleClipper(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.brown[900],
                              ),
                            ),
                          ),
                        ),
                        // Hut body
                        Container(
                          width: squareSize * 0.32,
                          height: squareSize * 0.45,
                          decoration: BoxDecoration(
                            color: Colors.brown[600],
                            border: Border.all(color: Colors.brown[900]!, width: 2),
                          ),
                          child: Stack(
                            children: [
                              // Door
                              Positioned(
                                bottom: squareSize * 0.05,
                                left: squareSize * 0.05,
                                right: squareSize * 0.05,
                                child: Container(
                                  height: squareSize * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.brown[800],
                                    border: Border.all(color: Colors.brown[900]!, width: 2),
                                    borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                                    child: Icon(
                                      Icons.wc,
                                      size: squareSize * 0.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: squareSize * 0.1,
                    bottom: squareSize * 0.15,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Roof
                        Container(
                          width: squareSize * 0.32,
                          height: squareSize * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.brown[800],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: ClipPath(
                            clipper: TriangleClipper(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.brown[900],
                              ),
                            ),
                          ),
                        ),
                        // Hut body
                        Container(
                          width: squareSize * 0.32,
                          height: squareSize * 0.45,
                          decoration: BoxDecoration(
                            color: Colors.brown[600],
                            border: Border.all(color: Colors.brown[900]!, width: 2),
                          ),
                          child: Stack(
                            children: [
                              // Door
                              Positioned(
                                bottom: squareSize * 0.05,
                                left: squareSize * 0.05,
                                right: squareSize * 0.05,
                                child: Container(
                                  height: squareSize * 0.35,
                                  decoration: BoxDecoration(
                                    color: Colors.brown[800],
                                    border: Border.all(color: Colors.brown[900]!, width: 2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.wc,
                                      size: squareSize * 0.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    // Two trash bins
                    Positioned(
                      left: squareSize * 0.2,
                      bottom: squareSize * 0.15,
                      child: Container(
                        width: squareSize * 0.25,
                        height: squareSize * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Stack(
                          children: [
                            // Lid
                            Positioned(
                              top: -4,
                              left: -4,
                              right: -4,
                              height: squareSize * 0.12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                                  child: Container(
                                    width: squareSize * 0.15,
                                    height: squareSize * 0.08,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Recycle symbol
                            Positioned(
                              top: squareSize * 0.25,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Icon(
                                  Icons.recycling,
                                  size: squareSize * 0.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: squareSize * 0.2,
                      bottom: squareSize * 0.15,
                      child: Container(
                        width: squareSize * 0.25,
                        height: squareSize * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Stack(
                          children: [
                            // Lid
                            Positioned(
                              top: -4,
                              left: -4,
                              right: -4,
                              height: squareSize * 0.12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[900],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Center(
                                  child: Container(
                                    width: squareSize * 0.15,
                                    height: squareSize * 0.08,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Recycle symbol
                            Positioned(
                              top: squareSize * 0.25,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Icon(
                                  Icons.recycling,
                                  size: squareSize * 0.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    // Tree
                    Positioned(
                      left: squareSize * 0.15,
                      bottom: squareSize * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tree top (leaves)
                          Container(
                            width: squareSize * 0.4,
                            height: squareSize * 0.4,
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              children: [
                                // Highlights
                                Positioned(
                                  top: squareSize * 0.08,
                                  left: squareSize * 0.1,
                                  child: Container(
                                    width: squareSize * 0.15,
                                    height: squareSize * 0.15,
                                    decoration: BoxDecoration(
                                      color: Colors.green[400]!.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Tree trunk
                          Container(
                            width: squareSize * 0.12,
                            height: squareSize * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.brown[700],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bench
                    Positioned(
                      right: squareSize * 0.1,
                      bottom: squareSize * 0.15,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Bench seat
                          Container(
                            width: squareSize * 0.4,
                            height: squareSize * 0.08,
                            decoration: BoxDecoration(
                              color: Colors.brown[800],
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Colors.brown[900]!, width: 1),
                            ),
                          ),
                          // Bench legs
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: squareSize * 0.04,
                                height: squareSize * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.brown[900],
                                ),
                              ),
                              SizedBox(width: squareSize * 0.32),
                              Container(
                                width: squareSize * 0.04,
                                height: squareSize * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.brown[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                  // Food truck body
                  Positioned(
                    bottom: squareSize * 0.15,
                    left: squareSize * 0.1,
                    right: squareSize * 0.1,
                    height: squareSize * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange[700],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Stack(
                        children: [
                          // Truck window
                          Positioned(
                            top: squareSize * 0.08,
                            left: squareSize * 0.12,
                            width: squareSize * 0.25,
                            height: squareSize * 0.2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                            ),
                          ),
                          // Serving window
                          Positioned(
                            top: squareSize * 0.15,
                            right: squareSize * 0.08,
                            width: squareSize * 0.18,
                            height: squareSize * 0.25,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow[100],
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: squareSize * 0.15,
                                  color: Colors.brown[800],
                                ),
                              ),
                            ),
                          ),
                          // Decorative stripes
                          Positioned(
                            top: squareSize * 0.08,
                            left: squareSize * 0.4,
                            right: squareSize * 0.3,
                            height: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            top: squareSize * 0.13,
                            left: squareSize * 0.4,
                            right: squareSize * 0.3,
                            height: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Truck wheels
                  Positioned(
                    bottom: squareSize * 0.08,
                    left: squareSize * 0.15,
                    child: Container(
                      width: squareSize * 0.18,
                      height: squareSize * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: squareSize * 0.1,
                          height: squareSize * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: squareSize * 0.08,
                    right: squareSize * 0.15,
                    child: Container(
                      width: squareSize * 0.18,
                      height: squareSize * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: squareSize * 0.1,
                          height: squareSize * 0.1,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
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


