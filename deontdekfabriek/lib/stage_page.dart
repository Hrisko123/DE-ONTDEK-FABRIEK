import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera_shake/camera_shake.dart';
import 'ui_styles.dart'; 

/// ------------------------------------------------------------
/// AUDIO CONTROLLER 
/// ------------------------------------------------------------
class StageAudioController {
  StageAudioController._internal() {
    _player.onPlayerComplete.listen((event) {
      _playNextInPlaylist();
    });
  }

  static final StageAudioController instance =
      StageAudioController._internal();

  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  final Map<String, List<String>> _playlists = {
    'rock': [
      'audio/band/band1.mp3',
      'audio/band/band2.mp3',
      'audio/band/band3.mp3',
      'audio/band/band4.mp3',
    ],
    'pop': [
      'audio/pop/pop1.mp3',
      'audio/pop/pop2.mp3',
      'audio/pop/pop3.mp3',
      'audio/pop/pop4.mp3',
      'audio/pop/pop5.mp3',
      'audio/pop/pop6.mp3',
    ],
    'dj': [
      'audio/dj/dj1.mp3',
      'audio/dj/dj2.mp3',
      'audio/dj/dj3.mp3',
      'audio/dj/dj4.mp3',
    ],
  };

  String? _currentKey;
  int _currentIndex = 0;
  bool _muted = false;

  bool get isMuted => _muted;

  Future<void> playForBand(String key) async {
    final tracks = _playlists[key];
    if (tracks == null || tracks.isEmpty) return;

    _currentKey = key;
    _currentIndex = Random().nextInt(tracks.length);

    if (_muted) return;

    await _player.stop();
    await _player.play(AssetSource(tracks[_currentIndex]));
  }

  void _playNextInPlaylist() {
    if (_currentKey == null) return;
    final list = _playlists[_currentKey];
    if (list == null || list.isEmpty) return;

    _currentIndex = Random().nextInt(list.length);
    if (!_muted) {
      _player.play(AssetSource(list[_currentIndex]));
    }
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> stop() async {
    _currentKey = null;
    await _player.stop();
  }
}

// -------------------------------------------------------------
// ENUMS
// -------------------------------------------------------------
enum BandStyle { rock, pop, dj }
enum StageLights { eco, mixed, flood }
enum StagePower { solar, grid, diesel }
enum StageFloor { none, woodenPallets, osb, steel }
enum SpeakerSetup { defaultSpeaker, normalSpeaker, bambooSpeaker, loudSpeaker }

// -------------------------------------------------------------
// AUDIO LOOPS
// -------------------------------------------------------------
final kBandLoops = {
  BandStyle.rock: 'assets/audio/rock_loop.mp3',
  BandStyle.pop: 'assets/audio/pop_loop.mp3',
  BandStyle.dj: 'assets/audio/techno_loop.mp3',
};

// -------------------------------------------------------------
// TAP PULSE (unchanged)
// -------------------------------------------------------------
class TapPulse extends StatelessWidget {
  final AnimationController controller;
  final double size;

  const TapPulse({super.key, required this.controller, this.size = 60});

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
// ROTATING BEAM (unchanged)
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
// CROWD ANIMATION (unchanged)
// -------------------------------------------------------------
class _AnimatedCrowd extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedCrowd({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final bounce = sin(controller.value * pi * 2) * 6;

        return Transform.translate(
          offset: Offset(0, bounce),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 0.78,
            child: Transform.scale(
              scaleX: 1.25,
              child: Image.asset(
                "assets/stage/audience.png",
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// -------------------------------------------------------------
// SPEAKER GLOW (unchanged)
// -------------------------------------------------------------
class SpeakerGlow extends StatelessWidget {
  final Animation<double> anim;
  final Widget child;
  final double size;

  const SpeakerGlow({
    super.key,
    required this.anim,
    required this.child,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final glow = (0.4 + anim.value * 0.6);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(glow * 0.5),
                blurRadius: 25 * glow,
                spreadRadius: 5 * glow,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

// -------------------------------------------------------------
// STAGE PAGE
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

  bool _shownIntro = false;

  // STATE
  BandStyle band = BandStyle.rock;
  StageLights lights = StageLights.eco;
  StagePower power = StagePower.solar;
  StageFloor floor = StageFloor.none;
  SpeakerSetup speakers = SpeakerSetup.defaultSpeaker;

  // PERFORMER IMAGE
  String selectedPerformerImage = "assets/stage/microphone.png";
  bool hasChosenPerformer = false;

  // HINT FLAGS
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

  // BACKDROP INDEX
  int backdropIndex = 0;

  // BACKDROP GRADIENTS (unchanged)
  final List<LinearGradient> _backdropGradients = const [
    LinearGradient(colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
    LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
    LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF283593)]),
    LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
    LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00796B)]),
    LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)]),
    LinearGradient(colors: [Color(0xFF33691E), Color(0xFF558B2F)]),
    LinearGradient(colors: [Color(0xFF004D40), Color(0xFF009688)]),
    LinearGradient(colors: [Color(0xFF4527A0), Color(0xFF5E35B1)]),
    LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF4A148C)]),
  ];

  // CONTROLLERS
  late AnimationController crowdCtrl;
  late AnimationController spotlightCtrl;
  late AnimationController pulseCtrl;
  late AnimationController beamPopCtrl;
  late AnimationController speakerGlowCtrl;

  // -------------------------------------------------------------
  // INIT
  // -------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    crowdCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    spotlightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    beamPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    speakerGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_shownIntro) {
        _shownIntro = true;
        _showIntroPopup();
      }
    });
  }

  @override
  void dispose() {
    crowdCtrl.dispose();
    spotlightCtrl.dispose();
    pulseCtrl.dispose();
    beamPopCtrl.dispose();
    speakerGlowCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // INTRO POPUP (unchanged)
  // -------------------------------------------------------------
  void _showIntroPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Build Your Eco Stage!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "You’re in charge of the main stage at ${widget.festivalName} 🎪\n\n"
          "Tap different parts of the stage to:\n"
          "• Pick the performer\n"
          "• Choose stage energy\n"
          "• Upgrade speakers\n"
          "• Change floor\n"
          "• Change background\n\n"
          "Finish all choices to see your ECO score!",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Let's Go!", style: TextStyle(color: Colors.greenAccent)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // COMPLETION CHECK (cleaned)
  // -------------------------------------------------------------
  void _checkCompletion() {
    final performerDone = hasChosenPerformer;
    final lightsDone = tappedLights;
    final powerDone = tappedPower;
    final floorDone = floor != StageFloor.none;
    final speakersDone = speakers != SpeakerSetup.defaultSpeaker;
    final backdropDone = tappedEffectsArea;

    if (performerDone &&
        lightsDone &&
        powerDone &&
        floorDone &&
        speakersDone &&
        backdropDone) {
      _goToResult();
    }
  }

  void _goToResult() {
    Future.delayed(const Duration(milliseconds: 250), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: ecoScore,
            bandName: band.name,
            festivalName: widget.festivalName,
            onMinigameCompleted: widget.onMinigameCompleted,
          ),
        ),
      );
    });
  }
  // -------------------------------------------------------------
  // CHOICE CARD (shared UI)
  // -------------------------------------------------------------
  Widget _choiceCard({
    required bool selected,
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? Colors.white10 : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.greenAccent : Colors.white12,
            width: selected ? 2.2 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // LIGHT / ENERGY PICKER
  // -------------------------------------------------------------
  void cycleLights() {
    tappedLights = true;
    _showLightEnergyOptions();
  }

  Widget _energyCard({
    required StageLights value,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final bool isSelected = lights == value;

    return _choiceCard(
      selected: isSelected,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 32, color: iconColor),
      ),
      title: title,
      subtitle: description,
      onTap: () => Navigator.pop(context, value),
    );
  }

  Future<void> _showLightEnergyOptions() async {
    final selected = await showModalBottomSheet<StageLights>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose energy for the festival",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              _energyCard(
                value: StageLights.eco,
                icon: Icons.wb_sunny,
                iconColor: Colors.greenAccent,
                title: "Solar Panels",
                description: "Clean, renewable sunlight energy.",
              ),

              _energyCard(
                value: StageLights.mixed,
                icon: Icons.battery_full,
                iconColor: Colors.lightBlueAccent,
                title: "Battery Grid",
                description: "Portable battery-powered grid.",
              ),

              _energyCard(
                value: StageLights.flood,
                icon: Icons.local_gas_station,
                iconColor: Colors.purpleAccent,
                title: "Diesel Generator",
                description: "Traditional generator power.",
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        lights = selected;
        tappedLights = true;
      });

      beamPopCtrl.forward(from: 0);
      _checkCompletion();  // ✅ ADDED
    }
  }

  // -------------------------------------------------------------
  // POWER CYCLE TAP
  // -------------------------------------------------------------
  void cyclePower() {
    setState(() {
      tappedPower = true;
      power = StagePower.values[
          (power.index + 1) % StagePower.values.length];
    });

    _checkCompletion();  // ✅ ADDED
  }

  // -------------------------------------------------------------
  // PERFORMER PICKER
  // -------------------------------------------------------------
  void _onBandAreaTap() {
    tappedBandArea = true;
    _showPerformerSelection();
  }

  Future<void> _showPerformerSelection() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose your performer",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _performerTile(
                bandStyle: BandStyle.rock,
                filename: "group.png",
                title: "Band",
                subtitle: "Live guitar and drums.",
              ),
              _performerTile(
                bandStyle: BandStyle.pop,
                filename: "pop.png",
                title: "Pop Artist",
                subtitle: "Vocals and pop dance music.",
              ),
              _performerTile(
                bandStyle: BandStyle.dj,
                filename: "dj2.png",
                title: "DJ",
                subtitle: "Electronic beats and EDM.",
              ),
            ],
          ),
        );
      },
    );

    if (choice != null) {
      setState(() {
        selectedPerformerImage = "assets/stage/$choice";
        hasChosenPerformer = true;

        if (choice == "group.png") band = BandStyle.rock;
        if (choice == "pop.png") band = BandStyle.pop;
        if (choice == "dj2.png") band = BandStyle.dj;
      });

      // Keep audio disabled as requested
      // StageAudioController.instance.playLoop(band.name, kBandLoops[band]!);

      _checkCompletion();  // ✅ ADDED
    }
  }

  Widget _performerTile({
    required String title,
    required String filename,
    required BandStyle bandStyle,
    required String subtitle,
  }) {
    return _choiceCard(
      selected: band == bandStyle,
      leading: Image.asset(
        "assets/stage/$filename",
        width: 70,
        height: 70,
      ),
      title: title,
      subtitle: subtitle,
      onTap: () => Navigator.pop(context, filename),
    );
  }

  // -------------------------------------------------------------
  // BACKDROP PICKER
  // -------------------------------------------------------------
  void _onBackdropColorTap() {
    tappedEffectsArea = true;
    _showBackdropPicker();
  }

  Future<void> _showBackdropPicker() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose a stage background",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 330,
                child: ListView.builder(
                  itemCount: _backdropGradients.length,
                  itemBuilder: (_, i) {
                    bool isSelected = backdropIndex == i;

                    return GestureDetector(
                      onTap: () => Navigator.pop(context, i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 14),
                        height: 85,
                        decoration: BoxDecoration(
                          gradient: _backdropGradients[i],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Colors.greenAccent
                                : Colors.white24,
                            width: isSelected ? 2.5 : 1.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => backdropIndex = selected);
      _checkCompletion();  // ✅ ADDED
    }
  }
  // -------------------------------------------------------------
  // FLOOR CHOICES
  // -------------------------------------------------------------
  Future<void> _showFloorOptions() async {
    final selected = await showModalBottomSheet<StageFloor>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose stage floor",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _floorChoiceTile(
                StageFloor.woodenPallets,
                "Wooden Pallets",
                "Reused pallet wood forms the stage surface.",
              ),
              _floorChoiceTile(
                StageFloor.osb,
                "OSB Panels",
                "Pressed wood panels commonly used.",
              ),
              _floorChoiceTile(
                StageFloor.steel,
                "Steel Deck",
                "A large heavy-duty metal platform.",
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        tappedFloor = true;
        floor = selected;
      });

      _checkCompletion(); // ✅ ADDED
    }
  }

  Widget _floorChoiceTile(
      StageFloor value, String title, String subtitle) {
    final bool isSelected = floor == value;

    return _choiceCard(
      selected: isSelected,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          _floorAsset(value)!,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        ),
      ),
      title: title,
      subtitle: subtitle,
      onTap: () => Navigator.pop(context, value),
    );
  }

  // -------------------------------------------------------------
  // SPEAKER OPTIONS
  // -------------------------------------------------------------
  Future<void> _showSpeakerOptions() async {
    final selected = await showModalBottomSheet<SpeakerSetup>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose speakers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _speakerChoiceTile(
                SpeakerSetup.normalSpeaker,
                "Tower Speakers",
                "Reliable all-round speakers.",
                "assets/stage/normalSpeaker.png",
              ),
              _speakerChoiceTile(
                SpeakerSetup.bambooSpeaker,
                "Bamboo Speakers",
                "Sustainable bamboo material.",
                "assets/stage/bambooSpeaker.png",
              ),
              _speakerChoiceTile(
                SpeakerSetup.loudSpeaker,
                "Loud Speakers",
                "High-volume tower speakers.",
                "assets/stage/loudSpeaker.png",
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        tappedSpeakers = true;
        speakers = selected;
      });

      _checkCompletion(); // ✅ ADDED
    }
  }

  Widget _speakerChoiceTile(
    SpeakerSetup value,
    String title,
    String subtitle,
    String imgPath,
  ) {
    final bool isSelected = speakers == value;

    return _choiceCard(
      selected: isSelected,
      leading: Image.asset(imgPath, width: 55, height: 55),
      title: title,
      subtitle: subtitle,
      onTap: () => Navigator.pop(context, value),
    );
  }

  // -------------------------------------------------------------
  // MAIN BUILD
  // -------------------------------------------------------------
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
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF66BB6A),
              Color(0xFFA5D6A7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1.2,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (_, c) =>
                            buildStage(context, c.maxWidth, c.maxHeight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // BUILD STAGE CONTENT
  // -------------------------------------------------------------
  Widget buildStage(BuildContext context, double width, double height) {
    final activeColor = lights == StageLights.eco
        ? Colors.greenAccent
        : lights == StageLights.mixed
            ? Colors.lightBlueAccent
            : Colors.purpleAccent;

    final double popScale = 1 + beamPopCtrl.value * 0.20;

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

        // TOP LIGHTS TAP AREA
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height * 0.30,
          child: GestureDetector(onTap: cycleLights),
        ),

        // PERFORMER AREA
        Positioned(
          bottom: height * 0.25,
          left: 0,
          right: 0,
          height: height * 0.25,
          child: GestureDetector(onTap: _onBandAreaTap),
        ),

        // BACKDROP AREA
        Positioned(
          top: height * 0.32,
          left: width * 0.28,
          right: width * 0.28,
          height: 75,
          child: GestureDetector(onTap: _onBackdropColorTap),
        ),

        // POWER LEFT/RIGHT TAPS
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
        _beam(width * 0.05, activeColor.withOpacity(0.55), true, popScale),
        _beam(width * 0.18, activeColor.withOpacity(0.75), false, popScale),
        _beam(width * 0.45, activeColor.withOpacity(0.95), false, popScale),
        _beam(width * 0.72, activeColor.withOpacity(0.75), true, popScale),
        _beam(width * 0.90, activeColor.withOpacity(0.55), false, popScale),
        // FLOOR
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height * 0.25,
          child: GestureDetector(
            onTap: _showFloorOptions,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, -2),
                  ),
                ],
                image: _floorAsset(floor) != null
                    ? DecorationImage(
                        image: AssetImage(_floorAsset(floor)!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.12),
                          BlendMode.darken,
                        ),
                      )
                    : null,
                color: _floorAsset(floor) == null
                    ? Colors.brown.shade700
                    : Colors.transparent,
              ),
            ),
          ),
        ),

        // PERFORMER
        Positioned(
          bottom: height * 0.25 - 155,
          left: 0,
          right: 0,
          child: Center(
            child: Builder(
              builder: (_) {
                final bool isMic =
                    selectedPerformerImage.contains("microphone");
                final bool isPop =
                    selectedPerformerImage.contains("pop");

                double w, h;
                if (isMic) {
                  w = width * 0.23;
                  h = width * 0.30;
                } else if (isPop) {
                  w = width * 0.26;
                  h = width * 0.34;
                } else {
                  w = width * 0.32;
                  h = width * 0.40;
                }

                return SizedBox(
                  width: w,
                  height: h,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(selectedPerformerImage),
                  ),
                );
              },
            ),
          ),
        ),

        // SPEAKER LEFT
        Positioned(
          bottom: height * 0.25 - 55,
          left: width * 0.10,
          child: GestureDetector(
            onTap: _showSpeakerOptions,
            child: Image.asset(
              _speakerAsset(speakers),
              width: width * 0.14,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // SPEAKER RIGHT
        Positioned(
          bottom: height * 0.25 - 55,
          right: width * 0.10,
          child: Image.asset(
            _speakerAsset(speakers),
            width: width * 0.14,
            fit: BoxFit.contain,
          ),
        ),

        // TAP HINTS
        if (showLightsHint)
          Positioned(
            top: height * 0.13,
            left: width / 2 - 27,
            child: GestureDetector(
              onTap: cycleLights,
              child: TapPulse(controller: pulseCtrl, size: 55),
            ),
          ),

        if (showBandHint)
          Positioned(
            bottom: height * 0.25 + height * 0.12,
            left: width / 2 - 27,
            child: GestureDetector(
              onTap: _onBandAreaTap,
              child: TapPulse(controller: pulseCtrl, size: 55),
            ),
          ),

        if (showPowerHint) ...[
          Positioned(
            top: height * 0.15,
            left: width * 0.10,
            child: GestureDetector(
              onTap: cyclePower,
              child: TapPulse(controller: pulseCtrl, size: 48),
            ),
          ),
          Positioned(
            top: height * 0.15,
            right: width * 0.10,
            child: GestureDetector(
              onTap: cyclePower,
              child: TapPulse(controller: pulseCtrl, size: 48),
            ),
          ),
        ],

        if (showFloorHint)
          Positioned(
            bottom: height * 0.12,
            left: width / 2 - 30,
            child: GestureDetector(
              onTap: _showFloorOptions,
              child: TapPulse(controller: pulseCtrl, size: 60),
            ),
          ),

        if (showSpeakersHint)
          Positioned(
            bottom: height * 0.25 - 35,
            left: width * 0.17 - 25,
            child: GestureDetector(
              onTap: _showSpeakerOptions,
              child: TapPulse(controller: pulseCtrl, size: 48),
            ),
          ),

        // CROWD
        if (hasChosenPerformer)
          Positioned(
            left: 0,
            right: 0,
            bottom: -8,
            child: _AnimatedCrowd(controller: crowdCtrl),
          ),
      ],
    );
  }

  // -------------------------------------------------------------
  // BEAM BUILDER
  // -------------------------------------------------------------
  Widget _beam(double leftPos, Color col, bool reverse, double scale) {
    return Positioned(
      top: 0,
      left: leftPos,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: _RotatingBeam(color: col, reverse: reverse),
      ),
    );
  }

  // -------------------------------------------------------------
  // FLOOR ASSET
  // -------------------------------------------------------------
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

  // -------------------------------------------------------------
  // SPEAKER ASSET
  // -------------------------------------------------------------
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

    score += lights == StageLights.eco
        ? 4
        : lights == StageLights.mixed
            ? -1
            : -6;

    score += power == StagePower.solar
        ? 4
        : power == StagePower.grid
            ? -1
            : -6;

    score += floor == StageFloor.woodenPallets
        ? 4
        : floor == StageFloor.osb
            ? 2
            : floor == StageFloor.steel
                ? -3
                : 0;

    switch (speakers) {
      case SpeakerSetup.bambooSpeaker:
        score += 2;
        break;
      case SpeakerSetup.loudSpeaker:
        score -= 1;
        break;
      default:
        break;
    }

    score += band == BandStyle.dj
        ? 2
        : band == BandStyle.rock
            ? 1
            : 0;

    return score;
  }

  int get ecoLevel {
    if (ecoScore >= 8) return 2;
    if (ecoScore >= 3) return 1;
    return 0;
  }
}

// -------------------------------------------------------------
// RESULT PAGE
// -------------------------------------------------------------
class ResultPage extends StatefulWidget {
  
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
      return "Your stage is super eco-friendly! The planet and the crowd both love your choices.";
    } else if (score >= 3) {
      return "Your stage is decent! Some choices helped the planet, but you can still improve.";
    } else {
      return "Your stage isn't very eco-friendly. Try using better energy, materials, and equipment next time!";
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

            Text("Performer: $bandName",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 6),

            Text("Eco Score: $score",
                style: const TextStyle(fontSize: 18)),

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
