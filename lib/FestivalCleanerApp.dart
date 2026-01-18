import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FestivalCleanerApp extends StatelessWidget {
  const FestivalCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CleanerGame();
  }
}

class TrashItem {
  /// Types:
  /// - cup       → herbruikbare beker
  /// - food      → GFT / eten (appel, banaan)
  /// - plastic   → plastic fles / blik
  /// - cigarette → sigarettenpeuk (restafval)
  final int id;
  final String type;
  final String? assetPath;
  double x; // 0–1 (relative to screen width)
  double y; // 0–1 (relative to screen height)
  int age;

  TrashItem({
    required this.id,
    required this.type,
    this.assetPath,
    required this.x,
    required this.y,
    this.age = 0,
  });
}

/// Spawn zones (normalized 0–1 of the screen)
class SpawnZone {
  final double left;
  final double top;
  final double width;
  final double height;

  const SpawnZone({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class CleanerGame extends StatefulWidget {
  const CleanerGame({super.key});

  @override
  State<CleanerGame> createState() => _CleanerGameState();
}

class _CleanerGameState extends State<CleanerGame> {
  int phase = 0; // 0 = intro, 1 = game, 2 = result

  // ✅ Background precache starts in background during intro (NO overlay at app open)
  bool _precacheStarted = false;
  Future<void>? _assetPrecacheFuture;

  // ✅ Loading overlay shown ONLY right before the game starts
  bool _showStartGameLoader = false;

  // Game state
  List<TrashItem> trashItems = [];
  int _nextId = 0;

  // Timing
  Timer? gameTimer;
  int tick = 0;
  final int maxTicks = 40;
  final int maxTrashAge = 8;

  // ✅ Points (10..0)
  static const int maxPoints = 10;
  int points = maxPoints;
  bool _failedByPoints = false;

  // ✅ GUARANTEE AT LEAST 10 TRASH SPAWNS, but paced
  static const int minTrashToSpawn = 10;

  // Keep clutter down
  static const int maxTrashOnScreen = 7;

  // after hitting 10 spawns, occasional extras
  static const double extraSpawnChance = 0.22;

  int _spawnedTrashCount = 0;

  // paced guarantee schedule (ticks are seconds)
  // spawn-check happens every 2 seconds (tick % 2 == 0)
  final List<int> _guaranteedTicks =
      const [2, 4, 6, 10, 14, 18, 21, 23, 26, 30, 34, 36, 38];
  int _guaranteeIndex = 0;

  // Stats
  int correctlySorted = 0;
  int missedTrash = 0;
  int wrongSorting = 0;

  // Cleaner animation (2-frame puppet)
  final String _cleanerIdleAsset = 'assets/trashGame/Cleaner/puppet1.png';
  final String _cleanerSweepAsset = 'assets/trashGame/Cleaner/puppet2.png';
  bool _cleanerUseFirstFrame = true;
  Timer? _cleanerAnimTimer;

  // Random for spawns
  final Random random = Random();

  // AUDIO
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer;
  double _bgVolume = 0.5;

  final String _introOutroTrack = 'trashGame/audio/golden instrumental.mp3';

  final List<String> _bgTracks = [
    'trashGame/audio/Soda pop (Instrumental).mp3',
  ];

  // ---------- BACKGROUNDS (YOUR FLOW) ----------
  final String _bgNormal =
      'assets/trashGame/BackgroundFlow/Background_Normal.png';
  final String _bgMoodLow =
      'assets/trashGame/BackgroundFlow/Background_Moodlow.png';
  final String _bgMoodLowest =
      'assets/trashGame/BackgroundFlow/Background_MoodLowest.png';
  final String _bgNoDancing = 'assets/trashGame/BackgroundFlow/NoDancing.png';
  final String _bgNoDancingNoPlant =
      'assets/trashGame/BackgroundFlow/NoDancingNoPlant.png';
  final String _bgNoDancingNoPlantNoNormal =
      'assets/trashGame/BackgroundFlow/NoDancingNoPlantNoNormal.png';
  final String _bgEmpty =
      'assets/trashGame/BackgroundFlow/Background_Empty.png';

  // ✅ Fail GIF at 0 points
  final String _bgEndIfDoneWrong =
      'assets/trashGame/BackgroundFlow/EndIfDoneWrong.gif';

  late final List<String> _allGameBackgrounds = [
    _bgNormal,
    _bgMoodLow,
    _bgMoodLowest,
    _bgNoDancing,
    _bgNoDancingNoPlant,
    _bgNoDancingNoPlantNoNormal,
    _bgEmpty,
    _bgEndIfDoneWrong,
  ];

  final List<String> _introBackgrounds = [
    'assets/trashGame/Intro and Outro/1.png',
    'assets/trashGame/Intro and Outro/2.png',
    'assets/trashGame/Intro and Outro/3.png',
    'assets/trashGame/Intro and Outro/4.png',
  ];

  final String _outroBackground = 'assets/trashGame/Intro and Outro/outro.png';

  int _introPage = 0;

  final Map<String, String> trashEmojis = {
    "cup": "🥤",
    "food": "🍌",
    "plastic": "🧴",
    "cigarette": "🚬",
  };

  // Bin visuals
  final Map<String, String> binAssetPaths = {
    "gft": "assets/trashGame/gft_bak.png",
    "rest": "assets/trashGame/restafval_bak.png",
    "plastic": "assets/trashGame/plastic_bak.png",
    "cups": "assets/trashGame/herbruikbeker_bin.png",
  };

  final Map<String, String> binEmojis = {
    "gft": "🍌",
    "rest": "🗑️",
    "plastic": "🧴",
    "cups": "🥤",
  };

  final List<SpawnZone> spawnZones = const [
    SpawnZone(left: 0.067, top: 0.396, width: 0.018, height: 0.120),
    SpawnZone(left: 0.097, top: 0.494, width: 0.044, height: 0.084),
    SpawnZone(left: 0.097, top: 0.647, width: 0.162, height: 0.092),
    SpawnZone(left: 0.154, top: 0.515, width: 0.030, height: 0.105),
    SpawnZone(left: 0.205, top: 0.528, width: 0.210, height: 0.092),
    SpawnZone(left: 0.231, top: 0.761, width: 0.044, height: 0.239),
    SpawnZone(left: 0.515, top: 0.550, width: 0.164, height: 0.058),
    SpawnZone(left: 0.632, top: 0.437, width: 0.075, height: 0.078),
    SpawnZone(left: 0.735, top: 0.777, width: 0.050, height: 0.198),
    SpawnZone(left: 0.815, top: 0.554, width: 0.071, height: 0.061),
  ];

  @override
  void initState() {
    super.initState();
    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _configureAudio();
      if (!mounted) return;
      await _playIntroOutroMusic();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;

    // ✅ Start precaching while intro is showing (no overlay yet)
    _assetPrecacheFuture = _precacheAssets(context);
  }

  Future<void> _configureAudio() async {
    await _bgPlayer.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.gain).build(),
    );

    await _sfxPlayer.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );

    try {
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {}

    await _bgPlayer.setVolume(_bgVolume);
    await _sfxPlayer.setVolume(1.0);
  }

  Future<void> _precacheAssets(BuildContext context) async {
    for (final path in _allGameBackgrounds) {
      await precacheImage(AssetImage(path), context);
    }

    for (final path in _introBackgrounds) {
      await precacheImage(AssetImage(path), context);
    }

    await precacheImage(AssetImage(_outroBackground), context);

    // IMPORTANT: precache both cleaner frames + bins
    await precacheImage(AssetImage(_cleanerIdleAsset), context);
    await precacheImage(AssetImage(_cleanerSweepAsset), context);

    for (final path in binAssetPaths.values) {
      await precacheImage(AssetImage(path), context);
    }

    const trashAssetPaths = [
      'assets/trashGame/applee.png',
      'assets/trashGame/banana.png',
      'assets/trashGame/plastic_bottle.png',
      'assets/trashGame/sigy.png',
      'assets/trashGame/herbruikbare_beker.png',
    ];
    for (final path in trashAssetPaths) {
      await precacheImage(AssetImage(path), context);
    }
  }

  // ✅ Background depends on points (10..0)
  String _currentGameBackground() {
    if (points <= 0) return _bgEndIfDoneWrong;

    final mistakes = maxPoints - points;

    if (mistakes == 0) return _bgNormal;
    if (mistakes == 1) return _bgMoodLow;
    if (mistakes == 2) return _bgMoodLowest;
    if (mistakes == 3) return _bgNoDancing;
    if (mistakes == 4) return _bgNoDancingNoPlant;
    if (mistakes == 5) return _bgNoDancingNoPlantNoNormal;

    return _bgEmpty;
  }

  void _losePoint() {
    points -= 1;
    if (points < 0) points = 0;
  }

  void _gainPoint() {
    points += 1;
    if (points > maxPoints) points = maxPoints;
  }

  void _endGame({required bool failed}) {
    gameTimer?.cancel();
    _failedByPoints = failed;
    setState(() {
      phase = 2;
    });
    _playIntroOutroMusic();
  }

  // ---------------- AUDIO ----------------

  Future<void> _playIntroOutroMusic() async {
    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(_bgVolume);
      await _bgPlayer.play(AssetSource(_introOutroTrack));
    } catch (e) {
      debugPrint("INTRO/OUTRO failed ($_introOutroTrack): $e");
    }
  }

  Future<void> _playGameMusic() async {
    if (_bgTracks.isEmpty) return;
    final track = _bgTracks[random.nextInt(_bgTracks.length)];

    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(_bgVolume);
      await _bgPlayer.play(AssetSource(track));
    } catch (e) {
      debugPrint("GAME MUSIC failed ($track): $e");
    }
  }

  Future<void> _playSfx(String asset) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint("SFX failed ($asset): $e");
    }
  }

  Future<void> _playSpawnSound() => _playSfx('trashGame/audio/TrashSpawn.mp3');
  Future<void> _playPickupSound() =>
      _playSfx('trashGame/audio/pickupTrash.mp3');
  Future<void> _playBinnedSound() => _playSfx('trashGame/audio/binnedTrash.mp3');

  IconData _bgVolumeIcon() {
    if (_bgVolume == 0) return Icons.volume_off;
    if (_bgVolume < 0.4) return Icons.volume_mute;
    if (_bgVolume < 0.8) return Icons.volume_down;
    return Icons.volume_up;
  }

  void _cycleBgVolume() {
    setState(() {
      if (_bgVolume == 0) {
        _bgVolume = 0.3;
      } else if (_bgVolume < 0.4) {
        _bgVolume = 0.6;
      } else if (_bgVolume < 0.8) {
        _bgVolume = 1.0;
      } else {
        _bgVolume = 0.0;
      }
    });
    _bgPlayer.setVolume(_bgVolume);
  }

  // ---------------- CLEANER ANIMATION ----------------

  void _startCleaningAnim() {
    _cleanerAnimTimer?.cancel();
    int ticks = 0;

    _cleanerAnimTimer =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;

      setState(() {
        _cleanerUseFirstFrame = !_cleanerUseFirstFrame;
      });

      ticks++;
      if (ticks >= 4) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _cleanerUseFirstFrame = true;
          });
        }
      }
    });
  }

  Future<void> _waitFrames(int n) async {
    for (int i = 0; i < n; i++) {
      final c = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) => c.complete());
      await c.future;
    }
  }

  /// ✅ GPU warmup while loader is showing
  Future<void> _gpuWarmupWhileLoading() async {
    if (!mounted) return;

    setState(() => _cleanerUseFirstFrame = true);
    await _waitFrames(1);

    if (!mounted) return;
    setState(() => _cleanerUseFirstFrame = false);
    await _waitFrames(1);

    if (!mounted) return;
    setState(() => _cleanerUseFirstFrame = true);
    await _waitFrames(1);
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _cleanerAnimTimer?.cancel();
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  void _resetGame() {
    gameTimer?.cancel();
    _cleanerAnimTimer?.cancel();

    setState(() {
      phase = 0;
      trashItems = [];
      tick = 0;

      points = maxPoints;
      _failedByPoints = false;

      _spawnedTrashCount = 0;
      _guaranteeIndex = 0;

      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
      _nextId = 0;
      _introPage = 0;
      _cleanerUseFirstFrame = true;
      _showStartGameLoader = false;
    });

    _playIntroOutroMusic();
  }

  /// ✅ loader only after last intro page
  Future<void> _startGameWithProperLoading() async {
    if (_showStartGameLoader) return;

    setState(() => _showStartGameLoader = true);

    await _waitFrames(1);
    if (!mounted) return;

    if (_assetPrecacheFuture != null) {
      await _assetPrecacheFuture;
      if (!mounted) return;
    }

    await _gpuWarmupWhileLoading();
    if (!mounted) return;

    setState(() => _showStartGameLoader = false);

    await _startGameInternal();
  }

  Future<void> _startGameInternal() async {
    gameTimer?.cancel();
    _cleanerAnimTimer?.cancel();

    setState(() {
      phase = 1;
      trashItems = [];
      tick = 0;

      points = maxPoints;
      _failedByPoints = false;

      _spawnedTrashCount = 0;
      _guaranteeIndex = 0;

      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
      _nextId = 0;
      _cleanerUseFirstFrame = true;
    });

    await _playGameMusic();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        tick++;

        // age trash + missed penalty
        final List<TrashItem> stillThere = [];
        for (var t in trashItems) {
          t.age += 1;
          if (t.age > maxTrashAge) {
            missedTrash++;
            _losePoint();
          } else {
            stillThere.add(t);
          }
        }
        trashItems = stillThere;

        // ✅ PACED spawn check (every 2 seconds)
        if (tick % 2 == 0 && trashItems.length < maxTrashOnScreen) {
          final needGuarantee = _spawnedTrashCount < minTrashToSpawn;

          if (needGuarantee) {
            if (_guaranteeIndex < _guaranteedTicks.length &&
                tick >= _guaranteedTicks[_guaranteeIndex]) {
              _spawnTrash();
              _guaranteeIndex++;
            }
          } else {
            if (random.nextDouble() < extraSpawnChance) {
              _spawnTrash();
            }
          }
        }

        // fail at 0 points
        if (points <= 0) {
          _endGame(failed: true);
          return;
        }

        if (tick >= maxTicks) {
          _endGame(failed: false);
          return;
        }
      });
    });
  }

  void _spawnTrash() {
    const types = ["cup", "food", "plastic", "cigarette"];
    final type = types[random.nextInt(types.length)];

    final zone = spawnZones[random.nextInt(spawnZones.length)];

    final double innerLeft = zone.left + zone.width * 0.10;
    final double innerRight = zone.left + zone.width * 0.90;
    final double innerTop = zone.top + zone.height * 0.10;
    final double innerBottom = zone.top + zone.height * 0.90;

    final double x = innerLeft + random.nextDouble() * (innerRight - innerLeft);
    final double y = innerTop + random.nextDouble() * (innerBottom - innerTop);

    String? assetPath;
    if (type == "food") {
      final foodAssets = [
        'assets/trashGame/applee.png',
        'assets/trashGame/banana.png',
      ];
      assetPath = foodAssets[random.nextInt(foodAssets.length)];
    } else if (type == "plastic") {
      assetPath = 'assets/trashGame/plastic_bottle.png';
    } else if (type == "cigarette") {
      assetPath = 'assets/trashGame/sigy.png';
    } else if (type == "cup") {
      assetPath = 'assets/trashGame/herbruikbare_beker.png';
    }

    trashItems.add(
      TrashItem(
        id: _nextId++,
        type: type,
        assetPath: assetPath,
        x: x,
        y: y,
      ),
    );

    _spawnedTrashCount++;
    _playSpawnSound();
  }

  void _handleDropOnBin(TrashItem item, String chosenBin) async {
    String correctBin;
    switch (item.type) {
      case "cup":
        correctBin = "cups";
        break;
      case "food":
        correctBin = "gft";
        break;
      case "plastic":
        correctBin = "plastic";
        break;
      case "cigarette":
        correctBin = "rest";
        break;
      default:
        correctBin = "rest";
    }

    if (chosenBin == correctBin) {
      setState(() {
        correctlySorted++;
        _gainPoint(); // ✅ reward +1 point (max 10) so background can recover
      });
    } else {
      wrongSorting++;
      setState(() {
        _losePoint();
      });

      if (points <= 0) {
        await _playBinnedSound();
        _startCleaningAnim();
        if (!mounted) return;
        setState(() {
          trashItems.removeWhere((t) => t.id == item.id);
        });
        _endGame(failed: true);
        return;
      }
    }

    await _playBinnedSound();
    _startCleaningAnim();

    if (!mounted) return;
    setState(() {
      trashItems.removeWhere((t) => t.id == item.id);
    });
  }

  /// Warmup scene used during loader (paint bins+cleaner for GPU upload)
  Widget _buildWarmupScene() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            _bgNormal,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _buildBinsRow(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: const Text(
          'Festival Cleaner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Builder(
              builder: (context) {
                if (phase == 0) return _buildIntro();
                if (phase == 1) return _buildGame();
                return _buildResult();
              },
            ),

            // ✅ Loader ONLY right before starting the game
            if (_showStartGameLoader) ...[
              // paint warmup scene at tiny opacity ON TOP (forces raster, but invisible)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.001,
                  child: IgnorePointer(
                    ignoring: true,
                    child: _buildWarmupScene(),
                  ),
                ),
              ),
              Positioned.fill(child: Container(color: Colors.black)),
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Loading…',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- INTRO ----------------

  Widget _buildIntro() {
    final bool isLast = _introPage >= _introBackgrounds.length - 1;

    final String bg = _introBackgrounds.isEmpty
        ? _bgNormal
        : _introBackgrounds[_introPage.clamp(0, _introBackgrounds.length - 1)];

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            bg,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 48, 159, 193),
                padding: const EdgeInsets.symmetric(
                  horizontal: 42,
                  vertical: 20,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _showStartGameLoader
                  ? null
                  : () async {
                      if (isLast) {
                        await _startGameWithProperLoading();
                      } else {
                        setState(() => _introPage++);
                      }
                    },
              child: Text(isLast ? 'Start spel' : 'Volgende ▶'),
            ),
          ),
        ),
        if (_introPage > 0)
          Positioned(
            left: 16,
            bottom: 30,
            child: TextButton(
              onPressed: _showStartGameLoader
                  ? null
                  : () => setState(() => _introPage = max(0, _introPage - 1)),
              child: const Text(
                'Terug',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------- GAME ----------------

  Widget _buildGame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _currentGameBackground(),
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: _buildCrowdAndHud(),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, playConstraints) {
                  return Stack(
                    children: [
                      ...trashItems.map((item) {
                        final left = item.x * playConstraints.maxWidth - 24;
                        final top = item.y * playConstraints.maxHeight - 24;

                        return Positioned(
                          left: left.clamp(0, playConstraints.maxWidth - 48),
                          top: top.clamp(0, playConstraints.maxHeight - 48),
                          child: Draggable<TrashItem>(
                            data: item,
                            onDragStarted: _playPickupSound,
                            feedback: Material(
                              color: Colors.transparent,
                              child: item.assetPath != null
                                  ? Image.asset(
                                      item.assetPath!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.contain,
                                    )
                                  : Text(
                                      trashEmojis[item.type] ?? "❓",
                                      style: const TextStyle(fontSize: 40),
                                    ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildTrashIcon(item),
                            ),
                            child: _buildTrashIcon(item),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _buildBinsRow(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrashIcon(TrashItem item) {
    if (item.assetPath != null) {
      return Image.asset(
        item.assetPath!,
        width: 74,
        height: 74,
        fit: BoxFit.contain,
      );
    } else {
      return Text(
        trashEmojis[item.type] ?? "❓",
        style: const TextStyle(fontSize: 32),
      );
    }
  }

  Widget _buildCrowdAndHud() {
    final moodText = points >= 8
        ? "De crowd gaat lekker 🎉"
        : (points >= 5 ? "De sfeer zakt… 😬" : "Bijna game over! 🚨");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("", style: TextStyle(fontSize: 24, color: Colors.white)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Punten: $points/$maxPoints",
              style: const TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                Text(
                  "Tijd: ${maxTicks - tick}s",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _cycleBgVolume,
                  icon: Icon(_bgVolumeIcon(), color: Colors.white),
                  tooltip: 'Muziek volume',
                ),
              ],
            ),
          ],
        ),
        Text(moodText, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildCleaner() {
    final String asset =
        _cleanerUseFirstFrame ? _cleanerIdleAsset : _cleanerSweepAsset;

    return SizedBox(
      height: 430,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }

  // ✅ DO NOT TOUCH: your bin layout exactly as you posted
  Widget _buildBinsRow() {
    final List<String> bins = ["gft", "rest", "plastic", "cups"];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double imgWidth = 160;
        const double gap = 0;
        const double slotWidth = 140;
        final double imgHeight = imgWidth * 1.4;

        final double totalWidth =
            bins.length * slotWidth + (bins.length - 1) * gap;

        return Center(
          child: SizedBox(
            width: totalWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < bins.length; i++) ...[
                      SizedBox(
                        width: slotWidth,
                        child: DragTarget<TrashItem>(
                          onWillAccept: (item) => item != null,
                          onAccept: (item) => _handleDropOnBin(item, bins[i]),
                          builder: (context, candidateData, rejectedData) {
                            final bool isHighlighted = candidateData.isNotEmpty;
                            final asset = binAssetPaths[bins[i]];

                            Widget iconWidget;
                            if (asset != null) {
                              iconWidget = Image.asset(
                                asset,
                                width:
                                    isHighlighted ? imgWidth * 1.05 : imgWidth,
                                height: isHighlighted
                                    ? imgHeight * 1.05
                                    : imgHeight,
                                fit: BoxFit.contain,
                              );
                            } else {
                              iconWidget = Text(
                                binEmojis[bins[i]] ?? "",
                                style: TextStyle(
                                  fontSize: isHighlighted ? 48 : 44,
                                  color: Colors.white,
                                ),
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Opacity(
                                  opacity: isHighlighted ? 1.0 : 0.95,
                                  child: iconWidget,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (i < bins.length - 1) const SizedBox(width: gap),
                    ],
                  ],
                ),
                Positioned(
                  right: slotWidth * -1.75,
                  bottom: -10,
                  child: IgnorePointer(
                    ignoring: true,
                    child: _buildCleaner(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- RESULT ----------------

  Widget _buildResult() {
    final bg = _failedByPoints ? _bgEndIfDoneWrong : _outroBackground;

    final summary = _failedByPoints
        ? "Je punten zijn op… de crowd is er klaar mee 😵"
        : "Tijd is om! Goed geprobeerd 💪";

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            bg,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Resultaten: Festival Cleaner",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text("Overgebleven punten: $points / $maxPoints"),
                const SizedBox(height: 8),
                Text("Goed gesorteerd: $correctlySorted"),
                Text("Gemist afval: $missedTrash"),
                Text("Verkeerd gesorteerd: $wrongSorting"),
                const SizedBox(height: 16),
                Text(summary),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _resetGame,
                    child: const Text("Opnieuw spelen 🔁"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
