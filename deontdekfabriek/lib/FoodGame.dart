import 'dart:async';
import 'dart:math';

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
  late final List<_TruckInfo> _trucks;
  late final List<double> _truckSpeeds;
  late List<bool> _carsRemoved;
  final List<bool> _circlesFilled = List.generate(3, (_) => false);
  final List<_TruckInfo> _selectedTrucks = [];
  Timer? _countdownTimer;
  Timer? _spawnTimer;
  int _timeLeft = 30;
  int _visibleTrucks = 2;
  bool _gameFinished = false;
  int _filledCirclesCount = 0;
  bool _timersStarted = false;
  bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
    _trucks = [
      _TruckInfo(
        name: 'Taco Truck',
        features: ['Solar panels', 'Veggie fillings', 'Compost bins'],
        color: Colors.orange.shade400,
        isEcoFriendly: true,
      ),
      _TruckInfo(
        name: 'Pizza Truck',
        features: ['Gas oven', 'Plastic plates', 'Meat heavy menu'],
        color: Colors.red.shade400,
        isEcoFriendly: false,
      ),
      _TruckInfo(
        name: 'Sushi Truck',
        features: ['Hybrid engine', 'Local fish', 'Bamboo trays'],
        color: Colors.blue.shade300,
        isEcoFriendly: true,
      ),
      _TruckInfo(
        name: 'Burger Truck',
        features: ['Diesel engine', 'Plastic cups', 'Paper napkins'],
        color: Colors.grey.shade600,
        isEcoFriendly: false,
      ),
      _TruckInfo(
        name: 'Salad Truck',
        features: ['Solar fridge', 'Reusable bowls', 'Vegan options'],
        color: Colors.lightGreen.shade400,
        isEcoFriendly: true,
      ),
      _TruckInfo(
        name: 'Coffee Truck',
        features: ['Propane tanks', 'Paper cups', 'Fair-trade beans'],
        color: Colors.brown.shade400,
        isEcoFriendly: false,
      ),
    ];
    final random = Random();
    _truckSpeeds = List<double>.generate(
      _trucks.length,
      (_) => 0.6 + random.nextDouble() * 0.9, // keep speeds between 0.6-1.5x
    );
    _visibleTrucks = min(1, _trucks.length);
    _carsRemoved = List<bool>.filled(_trucks.length, false);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_tutorialShown) {
        _tutorialShown = true;
        _showTutorialDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopTimers();
    super.dispose();
  }

  void _startTimers() {
    if (_timersStarted) return;
    _timersStarted = true;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameFinished) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          _handleTimeUp();
        }
      });
    });

    _spawnTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || _gameFinished) return;
      if (_visibleTrucks >= _trucks.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _visibleTrucks = min(_visibleTrucks + 1, _trucks.length);
      });
    });
  }

  void _stopTimers() {
    _timersStarted = false;
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Text(
            'In this mini-game you will have to collect 3 food trucks for your festival. '
            'You will have 30 seconds. The trucks will come one at a time choose careful '
            'which ones you want for your festival.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTimers();
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _handleCarTap(int carIndex) {
    if (_gameFinished || carIndex >= _visibleTrucks || _carsRemoved[carIndex] || _filledCirclesCount >= 3) {
      return; // Already removed or game completed
    }

    setState(() {
      // Remove the car
      _carsRemoved[carIndex] = true;
      _selectedTrucks.add(_trucks[carIndex]);
      
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
        _handleSuccess();
      }
    });
  }

  void _handleSuccess() {
    if (_gameFinished) return;
    _gameFinished = true;
    _controller.stop();
    _stopTimers();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Game Complete'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You picked:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedTrucks.map(
                    (truck) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            truck.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            truck.features.join(' • '),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  void _handleTimeUp() {
    if (_gameFinished) return;
    _gameFinished = true;
    _controller.stop();
    _stopTimers();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Time\'s Up'),
          content: Text(
            'You collected ${_selectedTrucks.length} out of 3 trucks.',
          ),
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
          final roadWidth = max(constraints.maxWidth - 16, 320.0);
          final roadHeight = constraints.maxHeight * 0.82;
          final truckHeight = roadHeight * 0.18;
          final truckWidth = roadWidth * 0.28;
          final travelDistance = roadWidth - truckWidth;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      '00:${_timeLeft.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Road area
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Calculate positions for trucks at different lanes and phases
                      final carPositions = List.generate(_visibleTrucks, (index) {
                        // Different animation phases and speeds for each truck
                        final phase = index * 0.2; // Stagger the animations
                        final speed = _truckSpeeds[index];
                        final animationValue =
                            ((_controller.value * speed) + phase) % 1.0;
                        return animationValue * travelDistance;
                      });
                      final laneCount = max(_visibleTrucks, 4);

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
                                    laneCount,
                                    (_) => Container(
                                      width: roadWidth * 0.6,
                                      height: 4,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // trucks at different vertical positions
                            for (int i = 0; i < _visibleTrucks; i++)
                              if (!_carsRemoved[i])
                                Positioned(
                                  top: roadHeight *
                                      (0.04 + i * (0.9 / max(_visibleTrucks, 1))),
                                  left: carPositions[i],
                                  child: GestureDetector(
                                    onTap: () => _handleCarTap(i),
                                    child: _TruckCard(
                                      width: truckWidth,
                                      height: truckHeight,
                                      truck: _trucks[i],
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

class _TruckInfo {
  final String name;
  final List<String> features;
  final Color color;
  final bool isEcoFriendly;

  const _TruckInfo({
    required this.name,
    required this.features,
    required this.color,
    required this.isEcoFriendly,
  });
}

class _TruckCard extends StatelessWidget {
  final double width;
  final double height;
  final _TruckInfo truck;

  const _TruckCard({
    required this.width,
    required this.height,
    required this.truck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: truck.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              truck.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: height * 0.2,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: truck.features.map((feature) {
                    return Text(
                      '• $feature',
                      style: TextStyle(
                        fontSize: height * 0.12,
                        color: Colors.black87,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

