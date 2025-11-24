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
    with TickerProviderStateMixin {
  late final List<_TruckInfo> _trucks;
  late final List<double> _truckSpeeds;
  late final List<AnimationController> _truckControllers;
  late final List<Animation<double>> _truckAnimations;
  late final Listenable _truckListenable;
  late List<bool> _carsRemoved;
  late List<bool> _truckVisible;
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
  bool _trucksRunning = false;
  int _ecoScore = 0;

  String _formatScore(int value) => value >= 0 ? '+$value' : value.toString();

  @override
  void initState() {
    super.initState();
    _trucks = [
      _TruckInfo(
        name: 'Taco Truck',
        features: ['Solar panels', 'Compost bins'],
        color: Colors.orange.shade400,
        isEcoFriendly: true,
        ecoScore: 5,
      ),
      _TruckInfo(
        name: 'Pizza Truck',
        features: ['Gas oven', 'Plastic plates'],
        color: Colors.red.shade400,
        isEcoFriendly: false,
        ecoScore: -5,
      ),
      _TruckInfo(
        name: 'Sushi Truck',
        features: ['Hybrid engine', 'Bamboo trays'],
        color: Colors.blue.shade300,
        isEcoFriendly: true,
        ecoScore: 3,
      ),
      _TruckInfo(
        name: 'Burger Truck',
        features: ['Diesel engine', 'Plastic cups'],
        color: Colors.grey.shade600,
        isEcoFriendly: false,
        ecoScore: -5,
      ),
      _TruckInfo(
        name: 'Salad Truck',
        features: ['Solar fridge', 'Reusable bowls'],
        color: Colors.lightGreen.shade400,
        isEcoFriendly: true,
        ecoScore: 5,
      ),
      _TruckInfo(
        name: 'Coffee Truck',
        features: ['Propane tanks', 'Paper cups'],
        color: Colors.brown.shade400,
        isEcoFriendly: false,
        ecoScore: -3,
      ),
    ];
    final random = Random();
    _truckSpeeds = List<double>.generate(
      _trucks.length,
      (_) => 0.6 + random.nextDouble() * 0.6, // speeds roughly 0.6-1.2x
    );
    _visibleTrucks = min(1, _trucks.length);
    _carsRemoved = List<bool>.filled(_trucks.length, false);
    _truckVisible = List<bool>.filled(_trucks.length, true);
    _truckControllers = List.generate(_trucks.length, (index) {
      final travelMillis = (5200 / _truckSpeeds[index]).round();
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: max(2500, travelMillis)),
      );
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _handleTruckEdgeReset(index);
        }
      });
      return controller;
    });
    _truckAnimations = _truckControllers
        .map(
          (controller) => CurvedAnimation(
            parent: controller,
            curve: Curves.linear,
          ),
        )
        .toList();
    _truckListenable = Listenable.merge(_truckControllers);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_tutorialShown) {
        _tutorialShown = true;
        _showTutorialDialog();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _truckControllers) {
      controller.dispose();
    }
    _stopTimers();
    super.dispose();
  }

  void _startTimers() {
    if (_timersStarted) return;
    _timersStarted = true;
    _startTruckAnimations();
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
      final previousVisible = _visibleTrucks;
      setState(() {
        _visibleTrucks = min(_visibleTrucks + 1, _trucks.length);
      });
      if (_trucksRunning) {
        for (int i = previousVisible; i < _visibleTrucks; i++) {
          _startSingleTruck(i);
        }
      }
    });
  }

  void _stopTimers() {
    _timersStarted = false;
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    _stopTruckAnimations();
  }

  void _startTruckAnimations() {
    if (_trucksRunning) return;
    _trucksRunning = true;
    for (int i = 0; i < _visibleTrucks; i++) {
      _startSingleTruck(i);
    }
  }

  void _stopTruckAnimations() {
    if (!_trucksRunning) return;
    for (final controller in _truckControllers) {
      controller.stop();
    }
    _trucksRunning = false;
  }

  void _startSingleTruck(int index) {
    if (index >= _truckControllers.length) return;
    final controller = _truckControllers[index];
    _truckVisible[index] = true;
    controller.forward(from: 0);
  }

  void _handleTruckEdgeReset(int index) {
    if (!_trucksRunning || index >= _truckControllers.length) return;
    setState(() {
      _truckVisible[index] = false;
    });
    final controller = _truckControllers[index];
    controller.reset();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _gameFinished || !_trucksRunning) return;
      setState(() {
        _truckVisible[index] = true;
      });
      controller.forward(from: 0);
    });
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Text(
            'In this mini-game you will have to collect 3 food trucks by clicking on them for your festival. '
            'Some food trucks are more eco friendly than others and you will have 30 seconds to complete the game. '
            'The trucks will come one at a time choose carefully which ones you want for your festival.',
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
      final selectedTruck = _trucks[carIndex];
      _selectedTrucks.add(selectedTruck);
      _ecoScore += selectedTruck.ecoScore;
      
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
                  const SizedBox(height: 16),
                  Text(
                    'Total Eco Score: ${_formatScore(_ecoScore)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
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
    _stopTimers();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Time\'s Up'),
          content: Text(
            'You collected ${_selectedTrucks.length} out of 3 trucks.\nEco Score: ${_formatScore(_ecoScore)}',
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
          const horizontalPadding = 16.0;
          final roadWidth = max(constraints.maxWidth - (horizontalPadding * 2), 320.0);
          final roadHeight = max(constraints.maxHeight - 140, 280.0);
          final truckHeight = roadHeight * 0.14;
          final truckWidth = roadWidth * 0.2;
          final travelDistance = roadWidth - truckWidth;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: SizedBox()),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, color: Colors.black87, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          '00:${_timeLeft.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                    ),
                  ],
                ),
              ),
              // Road area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _truckListenable,
                      builder: (context, child) {
                        final carPositions = List.generate(_visibleTrucks, (index) {
                          final animationValue =
                              _truckAnimations[index].value.clamp(0.0, 1.0);
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
                                    border:
                                        Border.all(color: Colors.black, width: 3),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                                if (!_carsRemoved[i] && _truckVisible[i])
                                  Positioned(
                                    top: roadHeight *
                                        (0.04 +
                                            i *
                                                (0.9 / max(_visibleTrucks, 1))),
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
  final int ecoScore;

  const _TruckInfo({
    required this.name,
    required this.features,
    required this.color,
    required this.isEcoFriendly,
    required this.ecoScore,
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
    final wheelDiameter = height * 0.28;
    return SizedBox(
      width: width,
      height: height + (wheelDiameter * 0.6),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
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
                      fontWeight: FontWeight.w500,
                      fontSize: height * 0.2,
                      color: Colors.black87,
                    ),
                  ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: truck.features.map((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                '• $feature',
                                style: TextStyle(
                                  fontSize: height * 0.18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: height * 0.12,
                right: height * 0.1,
                child: Container(
                  width: width * 0.22,
                  height: height * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black54, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: wheelDiameter * 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TruckWheel(diameter: wheelDiameter),
                _TruckWheel(diameter: wheelDiameter),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TruckWheel extends StatelessWidget {
  final double diameter;

  const _TruckWheel({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(color: Colors.white, width: diameter * 0.12),
      ),
    );
  }
}

