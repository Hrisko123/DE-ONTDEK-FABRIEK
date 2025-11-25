import 'package:flutter/material.dart';
import 'stage_page.dart';
import 'FoodGame.dart';
import 'FestivalCleanerApp.dart';
import 'HangOutGame.dart';
import 'ToiletGame.dart';
import 'QR.dart';

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
  bool _toiletCompleted = false;
  bool _hangoutCompleted = false;
  bool _foodCompleted = false;
  bool _wasteCompleted = false;

  // ----------- NAVIGATION -----------
  Future<void> _navigateToStage() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StagePage(
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
    setState(() => _foodCompleted = true);
  }

  void _navigateToHangout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HangoutQuizPage()),
    );
    setState(() => _hangoutCompleted = true);
  }

  void _navigateToCleaner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FestivalCleanerApp()),
    );
    setState(() => _wasteCompleted = true);
  }

  void _navigateToToiletGame() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ToiletGamePage()),
    );
    setState(() => _toiletCompleted = true);
  }

  void _navigateToQR() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QR()),   // <-- FIXED (no const)
    );
  }

  // ----------- GRAYSCALE -----------
  ColorFilter _gray(bool completed) {
    return completed
        ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
        : const ColorFilter.matrix([
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]);
  }

  @override
  Widget build(BuildContext context) {
    final squareSize = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      body: Stack(
        children: [
          // ------------------ STAGE ------------------
          Positioned(
            top: 16,
            left: 16,
            child: ColorFiltered(
              colorFilter: _gray(_stageCompleted),
              child: GestureDetector(
                onTap: _navigateToStage,
                child: _buildSquare(
                  squareSize,
                  label: "stage",
                  image: "assets/Images/Festival_Colour.png",
                ),
              ),
            ),
          ),

          // ------------------ TOILET ------------------
          Positioned(
            top: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: _gray(_toiletCompleted),
              child: GestureDetector(
                onTap: _navigateToToiletGame,
                child: _buildSquare(
                  squareSize,
                  label: "toilet",
                  image: "assets/Images/toilet.jpeg",
                ),
              ),
            ),
          ),

          // ------------------ WASTE ------------------
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: _gray(_wasteCompleted),
                child: GestureDetector(
                  onTap: () {
                    _navigateToCleaner();
                    setState(() => _wasteCompleted = true);
                  },
                  child: _buildSquare(
                    squareSize,
                    label: "waste",
                    image: "assets/Images/waste.jpeg",
                  ),
                ),
              ),
            ),
          ),

          // ------------------ HANGOUT ------------------
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ColorFiltered(
                colorFilter: _gray(_hangoutCompleted),
                child: GestureDetector(
                  onTap: _navigateToHangout,
                  child: _buildSquare(
                    squareSize,
                    label: "hang out",
                    image: "assets/garden/Hangout_minigame.jpg",
                  ),
                ),
              ),
            ),
          ),

          // ------------------ FOOD TRUCK ------------------
          Positioned(
            bottom: 16,
            right: 16,
            child: ColorFiltered(
              colorFilter: _gray(_foodCompleted),
              child: GestureDetector(
                onTap: _navigateToFoodTruck,
                child: _buildSquare(
                  squareSize,
                  label: "food truck",
                  image: "assets/Images/food.jpeg",
                ),
              ),
            ),
          ),

          // ------------------ QR BUTTON ------------------
          Positioned(
            bottom: 16,
            left: 16,
            child: GestureDetector(
              onTap: _navigateToQR,
              child: _buildSquare(
                squareSize,
                label: "QR",
                image: "assets/Images/qr_placeholder.png", // you can replace this
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------- SQUARE UI BUILDER -----------
  Widget _buildSquare(double size,
      {required String label, required String image}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: _labelOverlay(label, size),
    );
  }

  Widget _labelOverlay(String text, double size) {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.08,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
