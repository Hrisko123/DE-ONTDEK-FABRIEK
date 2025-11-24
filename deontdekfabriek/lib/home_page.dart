import 'package:flutter/material.dart';
import 'stage_page.dart';
import 'FoodGame.dart';
import 'FestivalCleanerApp.dart';
import 'HangOutGame.dart';
import 'ToiletGame.dart'; // 👈 make sure this file exists and class name matches

class MyHomePage extends StatefulWidget {
  final String festivalName;

  const MyHomePage({
    super.key,
    required this.festivalName,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _stageCompleted = false;

  // grayscale matrix used in the original code
  static const List<double> _greyMatrix = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  Future<void> _navigateToStage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StagePage(
          festivalName: widget.festivalName,
          onMinigameCompleted: () {
            setState(() => _stageCompleted = true);
          },
        ),
      ),
    );

    if (result == true) {
      setState(() => _stageCompleted = true);
    }
  }

  void _navigateToFoodTruck() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FoodTruckPage()),
    );
  }

  void _navigateToHangout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HangoutQuizPage()),
    );
  }

  void _navigateToWaste() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FestivalCleanerApp()),
    );
  }

  void _navigateToToilet() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ToiletGame()),
      // 👆 if your main widget in ToiletGame.dart has another name,
      // change `ToiletGame` to that class name.
    );
  }

  @override
  Widget build(BuildContext context) {
    final squareSize = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      body: Stack(
        children: [
          // ───────────────── STAGE ─────────────────
          Positioned(
            top: 16,
            left: 16,
            child: ColorFiltered(
              colorFilter: _stageCompleted
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.color,
                    )
                  : const ColorFilter.matrix(_greyMatrix),
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
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/Images/Festival_Colour.png',
                          fit: BoxFit.cover,
                        ),
                      ),
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

          // ───────────────── TOILET (grayscale, with image) ─────────────────
          Positioned(
            top: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(_greyMatrix),
              child: GestureDetector(
                onTap: _navigateToToilet,
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage("assets/Images/Toilets_minigame.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
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

          // ───────────────── WASTE (no picture, just blank card) ─────────────────
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(_greyMatrix),
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
                                color: Colors.black.withOpacity(0.6),
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

          // ───────────────── HANG OUT ─────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(_greyMatrix),
                child: GestureDetector(
                  onTap: _navigateToHangout,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage("assets/garden/Hangout_minigame.jpg"),
                        fit: BoxFit.cover,
                      ),
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
                                color: Colors.black.withOpacity(0.6),
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

          // ───────────────── FOOD TRUCK ─────────────────
          Positioned(
            bottom: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(_greyMatrix),
              child: GestureDetector(
                onTap: _navigateToFoodTruck,
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage("assets/Images/Food_minigame.png"),
                      fit: BoxFit.cover,
                    ),
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
                              color: Colors.black.withOpacity(0.6),
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
