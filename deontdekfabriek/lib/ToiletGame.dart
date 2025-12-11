import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
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
  StreamSubscription<dynamic>? _gyroSub;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _feedbackMessage;
  bool _feedbackIsGood = false;
  Timer? _feedbackTimer;

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
  int _totalPoints = 0;

  bool _showIntro = true;

  static const int targetToFill = 10;

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
          final dt = ((now - (_lastGyroMillis ?? now)) / 1000.0).clamp(
            0.0,
            0.2,
          );
          _lastGyroMillis = now;

          final double rawTilt = (e is GyroscopeEvent) ? e.z : (e?.z ?? 0.0);
          final double targetVel = -rawTilt * _gyroSensitivity;
          _gyroVelocity += (targetVel - _gyroVelocity) * _gyroSmooth;
          final dx = _gyroVelocity * dt;
          if (!mounted) return;

          setState(() {
            _bucketX = (_bucketX + dx).clamp(
              0.0,
              _screenWidth - _bucketWidth - 120,
            );
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
        _audioPlayer.play(AssetSource('ToiletImage/GoodToilet.mp3'));

        // Show feedback
        _feedbackTimer?.cancel();
        if (it.spec.good) {
          _feedbackIsGood = true;
          _caught++;
          if (_caught >= targetToFill) {
            _isRunning = false;
            _showWin();
          }
        } else {
          _feedbackIsGood = false;
          _hearts--;
          if (_hearts <= 0) {
            _isRunning = false;
            _showGameOver();
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

  int _calculatePoints() {
    final double ratio = _caught / targetToFill;
    final int points = (ratio * 10).clamp(0, 10).round();
    return points;
  }

  Future<void> _showWin() async {
    if (!mounted) return;
    _audioPlayer.play(AssetSource('ToiletImage/WinToilet.mp3'));

    _totalPoints = _calculatePoints();
    await LedService.updateLeds(_totalPoints);

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Je hebt gewonnen!'),
        content: Text('Je hebt 10 eco punten verdiend!'),
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
    _feedbackTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show intro/instructions until player starts the game
    if (_showIntro) {
      return Scaffold(
        appBar: AppBar(title: const Text('Toilet game intro')),
        backgroundColor: const Color.fromARGB(255, 139, 210, 142),
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

    _bucketX = _bucketX.clamp(0.0, _screenWidth - _bucketWidth - 120);

    return Scaffold(
      appBar: AppBar(title: const Text('Toilet Catch')),
      backgroundColor: const Color.fromARGB(255, 135, 206, 235),
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
            Positioned(
              left: 200,
              top: 160,
              child: SizedBox(
                width: 100,
                height: 60,
                child: Image.asset(
                  'assets/ToiletImage/Cloud.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
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
            if (_feedbackMessage != null)
              Positioned(
                left: _bucketX + 40,
                top: _bucketY - 40,
                child: Icon(
                  _feedbackIsGood ? Icons.check_circle : Icons.cancel,
                  color: _feedbackIsGood ? Colors.green : Colors.red,
                  size: 32,
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
