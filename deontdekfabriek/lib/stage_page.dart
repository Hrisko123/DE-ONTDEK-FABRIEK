//// PART 1 START
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// -------------------------------------------------------------
// GLOBAL AUDIO CONTROLLER
// -------------------------------------------------------------
class StageAudioController {
  StageAudioController._internal();
  static final StageAudioController instance = StageAudioController._internal();

  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
  String? _currentTrack;

  Future<void> playLoop(String key, String asset) async {
    if (_currentTrack == key) return;
    _currentTrack = key;
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  Future<void> stop() async {
    _currentTrack = null;
    await _player.stop();
  }
}

// -------------------------------------------------------------
// ENUMS
// -------------------------------------------------------------
enum BandStyle { rock, pop, dj }
enum StageLights { eco, mixed, flood }
enum StagePower { solar, grid, diesel }

/// Floor starts as NONE → brown color until user chooses a material.
enum StageFloor { none, woodenPallets, osb, steel }

/// Speakers – visual choice
enum SpeakerSetup { defaultSpeaker, normalSpeaker, bambooSpeaker, loudSpeaker }

// -------------------------------------------------------------
// MUSIC LOOPS
// -------------------------------------------------------------
final kBandLoops = {
  BandStyle.rock: 'assets/audio/rock_loop.mp3',
  BandStyle.pop: 'assets/audio/pop_loop.mp3',
  BandStyle.dj: 'assets/audio/techno_loop.mp3',
};

// -------------------------------------------------------------
// TAP PULSE
// -------------------------------------------------------------
class TapPulse extends StatelessWidget {
  final AnimationController controller;
  final double size;

  const TapPulse({
    super.key,
    required this.controller,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final scale = 1 + t * 1.4;
        final opacity = (1 - t).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.8 * opacity),
                  width: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// ROTATING LIGHT BEAM
// -------------------------------------------------------------
class _RotatingBeam extends StatefulWidget {
  final Color color;
  final bool reverse;
  const _RotatingBeam({required this.color, required this.reverse});

  @override
  State<_RotatingBeam> createState() => _RotatingBeamState();
}

class _RotatingBeamState extends State<_RotatingBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spin,
      builder: (_, child) {
        final angle = (widget.reverse ? -1 : 1) *
            (0.4 + 0.3 * sin(spin.value * pi * 2));
        return Transform.rotate(angle: angle, child: child);
      },
      child: Container(
        width: 70,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color,
              widget.color.withOpacity(0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// CROWD ANIMATION
// -------------------------------------------------------------
class _AnimatedCrowd extends StatelessWidget {
  final AnimationController controller;
  final AnimationController spotlightController;
  final String emojiRow;

  const _AnimatedCrowd({
    required this.controller,
    required this.spotlightController,
    required this.emojiRow,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, spotlightController]),
      builder: (_, __) {
        final bounce = (controller.value - 0.5) * 10;
        final spotX = sin(spotlightController.value * pi * 2) * 120;

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: MediaQuery.of(context).size.width / 2 + spotX - 90,
              child: Container(
                width: 180,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(.25),
                      Colors.white.withOpacity(.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, bounce),
              child: Text(
                emojiRow,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -------------------------------------------------------------
// BAND MEMBERS (smaller)
// -------------------------------------------------------------
class _BandRow extends StatelessWidget {
  final BandStyle band;
  const _BandRow({required this.band});

  @override
  Widget build(BuildContext context) {
    final count =
        band == BandStyle.rock ? 4 : band == BandStyle.pop ? 3 : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(count, (_) {
        return Column(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        );
      }),
    );
  }
}
//// PART 2 START
// -------------------------------------------------------------
// MAIN STAGE PAGE
// -------------------------------------------------------------
class StagePage extends StatefulWidget {
  final VoidCallback onMinigameCompleted;
  final String festivalName;

  const StagePage({
    super.key,
    required this.onMinigameCompleted,
    required this.festivalName,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage>
    with TickerProviderStateMixin {
  BandStyle band = BandStyle.rock;
  StageLights lights = StageLights.eco;
  StagePower power = StagePower.solar;
  StageFloor floor = StageFloor.none; // start brown

  SpeakerSetup speakers = SpeakerSetup.defaultSpeaker;

  late AnimationController crowdCtrl;
  late AnimationController spotlightCtrl;
  late AnimationController pulseCtrl;

  // Back wall theme index (for background color changes)
  int backdropIndex = 0;

  // Some nice preset gradients
  final List<LinearGradient> _backdropGradients = const [
    LinearGradient(
      colors: [Colors.black87, Colors.black54],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // deep blue
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)], // purple
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF004D40), Color(0xFF00796B)], // teal
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF880E4F), Color(0xFFC2185B)], // pink/red
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  // Track what the user already changed (to hide pulse after interaction)
  bool tappedLights = false;
  bool tappedBandArea = false; 
  bool tappedPower = false;
  bool tappedEffectsArea = false; 
  bool tappedFloor = false;
  bool tappedSpeakers = false;

  bool get showLightsHint => !tappedLights;
  bool get showBandHint => !tappedBandArea;
  bool get showPowerHint => !tappedPower;
  bool get showEffectsHint => !tappedEffectsArea;
  bool get showFloorHint => !tappedFloor;
  bool get showSpeakersHint => !tappedSpeakers;

  @override
  void initState() {
    super.initState();

    crowdCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    spotlightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    StageAudioController.instance.playLoop(band.name, kBandLoops[band]!);
  }

  @override
  void dispose() {
    crowdCtrl.dispose();
    spotlightCtrl.dispose();
    pulseCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // TAP LOGIC
  // -------------------------------------------------------------
  void cycleLights() {
    setState(() {
      tappedLights = true;
      lights = StageLights.values[(lights.index + 1) % StageLights.values.length];
    });
  }

  void cyclePower() {
    setState(() {
      tappedPower = true;
      power = StagePower.values[(power.index + 1) % StagePower.values.length];
    });
  }

  /// Middle tap → ONLY changes the band (4 / 3 / 1 performers).
  void _onBandAreaTap() {
    setState(() {
      tappedBandArea = true;
      band = BandStyle.values[(band.index + 1) % BandStyle.values.length];
    });
    StageAudioController.instance.playLoop(band.name, kBandLoops[band]!);
  }

  /// Effects area tap → ONLY changes background color now.
  void _onBackdropColorTap() {
    setState(() {
      tappedEffectsArea = true;
      backdropIndex = (backdropIndex + 1) % _backdropGradients.length;
    });
  }

  // -------------------------------------------------------------
  // FLOOR OPTION MENU
  // -------------------------------------------------------------
  Future<void> _showFloorOptions() async {
    final selected = await showModalBottomSheet<StageFloor>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose stage floor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _floorChoiceTile(
                StageFloor.woodenPallets,
                "Wooden pallets",
                "Wood from reused transport pallets.",
              ),
              _floorChoiceTile(
                StageFloor.osb,
                "OSB panels",
                "Engineered wood strands pressed into sheets.",
              ),
              _floorChoiceTile(
                StageFloor.steel,
                "Steel deck",
                "A strong metal surface used in heavy staging.",
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        tappedFloor = true;
        floor = selected;
      });
    }
  }

  Widget _floorChoiceTile(
    StageFloor value,
    String title,
    String subtitle,
  ) {
    final bool isSelected = floor == value;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          _floorAsset(value)!,
          width: 90,
          height: 60,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.greenAccent)
          : null,
      onTap: () => Navigator.pop(context, value),
    );
  }

  // -------------------------------------------------------------
  // SPEAKER OPTION MENU
  // -------------------------------------------------------------
  Future<void> _showSpeakerOptions() async {
    final selected = await showModalBottomSheet<SpeakerSetup>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose speakers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _speakerChoiceTile(
                SpeakerSetup.normalSpeaker,
                "Normal speaker",
                "A clean black speaker made from composite panels.",
              ),
              _speakerChoiceTile(
                SpeakerSetup.bambooSpeaker,
                "Bamboo speaker",
                "A speaker with a pressed bamboo outer shell.",
              ),
              _speakerChoiceTile(
                SpeakerSetup.loudSpeaker,
                "Loud speaker",
                "A reinforced metal tower made for high volume.",
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        tappedSpeakers = true;
        speakers = selected;
      });
    }
  }

  Widget _speakerChoiceTile(
    SpeakerSetup value,
    String title,
    String subtitle,
  ) {
    final bool isSelected = speakers == value;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.greenAccent)
          : null,
      onTap: () => Navigator.pop(context, value),
    );
  }
  // -------------------------------------------------------------
  // ASSET HELPERS
  // -------------------------------------------------------------

  // FLOOR VISUAL — brown when none, image otherwise
  String? _floorAsset(StageFloor f) {
    switch (f) {
      case StageFloor.none:
        return null;
      case StageFloor.woodenPallets:
        return 'assets/stage/PalletWood.png';
      case StageFloor.osb:
        return 'assets/stage/OSB.png';
      case StageFloor.steel:
        return 'assets/stage/Steel.png';
    }
  }

  Color _floorColor(StageFloor f) {
    return f == StageFloor.none ? Colors.brown.shade600 : Colors.transparent;
  }

  // SPEAKERS — UPDATED WITH YOUR FINAL FILENAMES
  String _speakerAsset(SpeakerSetup s) {
    switch (s) {
      case SpeakerSetup.defaultSpeaker:
        return 'assets/stage/defaultSpeaker.png';
      case SpeakerSetup.normalSpeaker:
        return 'assets/stage/normalSpeaker.png';
      case SpeakerSetup.bambooSpeaker:
        return 'assets/stage/bambooSpeaker.png';
      case SpeakerSetup.loudSpeaker:
        return 'assets/stage/loudSpeaker.png';
    }
  }

  // -------------------------------------------------------------
  // ECO SCORE
  // -------------------------------------------------------------
  int get ecoScore {
    int score = 0;

    score += lights == StageLights.eco ? 4 :
             lights == StageLights.mixed ? 1 : -4;

    score += power == StagePower.solar ? 4 :
             power == StagePower.grid ? 2 : -4;

    score += floor == StageFloor.woodenPallets ? 4 :
             floor == StageFloor.osb ? 2 :
             floor == StageFloor.steel ? -3 : 0;

    switch (speakers) {
      case SpeakerSetup.bambooSpeaker:
        score += 2;
        break;
      case SpeakerSetup.loudSpeaker:
        score -= 1;
        break;
      case SpeakerSetup.defaultSpeaker:
      case SpeakerSetup.normalSpeaker:
        break;
    }

    score += band == BandStyle.dj ? 2 :
             band == BandStyle.rock ? 1 : 0;

    return score;
  }

  int get ecoLevel {
    if (ecoScore >= 8) return 2;
    if (ecoScore >= 3) return 1;
    return 0;
  }

//// PART 3 START
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      appBar: AppBar(
        title: const Text("Build your eco stage"),
        backgroundColor: Colors.grey.shade700,
        actions: [
          IconButton(
            tooltip: 'Mute music',
            onPressed: StageAudioController.instance.stop,
            icon: const Icon(Icons.volume_off),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (_, c) => buildStage(context, c.maxWidth, c.maxHeight),
            ),
          ),
          const SizedBox(height: 12),
          _AnimatedCrowd(
            controller: crowdCtrl,
            spotlightController: spotlightCtrl,
            emojiRow: ecoLevel == 2
                ? "🙋‍♀️🙋‍♂️🎉🙋‍♀️🙋‍♂️🎉🙋‍♀️"
                : ecoLevel == 1
                    ? "🙋‍♂️🙋‍♀️🎵🙋‍♂️"
                    : "🙋‍♀️🙋‍♂️😐",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // BUILD STAGE VISUAL
  // -------------------------------------------------------------
  Widget buildStage(BuildContext context, double width, double height) {
    final beamColor = lights == StageLights.eco
        ? Colors.greenAccent
        : lights == StageLights.mixed
            ? Colors.amberAccent
            : Colors.redAccent;

    return Stack(
      children: [
        // BACK WALL
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: _backdropGradients[backdropIndex],
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),

        // TAP ZONES
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height * 0.30,
          child: GestureDetector(onTap: cycleLights),
        ),
        Positioned(
          bottom: height * 0.25,
          left: 0,
          right: 0,
          height: height * 0.25,
          child: GestureDetector(onTap: _onBandAreaTap),
        ),
        Positioned(
          top: height * 0.32,
          left: width * 0.3,
          right: width * 0.3,
          height: 60,
          child: GestureDetector(onTap: _onBackdropColorTap),
        ),
        Positioned(
          top: 0,
          left: 0,
          width: width * 0.25,
          height: height * 0.30,
          child: GestureDetector(onTap: cyclePower),
        ),
        Positioned(
          top: 0,
          right: 0,
          width: width * 0.25,
          height: height * 0.30,
          child: GestureDetector(onTap: cyclePower),
        ),

        // LIGHT BEAMS
        Positioned(
          top: 0,
          left: width * 0.18,
          child: _RotatingBeam(
            color: beamColor.withOpacity(0.8),
            reverse: false,
          ),
        ),
        Positioned(
          top: 0,
          right: width * 0.18,
          child: _RotatingBeam(
            color: beamColor.withOpacity(0.6),
            reverse: true,
          ),
        ),

        // BAND MEMBERS
        Positioned(
          bottom: height * 0.25 + 12,
          left: 0,
          right: 0,
          child: _BandRow(band: band),
        ),

        // FLOOR VISUAL
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height * 0.25,
          child: Container(
            decoration: BoxDecoration(
              color: _floorColor(floor),
              image: _floorAsset(floor) != null
                  ? DecorationImage(
                      image: AssetImage(_floorAsset(floor)!),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
        ),

        // FLOOR TAP ZONE
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height * 0.25,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _showFloorOptions,
          ),
        ),

        // SPEAKERS — corrected placement & scaling
        Positioned(
          bottom: height * 0.25 - 55,
          left: width * 0.02,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _showSpeakerOptions,
            child: Image.asset(
              _speakerAsset(speakers),
              width: width * 0.10,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          bottom: height * 0.25 - 55,
          right: width * 0.02,
          child: Image.asset(
            _speakerAsset(speakers),
            width: width * 0.10,
            fit: BoxFit.contain,
          ),
        ),
// -------------------------------------------------------------
// PERFECTLY CENTERED PULSE CIRCLES
// -------------------------------------------------------------

// Lights pulse (center of top 30%)
if (showLightsHint)
  Positioned(
    top: height * 0.15 - 25,
    left: width / 2 - 25,
    child: TapPulse(controller: pulseCtrl, size: 50),
  ),

// Band area pulse (center of 25% middle band area)
if (showBandHint)
  Positioned(
    bottom: height * 0.25 + (height * 0.125) - 25,
    left: width / 2 - 25,
    child: TapPulse(controller: pulseCtrl, size: 50),
  ),

// Backdrop color pulse (center of the 60px zone)
if (showEffectsHint)
  Positioned(
    top: height * 0.32 + 30 - 25,
    left: width / 2 - 25,
    child: TapPulse(controller: pulseCtrl, size: 50),
  ),

// Power pulses
if (showPowerHint) ...[
  Positioned(
    top: height * 0.15 - 25,
    left: width * 0.125 - 25,
    child: TapPulse(controller: pulseCtrl, size: 45),
  ),
  Positioned(
    top: height * 0.15 - 25,
    right: width * 0.125 - 25,
    child: TapPulse(controller: pulseCtrl, size: 45),
  ),
],

// Floor pulse
if (showFloorHint)
  Positioned(
    bottom: height * 0.125 - 25,
    left: width / 2 - 25,
    child: TapPulse(controller: pulseCtrl, size: 55),
  ),

// Speaker pulse (left speaker center)
if (showSpeakersHint)
  Positioned(
    bottom: height * 0.25 - 55 + (width * 0.10 / 2) - 25,
    left: width * 0.02 + (width * 0.10 / 2) - 25,
    child: TapPulse(controller: pulseCtrl, size: 45),
  ),
      ],
    );
  }
}

//// PART 4 START
// -------------------------------------------------------------
// RESULT PAGE
// -------------------------------------------------------------
class ResultPage extends StatelessWidget {
  final int score;
  final String bandName;
  final String festivalName;
  final VoidCallback onMinigameCompleted;

  const ResultPage({
    super.key,
    required this.score,
    required this.bandName,
    required this.festivalName,
    required this.onMinigameCompleted,
  });

  String get title {
    if (score >= 8) return "Eco Hero Stage 🌱";
    if (score >= 3) return "Nice Try Stage 🙂";
    return "Eco Disaster Stage 😬";
  }

  String get message {
    if (score >= 8) {
      return "Your stage is super eco! The planet and the crowd both love you.";
    } else if (score >= 3) {
      return "You made some good choices! There's still some room to improve.";
    } else {
      return "Your stage is not very eco-friendly. Try adjusting lights, power or effects next time.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      appBar: AppBar(
        title: const Text("Stage result"),
        backgroundColor: Colors.grey.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              festivalName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Band: $bandName",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              "Eco Score: $score",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                onMinigameCompleted();
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
              child: const Text("Back to festival map"),
            ),
          ],
        ),
      ),
    );
  }
}
