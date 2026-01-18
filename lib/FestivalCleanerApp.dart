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
  final int id;
  final String type;
  final String? assetPath;
  double x; // 0–1 (relative to STAGE width)
  double y; // 0–1 (relative to STAGE height)
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

// ---------------- PEOPLE (overlay) ----------------

class _PeopleSprite {
  final String key; // "band", "plantpeople", etc.
  final String normalAsset; // 1 = default
  final String angryAsset; // 2 = angry

  /// Normalized rectangle (0..1) relative to your background/stage
  final Rect rectN;

  /// Height fraction of the box (you can tweak per sprite)
  final double heightFill;

  const _PeopleSprite({
    required this.key,
    required this.normalAsset,
    required this.angryAsset,
    required this.rectN,
    this.heightFill = 0.95,
  });
}

class CleanerGame extends StatefulWidget {
  const CleanerGame({super.key});

  @override
  State<CleanerGame> createState() => _CleanerGameState();
}

class _CleanerGameState extends State<CleanerGame> {
  int phase = 0; // 0 = intro, 1 = game, 2 = result

  // ✅ background is 3480x2400 => aspect = 1.45
  // If you *really* use 3840x2400, switch back, but for 3480x2400 this is correct.
  static const double _stageAspect = 3480 / 2400;

  // ✅ assets gate so we never show "background only" then pop-in bins/cleaner
  bool _assetsReady = false;
  bool _precacheStarted = false;

  // Game state
  List<TrashItem> trashItems = [];
  int _nextId = 0;

  // Timing
  Timer? gameTimer;
  int tick = 0;
  final int maxTicks = 40;
  final int maxTrashAge = 8;

  // Vibe
  int vibe = 100; // 0–100
  int correctlySorted = 0;
  int missedTrash = 0;
  int wrongSorting = 0;

  // Cleaner animation (2-frame puppet)
  final String _cleanerIdleAsset = 'assets/trashGame/Cleaner/puppet1.png';
  final String _cleanerSweepAsset = 'assets/trashGame/Cleaner/puppet2.png';
  bool _cleanerUseFirstFrame = true;
  Timer? _cleanerAnimTimer;

  final Random random = Random();

  // AUDIO
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer;
  double _bgVolume = 0.5;

  final String _introOutroTrack = 'trashGame/audio/golden instrumental.mp3';

  final List<String> _bgTracks = [
    'trashGame/audio/Soda pop (Instrumental).mp3',
  ];

  // ---------- BACKGROUNDS ----------
  final List<String> _backgrounds = [
    'assets/trashGame/BackgroundFlow/Background_Normal.png',
    'assets/trashGame/BackgroundFlow/Background_Angry.png',
    'assets/trashGame/BackgroundFlow/NoDancing.png',
    'assets/trashGame/BackgroundFlow/NoDancingNoPlant.png',
    'assets/trashGame/BackgroundFlow/NoDancingNoPlantNoNormal.png',
    'assets/trashGame/BackgroundFlow/Background_Empty.png',
  ];

  // ✅ Gameplay uses empty background; we layer people ourselves.
  final String _gameBackgroundEmpty =
      'assets/trashGame/BackgroundFlow/Background_Empty.png';

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

  // ---------------- PEOPLE SPRITES ----------------
  static const String _peopleDir = 'assets/trashGame/people/';

  // Rects are the red boxes from your last screenshot (normalized).
  // You can tweak these numbers later.
  final List<_PeopleSprite> _people = const [
    _PeopleSprite(
      key: 'girlsdancing',
      normalAsset: '${_peopleDir}girlsdancing1.png',
      angryAsset: '${_peopleDir}girlsdancing2.png',
      rectN: Rect.fromLTWH(0.056640625, 0.34375, 0.1787109375, 0.5234375),
      heightFill: 0.98,
    ),
    _PeopleSprite(
      key: 'band',
      normalAsset: '${_peopleDir}band1.png',
      angryAsset: '${_peopleDir}band2.png',
      rectN: Rect.fromLTWH(0.23828125, 0.2640625, 0.279296875, 0.3109375),
      heightFill: 0.95,
    ),
    _PeopleSprite(
      key: 'plantpeople',
      normalAsset: '${_peopleDir}plantpeople1.png',
      angryAsset: '${_peopleDir}plantpeople2.png',
      rectN: Rect.fromLTWH(0.64599609375, 0.26328125, 0.353515625, 0.3171875),
      heightFill: 0.95,
    ),
    _PeopleSprite(
      key: 'normalpple',
      normalAsset: '${_peopleDir}normalpple1.png',
      angryAsset: '${_peopleDir}normalpple2.png',
      rectN: Rect.fromLTWH(0.830078125, 0.58125, 0.16748046875, 0.29453125),
      heightFill: 0.98,
    ),
  ];

  // ----------------- Decode helpers (only for PEOPLE + TRASH) -----------------
  // This is what fixes pixelation on large screens:
  // decode size = logicalSize * DPR * boost, clamped to source max.
  static const double _decodeBoost = 2.0; // raise if still pixelated (2.0–3.0 is common)

  int _px(BuildContext context, double logical) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return max(1, (logical * dpr).round());
  }

  int _pxBoosted(BuildContext context, double logical, {required int maxPx}) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final wanted = (logical * dpr * _decodeBoost).round();
    return wanted.clamp(1, maxPx);
  }

  Size _computeStageSize(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height -
        mq.padding.top -
        mq.padding.bottom -
        kToolbarHeight;

    double stageW = screenW;
    double stageH = stageW / _stageAspect;
    if (stageH > screenH) {
      stageH = screenH;
      stageW = stageH * _stageAspect;
    }
    return Size(stageW, stageH);
  }

  ImageProvider _resizedAsset(BuildContext context, String asset,
      {int? cacheW, int? cacheH}) {
    final base = AssetImage(asset);
    if (cacheW == null && cacheH == null) return base;
    return ResizeImage(base, width: cacheW, height: cacheH);
  }

  Future<void> _precacheAllForThisDevice(BuildContext context) async {
    final stage = _computeStageSize(context);

    // These match your in-stage sizing
    final slotWidth = (stage.width * 0.125).clamp(70.0, 120.0);
    final imgWidth = (slotWidth * 0.92).clamp(75.0, 125.0);
    final imgHeight = imgWidth * 1.25;
    final cleanerHeight = (stage.height * 0.42).clamp(150.0, 280.0);
    final trashSize =
        (min(stage.width, stage.height) * 0.065).clamp(34.0, 66.0);

    final bgCW = _px(context, stage.width);
    final bgCH = _px(context, stage.height);

    // backgrounds (decoded at stage size)
    for (final path in _backgrounds) {
      await precacheImage(
          _resizedAsset(context, path, cacheW: bgCW, cacheH: bgCH), context);
    }
    for (final path in _introBackgrounds) {
      await precacheImage(
          _resizedAsset(context, path, cacheW: bgCW, cacheH: bgCH), context);
    }
    await precacheImage(
        _resizedAsset(context, _outroBackground, cacheW: bgCW, cacheH: bgCH),
        context);

    // cleaner (decode around its display size)  (UNCHANGED behavior)
    await precacheImage(
      _resizedAsset(context, _cleanerIdleAsset,
          cacheH: _px(context, cleanerHeight)),
      context,
    );
    await precacheImage(
      _resizedAsset(context, _cleanerSweepAsset,
          cacheH: _px(context, cleanerHeight)),
      context,
    );

    // bins (decode around their display size) (UNCHANGED behavior)
    for (final path in binAssetPaths.values) {
      await precacheImage(
        _resizedAsset(
          context,
          path,
          cacheW: _px(context, imgWidth),
          cacheH: _px(context, imgHeight),
        ),
        context,
      );
    }

    // ✅ PEOPLE: precache at boosted size (clamp to 8192)
    for (final p in _people) {
      final boxH = (p.rectN.height * stage.height).clamp(10.0, stage.height);
      final targetH = (boxH * p.heightFill).clamp(20.0, stage.height);
      final cacheH = _pxBoosted(context, targetH, maxPx: 8192);

      await precacheImage(_resizedAsset(context, p.normalAsset, cacheH: cacheH), context);
      await precacheImage(_resizedAsset(context, p.angryAsset, cacheH: cacheH), context);
    }

    // ✅ TRASH: precache at boosted size (clamp to 2048 because your trash is 2048x2048)
    const trashAssetPaths = [
      'assets/trashGame/applee.png',
      'assets/trashGame/banana.png',
      'assets/trashGame/plastic_bottle.png',
      'assets/trashGame/sigy.png',
      'assets/trashGame/herbruikbare_beker.png',
    ];
    final trashCache = _pxBoosted(context, trashSize, maxPx: 2048);
    for (final path in trashAssetPaths) {
      await precacheImage(
        _resizedAsset(context, path, cacheW: trashCache, cacheH: trashCache),
        context,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _configureAudio();
      await _precacheAllForThisDevice(context);

      if (!mounted) return;
      setState(() => _assetsReady = true);

      await _playIntroOutroMusic();
    });
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

  String _currentGameBackground() {
    // We're using the empty background for gameplay now; vibe affects people state.
    return _gameBackgroundEmpty;
  }

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

  void _startCleaningAnim() {
    _cleanerAnimTimer?.cancel();
    int ticks = 0;
    _cleanerAnimTimer =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      setState(() => _cleanerUseFirstFrame = !_cleanerUseFirstFrame);
      ticks++;
      if (ticks >= 4) {
        timer.cancel();
        if (mounted) setState(() => _cleanerUseFirstFrame = true);
      }
    });
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
      vibe = 100;
      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
      _nextId = 0;
      _introPage = 0;
      _cleanerUseFirstFrame = true;
    });

    _playIntroOutroMusic();
  }

  Future<void> _startGame() async {
    gameTimer?.cancel();
    _cleanerAnimTimer?.cancel();

    setState(() {
      phase = 1;
      trashItems = [];
      tick = 0;
      vibe = 100;
      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
      _nextId = 0;
      _cleanerUseFirstFrame = true;
    });

    await _playGameMusic();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      bool ended = false;

      setState(() {
        tick++;

        final List<TrashItem> stillThere = [];
        for (var t in trashItems) {
          t.age += 1;
          if (t.age > maxTrashAge) {
            missedTrash++;
            vibe -= 5;
            if (vibe < 0) vibe = 0;
          } else {
            stillThere.add(t);
          }
        }
        trashItems = stillThere;

        if (tick % 2 == 0 && trashItems.length < 7) {
          if (random.nextBool()) _spawnTrash();
        }

        if (tick >= maxTicks) {
          ended = true;
          phase = 2;
        }
      });

      if (ended) {
        gameTimer?.cancel();
        _playIntroOutroMusic();
      }
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
      correctlySorted++;
      vibe += 7;
      if (vibe > 100) vibe = 100;
    } else {
      wrongSorting++;
      vibe -= 5;
      if (vibe < 0) vibe = 0;
    }

    await _playBinnedSound();
    _startCleaningAnim();

    if (!mounted) return;
    setState(() => trashItems.removeWhere((t) => t.id == item.id));
  }

  // ✅ stage renderer: no crop, no distortion; letterbox solid
  Widget _buildStage({
    required String backgroundAsset,
    required Color letterboxColor,
    required Widget Function(Size stageSize) overlayBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        double stageW = screenW;
        double stageH = stageW / _stageAspect;
        if (stageH > screenH) {
          stageH = screenH;
          stageW = stageH * _stageAspect;
        }

        final dx = (screenW - stageW) / 2;
        final dy = (screenH - stageH) / 2;

        final stageSize = Size(stageW, stageH);

        return Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: letterboxColor)),
            Positioned(
              left: dx,
              top: dy,
              width: stageW,
              height: stageH,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image(
                      image: _resizedAsset(
                        context,
                        backgroundAsset,
                        cacheW: _px(context, stageW),
                        cacheH: _px(context, stageH),
                      ),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  Positioned.fill(child: overlayBuilder(stageSize)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ People renderer (inside stage coordinates, so looks same on all devices)
  Widget _buildPeople(Size stageSize) {
    final w = stageSize.width;
    final h = stageSize.height;

    // simple rule: angry if vibe is low
    final bool angry = vibe < 60;

    return Stack(
      children: [
        for (final p in _people)
          Positioned(
            left: p.rectN.left * w,
            top: p.rectN.top * h,
            width: p.rectN.width * w,
            height: p.rectN.height * h,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Builder(
                builder: (context) {
                  final boxH = p.rectN.height * h;
                  final targetH = (boxH * p.heightFill).clamp(20.0, h);

                  // people files can be huge (band 8533), clamp decode to 8192 for safety
                  final cacheH = _pxBoosted(context, targetH, maxPx: 8192);

                  return Image(
                    image: _resizedAsset(
                      context,
                      angry ? p.angryAsset : p.normalAsset,
                      cacheH: cacheH,
                    ),
                    height: targetH,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high, // ✅ sharper
                    isAntiAlias: true,
                    gaplessPlayback: true,
                  );
                },
              ),
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

            // ✅ Loading overlay until EVERYTHING is cached
            if (!_assetsReady)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
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
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- INTRO ----------------

  Widget _buildIntro() {
    final bool isLast = _introPage >= _introBackgrounds.length - 1;
    final String bg = _introBackgrounds.isEmpty
        ? _gameBackgroundEmpty
        : _introBackgrounds[_introPage.clamp(0, _introBackgrounds.length - 1)];

    return _buildStage(
      backgroundAsset: bg,
      letterboxColor: Colors.black,
      overlayBuilder: (stageSize) {
        final w = stageSize.width;
        final h = stageSize.height;

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: h * 0.08,
              child: Center(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 48, 159, 193),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 42, vertical: 20),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: !_assetsReady
                      ? null
                      : () async {
                          if (isLast) {
                            await _startGame();
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
                left: w * 0.02,
                bottom: h * 0.055,
                child: TextButton(
                  onPressed: () =>
                      setState(() => _introPage = max(0, _introPage - 1)),
                  child: const Text(
                    'Terug',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ---------------- GAME ----------------

  Widget _buildGame() {
    final bg = _currentGameBackground();

    return _buildStage(
      backgroundAsset: bg,
      letterboxColor: Colors.black,
      overlayBuilder: (stageSize) {
        final w = stageSize.width;
        final h = stageSize.height;

        final trashSize = (min(w, h) * 0.065).clamp(34.0, 66.0);
        final trashHalf = trashSize / 2;

        // ✅ boosted decode for trash (clamp to 2048)
        final trashCache = _pxBoosted(context, trashSize, maxPx: 2048);

        return Stack(
          children: [
            // ✅ PEOPLE go above background, behind UI/trash
            _buildPeople(stageSize),

            Positioned(
              left: w * 0.02,
              right: w * 0.02,
              top: h * 0.02,
              child: _buildCrowdAndHud(),
            ),

            ...trashItems.map((item) {
              final left = item.x * w - trashHalf;
              final top = item.y * h - trashHalf;

              return Positioned(
                left: left.clamp(0.0, w - trashSize),
                top: top.clamp(0.0, h - trashSize),
                child: Draggable<TrashItem>(
                  data: item,
                  onDragStarted: _playPickupSound,
                  feedback: Material(
                    color: Colors.transparent,
                    child: item.assetPath != null
                        ? Image(
                            image: _resizedAsset(
                              context,
                              item.assetPath!,
                              cacheW: trashCache,
                              cacheH: trashCache,
                            ),
                            width: trashSize,
                            height: trashSize,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high, // ✅ sharper
                            isAntiAlias: true,
                          )
                        : Text(
                            trashEmojis[item.type] ?? "❓",
                            style: TextStyle(fontSize: trashSize * 0.8),
                          ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildTrashIcon(item, trashSize, trashCache),
                  ),
                  child: _buildTrashIcon(item, trashSize, trashCache),
                ),
              );
            }),

            Positioned(
              left: 0,
              right: 0,
              bottom: h * 0.01,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                child: _buildBinsRow(stageSize),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrashIcon(TrashItem item, double size, int trashCache) {
    if (item.assetPath != null) {
      return Image(
        image: _resizedAsset(context, item.assetPath!,
            cacheW: trashCache, cacheH: trashCache),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high, // ✅ sharper
        isAntiAlias: true,
      );
    }
    return Text(trashEmojis[item.type] ?? "❓",
        style: TextStyle(fontSize: size * 0.55));
  }

  Widget _buildCrowdAndHud() {
    final vibeText = vibe >= 70
        ? "De crowd gaat lekker 🎉"
        : (vibe >= 40 ? "De sfeer is oké" : "De crowd klaagt over rommel…");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Vibe: $vibe/100", style: const TextStyle(color: Colors.white)),
            Row(
              children: [
                Text("Tijd: ${maxTicks - tick}s",
                    style: const TextStyle(color: Colors.white)),
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
        Text(vibeText, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildCleaner(double height) {
    final asset = _cleanerUseFirstFrame ? _cleanerIdleAsset : _cleanerSweepAsset;
    return SizedBox(
      height: height,
      child: Image(
        image: _resizedAsset(context, asset, cacheH: _px(context, height)),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget _buildBinsRow(Size stageSize) {
    final bins = ["gft", "rest", "plastic", "cups"];
    final w = stageSize.width;
    final h = stageSize.height;

    final slotWidth = (w * 0.125).clamp(70.0, 120.0);
    final imgWidth = (slotWidth * 0.92).clamp(75.0, 125.0);
    final imgHeight = imgWidth * 1.25;
    final cleanerHeight = (h * 0.42).clamp(150.0, 280.0);

    final totalWidth = slotWidth * bins.length;

    return Center(
      child: SizedBox(
        width: totalWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < bins.length; i++)
                  SizedBox(
                    width: slotWidth,
                    child: DragTarget<TrashItem>(
                      onWillAccept: (item) => item != null,
                      onAccept: (item) => _handleDropOnBin(item, bins[i]),
                      builder: (context, candidateData, rejectedData) {
                        final isHighlighted = candidateData.isNotEmpty;
                        final asset = binAssetPaths[bins[i]];
                        final scale = isHighlighted ? 1.05 : 1.0;

                        if (asset != null) {
                          return Opacity(
                            opacity: isHighlighted ? 1.0 : 0.95,
                            child: Transform.scale(
                              scale: scale,
                              child: Image(
                                image: _resizedAsset(
                                  context,
                                  asset,
                                  cacheW: _px(context, imgWidth),
                                  cacheH: _px(context, imgHeight),
                                ),
                                width: imgWidth,
                                height: imgHeight,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          );
                        }

                        return Text(
                          binEmojis[bins[i]] ?? "",
                          style: TextStyle(
                              fontSize: isHighlighted ? 46 : 42,
                              color: Colors.white),
                        );
                      },
                    ),
                  ),
              ],
            ),
            Positioned(
              right: -slotWidth * 0.32,
              bottom: -imgHeight * 0.02,
              child: IgnorePointer(
                ignoring: true,
                child: _buildCleaner(cleanerHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- RESULT ----------------

  Widget _buildResult() {
    String summary;
    if (vibe >= 70) {
      summary =
          "De festival vibe is hoog gebleven! De crowd waardeerde een schoon terrein en goede afvalscheiding. 🎉";
    } else if (vibe >= 40) {
      summary =
          "De vibe was wisselend. Soms schoon en netjes gescheiden, soms rommelig. Er is ruimte om beter te sorteren.";
    } else {
      summary =
          "De vibe zakte flink weg. Veel afval bleef liggen of werd verkeerd gesorteerd (bijvoorbeeld sigaretten bij GFT of bekers bij restafval). 😬";
    }

    return _buildStage(
      backgroundAsset: _outroBackground,
      letterboxColor: Colors.black,
      overlayBuilder: (stageSize) {
        final w = stageSize.width;

        return Padding(
          padding: EdgeInsets.all(w * 0.03),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Resultaten: Festival Cleaner",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text("Eind-vibe: $vibe / 100"),
                const SizedBox(height: 8),
                Text("Goed gesorteerd: $correctlySorted"),
                Text("Gemist afval: $missedTrash"),
                Text("Verkeerd gesorteerd: $wrongSorting"),
                const SizedBox(height: 16),
                Text(summary),
                const SizedBox(height: 24),
                const Text("Reflectie:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text(
                  "• Welke soorten afval vond je het makkelijkst om te plaatsen?\n"
                  "• Wanneer koos je voor restafval? Was dat echt nodig?\n"
                  "• Hoe merk je in het spel dat goed scheiden invloed heeft op de festival-vibe?",
                ),
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
        );
      },
    );
  }
}
