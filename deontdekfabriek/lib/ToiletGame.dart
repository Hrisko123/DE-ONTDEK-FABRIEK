import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ToiletGamePage extends StatefulWidget {
  const ToiletGamePage({super.key});

  @override
  State<ToiletGamePage> createState() => _ToiletGamePageState();
}

class _ToiletGamePageState extends State<ToiletGamePage> {
  final Random _rnd = Random();
  final List<_FallingItem> _items = [];
  StreamSubscription<dynamic>? _gyroSub;

  // gyro tuning
  double _gyroSensitivity = 2350.0;
  double _gyroSmooth = 0.05;
  double _gyroVelocity = 0.0;
  int? _lastGyroMillis;

  Timer? _gameTimer;
  Timer? _spawnTimer;

  double _bucketX = 0;
  double _bucketWidth = 100;
  double _bucketY = 0;
  int _caught = 0;
  int _hearts = 3;
  bool _isRunning = true;

  // Intro flag: show instructions before starting the minigame
  bool _showIntro = true;

  static const int targetToFill = 15;

  static final List<_ItemSpec> _specs = <_ItemSpec>[
    _ItemSpec('bananapeel', 'assets/ToiletImage/Bananapeel.png', true),
    _ItemSpec('compost', 'assets/ToiletImage/Compost.png', true),
    _ItemSpec('leaf', 'assets/ToiletImage/Leaf.png', true),
    _ItemSpec('sawdust', 'assets/ToiletImage/Sawdust.png', true),
    _ItemSpec('sigaret', 'assets/ToiletImage/Sigaret.png', false),
    _ItemSpec('chewingum', 'assets/ToiletImage/Chewingum.png', false),
    _ItemSpec('Bucket', 'assets/ToiletImage/Bucket.png', false),
  ];

  @override
  void initState() {
    super.initState();

    // Check assets in console
    for (final s in _specs) {
      rootBundle.load(s.asset).then((_) {
        debugPrint('FOUND: ${s.asset}');
      }).catchError((e) {
        debugPrint('MISSING: ${s.asset} -> $e');
      });
    }
    rootBundle.load('assets/ToiletImage/Bucket.png');

    // timers and gyro are started when the player taps "Start" (_startGame)
  }

  void _startGame() {
    if (!mounted) return;
    setState(() {
      _showIntro = false;
      _isRunning = true;
      _caught = 0;
      _hearts = 3;
      _items.clear();
    });

    // Item spawner
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!_isRunning || !mounted) return;
      setState(() {
        _items.add(_createRandomItem());
      });
    });

    // Main loop
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isRunning || !mounted) return;
      _updateGame(16 / 1000);
    });

    // Gyroscope subscription
    try {
      _lastGyroMillis = DateTime.now().millisecondsSinceEpoch;
      _gyroSub?.cancel();
      _gyroSub = gyroscopeEvents.listen((dynamic e) {
        try {
          final now = DateTime.now().millisecondsSinceEpoch;
          final dt =
              ((now - (_lastGyroMillis ?? now)) / 1000.0).clamp(0.0, 0.2);
          _lastGyroMillis = now;

          final double rawTilt = (e is GyroscopeEvent) ? e.z : (e?.z ?? 0.0);
          final double targetVel = -rawTilt * _gyroSensitivity;
          _gyroVelocity += (targetVel - _gyroVelocity) * _gyroSmooth;
          final dx = _gyroVelocity * dt;
          if (!mounted) return;

          setState(() {
            _bucketX =
                (_bucketX + dx).clamp(0.0, _screenWidth - _bucketWidth - 120);
          });
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Gyroscope not available: $e');
      _gyroSub = null;
    }
  }

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  _FallingItem _createRandomItem() {
    final spec = _specs[_rnd.nextInt(_specs.length)];
    final size = 36.0 + _rnd.nextDouble() * 36.0;
    final speed = 80.0 + _rnd.nextDouble() * 120.0;
    final x = _rnd.nextDouble() * (_screenWidth - size - 140);
    return _FallingItem(x: x, y: -size, size: size, speed: speed, spec: spec);
  }

  void _updateGame(double dt) {
    setState(() {
      if (_bucketX == 0) _bucketX = (_screenWidth - _bucketWidth) / 2;
      _bucketY = _screenHeight - 160;

      for (final it in _items) {
        it.y += it.speed * dt;
      }

      final caught = <_FallingItem>[];
      final remove = <_FallingItem>[];

      for (final it in _items) {
        if (_checkCollision(it)) {
          caught.add(it);
        } else if (it.y > _screenHeight + 60) {
          remove.add(it);
        }
      }

      for (final it in caught) {
        _items.remove(it);
        if (it.spec.good) {
          _caught++;
          if (_caught >= targetToFill) {
            _isRunning = false;
            _showWin();
          }
        } else {
          _hearts--;
          if (_hearts <= 0) {
            _isRunning = false;
            _showGameOver();
          }
        }
      }

      for (final it in remove) {
        _items.remove(it);
      }
    });
  }

  bool _checkCollision(_FallingItem it) {
    final bucketLeft = _bucketX;
    final bucketRight = _bucketX + _bucketWidth;
    final itemLeft = it.x;
    final itemRight = it.x + it.size;
    final bucketTop = _bucketY;
    final itemBottom = it.y + it.size;

    final verticalOverlap = itemBottom >= bucketTop + 10;
    final horizontalOverlap =
        !(itemRight < bucketLeft || itemLeft > bucketRight);
    return verticalOverlap && horizontalOverlap;
  }

  Future<void> _showWin() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Je hebt gewonnen!'),
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
    _gyroSub?.cancel();
    super.dispose();
  }

  void _togglePauseOrReset() {
    setState(() {
      if (_isRunning) {
        _isRunning = false;
      } else {
        _items.clear();
        _caught = 0;
        _hearts = 3;
        _isRunning = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show intro/instructions until player starts the game
    if (_showIntro) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toilet Catch - Intro')),
        backgroundColor: Colors.blueGrey.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Draai de tablet van links naar rechts om de emmer te bewegen\n\n'
                  'Vang de juiste spullen om een compost toilet te maken!\n\n'
                  'Als je 3x fouten dingen vangt ben je af',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Text('Start', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _bucketX = _bucketX.clamp(0.0, _screenWidth - _bucketWidth - 120);

    return Scaffold(
      appBar: AppBar(title: const Text('Toilet Catch')),
      backgroundColor: Colors.blueGrey.shade50,
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _bucketX = (_bucketX + details.delta.dx).clamp(
              0.0,
              _screenWidth - _bucketWidth - 120,
            );
          });
        },
        child: Stack(
          children: [
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
            Positioned(
              left: _bucketX,
              top: _bucketY,
              child: SizedBox(
                width: _bucketWidth,
                height: 80,
                child: Image.asset('assets/ToiletImage/Bucket.png'),
              ),
            ),
            Positioned(
              right: 16,
              top: 80,
              bottom: 80,
              width: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.brown.shade700, width: 2),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: (_caught / targetToFill).clamp(0.0, 1.0),
                    widthFactor: 1.0,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 90,
              top: 20,
              child: Row(
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
            Positioned(
              left: 12,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
                child: Text('Gevangen: $_caught / $targetToFill'),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: _togglePauseOrReset,
                child: Icon(_isRunning ? Icons.pause : Icons.replay),
              ),
            ),
          ],
        ),
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

class _FallingItem {
  double x;
  double y;
  final double size;
  final double speed;
  final _ItemSpec spec;
  _FallingItem({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.spec,
  });
}
