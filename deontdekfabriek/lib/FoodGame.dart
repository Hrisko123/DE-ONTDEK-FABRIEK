import 'package:flutter/material.dart';

// FOOD TRUCK MINI-GAME
class FoodTruckPage extends StatefulWidget {
  const FoodTruckPage({super.key});

  @override
  State<FoodTruckPage> createState() => _FoodTruckPageState();
}

class _FoodTruckPageState extends State<FoodTruckPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<bool> _carsRemoved = List.generate(5, (_) => false);
  final List<bool> _circlesFilled = List.generate(3, (_) => false);
  int _filledCirclesCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCarTap(int carIndex) {
    if (_carsRemoved[carIndex] || _filledCirclesCount >= 3) {
      return; // Already removed or game completed
    }

    setState(() {
      // Remove the car
      _carsRemoved[carIndex] = true;
      
      // Fill the next empty circle
      for (int i = 0; i < _circlesFilled.length; i++) {
        if (!_circlesFilled[i]) {
          _circlesFilled[i] = true;
          _filledCirclesCount++;
          break;
        }
      }

      // Check if game is complete
      if (_filledCirclesCount >= 3) {
        _controller.stop();
        Future.delayed(const Duration(milliseconds: 500), () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Game Complete'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to main page
                    },
                    child: const Text('Back to Map'),
                  ),
                ],
              );
            },
          );
        });
      }
    });
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
          final roadHeight = constraints.maxHeight * 0.7;
          final carSize = roadHeight * 0.3;
          final travelDistance = roadWidth - carSize;

          return Column(
            children: [
              // Road area
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Calculate positions for 5 cars at different lanes and phases
                      final carPositions = List.generate(5, (index) {
                        // Different animation phases for each car
                        final phase = index * 0.2; // Stagger the animations
                        final animationValue = (_controller.value + phase) % 1.0;
                        return animationValue * travelDistance;
                      });

                      return SizedBox(
                        width: roadWidth,
                        height: roadHeight,
                        child: Stack(
                          children: [
                            // Road background
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
                            // 5 cars at different vertical positions
                            for (int i = 0; i < 5; i++)
                              if (!_carsRemoved[i])
                                Positioned(
                                  top: roadHeight * (0.05 + i * 0.14),
                                  left: carPositions[i],
                                  child: GestureDetector(
                                    onTap: () => _handleCarTap(i),
                                    child: _CarSquare(
                                      size: carSize,
                                      color: [
                                        Colors.green.shade400,      // Eco-friendly
                                        Colors.red.shade400,        // Not eco-friendly
                                        Colors.green.shade500,      // Eco-friendly
                                        Colors.grey.shade600,       // Not eco-friendly
                                        Colors.lightGreen.shade400, // Eco-friendly
                                      ][i],
                                      label: [
                                        'Solar\nElectric',
                                        'Gas\nTruck',
                                        'Hybrid\nCar',
                                        'Diesel\nVan',
                                        'Eco\nBus',
                                      ][i],
                                      isEcoFriendly: [
                                        true,
                                        false,
                                        true,
                                        false,
                                        true,
                                      ][i],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Circles at the bottom
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _circlesFilled[index] 
                            ? Colors.green 
                            : Colors.grey.shade300,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CarSquare extends StatelessWidget {
  final double size;
  final Color color;
  final String label;
  final bool isEcoFriendly;

  const _CarSquare({
    required this.size,
    required this.color,
    required this.label,
    required this.isEcoFriendly,
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: size * 0.12,
            ),
          ),
        ),
      ),
    );
  }
}

