import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ui_styles.dart';
import 'services/led_service.dart';

class ToiletGamePage extends StatefulWidget {
  const ToiletGamePage({super.key});

  @override
  State<ToiletGamePage> createState() => _ToiletGamePageState();
}

class _ToiletGamePageState extends State<ToiletGamePage> {
  final Random _rnd = Random();
  final List<_FallingItem> _items = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _feedbackMessage;
  bool _feedbackIsGood = false;
  Timer? _feedbackTimer;

  Timer? _gameTimer;
  Timer? _spawnTimer;

  double _bucketX = 0;
  double _bucketWidth = 100;
  double _bucketY = 0;

  // Players score
  int _hearts = 3;
  int _score = 0;
  bool _isRunning = true;
  bool _winGame = false;
  bool _gameOver = false;

  bool _showIntro = true;

  static const int targetToFill = 10;
  static const int numSlots = 3;
  static const double slotWidth = 100;
  static const double slotHeight = 100;

  // Top slots
  late List<_SlotItem?> _slots;

  static final List<_ItemSpec> _specs = <_ItemSpec>[
    _ItemSpec('bananapeel', 'assets/ToiletImage/Bananapeel.png', true),
    _ItemSpec('compost', 'assets/ToiletImage/Compost.png', true),
    _ItemSpec('leaf', 'assets/ToiletImage/Leaf.png', true),
    _ItemSpec('sawdust', 'assets/ToiletImage/Sawdust.png', true),
    _ItemSpec('sigaret', 'assets/ToiletImage/Sigaret.png', false),
    _ItemSpec('chewingum', 'assets/ToiletImage/Chewingum.png', false),
  ];

  @override
  void initState() {
    super.initState();
    _slots = List<_SlotItem?>.filled(numSlots, null);

    // Check assets in console
    for (final s in _specs) {
      rootBundle
          .load(s.asset)
          .then((_) {
            debugPrint('FOUND: ${s.asset}');
          })
          .catchError((e) {
            debugPrint('MISSING: ${s.asset} -> $e');
          });
    }
    rootBundle.load('assets/ToiletImage/Bucket.png');
    rootBundle.load('assets/ToiletImage/Sun.png');
    rootBundle.load('assets/ToiletImage/Cloud.png');
  }

  void _startGame() {
    if (!mounted) return;
    setState(() {
      _showIntro = false;
      _isRunning = true;
      _hearts = 3;
      _score = 0;
      _items.clear();
      _slots = List<_SlotItem?>.filled(numSlots, null);

      // Initialize slots with random items
      for (int i = 0; i < numSlots; i++) {
        _slots[i] = _createSlotItem();
      }
    });

    // Item spawner - fill empty slots
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isRunning || !mounted) return;
      setState(() {
        for (int i = 0; i < numSlots; i++) {
          if (_slots[i] == null) {
            _slots[i] = _createSlotItem();
          }
        }
      });
    });

    // Main loop
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isRunning || !mounted) return;
      _updateGame(16 / 1000);
    });
  }

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  _SlotItem _createSlotItem() {
    final spec = _specs[_rnd.nextInt(_specs.length)];
    return _SlotItem(spec: spec);
  }

  void _onSlotTapped(int slotIndex) {
    if (!_isRunning || _slots[slotIndex] == null) return;

    final item = _slots[slotIndex]!;
    final randomX = _rnd.nextDouble() * (_screenWidth - 36);

    setState(() {
      _items.add(
        _FallingItem(
          x: randomX,
          y: 100 + slotHeight,
          size: 36,
          speed: 200 + _rnd.nextDouble() * 100,
          spec: item.spec,
        ),
      );
      _slots[slotIndex] = null;
    });
  }

  void _updateGame(double dt) {
    setState(() {
      _bucketX = _bucketX.clamp(0.0, _screenWidth - _bucketWidth - 120);
      _bucketY = _screenHeight - 160;

      for (final it in _items) {
        it.y += it.speed * dt;
      }

      final caught = <_FallingItem>[];
      final remove = <_FallingItem>[];

      for (final it in _items) {
        bool caughtByBucket = _checkCollision(it, _bucketX);

        if (caughtByBucket) {
          caught.add(it);
        } else if (it.y > _screenHeight + 60) {
          remove.add(it);
        }
      }

      for (final it in caught) {
        _items.remove(it);
        _audioPlayer.play(AssetSource('ToiletImage/GoodToilet.mp3'));

        // Show feedback
        _feedbackTimer?.cancel();
        if (it.spec.good) {
          _feedbackIsGood = true;
          _score++;
          if (_score >= targetToFill) {
            _isRunning = false;
            _winGame = true;
          }
        } else {
          _feedbackIsGood = false;
          _hearts--;
          if (_hearts <= 0) {
            _isRunning = false;
            _gameOver = true;
          }
        }
        _feedbackMessage = 'show';
        _feedbackTimer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _feedbackMessage = null;
            });
          }
        });
      }

      for (final it in remove) {
        _items.remove(it);
      }
    });

    // Call game completion outside setState
    if (_winGame) {
      _winGame = false;
      _completeGame(5);
    } else if (_gameOver) {
      _gameOver = false;
      _showGameOver();
    }
  }

  bool _checkCollision(_FallingItem it, double bucketX) {
    final bucketLeft = bucketX;
    final bucketRight = bucketX + _bucketWidth;
    final itemLeft = it.x;
    final itemRight = it.x + it.size;
    final bucketTop = _bucketY;
    final itemBottom = it.y + it.size;

    final verticalOverlap = itemBottom >= bucketTop + 10;
    final horizontalOverlap =
        !(itemRight < bucketLeft || itemLeft > bucketRight);
    return verticalOverlap && horizontalOverlap;
  }

  Future<void> _completeGame(int points) async {
    if (!mounted) return;
    _audioPlayer.play(AssetSource('ToiletImage/WinToilet.mp3'));

    debugPrint('🎉 GAME WON! Attempting to award $points points');

    // Add points via LedService
    try {
      await LedService.addPoints(points);
      debugPrint('✅ Points awarded successfully: $points');
    } catch (e) {
      debugPrint('❌ Error adding points: $e');
    }

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Je hebt gewonnen!'),
        content: Text('Goed gedaan! +$points punten'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(c).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGameOver() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Game over'),
        content: const Text('Je hebt alle levens verloren.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(c).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _feedbackTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show intro/instructions until player starts the game
    if (_showIntro) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toilet Game')),
        backgroundColor: const Color.fromARGB(255, 139, 210, 142),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tap de vakjes bovenin om items te laten vallen!\n\n'
                  'Vang de juiste spullen met je emmer.\n\n'
                  'Als je 3x foute dingen vangt ben je af',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: kStartButtonStyle,
                  onPressed: _startGame,
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Toilet Catch')),
      backgroundColor: const Color.fromARGB(255, 135, 206, 235),
      body: Stack(
        children: [
          // Background elements
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(
                  'assets/ToiletImage/Sun.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 120,
            child: SizedBox(
              width: 100,
              height: 60,
              child: Image.asset(
                'assets/ToiletImage/Cloud.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            right: 120,
            top: 140,
            child: SizedBox(
              width: 100,
              height: 60,
              child: Image.asset(
                'assets/ToiletImage/Cloud.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Top slots
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: SizedBox(
              height: slotHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(numSlots, (i) {
                  return Listener(
                    onPointerDown: (_) => _onSlotTapped(i),
                    child: Container(
                      width: slotWidth,
                      height: slotHeight,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        border: Border.all(color: Colors.brown, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _slots[i] != null
                          ? Image.asset(
                              _slots[i]!.spec.asset,
                              fit: BoxFit.contain,
                            )
                          : const SizedBox(),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Falling items
          for (final it in _items)
            Positioned(
              left: it.x,
              top: it.y,
              child: SizedBox(
                width: it.size,
                height: it.size,
                child: Image.asset(it.spec.asset, fit: BoxFit.contain),
              ),
            ),

          // Player bucket (catcher)
          Positioned(
            left: _bucketX,
            top: _bucketY,
            child: Listener(
              onPointerMove: (details) {
                setState(() {
                  _bucketX = (_bucketX + details.delta.dx).clamp(
                    0.0,
                    _screenWidth - _bucketWidth - 120,
                  );
                });
              },
              child: SizedBox(
                width: _bucketWidth,
                height: 80,
                child: Image.asset('assets/ToiletImage/Bucket.png'),
              ),
            ),
          ),

          // Hearts
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final alive = i < _hearts;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.favorite,
                      color: alive ? Colors.red : Colors.grey.shade400,
                      size: 28,
                    ),
                  );
                }),
              ),
            ),
          ),

          // Score bar (rechts)
          Positioned(
            right: 20,
            top: 100,
            child: Container(
              width: 60,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.brown.shade200,
                border: Border.all(color: Colors.brown.shade800, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Filled portion
                  Container(
                    width: double.infinity,
                    height: (400 - 8) * (_score / targetToFill),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade600,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Score text
          Positioned(
            right: 20,
            top: 510,
            child: Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '$_score/$targetToFill',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black,
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

class _ItemSpec {
  final String name;
  final String asset;
  final bool good;
  const _ItemSpec(this.name, this.asset, this.good);
}

class _SlotItem {
  final _ItemSpec spec;
  _SlotItem({required this.spec});
}

class _FallingItem {
  double x;
  double y;
  final double size;
  final double speed;
  final _ItemSpec spec;
  int caughtByPlayer = 0;

  _FallingItem({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.spec,
  });
}
//Github push test