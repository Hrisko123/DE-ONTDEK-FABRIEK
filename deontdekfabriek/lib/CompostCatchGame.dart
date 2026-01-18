import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/led_service.dart';

class CompostCatchGame extends StatefulWidget {
  const CompostCatchGame({super.key});

  @override
  State<CompostCatchGame> createState() => _CompostCatchGameState();
}

class _CompostCatchGameState extends State<CompostCatchGame> {
  final Random _rnd = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Game state
  bool _showIntro = true;
  bool _isRunning = false;
  bool _gameFinished = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;

  // 4 Players
  final List<_Player> _players = [];
  final List<_CompostItem> _items = [];
  int _winnerId = -1;

  final Map<int, Offset> _joystickDirections = {
    0: Offset.zero,
    1: Offset.zero,
    2: Offset.zero,
    3: Offset.zero,
  };

  double _arenaWidth = 0;
  double _arenaHeight = 0;

  // Item specs
  static final List<_ItemSpec> _goodItems = [
    _ItemSpec('banana', 'assets/ToiletImage/Bananapeel.png', 7, true),
    _ItemSpec('leaf', 'assets/ToiletImage/Leaf.png', 4, true),
    _ItemSpec('compost', 'assets/ToiletImage/Compost.png', 6, true),
  ];

  static final List<_ItemSpec> _badItems = [
    _ItemSpec('plastic', 'assets/ToiletImage/Chewingum.png', -8, false),
    _ItemSpec('cigarette', 'assets/ToiletImage/Sigaret.png', -12, false),
  ];

  final List<_Wall> _walls = [
    _Wall(x: 100, y: 200, width: 100, height: 30),
    _Wall(x: 400, y: 180, width: 120, height: 28),
    _Wall(x: 700, y: 220, width: 100, height: 30),

    _Wall(x: 250, y: 320, width: 30, height: 100),
    _Wall(x: 500, y: 340, width: 28, height: 110),
    _Wall(x: 750, y: 300, width: 32, height: 120),

    _Wall(x: 300, y: 480, width: 80, height: 28),
    _Wall(x: 600, y: 500, width: 90, height: 30),

    _Wall(x: 820, y: 560, width: 100, height: 28),
    _Wall(x: 910, y: 300, width: 30, height: 150),
  ];

  @override
  void initState() {
    super.initState();
    _initPlayers();
    _configureAudio();
    // Start muziek meteen bij het laden van de game
    _playGameMusic();
  }

  Future<void> _configureAudio() async {
    try {
      await _audioPlayer.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.gain).build(),
      );

      await _sfxPlayer.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );

      try {
        await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      } catch (_) {}
    } catch (e) {
      debugPrint('Failed to configure audio: $e');
    }
  }

  Future<void> _playGameMusic() async {
    try {
      await _audioPlayer.stop();

      await _audioPlayer.setVolume(0.6);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/ToiletMusic3.mp3'));
      debugPrint('✅ CompostCatch background music started');
    } catch (e) {
      debugPrint('❌ Failed to play music: $e');
    }
  }

  void _initPlayers() {
    _players.clear();
    _players.addAll([
      _Player(id: 0, name: 'P1', color: Colors.red),
      _Player(id: 1, name: 'P2', color: Colors.blue),
      _Player(id: 2, name: 'P3', color: Colors.green),
      _Player(id: 3, name: 'P4', color: Colors.orange),
    ]);
  }

  void _startGame() {
    setState(() {
      _showIntro = false;
      _isRunning = true;
      _gameFinished = false;
      _items.clear();
      _winnerId = -1;

      for (var i = 0; i < 4; i++) {
        _joystickDirections[i] = Offset.zero;
      }

      _players[0].setPosition(100, 100);
      _players[1].setPosition(_arenaWidth - 150, 100);
      _players[2].setPosition(100, _arenaHeight - 150);
      _players[3].setPosition(_arenaWidth - 150, _arenaHeight - 150);

      for (var player in _players) {
        player.compostMeter = 0;
      }
    });

    _playGameMusic();

    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!_isRunning || !mounted) return;
      _spawnRandomItem();
    });

    // Main game loop
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isRunning || !mounted) return;
      _updateGame(16 / 1000);
    });
  }

  void _spawnRandomItem() {
    if (_arenaWidth == 0 || _arenaHeight == 0) return;

    if (_items.length >= 25) return;

    final allSpecs = [..._goodItems, ..._badItems];
    final spec = allSpecs[_rnd.nextInt(allSpecs.length)];

    setState(() {
      _items.add(
        _CompostItem(
          spec: spec,
          x: 80 + _rnd.nextDouble() * (_arenaWidth - 160),
          y: 80 + _rnd.nextDouble() * (_arenaHeight - 160),
        ),
      );
    });
  }

  void _updateGame(double dt) {
    if (!_isRunning) return;

    setState(() {
      _items.removeWhere((item) => item.age >= 5.0);

      for (var player in _players) {
        final direction = _joystickDirections[player.id] ?? Offset.zero;

        const speed = 250.0;
        double newX = player.x + direction.dx * speed * dt;
        double newY = player.y + direction.dy * speed * dt;

        newX = newX.clamp(0, _arenaWidth - 50);
        newY = newY.clamp(0, _arenaHeight - 50);

        if (!_checkWallCollision(newX, newY)) {
          player.x = newX;
          player.y = newY;
        }
      }

      final itemsToRemove = <_CompostItem>[];

      for (var player in _players) {
        for (var item in _items) {
          if (_checkCollision(player, item)) {
            player.compostMeter += item.spec.meterChange;
            player.compostMeter = player.compostMeter.clamp(0, 100);

            itemsToRemove.add(item);

            if (item.spec.isGood) {
              _playSfx('ToiletImage/GoodToilet.mp3');
            }

            // Check win condition
            if (player.compostMeter >= 100) {
              _winnerId = player.id;
              _isRunning = false;
              _completeGame(player);
            }
          }
        }
      }

      // Remove collected items
      _items.removeWhere((item) => itemsToRemove.contains(item));
    });
  }

  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Failed to play SFX: $e');
    }
  }

  bool _checkCollision(_Player player, _CompostItem item) {
    const playerSize = 60.0;
    const itemSize = 40.0;

    final dx = (player.x + playerSize / 2) - (item.x + itemSize / 2);
    final dy = (player.y + playerSize / 2) - (item.y + itemSize / 2);
    final distance = sqrt(dx * dx + dy * dy);

    return distance < (playerSize / 2 + itemSize / 2);
  }

  bool _checkWallCollision(double playerX, double playerY) {
    const playerSize = 50.0;

    for (var wall in _walls) {
      if (playerX < wall.x + wall.width &&
          playerX + playerSize > wall.x &&
          playerY < wall.y + wall.height &&
          playerY + playerSize > wall.y) {
        return true;
      }
    }
    return false;
  }

  Future<void> _completeGame(_Player winner) async {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();

    setState(() {
      _gameFinished = true;
    });

    debugPrint('🎉 COMPOST CATCH COMPLETED! Player ${winner.name} won!');
    await LedService.addPoints(5)
        .then((_) {
          debugPrint('✅ Points awarded successfully');
        })
        .catchError((e) {
          debugPrint('❌ Error adding points: $e');
        });

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('${winner.name} Wins!'),
          content: Text(
            '${winner.name} filled their compost meter first!\n\n+5 points',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();

    _audioPlayer.stop();
    _sfxPlayer.stop();
    _audioPlayer.dispose();
    _sfxPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return _buildIntro();
    }

    return _buildGame();
  }

  Widget _buildIntro() {
    return Scaffold(
      appBar: AppBar(title: const Text('Compost Catch')),
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Compost Catch',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '4-Player Multiplayer Party Game\n\n'
                'Use the joysticks in each corner to move!\n\n'
                'Collect the RIGHT compost items:\n'
                '• Green = Good (+points)\n'
                '• Red/Grey = Bad (-points)\n\n'
                'First player to reach 100% wins!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _arenaWidth = constraints.maxWidth;
          _arenaHeight = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF66BB6A),
                        Color(0xFF43A047),
                        Color(0xFF388E3C),
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                  // Gras patroon overlay
                  child: CustomPaint(painter: _GrassPatternPainter()),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF5D4037), width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: -5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              for (var wall in _walls)
                Positioned(
                  left: wall.x,
                  top: wall.y,
                  child: Container(
                    width: wall.width,
                    height: wall.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF78909C),
                          Color(0xFF607D8B),
                          Color(0xFF546E7A),
                        ],
                      ),
                      border: Border.all(color: Color(0xFF37474F), width: 3),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: Offset(3, 3),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: -2,
                          offset: Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: CustomPaint(painter: _StoneWallPainter()),
                  ),
                ),
              for (var item in _items)
                Positioned(
                  left: item.x,
                  top: item.y,
                  child: Opacity(
                    opacity: item.opacity,
                    child: Transform.scale(
                      scale: item.opacity,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          item.spec.asset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            item.spec.isGood ? Icons.eco : Icons.dangerous,
                            color: Colors.black87,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Players
              for (var player in _players)
                Positioned(
                  left: player.x,
                  top: player.y,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CustomPaint(
                          painter: _GardenerPainter(
                            color: player.color,
                            name: player.name,
                          ),
                        ),
                      ),
                      // Meter below player
                      Positioned(
                        top: 60,
                        child: Container(
                          width: 60,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: player.compostMeter / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Joysticks in 4 corners
              _buildJoystick(0, Alignment.bottomLeft),
              _buildJoystick(1, Alignment.bottomRight),
              _buildJoystick(2, Alignment.topLeft),
              _buildJoystick(3, Alignment.topRight),

              // Leaderboard (centered at top)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _players.map((p) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${p.name}: ${p.compostMeter}%',
                            style: TextStyle(
                              color: p.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildJoystick(int playerId, Alignment alignment) {
    const joystickSize = 140.0;
    const knobSize = 60.0;
    const maxDistance = (joystickSize - knobSize) / 2;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onPanStart: (details) {
            // Start tracking
          },
          onPanUpdate: (details) {
            setState(() {
              // Calculate direction from center
              final dx = details.localPosition.dx - joystickSize / 2;
              final dy = details.localPosition.dy - joystickSize / 2;

              // Limit to max distance
              final distance = sqrt(dx * dx + dy * dy);
              if (distance > maxDistance) {
                final ratio = maxDistance / distance;
                _joystickDirections[playerId] = Offset(
                  dx * ratio / maxDistance,
                  dy * ratio / maxDistance,
                );
              } else {
                _joystickDirections[playerId] = Offset(
                  dx / maxDistance,
                  dy / maxDistance,
                );
              }
            });
          },
          onPanEnd: (_) {
            setState(() {
              _joystickDirections[playerId] = Offset.zero;
            });
          },
          onPanCancel: () {
            setState(() {
              _joystickDirections[playerId] = Offset.zero;
            });
          },
          child: Container(
            width: joystickSize,
            height: joystickSize,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: _players[playerId].color, width: 4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Joystick knob
                Transform.translate(
                  offset: Offset(
                    _joystickDirections[playerId]!.dx * maxDistance,
                    _joystickDirections[playerId]!.dy * maxDistance,
                  ),
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: _players[playerId].color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemSpec {
  final String name;
  final String asset;
  final int meterChange;
  final bool isGood;

  const _ItemSpec(this.name, this.asset, this.meterChange, this.isGood);
}

class _CompostItem {
  final _ItemSpec spec;
  double x;
  double y;
  final DateTime spawnTime;

  _CompostItem({required this.spec, required this.x, required this.y})
    : spawnTime = DateTime.now();

  double get age =>
      DateTime.now().difference(spawnTime).inMilliseconds / 1000.0;

  double get opacity {
    if (age < 4.0) return 1.0;
    if (age >= 5.0) return 0.0;
    return 1.0 - (age - 4.0);
  }
}

class _Player {
  final int id;
  final String name;
  final Color color;

  double x = 0;
  double y = 0;
  int compostMeter = 0;

  _Player({required this.id, required this.name, required this.color});

  void setPosition(double newX, double newY) {
    x = newX;
    y = newY;
  }
}

class _Wall {
  final double x;
  final double y;
  final double width;
  final double height;

  _Wall({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class _GrassPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    final random = Random(42);

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 3 + random.nextDouble() * 5;

      paint.color = Color.fromRGBO(
        30 + random.nextInt(40),
        100 + random.nextInt(50),
        30 + random.nextInt(40),
        0.3 + random.nextDouble() * 0.4,
      );

      canvas.drawLine(Offset(x, y), Offset(x + length, y - length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter voor stenen muur textuur
class _StoneWallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final random = Random(123); // Fixed seed

    // Teken stenen patroon
    final stoneWidth = size.width / (size.width > size.height ? 4 : 2);
    final stoneHeight = size.height / (size.height > size.width ? 4 : 2);

    for (double x = 0; x < size.width; x += stoneWidth) {
      for (double y = 0; y < size.height; y += stoneHeight) {
        paint.color = Colors.black.withOpacity(0.15);
        paint.strokeWidth = 2;
        canvas.drawRect(Rect.fromLTWH(x, y, stoneWidth, stoneHeight), paint);

        // Voeg wat scheuren toe voor textuur
        if (random.nextBool()) {
          paint.color = Colors.black.withOpacity(0.1);
          paint.strokeWidth = 1;
          canvas.drawLine(
            Offset(x + random.nextDouble() * stoneWidth, y),
            Offset(x + random.nextDouble() * stoneWidth, y + stoneHeight),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GardenerPainter extends CustomPainter {
  final Color color;
  final String name;

  _GardenerPainter({required this.color, required this.name});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final headPaint = Paint()
      ..color = Colors.brown.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY - 8), 6, headPaint);

    // Ogen (eyes)
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX - 2, centerY - 10), 1.5, eyePaint);
    canvas.drawCircle(Offset(centerX + 2, centerY - 10), 1.5, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY - 6), radius: 2),
      0,
      3.14159,
      false,
      mouthPaint,
    );

    final hatPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 8, centerY - 16, 16, 4),
        const Radius.circular(2),
      ),
      hatPaint,
    );
    // Hat front brim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 9, centerY - 13, 18, 2),
        const Radius.circular(1),
      ),
      hatPaint,
    );

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 5, centerY - 2, 10, 10),
        const Radius.circular(2),
      ),
      bodyPaint,
    );

    final pantsPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(centerX - 5, centerY + 8, 10, 6), pantsPaint);

    final armPaint = Paint()
      ..color = Colors.brown.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - 5, centerY + 2),
      Offset(centerX - 10, centerY + 4),
      armPaint,
    );
    canvas.drawLine(
      Offset(centerX + 5, centerY + 2),
      Offset(centerX + 10, centerY + 4),
      armPaint,
    );

    final legPaint = Paint()
      ..color = Colors.brown.shade700
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - 2, centerY + 14),
      Offset(centerX - 2, centerY + 20),
      legPaint,
    );
    canvas.drawLine(
      Offset(centerX + 2, centerY + 14),
      Offset(centerX + 2, centerY + 20),
      legPaint,
    );

    final shovelPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;
    canvas.drawLine(
      Offset(centerX + 10, centerY + 2),
      Offset(centerX + 12, centerY - 5),
      Paint()
        ..color = Colors.brown.shade800
        ..strokeWidth = 1.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 11, centerY - 6, 3, 3),
        const Radius.circular(1),
      ),
      shovelPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black87),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY + 16),
    );
  }

  @override
  bool shouldRepaint(_GardenerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.name != name;
}
