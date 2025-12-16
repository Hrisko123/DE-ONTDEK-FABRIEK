import 'dart:async';
import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:audioplayers/audioplayers.dart';


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
  
  // Part 2 state
  bool _part2Active = false;
  List<int> _truckLanes = [0, 0, 0]; // 0=top, 1=mid, 2=bottom for each truck
  List<_Roadblock> _roadblocks = [];
  Timer? _roadblockSpawnTimer;
  Timer? _part2GameTimer;
  int _part2Time = 0;
  bool _part2GameOver = false;
  Timer? _part2WinTimer;
  List<_PredeterminedRoadblock> _predeterminedPath = [];
  int _pathIndex = 0;
  double _part2ScreenWidth = 0;
  double _part2ScreenHeight = 0;

  String _formatScore(int value) => value >= 0 ? '+$value' : value.toString();

  // --- Drag & lane animation helpers ---
  final Map<int, double> _dragAccum = {}; // accumulated drag distance per truck
  final Map<int, bool> _isDragging = {}; // cursor feedback per truck
  final Map<int, AnimationController> _laneControllers = {};
  final Map<int, Animation<double>> _laneAnimations = {};
  final Map<int, int> _previousLane = {}; // previous lane for interpolation
  final Map<int, bool> _laneChangeInProgress = {}; // prevent multiple lane changes

  Future<void> _playSound(String assetPath) async {
    try {
      final player = AudioPlayer();
      await player.setVolume(0.1);
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.play(AssetSource(assetPath));
      // Dispose player when sound completes
      player.onPlayerComplete.listen((_) {
        try {
          player.dispose();
        } catch (_) {}
      });
      // Safety timeout to dispose player
      Future.delayed(const Duration(seconds: 3), () {
        try {
          player.dispose();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Failed to play sound: $assetPath - $e');
    }
  }

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
        imagePath: 'assets/trucks/taco_truck.png',
      ),
      _TruckInfo(
        name: 'Pizza Truck',
        features: ['Gas oven', 'Plastic plates'],
        color: Colors.red.shade400,
        isEcoFriendly: false,
        ecoScore: -5,
        imagePath: 'assets/trucks/pizza_truck.png',
      ),
      _TruckInfo(
        name: 'Sushi Truck',
        features: ['Hybrid engine', 'Bamboo trays'],
        color: Colors.blue.shade300,
        isEcoFriendly: true,
        ecoScore: 3,
        imagePath: 'assets/trucks/sushi_truck.png',
      ),
      _TruckInfo(
        name: 'Burger Truck',
        features: ['Diesel engine', 'Plastic cups'],
        color: Colors.grey.shade600,
        isEcoFriendly: false,
        ecoScore: -5,
        imagePath: 'assets/trucks/burger_truck.png',
      ),
      _TruckInfo(
        name: 'Salad Truck',
        features: ['Solar fridge', 'Reusable bowls'],
        color: Colors.lightGreen.shade400,
        isEcoFriendly: true,
        ecoScore: 5,
        imagePath: 'assets/trucks/salad_truck.png',
      ),
      _TruckInfo(
        name: 'Coffee Truck',
        features: ['Propane tanks', 'Paper cups'],
        color: Colors.brown.shade400,
        isEcoFriendly: false,
        ecoScore: -3,
        imagePath: 'assets/trucks/coffee_truck.png',
      ),
    ];
    final random = Random();
    _truckSpeeds = List<double>.generate(
      _trucks.length,
      (_) => 0.4 + random.nextDouble() * 0.4, // speeds roughly 0.4-0.8x (slightly faster)
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
    for (final controller in _laneControllers.values) {
      controller.dispose();
    }
    _stopTimers();
    _stopPart2Timers();
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
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Food Truck Run',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'How to Play',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'In this mini-game you will have to collect 3 food trucks by clicking on them for your festival. '
                  'Some food trucks are more eco friendly than others and you will have 30 seconds to complete the game. '
                  'The trucks will come one at a time choose carefully which ones you want for your festival.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startTimers();
                  },
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCarTap(int carIndex) {
    if (_gameFinished ||
        carIndex >= _visibleTrucks ||
        _carsRemoved[carIndex] ||
        _filledCirclesCount >= 3) {
      return; // Already removed or game completed
    }

    // Play truck selection sound
    _playSound('sounds/truck.mp3');

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
            contentPadding: const EdgeInsets.all(24),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Congrats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'You successfully collected 3 food trucks!\n\n'
                    'Total Eco Score: ${_formatScore(_ecoScore)}\n\n'
                    'Now guide your trucks through the roadblocks!',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startPart2();
                    },
                    child: const Text('Start Part 2'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
  
  void _startPart2() {
    setState(() {
      _part2Active = true;
      // Start all trucks in the middle lane
      _truckLanes = [1, 1, 1];
      // initialize previous lanes for interpolation
      for (int i = 0; i < _truckLanes.length; i++) {
        _previousLane[i] = _truckLanes[i];
      }
      _part2Time = 0;
      _part2GameOver = false;
      _roadblocks = [];
      _pathIndex = 0;
    });
    
    _generatePredeterminedPath();
    _startPart2Timers();
  }
  
  void _generatePredeterminedPath() {
    // Generate a path for 30 seconds that always has at least one safe lane
    // Pattern: alternate between lanes, never block all 3 lanes at once
    final random = Random();
    _predeterminedPath = [];
    
    int currentTime = 2500; // Start spawning after 2.5 seconds
    
    while (currentTime < 30000) { // 30 seconds
      // Determine how many blocks to spawn (1-2) - mix of single and double blocks
      final blockCount = random.nextDouble() < 0.75 ? 1 : 2;
      final lanesToSpawn = <int>[];
      
      if (blockCount == 1) {
        // Single block - pick any lane, ensure at least one safe lane remains
        final availableLanes = [0, 1, 2];
        availableLanes.shuffle(random);
        lanesToSpawn.add(availableLanes[0]);
      } else {
        // Two blocks - pick two different lanes, ensure at least one safe lane remains
        final availableLanes = [0, 1, 2];
        availableLanes.shuffle(random);
        lanesToSpawn.add(availableLanes[0]);
        lanesToSpawn.add(availableLanes[1]);
      }
      
      // Add blocks to predetermined path
      for (final lane in lanesToSpawn) {
        _predeterminedPath.add(_PredeterminedRoadblock(
          spawnTime: currentTime,
          lane: lane,
          speed: 0.012 + random.nextDouble() * 0.006,
        ));
      }
      
      // Progress time with moderate difficulty progressio
      final difficultyLevel = (currentTime / 5000).floor();
      final interval = max(1600, 2500 - difficultyLevel * 60);
      currentTime += interval;
    }
    
    // Sort by spawn time
    _predeterminedPath.sort((a, b) => a.spawnTime.compareTo(b.spawnTime));
  }
  
  void _startPart2Timers() {
    // Game timer - spawns from predetermined path
    _part2GameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || _part2GameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        _part2Time += 100;
        
        // Spawn roadblocks from predetermined path
        while (_pathIndex < _predeterminedPath.length && 
               _predeterminedPath[_pathIndex].spawnTime <= _part2Time) {
          final predBlock = _predeterminedPath[_pathIndex];
          _roadblocks.add(_Roadblock(
            lane: predBlock.lane,
            position: 1.0,
            speed: predBlock.speed,
          ));
          _pathIndex++;
        }
        
        // Update roadblock positions
        _roadblocks.removeWhere((block) {
          block.position -= block.speed;
          if (block.position < -0.2) {
            // Roadblock passed
            return true;
          }
          
          // Check collision with trucks using actual visual positions
          if (_part2ScreenHeight == 0 || _part2ScreenWidth == 0) return false;
          
          final screenHeight = _part2ScreenHeight;
          final laneHeight = screenHeight / 3;
          final truckSize = 80.0;
          final roadblockSize = 60.0;
          
          for (int i = 0; i < _truckLanes.length; i++) {
            // Calculate actual visual Y position of truck (with interpolation)
            final targetLane = _truckLanes[i];
            final prevLane = _previousLane[i] ?? targetLane;
            final anim = _laneAnimations[i];
            final fromY = prevLane * laneHeight;
            final toY = targetLane * laneHeight;
            final truckCenterY = (anim != null)
                ? (lerpDouble(fromY, toY, anim.value) ?? toY) + laneHeight / 2
                : toY + laneHeight / 2;
            
            // Calculate roadblock Y position
            final blockCenterY = block.lane * laneHeight + laneHeight / 2;
            
            // Check if truck and roadblock overlap vertically
            final truckTop = truckCenterY - truckSize / 2;
            final truckBottom = truckCenterY + truckSize / 2;
            final blockTop = blockCenterY - roadblockSize / 2;
            final blockBottom = blockCenterY + roadblockSize / 2;
            
            final verticalOverlap = !(truckBottom < blockTop || truckTop > blockBottom);
            
            // Check horizontal overlap (roadblock X position)
            final blockLeft = block.position * _part2ScreenWidth;
            final blockRight = blockLeft + roadblockSize;
            final truckLeft = 50.0 + i * 100.0;
            final truckRight = truckLeft + truckSize;
            
            final horizontalOverlap = !(truckRight < blockLeft || truckLeft > blockRight);
            
            if (verticalOverlap && horizontalOverlap) {
              // Play crash sound
              _playSound('sounds/crash.mp3');
              _handlePart2GameOver();
              return true;
            }
          }
          return false;
        });
      });
    });
    
    // Win condition: survive 30 seconds
    _part2WinTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted || _part2GameOver) return;
      _handlePart2Win();
    });
  }
  
  void _stopPart2Timers() {
    _roadblockSpawnTimer?.cancel();
    _part2GameTimer?.cancel();
    _part2WinTimer?.cancel();
  }
  
  void _handlePart2GameOver() {
    if (_part2GameOver) return;
    setState(() {
      _part2GameOver = true;
    });
    _stopPart2Timers();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(24),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Game Over',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your trucks hit a roadblock!\n\n'
                    'Time Survived: ${(_part2Time / 1000).toStringAsFixed(1)}s\n'
                    'Total Eco Score: ${_formatScore(_ecoScore)}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startPart2();
                        },
                        child: const Text('Replay Game'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Go Back to Map'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
  
  void _handlePart2Win() {
    if (_part2GameOver) return;
    setState(() {
      _part2GameOver = true;
    });
    _stopPart2Timers();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(24),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Congrats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'You successfully guided all your trucks!\n\n'
                    'Total Eco Score: ${_formatScore(_ecoScore)}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startPart2();
                        },
                        child: const Text('Replay Game'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Go Back to Map'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
  
  void _moveTruckToLane(int truckIndex, int lane) {
    if (_part2GameOver || truckIndex >= _truckLanes.length) return;
    final newLane = lane.clamp(0, 2);
    final oldLane = _truckLanes[truckIndex];
    if (oldLane == newLane) return;
    
    // Prevent multiple lane changes - only allow one lane change at a time
    if (_laneChangeInProgress[truckIndex] == true) return;
    
    // Mark lane change as in progress
    _laneChangeInProgress[truckIndex] = true;

    // record previous lane for interpolation
    _previousLane[truckIndex] = oldLane;

    // create controller if needed
    _laneControllers[truckIndex] ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    final controller = _laneControllers[truckIndex]!;
    controller.stop();
    controller.reset();

    // assign animation
    _laneAnimations[truckIndex] = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    )..addListener(() {
        // animation changes need re-render to move the widget smoothly
        if (mounted) setState(() {});
      });
    
    // Reset lane change flag when animation completes
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _laneChangeInProgress[truckIndex] = false;
      }
    });

    // set the logical lane immediately (target)
    _truckLanes[truckIndex] = newLane;

    // play
    controller.forward();
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
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Time\'s Up',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'You collected ${_selectedTrucks.length} out of 3 trucks.\n\n'
                  'Total Eco Score: ${_formatScore(_ecoScore)}',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go Back to Map'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_part2Active) {
      return _buildPart2();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFB3E5FC),
      appBar: AppBar(
        title: const Text('Food Truck Run'),
        backgroundColor: Colors.green.shade700,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 16.0;
          final roadWidth =
              max(constraints.maxWidth - (horizontalPadding * 2), 320.0);
          final roadHeight = max(constraints.maxHeight - 140, 280.0);
          final truckHeight = roadHeight * 0.22;
          final truckWidth = roadWidth * 0.3;
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
                        const Icon(Icons.timer,
                            color: Colors.black87, size: 32),
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
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _truckListenable,
                      builder: (context, child) {
                        final carPositions =
                            List.generate(_visibleTrucks, (index) {
                          final animationValue =
                              _truckAnimations[index].value.clamp(0.0, 1.0);
                          return animationValue * travelDistance;
                        });
                        final laneCount = max(_visibleTrucks, 4);

                        final laneHeight = roadHeight / max(laneCount, 1);
                        return SizedBox(
                          width: roadWidth,
                          height: roadHeight,
                          child: Stack(
                            children: [
                              // Road background with lanes (matching part 2 style)
                              Positioned.fill(
                                child: Column(
                                  children: List.generate(
                                    laneCount,
                                    (index) => _buildLane(
                                      index,
                                      laneHeight,
                                      roadWidth,
                                      index % 2 == 0
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade700,
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
                                            i * (0.9 / max(_visibleTrucks, 1))),
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
  
  Widget _buildPart2() {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      appBar: AppBar(
        title: const Text('Food Truck Run - Part 2'),
        backgroundColor: Colors.green.shade900,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight - kToolbarHeight;
          final laneHeight = screenHeight / 3;
          
          // Update screen dimensions for collision detection
          _part2ScreenWidth = screenWidth;
          _part2ScreenHeight = screenHeight;
          
          return Stack(
            children: [
              // Road background with lanes
              Positioned.fill(
                child: Column(
                  children: [
                    _buildLane(0, laneHeight, screenWidth, Colors.grey.shade800),
                    _buildLane(1, laneHeight, screenWidth, Colors.grey.shade700),
                    _buildLane(2, laneHeight, screenWidth, Colors.grey.shade800),
                  ],
                ),
              ),
              
              // Roadblocks
              ..._roadblocks.map((block) {
                final laneY = block.lane * laneHeight;
                final blockX = block.position * screenWidth;
                return Positioned(
                  left: blockX,
                  top: laneY + laneHeight / 2 - 30,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: const Icon(Icons.block, color: Colors.white, size: 40),
                  ),
                );
              }).toList(),
              
              // Player trucks - optimized with single drag handler and smooth animation
              for (int i = 0; i < _selectedTrucks.length && i < 3; i++)
                Positioned(
                  left: 50 + i * 100, // Maximum horizontal spacing between trucks
                  top: (() {
                    // compute top with interpolation if animating
                    final targetLane = _truckLanes[i];
                    final prevLane = _previousLane[i] ?? targetLane;
                    final anim = _laneAnimations[i];
                    final fromY = prevLane * laneHeight;
                    final toY = targetLane * laneHeight;
                    final lerped = (anim != null)
                        ? lerpDouble(fromY, toY, anim.value) ?? toY
                        : toY;
                    return lerped + laneHeight / 2 - 40;
                  })(),
                  child: MouseRegion(
                    cursor: (_isDragging[i] ?? false)
                        ? SystemMouseCursors.grabbing
                        : SystemMouseCursors.grab,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,

                      onPanStart: (_) {
                        _dragAccum[i] = 0.0;
                        setState(() => _isDragging[i] = true);
                      },

                      onPanUpdate: (details) {
                        // Don't process if lane change is in progress
                        if (_laneChangeInProgress[i] == true) return;
                        
                        _dragAccum[i] = (_dragAccum[i] ?? 0.0) + details.delta.dy;

                        const double minPx = 22.0; // works well for mouse
                        final double threshold =
                            minPx.clamp(0, laneHeight * 0.22); // scales for mobile

                        if (_dragAccum[i]!.abs() >= threshold) {
                          final currentLane = _truckLanes[i];
                          // Only allow one lane change at a time
                          if (_dragAccum[i]! < 0 && currentLane > 0) {
                            _moveTruckToLane(i, currentLane - 1);
                            _dragAccum[i] = 0.0; // reset accumulator immediately
                          } else if (_dragAccum[i]! > 0 && currentLane < 2) {
                            _moveTruckToLane(i, currentLane + 1);
                            _dragAccum[i] = 0.0; // reset accumulator immediately
                          }
                        }
                      },

                      onPanEnd: (_) {
                        _dragAccum[i] = 0.0;
                        _laneChangeInProgress[i] = false; // Reset on gesture end
                        setState(() => _isDragging[i] = false);
                      },

                      onPanCancel: () {
                        _dragAccum[i] = 0.0;
                        _laneChangeInProgress[i] = false; // Reset on gesture cancel
                        setState(() => _isDragging[i] = false);
                      },

                      child: _ChibiTruck(
                        truck: _selectedTrucks[i],
                        size: 80,
                      ),
                    ),
                  ),
                ),
              
              // UI Overlay - Only show timer, no score
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Time: ${(30 - (_part2Time / 1000)).clamp(0.0, 30.0).toStringAsFixed(1)}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              // Instructions overlay
              if (_part2Time < 3000)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Part 2: Avoid the Roadblocks!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Drag your trucks up or down to switch lanes',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Avoid the red roadblocks!',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Survive for 30 seconds!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
  
  Widget _buildLane(int laneIndex, double height, double width, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
      ),
      child: CustomPaint(
        painter: _RoadLinesPainter(),
      ),
    );
  }
}

class _Roadblock {
  int lane;
  double position;
  double speed;
  
  _Roadblock({
    required this.lane,
    required this.position,
    required this.speed,
  });
}

class _PredeterminedRoadblock {
  final int spawnTime; // milliseconds when to spawn
  final int lane; // 0, 1, or 2
  final double speed;
  
  _PredeterminedRoadblock({
    required this.spawnTime,
    required this.lane,
    required this.speed,
  });
}

class _RoadLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // Draw dashed center line
    const dashWidth = 20.0;
    const dashSpace = 15.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(_RoadLinesPainter oldDelegate) => false;
}

class _ChibiTruck extends StatelessWidget {
  final _TruckInfo truck;
  final double size;
  
  const _ChibiTruck({
    required this.truck,
    required this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Main truck body (chibi style - more rounded and cute)
          Container(
            width: size,
            height: size * 0.75,
            decoration: BoxDecoration(
              color: truck.color,
              borderRadius: BorderRadius.circular(size * 0.2),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    truck.name.split(' ')[0], // Just first word for chibi
                    style: TextStyle(
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Chibi wheels
          Positioned(
            bottom: 0,
            left: size * 0.15,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: size * 0.15,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
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
  final String imagePath;

  const _TruckInfo({
    required this.name,
    required this.features,
    required this.color,
    required this.isEcoFriendly,
    required this.ecoScore,
    required this.imagePath,
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
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        truck.imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to old design if image not found
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: truck.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Center(
              child: Text(
                truck.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: height * 0.2,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

