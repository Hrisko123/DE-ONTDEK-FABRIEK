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

  // Game state
  List<TrashItem> trashItems = [];
  int _nextId = 0;

  // Timing
  Timer? gameTimer;
  int tick = 0;
  final int maxTicks = 40; // how long the game lasts
  final int maxTrashAge = 8; // ticks before trash counts as "missed"

  // Vibe
  int vibe = 50; // 0–100
  int correctlySorted = 0;
  int missedTrash = 0;
  int wrongSorting = 0;

  // Random for spawns / bg music
  final Random random = Random();

  // AUDIO
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer; // reuse for short sounds
  double _bgVolume = 0.5;

  // Achtergronden 21 t/m 29: van weinig mensen (21) naar veel mensen (29)
  final List<String> _backgrounds = [
    'assets/trashGame/background/21.png',
    'assets/trashGame/background/22.png',
    'assets/trashGame/background/23.png',
    'assets/trashGame/background/24.png',
    'assets/trashGame/background/25.png',
    'assets/trashGame/background/26.png',
    'assets/trashGame/background/27.png',
    'assets/trashGame/background/28.png',
    'assets/trashGame/background/29.png',
  ];

  // Two possible BG tracks – one will be picked at random when the game starts
  final List<String> _bgTracks = [
    'trashGame/audio/Soda pop (Instrumental).mp3', // e.g. Soda Pop (Instrumental)
    'trashGame/audio/Owl City - Fireflies (Instrumental).mp3', // e.g. Fireflies (Instrumental)
  ];

  // TRASH visuals (labels + emoji fallback)
  final Map<String, String> trashEmojis = {
    "cup": "🥤",
    "food": "🍌",
    "plastic": "🧴",
    "cigarette": "🚬",
  };

  final Map<String, String> trashLabels = {
    "cup": "Herbruikbare beker",
    "food": "Eten / GFT",
    "plastic": "Plastic fles / blik",
    "cigarette": "Sigaret / restafval",
  };

  // BIN visuals
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

  // Spawn zones based on your red boxes (normalized 0–1)
  final List<SpawnZone> spawnZones = const [
    // 0 – small vertical area at the far left
    SpawnZone(
      left: 0.067,
      top: 0.396,
      width: 0.018,
      height: 0.120,
    ),

    // 1 – long bar above the left bottom hill
    SpawnZone(
      left: 0.097,
      top: 0.494,
      width: 0.044,
      height: 0.084,
    ),

    // 2 – wide bar above the left chairs
    SpawnZone(
      left: 0.097,
      top: 0.647,
      width: 0.162,
      height: 0.092,
    ),

    // 3 – small bar under the singer / band
    SpawnZone(
      left: 0.154,
      top: 0.515,
      width: 0.030,
      height: 0.105,
    ),

    // 4 – long bar in front of the band (center)
    SpawnZone(
      left: 0.205,
      top: 0.528,
      width: 0.210,
      height: 0.092,
    ),

    // 5 – tall vertical bar next to the dancing couple
    SpawnZone(
      left: 0.231,
      top: 0.761,
      width: 0.044,
      height: 0.239,
    ),

    // 6 – long bar on the big middle-right hill
    SpawnZone(
      left: 0.515,
      top: 0.550,
      width: 0.164,
      height: 0.058,
    ),

    // 7 – small bar above the picnic area
    SpawnZone(
      left: 0.632,
      top: 0.437,
      width: 0.075,
      height: 0.078,
    ),

    // 8 – vertical bar near the right-bottom hill
    SpawnZone(
      left: 0.735,
      top: 0.777,
      width: 0.050,
      height: 0.198,
    ),

    // 9 – small bar above the watering girl
    SpawnZone(
      left: 0.815,
      top: 0.554,
      width: 0.071,
      height: 0.061,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload all background images so switching is instant
    for (final path in _backgrounds) {
      precacheImage(AssetImage(path), context);
    }
  }

  String _backgroundForVibe() {
    if (_backgrounds.isEmpty) {
      return 'assets/trashGame/background/21.png'; // fallback
    }

    final double t = (vibe / 100).clamp(0.0, 1.0);
    final int idx =
        (t * (_backgrounds.length - 1)).round().clamp(0, _backgrounds.length - 1);

    return _backgrounds[idx];
  }

  // ---------- AUDIO HELPERS ----------

  Future<void> _startBackgroundMusic() async {
    if (_bgTracks.isEmpty) return;
    final track = _bgTracks[random.nextInt(_bgTracks.length)];

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(_bgVolume);
    await _bgPlayer.play(AssetSource(track));
  }

  Future<void> _stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  Future<void> _playSpawnSound() async {
    await _sfxPlayer.play(AssetSource('trashGame/audio/TrashSpawn.mp3'));
  }

  Future<void> _playPickupSound() async {
    await _sfxPlayer.play(AssetSource('trashGame/audio/pickupTrash.mp3'));
  }

  Future<void> _playBinnedSound() async {
    await _sfxPlayer.play(AssetSource('trashGame/audio/binnedTrash.mp3'));
  }

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

  @override
  void dispose() {
    gameTimer?.cancel();
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  void _resetGame() {
    gameTimer?.cancel();
    _stopBackgroundMusic();
    setState(() {
      phase = 0;
      trashItems = [];
      tick = 0;
      vibe = 50;
      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
      _nextId = 0;
    });
  }

  void _startGame() {
    gameTimer?.cancel();
    setState(() {
      phase = 1;
      trashItems = [];
      tick = 0;
      vibe = 50;
      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
      _nextId = 0;
    });

    _startBackgroundMusic(); // 🔊 random bg track when game starts

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tick++;

        // Ageing: too long on the ground = missed
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

        // Spawn new items
        if (tick % 2 == 0 && trashItems.length < 7) {
          if (random.nextBool()) {
            _spawnTrash();
          }
        }

        // End of game
        if (tick >= maxTicks) {
          gameTimer?.cancel();
          phase = 2;
          _stopBackgroundMusic();
        }
      });
    });
  }

  /// Spawn trash only in the zones, with a 10% inner margin
  void _spawnTrash() {
    const types = [
      "cup",
      "food",
      "plastic",
      "cigarette",
    ];
    final type = types[random.nextInt(types.length)];

    // Pick one of the spawn zones
    final zone = spawnZones[random.nextInt(spawnZones.length)];

    // Inner rectangle: keep 10% margin inside the red box
    final double innerLeft = zone.left + zone.width * 0.10;
    final double innerRight = zone.left + zone.width * 0.90;
    final double innerTop = zone.top + zone.height * 0.10;
    final double innerBottom = zone.top + zone.height * 0.90;

    final double x =
        innerLeft + random.nextDouble() * (innerRight - innerLeft);
    final double y =
        innerTop + random.nextDouble() * (innerBottom - innerTop);

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

    _playSpawnSound(); // 🔊 play when trash appears
  }

  /// chosenBin is one of: gft, rest, plastic, cups
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

    await _playBinnedSound(); // 🔊 play when item is binned (correct or not)

    setState(() {
      trashItems.removeWhere((t) => t.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Festival Cleaner'),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (phase == 0) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: _buildIntro(),
              );
            } else if (phase == 1) {
              return _buildGame();
            } else {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: _buildResult(),
              );
            }
          },
        ),
      ),
    );
  }

  // ---------------- INTRO ----------------

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Concept – Jij bent de schoonmaker tijdens het muziekoptreden",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text("123abc "),
        const Spacer(),
        Center(
          child: FilledButton(
            onPressed: _startGame,
            child: const Text("Start festival 🎵"),
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
            // 1) Full festival background
            Positioned.fill(
              child: Image.asset(
                _backgroundForVibe(),
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),

            // 2) HUD at the very top
            Positioned(
              left: 16,
              right: 16,
              top: 8,
              child: _buildCrowdAndHud(),
            ),

            // 3) Trash items over the grass
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, playConstraints) {
                  return Stack(
                    children: [
                      ...trashItems.map((item) {
                        final left =
                            item.x * playConstraints.maxWidth - 24;
                        final top =
                            item.y * playConstraints.maxHeight - 24;

                        return Positioned(
                          left: left
                              .clamp(0, playConstraints.maxWidth - 48),
                          top: top
                              .clamp(0, playConstraints.maxHeight - 48),
                          child: Draggable<TrashItem>(
                            data: item,
                            onDragStarted: () {
                              _playPickupSound(); // 🔊 when player picks up trash
                            },
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
                                      style:
                                          const TextStyle(fontSize: 40),
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

            // 4) Bins at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _buildBinsRow(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrashIcon(TrashItem item) {
    Widget iconWidget;

    if (item.assetPath != null) {
      iconWidget = Image.asset(
        item.assetPath!,
        width: 74,
        height: 74,
        fit: BoxFit.contain,
      );
    } else {
      iconWidget = Text(
        trashEmojis[item.type] ?? "❓",
        style: const TextStyle(fontSize: 32),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        Text(
          trashLabels[item.type] ?? "",
          style: const TextStyle(fontSize: 11, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCrowdAndHud() {
    final vibeText = vibe >= 70
        ? "De crowd gaat lekker 🎉"
        : (vibe >= 40 ? "De sfeer is oké" : "De crowd klaagt over rommel…");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Vibe: $vibe/100",
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
                  icon: Icon(
                    _bgVolumeIcon(),
                    color: Colors.white,
                  ),
                  tooltip: 'Muziek volume',
                ),
              ],
            ),
          ],
        ),
        Text(
          vibeText,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBinsRow() {
    final List<String> bins = ["gft", "rest", "plastic", "cups"];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double imgWidth = 160;
        const double gap = 0;
        const double slotWidth = 140; // a bit smaller than image

        final double imgHeight = imgWidth * 1.4;

        return Center(
          child: SizedBox(
            width: bins.length * slotWidth + (bins.length - 1) * gap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < bins.length; i++) ...[
                  SizedBox(
                    width: slotWidth,
                    child: DragTarget<TrashItem>(
                      onWillAccept: (item) => item != null,
                      onAccept: (item) => _handleDropOnBin(item, bins[i]),
                      builder: (context, candidateData, rejectedData) {
                        final bool isHighlighted =
                            candidateData.isNotEmpty;
                        final asset = binAssetPaths[bins[i]];

                        Widget iconWidget;
                        if (asset != null) {
                          iconWidget = Image.asset(
                            asset,
                            width: isHighlighted
                                ? imgWidth * 1.05
                                : imgWidth,
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
          ),
        );
      },
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

    return Column(
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
        const Text(
          "Reflectie:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
    );
  }
}
