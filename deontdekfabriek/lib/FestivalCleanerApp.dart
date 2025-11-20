import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TrashItem {
  /// Types:
  /// - cup         → herbruikbare beker
  /// - food        → GFT / eten
  /// - plastic     → plastic & blik
  /// - paper_clean → schoon papier
  /// - paper_dirty → vies papier
  final String type;
  final int lane;
  int age;

  TrashItem({
    required this.type,
    required this.lane,
    this.age = 0,
  });
}

class CleanerGame extends StatefulWidget {
  const CleanerGame({super.key});

  @override
  State<CleanerGame> createState() => _CleanerGameState();
}

class _CleanerGameState extends State<CleanerGame> {
  int phase = 0;

  // Game state
  int cleanerLane = 1;
  List<TrashItem> trashItems = [];

  // Timing
  Timer? gameTimer;
  int tick = 0;
  final int maxTicks = 40; // how long the game lasts
  final int maxTrashAge = 6; // ticks before trash counts as "missed"

  // Vibe
  int vibe = 50; // 0–100
  int correctlySorted = 0;
  int missedTrash = 0;
  int wrongSorting = 0;

  // Random for spawns
  final Random random = Random();

  // Trash item visuals
  final Map<String, String> trashEmojis = {
    "cup": "🥤",
    "food": "🍌",
    "plastic": "🧴",
    "paper_clean": "📄",
    "paper_dirty": "🧻",
  };

  final Map<String, String> trashLabels = {
    "cup": "Herbruikbare beker",
    "food": "Eten / GFT",
    "plastic": "Plastic & blik",
    "paper_clean": "Schoon papier",
    "paper_dirty": "Vies papier",
  };

  // Bin visuals (buttons at bottom)
  final Map<String, String> binEmojis = {
    "cups": "🥤",
    "gft": "🍌",
    "plastic": "🧴",
    "paper": "📄",
    "rest": "🗑️",
  };

  final Map<String, String> binLabels = {
    "cups": "Bekers inleveren",
    "gft": "GFT (eten)",
    "plastic": "Plastic & blik",
    "paper": "Papier & karton",
    "rest": "Restafval",
  };

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      phase = 0;
      cleanerLane = 1;
      trashItems = [];
      tick = 0;
      vibe = 50;
      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
    });
  }

  void _startGame() {
    gameTimer?.cancel();
    setState(() {
      phase = 1;
      cleanerLane = 1;
      trashItems = [];
      tick = 0;
      vibe = 50;
      correctlySorted = 0;
      missedTrash = 0;
      wrongSorting = 0;
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tick++;

        // Time of how long the trash has been uninteracted with
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

        // Spawn new trash every 2 ticks with randomness
        if (tick % 2 == 0) {
          if (random.nextBool()) {
            _spawnTrash();
          }
        }

        // End of game
        if (tick >= maxTicks) {
          gameTimer?.cancel();
          phase = 2;
        }
      });
    });
  }

  void _spawnTrash() {
    const types = [
      "cup",
      "food",
      "plastic",
      "paper_clean",
      "paper_dirty",
    ];
    final type = types[random.nextInt(types.length)];
    final lane = random.nextInt(3); // 0,1,2

    trashItems.add(TrashItem(type: type, lane: lane));
  }

  void _moveCleaner(int direction) {
    // -1 = left, +1 = right
    setState(() {
      cleanerLane = (cleanerLane + direction).clamp(0, 2);
    });
  }

  /// chosenBin is one of: cups, gft, plastic, paper, rest
  void _pickAndSort(String chosenBin) {
    // Look for trash in the cleaner's lane
    final index = trashItems.indexWhere((t) => t.lane == cleanerLane);
    if (index == -1) {
      // no trash here, nothing happens
      return;
    }

    final item = trashItems[index];

    // Determine correct bin based on item.type
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
      case "paper_clean":
        correctBin = "paper";
        break;
      case "paper_dirty":
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

    setState(() {
      trashItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Background color based on vibe (0 = grey, 100 = purple/bright)
    final double t = (vibe / 100).clamp(0.0, 1.0);
    final Color bgColor = Color.lerp(
          Colors.grey.shade900,
          Colors.deepPurpleAccent,
          t,
        ) ??
        Colors.grey.shade900;

    Widget body;
    if (phase == 0) {
      body = _buildIntro();
    } else if (phase == 1) {
      body = _buildGame();
    } else {
      body = _buildResult();
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Festival Cleaner'),
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: body,
        ),
      ),
    );
  }

  // The intro
  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Concept – Jij bent de schoonmaker tijdens het muziekoptreden",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "Je kruipt in de rol van schoonmaker op een druk festival. "
          "Je loopt voor het podium heen en weer, terwijl achter je een grote crowd van de show geniet. "
          "Bezoekers laten tijdens het optreden allerlei afval vallen: herbruikbare bekers 🥤, etensresten 🍌, "
          "plastic flesjes en blik 🧴, schoon papier 📄 en vieze servetten 🧻.\n\n"
          "Jij beslist in welke bak dat afval hoort: bekers inleveren, GFT, plastic & blik, papier & karton of restafval. "
          "Sorteer je snel én goed, dan gaat de festival-vibe omhoog en worden de kleuren in het spel steeds feller. "
          "Laat je afval liggen of kies je de verkeerde bak (zoals vies papier in de papierbak), dan zakt de vibe "
          "en wordt het beeld grauwer. Zo merk je direct het verschil tussen herbruikbaar, recyclebaar en echt restafval.\n\n"
          "Herbruikbare bekers 🥤 gaan naar het inleverpunt. Daar worden ze gewassen en opnieuw gebruikt in plaats van weggegooid. "
          "Etensresten 🍌 komen in de GFT-bak en kunnen worden verwerkt tot compost of biogas. "
          "Schone plastic verpakkingen en blik 🧴 worden gerecycled tot nieuwe verpakkingen. "
          "Schoon papier 📄 kan weer nieuw papier en karton worden. "
          "Wat overblijft, zoals vieze servetten 🧻 of gemengd afval, is restafval en wordt meestal verbrand. ",
        ),
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

  // Phase 1: the game
  Widget _buildGame() {
    return Column(
      children: [
        _buildCrowdAndHud(),
        const SizedBox(height: 16),
        _buildLanes(),
        const SizedBox(height: 16),
        _buildControls(),
      ],
    );
  }

  Widget _buildCrowdAndHud() {
    final vibeText = vibe >= 70
        ? "De crowd gaat lekker 🎉"
        : (vibe >= 40 ? "De sfeer is oké" : "De crowd klaagt over rommel…");

    return Column(
      children: [
        Text(
          "🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️🎵🙋‍♀️🙋‍♂️",
          style: const TextStyle(fontSize: 26),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Vibe: $vibe/100"),
            Text("Tijd: ${maxTicks - tick}s"),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(vibeText),
        ),
      ],
    );
  }

  Widget _buildLanes() {
    return Expanded(
      child: Row(
        children: List.generate(3, (lane) {
          final item = trashItems.firstWhere(
            (t) => t.lane == lane,
            orElse: () => TrashItem(type: "", lane: lane, age: 0),
          );
          final hasTrash = item.type.isNotEmpty;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: lane == cleanerLane
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                  width: lane == cleanerLane ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 8),
                  if (hasTrash)
                    Column(
                      children: [
                        Text(
                          trashEmojis[item.type] ?? "❓",
                          style: const TextStyle(fontSize: 32),
                        ),
                        Text(
                          trashLabels[item.type] ?? "",
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else
                    const SizedBox(height: 48),
                  const Spacer(),
                  if (lane == cleanerLane)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "🧹",
                        style: TextStyle(fontSize: 32),
                      ),
                    )
                  else
                    const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControls() {
    final List<String> bins = ["cups", "gft", "plastic", "paper", "rest"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _moveCleaner(-1),
              icon: const Icon(Icons.arrow_left),
              iconSize: 32,
            ),
            const SizedBox(width: 16),
            const Text("Beweeg de schoonmaker"),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => _moveCleaner(1),
              icon: const Icon(Icons.arrow_right),
              iconSize: 32,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Kies de juiste bak voor het afval in jouw rij:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: bins.map((binKey) {
            return FilledButton(
              onPressed: () => _pickAndSort(binKey),
              child: Text(
                "${binEmojis[binKey]} ${binLabels[binKey]}",
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Phase 2: the result
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
          "De vibe zakte flink weg. Veel afval bleef liggen of werd verkeerd gesorteerd (bijvoorbeeld vies papier bij het oud papier). 😬";
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

/// Page widget you navigate to from the main map.
/// Name = FestivalCleanerApp like you wanted 💚
class FestivalCleanerApp extends StatelessWidget {
  const FestivalCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CleanerGame();
  }
}
