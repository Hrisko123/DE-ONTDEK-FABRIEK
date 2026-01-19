import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_page.dart';
import 'stage_audio_controller.dart';
import 'services/led_service.dart';

// GLOBAL AUDIO ENGINE (Audioplayers 5.x)

class StageAudioEngine {
  StageAudioEngine._internal();

  static final StageAudioEngine instance = StageAudioEngine._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;
  String? _currentArtistKey;

  bool get isMuted => _muted;

  // Artist playlists
  final Map<String, List<String>> _artistTracks = {
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

  Future<void> playArtist(String artistKey) async {
    if (_muted) return;

    _currentArtistKey = artistKey;
    final tracks = _artistTracks[artistKey];
    if (tracks == null || tracks.isEmpty) return;

    int currentIndex = Random().nextInt(tracks.length);
    await _player.stop();
    await _player.play(AssetSource(tracks[currentIndex]));

    _player.onPlayerComplete.listen((event) async {
      if (_muted) return;

      currentIndex = (currentIndex + 1) % tracks.length;

      await _player.stop();
      await _player.play(AssetSource(tracks[currentIndex]));
    });
  }

  Future<void> toggleMute() async {
    if (!_muted) {
      _muted = true;
      await _player.pause();
    } else {
      _muted = false;

      if (_currentArtistKey != null) {
        await _player.resume();
      }
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }
}

// SAVE SYSTEM FOR STAGE SELECTIONS

class StageSave {
  static Future<void> saveChoices({
    required String performer,
    required String power,
    required String lights,
    required String floor,
    required String speakers,
    required int backdrop,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("stage_performer", performer);
    await prefs.setString("stage_power", power);
    await prefs.setString("stage_lights", lights);
    await prefs.setString("stage_floor", floor);
    await prefs.setString("stage_speakers", speakers);
    await prefs.setInt("stage_backdrop", backdrop);
  }

  static Future<Map<String, dynamic>> loadChoices() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "performer": prefs.getString("stage_performer"),
      "power": prefs.getString("stage_power"),
      "lights": prefs.getString("stage_lights"),
      "floor": prefs.getString("stage_floor"),
      "speakers": prefs.getString("stage_speakers"),
      "backdrop": prefs.getInt("stage_backdrop"),
    };
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("stage_completed", true);
  }

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("stage_completed") ?? false;
  }
}

// FESTIVAL LIGHTING + VISUAL EFFECT HELPERS

class GlowPainter extends CustomPainter {
  final Color color;
  final double intensity;

  GlowPainter(this.color, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = color.withOpacity(0.07 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.18),
      size.width * 0.65,
      glow,
    );
  }

  @override
  bool shouldRepaint(GlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}

class FollowSpotLight extends StatelessWidget {
  final Animation<double> anim;
  final Color color;
  final Offset Function() performerCenter;

  const FollowSpotLight({
    super.key,
    required this.anim,
    required this.color,
    required this.performerCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final performer = performerCenter();
        final offsetX = sin(anim.value * 2 * pi) * 35;

        return Positioned(
          left: performer.dx - 90 + offsetX,
          top: performer.dy - 250,
          child: Container(
            width: 180,
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.6), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        );
      },
    );
  }
}

class SweepingLight extends StatelessWidget {
  final Animation<double> anim;
  final Color color;

  const SweepingLight({super.key, required this.anim, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final x = sin(anim.value * 2 * pi) * 0.55;

        return Positioned(
          top: -60,
          left: MediaQuery.of(context).size.width * (0.5 + x) - 140,
          child: Transform.rotate(
            angle: x * 0.9,
            child: Container(
              width: 300,
              height: 380,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Speaker pulse animation (reacts to music beat)
class SpeakerPulse extends StatelessWidget {
  final Animation<double> anim;
  final Widget child;
  final double strength;

  const SpeakerPulse({
    super.key,
    required this.anim,
    required this.child,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final scale = 1 + sin(anim.value * 2 * pi) * strength;
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

// Audience bounce animation
class AudienceBounce extends StatelessWidget {
  final Animation<double> anim;
  final Widget child;

  const AudienceBounce({super.key, required this.anim, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final offset = sin(anim.value * 2 * pi) * 6;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
    );
  }
}

// ENUMS FOR STAGE OPTIONS

enum BandStyle { rock, pop, dj }

enum StageLights { eco, mixed, flood }

enum StagePower { solar, grid, diesel }

enum StageFloor { none, woodenPallets, osb, steel }

enum SpeakerSetup { defaultSpeaker, normalSpeaker, bambooSpeaker, loudSpeaker }

// MAIN STAGE PAGE

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

class _StagePageState extends State<StagePage> with TickerProviderStateMixin {
  // GAME STATE
  BandStyle band = BandStyle.rock;
  StageLights lights = StageLights.eco;
  StagePower power = StagePower.solar;
  StageFloor floor = StageFloor.none;
  SpeakerSetup speakers = SpeakerSetup.defaultSpeaker;

  String selectedPerformerImage = "assets/stage/microphone.png";
  bool hasChosenPerformer = false;
  bool _hasSavedPerformer = false;

  bool tappedLights = false;
  bool tappedBandArea = false;
  bool tappedPower = false;
  bool tappedEffectsArea = false;
  bool tappedFloor = false;
  bool tappedSpeakers = false;
  bool _hasInteracted = false;
  bool _stageCompleted = false;
  bool _showSearchLight = true;

  bool get showLightsHint => !_stageCompleted && !tappedLights;
  bool get showBandHint => !hasChosenPerformer;
  bool get showEffectsHint => !_stageCompleted && !tappedEffectsArea;
  bool get showFloorHint => !_stageCompleted && !tappedFloor;
  bool get showSpeakersHint => !_stageCompleted && !tappedSpeakers;

  String _bandToImage(BandStyle band) {
    switch (band) {
      case BandStyle.rock:
        return "assets/stage/group.png";
      case BandStyle.pop:
        return "assets/stage/pop.png";
      case BandStyle.dj:
        return "assets/stage/dj2.png";
    }
  }

  int backdropIndex = 0;
  bool _shownIntro = false;
  String _stageDialogue =
      "Hey there! Before the festival can start, choose a performer by tapping the microphone.";
  bool _showStageDialogue = true;

  // ---------------- ANIMATION CONTROLLERS ----------------
  late AnimationController crowdCtrl;
  late AnimationController speakerBeatCtrl;
  late AnimationController sweepCtrl;
  late AnimationController glowCtrl;
  late AnimationController confettiCtrl;

  // ---------------- BACKDROP GRADIENTS ----------------
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
  final GlobalKey _performerKey = GlobalKey();

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    // Crowd bounce
    crowdCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Speaker beat pulse
    speakerBeatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Sweeping light
    sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Glow pulse
    glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Confetti
    confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _loadSavedStage();
  }

  @override
  void dispose() {
    crowdCtrl.dispose();
    speakerBeatCtrl.dispose();
    sweepCtrl.dispose();
    glowCtrl.dispose();
    confettiCtrl.dispose();
    super.dispose();
  }

  Widget _securityIntroOverlay(double width) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          if (!hasChosenPerformer)
            Positioned(
              right: 20,
              bottom: 0,
              child: Image.asset(
                "assets/stage/security.png",
                height: width * 0.32,
                fit: BoxFit.contain,
              ),
            ),

          if (!_stageCompleted && !_hasInteracted && !hasChosenPerformer)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // soft glass tint (not depressing, fits eco theme)
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.92),
                          Colors.white.withOpacity(0.78),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                        width: 1.2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color(0xFF1F2933),
                                fontSize: 17,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "You’re now responsible for the festival stage.\n\n",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      "Select a performer and adjust the stage elements to get everything ready for the show.\n\n",
                                ),
                                TextSpan(
                                  text:
                                      "Keep sustainability in mind — eco-friendly choices lead to the best results.",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // LOAD SAVED STATE
  Future<void> _loadSavedStage() async {
    _hasInteracted = false;

    final data = await StageSave.loadChoices();
    final completed = await StageSave.isCompleted();

    setState(() {
      _hasInteracted = false;
      _stageCompleted = completed;

      final savedPerformer = data["performer"] as String?;

      if (savedPerformer != null) {
        band = BandStyle.values.firstWhere(
          (e) => e.name == savedPerformer,
          orElse: () => BandStyle.rock,
        );

        selectedPerformerImage = _bandToImage(band);

        _hasSavedPerformer = true;
        hasChosenPerformer = false;
      } else {
        selectedPerformerImage = "assets/stage/microphone.png";

        _hasSavedPerformer = false;
        hasChosenPerformer = false;
      }

      // ---------------- POWER ----------------
      final p = data["power"] as String?;
      if (p == "solar") power = StagePower.solar;
      if (p == "grid") power = StagePower.grid;
      if (p == "diesel") power = StagePower.diesel;

      // ---------------- LIGHTS ----------------
      final l = data["lights"] as String?;
      if (l == "eco") lights = StageLights.eco;
      if (l == "mixed") lights = StageLights.mixed;
      if (l == "flood") lights = StageLights.flood;

      // ---------------- FLOOR ----------------
      final f = data["floor"] as String?;
      if (f == "wood") floor = StageFloor.woodenPallets;
      if (f == "osb") floor = StageFloor.osb;
      if (f == "steel") floor = StageFloor.steel;

      // ---------------- SPEAKERS ----------------
      final s = data["speakers"] as String?;
      if (s != null) {
        speakers = SpeakerSetup.values.firstWhere(
          (e) => e.name == s,
          orElse: () => SpeakerSetup.defaultSpeaker,
        );
      }

      // ---------------- BACKDROP ----------------
      final b = data["backdrop"] as int?;
      if (b != null && b >= 0 && b < _backdropGradients.length) {
        backdropIndex = b;
      }
    });
  }

  Widget _realisticFloor(double width, double height) {
    final floorTexture = _floorAsset(floor);

    return Stack(
      children: [
        Container(
          height: height * 0.17,
          decoration: BoxDecoration(
            color: floorTexture == null ? Colors.brown.shade700 : null,
            image: floorTexture != null
                ? DecorationImage(
                    image: AssetImage(floorTexture),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),

        Positioned(
          bottom: height * 0.03,
          left: 0,
          right: 0,
          child: Container(
            height: height * 0.03,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: width * 0.06,
          right: width * 0.06,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(0.18),
            alignment: Alignment.topCenter,
            child: Container(
              height: height * 0.03,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset _getPerformerCenter() {
    final box = _performerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;

    final position = box.localToGlobal(Offset.zero);
    final centerX = position.dx + box.size.width / 2;
    final centerY = position.dy + box.size.height / 2;

    return Offset(centerX, centerY);
  }

  // MAIN BUILD

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),

      appBar: AppBar(
        title: Text(
          "${widget.festivalName} — Eco Stage",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        actions: [
          IconButton(
            tooltip: StageAudioEngine.instance.isMuted ? "Unmute" : "Mute",
            icon: Icon(
              StageAudioController.instance.isMuted
                  ? Icons.volume_off
                  : Icons.volume_up,
            ),
            onPressed: () async {
              StageAudioController.instance.toggleMute();
              setState(() {});
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 9,
                child: Stack(
                  children: [
                    // BACKGROUND
                    Positioned.fill(
                      child: Image.asset(
                        "assets/stage/background-final.png",
                        fit: BoxFit.cover,
                      ),
                    ),

                    // GAME LAYER
                    Positioned.fill(
                      child: Transform.translate(
                        offset: const Offset(-8, 185),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 740,
                            height: 624,
                            child: buildGameContent(context),
                          ),
                        ),
                      ),
                    ),

                    // STAGE OVERLAY
                    IgnorePointer(
                      ignoring: true,
                      child: Transform.translate(
                        offset: const Offset(0, 28),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 1105,
                            height: 650,
                            child: Image.asset(
                              "assets/stage/stage.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // BARRICADE
          IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "assets/stage/metal-baricade.png",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (_hasSavedPerformer || hasChosenPerformer)
            IgnorePointer(
              ignoring: true,
              child: Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: const Offset(0, 40),
                    child: SizedBox(
                      height: height * 0.10,
                      width: width,
                      child: AudienceBounce(
                        anim: crowdCtrl,
                        child: Image.asset(
                          "assets/stage/layer3.png",
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (_hasSavedPerformer || hasChosenPerformer)
            IgnorePointer(
              ignoring: true,
              child: Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: const Offset(0, 110),
                    child: SizedBox(
                      height: height * 0.50,
                      width: width,
                      child: AudienceBounce(
                        anim: crowdCtrl,
                        child: Image.asset(
                          "assets/stage/layer4.png",
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (showLightsHint)
            Positioned(
              top: 195,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: GestureDetector(onTap: cycleLights, child: _hintPulse()),
            ),

          if (!_hasInteracted)
            Positioned(
              bottom: 330,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: GestureDetector(
                onTap: _onBandAreaTap,
                child: _hintPulse(),
              ),
            ),

          if (showEffectsHint)
            Positioned(
              top: 400,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: GestureDetector(
                onTap: _onBackdropColorTap,
                child: _hintPulse(),
              ),
            ),

          if (showSpeakersHint)
            Positioned(
              bottom: 280,
              left: 400,
              child: GestureDetector(
                onTap: _showSpeakerOptions,
                child: _hintPulse(),
              ),
            ),

          if (showFloorHint)
            Positioned(
              bottom: 200,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: GestureDetector(
                onTap: _showFloorOptions,
                child: _hintPulse(),
              ),
            ),
          if (!_stageCompleted && !hasChosenPerformer)
            _securityIntroOverlay(width),
        ],
      ),
    );
  }

  Widget buildGameContent(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: buildStage(
            context,
            constraints.maxWidth,
            constraints.maxHeight,
          ),
        );
      },
    );
  }

  // BUILD STAGE

  Widget buildStage(BuildContext context, double width, double height) {
    final activeColor = lights == StageLights.eco
        ? Colors.greenAccent
        : lights == StageLights.mixed
        ? Colors.lightBlueAccent
        : Colors.purpleAccent;

    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.79,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _backdropGradients[backdropIndex],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.3),
                      radius: 1.4,
                      colors: [
                        Colors.white.withOpacity(0.12 + glowCtrl.value * 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15 * glowCtrl.value),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Pulsing glow behind performer
              Positioned.fill(
                child: CustomPaint(
                  painter: GlowPainter(
                    Colors.white,
                    0.15 + glowCtrl.value * 0.2,
                  ),
                ),
              ),

              if (_showSearchLight)
                FollowSpotLight(
                  anim: sweepCtrl,
                  color: activeColor,
                  performerCenter: _getPerformerCenter,
                ),
            ],
          ),
        ),

        // Top lights area
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height * 0.25,
          child: GestureDetector(onTap: _stageCompleted ? null : cycleLights),
        ),

        // Performer tap area
        Positioned(
          bottom: height * 0.25,
          left: 0,
          right: 0,
          height: height * 0.22,
          child: IgnorePointer(
            ignoring: hasChosenPerformer,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _onBandAreaTap,
            ),
          ),
        ),

        // Backdrop area
        Positioned(
          top: height * 0.30,
          left: width * 0.25,
          right: width * 0.25,
          height: 80,
          child: GestureDetector(
            onTap: _stageCompleted ? null : _onBackdropColorTap,
          ),
        ),

        _beam(0.07 * width, activeColor.withOpacity(0.60), true),
        _beam(0.18 * width, activeColor.withOpacity(0.80), false),
        _beam(0.48 * width, activeColor.withOpacity(1.00), false),
        _beam(0.73 * width, activeColor.withOpacity(0.80), true),
        _beam(0.91 * width, activeColor.withOpacity(0.60), false),

        // STAGE FLOOR
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height * 0.21,
          child: GestureDetector(
            onTap: _stageCompleted ? null : _showFloorOptions,
            child: _realisticFloor(width, height),
          ),
        ),

        // Performer glow
        Positioned(
          bottom: height * 0.25 - 130,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: width * 0.42,
              height: width * 0.18,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.25), Colors.transparent],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: height * 0.25 - 90,
          left: 0,
          right: 0,
          child: Center(
            child: Builder(
              builder: (_) {
                final isMic = selectedPerformerImage.contains("microphone");
                final isPop = selectedPerformerImage.contains("pop");

                double w, h;
                if (isMic) {
                  w = width * 0.22;
                  h = width * 0.28;
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
                    child: Container(
                      key: _performerKey,
                      child: Image.asset(selectedPerformerImage),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // SPEAKERS
        Positioned(
          bottom: height * 0.25 - 55,
          left: width * 0.10,
          child: GestureDetector(
            onTap: _stageCompleted ? null : _showSpeakerOptions,
            child: SpeakerPulse(
              anim: speakerBeatCtrl,
              strength: 0.04,
              child: Image.asset(
                _speakerAsset(speakers),
                width: width * 0.14,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: height * 0.25 - 55,
          right: width * 0.10,
          child: GestureDetector(
            onTap: _stageCompleted ? null : _showSpeakerOptions,
            child: SpeakerPulse(
              anim: speakerBeatCtrl,
              strength: 0.04,
              child: Image.asset(
                _speakerAsset(speakers),
                width: width * 0.14,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // HINT PULSE WIDGET

  Widget _hintPulse({double size = 55}) {
    return AnimatedBuilder(
      animation: glowCtrl,
      builder: (_, __) {
        final scale = 1 + glowCtrl.value * 0.4;
        final opacity = 0.6 + glowCtrl.value * 0.4;

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
                  color: Colors.white.withOpacity(0.9),
                  width: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // LIGHT / ENERGY PICKER

  void cycleLights() async {
    tappedLights = true;
    _hasInteracted = true;
    final choice = await _showLightEnergyOptions();
    if (choice != null) {
      setState(() => lights = choice);
      _saveStage();
      _checkCompletion();
    }
  }

  Future<StageLights?> _showLightEnergyOptions() async {
    return showModalBottomSheet<StageLights>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Stage Lights",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _lightTile(
                StageLights.eco,
                "Solar Lights",
                "Lights impowered by solar energy",
                Icons.wb_sunny,
                Colors.greenAccent,
              ),
              _lightTile(
                StageLights.mixed,
                "Battery Grid",
                "Hybrid battery-powered lights",
                Icons.battery_full,
                Colors.lightBlueAccent,
              ),
              _lightTile(
                StageLights.flood,
                "Floodlights",
                "Diesel generator floodlights",
                Icons.local_gas_station,
                Colors.purpleAccent,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lightTile(
    StageLights value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: value == lights ? Colors.greenAccent : Colors.white24,
            width: value == lights ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PERFORMER PICKER

  void _onBandAreaTap() async {
    tappedBandArea = true;
    _hasInteracted = true;

    final filename = await _showPerformerSelection();
    if (filename == null) return;

    setState(() {
      hasChosenPerformer = true;
      _hasSavedPerformer = false;
      selectedPerformerImage = "assets/stage/$filename";
      if (filename == "group.png") band = BandStyle.rock;
      if (filename == "pop.png") band = BandStyle.pop;
      if (filename == "dj2.png") band = BandStyle.dj;
    });

    final artistKey = band == BandStyle.rock
        ? "rock"
        : band == BandStyle.pop
        ? "pop"
        : "dj";

    if (!StageAudioEngine.instance.isMuted) {
      await StageAudioController.instance.chooseBand(artistKey);
    }

    _saveStage();
    _checkCompletion();
  }

  Future<String?> _showPerformerSelection() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Performer",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _performerTile(
                "group.png",
                "Band",
                "Live guitar + drums",
                BandStyle.rock,
              ),
              _performerTile(
                "pop.png",
                "Pop Artist",
                "Dance-pop vocals",
                BandStyle.pop,
              ),
              _performerTile(
                "dj2.png",
                "DJ",
                "Electronic beats & Techno music",
                BandStyle.dj,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _performerTile(
    String filename,
    String title,
    String subtitle,
    BandStyle value,
  ) {
    final selected = band == value;

    return GestureDetector(
      onTap: () => Navigator.pop(context, filename),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.greenAccent : Colors.white30,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset("assets/stage/$filename", width: 70, height: 70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BACKDROP PICKER

  void _onBackdropColorTap() async {
    if (!hasChosenPerformer) return;
    tappedEffectsArea = true;
    _hasInteracted = true;

    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Stage Background",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 330,
                child: ListView.builder(
                  itemCount: _backdropGradients.length,
                  itemBuilder: (_, i) {
                    final selected = backdropIndex == i;

                    return GestureDetector(
                      onTap: () => Navigator.pop(context, i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        height: 85,
                        decoration: BoxDecoration(
                          gradient: _backdropGradients[i],
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Colors.greenAccent
                                : Colors.white24,
                            width: selected ? 2.5 : 1.2,
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
      _saveStage();
      _checkCompletion();
    }
  }

  // FLOOR PICKER

  void _showFloorOptions() async {
    if (!hasChosenPerformer) return;
    tappedFloor = true;
    _hasInteracted = true;

    final result = await showModalBottomSheet<StageFloor>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Stage Floor",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _floorTile(
                StageFloor.woodenPallets,
                "Wooden Pallets",
                "Reused wood pieces",
              ),
              _floorTile(
                StageFloor.osb,
                "OSB Panels",
                "Pressed wooden sheets, common stage material",
              ),
              _floorTile(
                StageFloor.steel,
                "Steel Deck",
                "Heavy-duty metal stage decking",
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() => floor = result);
      _saveStage();
      _checkCompletion();
    }
  }

  Widget _floorTile(StageFloor value, String title, String subtitle) {
    final selected = floor == value;

    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.greenAccent : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                _floorAsset(value)!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SPEAKER PICKER

  void _showSpeakerOptions() async {
    tappedSpeakers = true;
    _hasInteracted = true;

    final result = await showModalBottomSheet<SpeakerSetup>(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Speakers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _speakerTile(
                SpeakerSetup.normalSpeaker,
                "Tower Speakers",
                "Standard all-round stage sound",
                "assets/stage/normalSpeaker.png",
              ),
              _speakerTile(
                SpeakerSetup.bambooSpeaker,
                "Bamboo Speakers",
                "Sound system made from bamboo",
                "assets/stage/bambooSpeaker.png",
              ),
              _speakerTile(
                SpeakerSetup.loudSpeaker,
                "Loud Speakers",
                "High-volume stage speakers",
                "assets/stage/loudSpeaker.png",
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() => speakers = result);
      _saveStage();
      _checkCompletion();
    }
  }

  Widget _speakerTile(
    SpeakerSetup value,
    String title,
    String subtitle,
    String image,
  ) {
    final selected = speakers == value;

    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.greenAccent : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(image, width: 70, height: 70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SAVE STAGE SETTINGS

  void _saveStage() {
    StageSave.saveChoices(
      performer: band.name,
      power: power.name,
      lights: lights.name,
      floor: floor.name,
      speakers: speakers.name,
      backdrop: backdropIndex,
    );
  }

  void _checkCompletion() {
    if (_stageCompleted) return;
    final performerDone = hasChosenPerformer;
    final lightsDone = tappedLights;
    final powerDone = true;
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
    if (_stageCompleted) return;

    setState(() {
      _stageCompleted = true;
      _showSearchLight = false;
    });

    crowdCtrl.stop();
    speakerBeatCtrl.stop();
    sweepCtrl.stop();
    glowCtrl.stop();

    StageAudioEngine.instance.stop();

    StageSave.markCompleted();

    // Add 5 points for completing stage game
    debugPrint('🎉 STAGE COMPLETED! Attempting to award 5 points');
    LedService.addPoints(5)
        .then((_) {
          debugPrint('✅ Points awarded successfully for stage game');
        })
        .catchError((e) {
          debugPrint('❌ Error adding points: $e');
        });

    // Call the completion callback
    widget.onMinigameCompleted();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      // Pop back to home page instead of navigating to ResultPage
      // The home page will handle showing ResultPage when all games are completed
      Navigator.of(context).pop();
    });
  }

  Widget _beam(double left, Color color, bool reverse) {
    final width = 160.0;
    final height = 280.0;

    return Positioned(
      top: -20,
      left: left - width / 2,
      child: Transform.rotate(
        angle: reverse ? -0.28 : 0.28,
        child: ClipPath(
          clipper: _LightConeClipper(),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.55), color.withOpacity(0.0)],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

  String? _floorAsset(StageFloor f) {
    switch (f) {
      case StageFloor.woodenPallets:
        return "assets/stage/PalletWood.png";
      case StageFloor.osb:
        return "assets/stage/OSB.png";
      case StageFloor.steel:
        return "assets/stage/Steel.png";
      case StageFloor.none:
        return null;
    }
  }

  String _speakerAsset(SpeakerSetup s) {
    switch (s) {
      case SpeakerSetup.defaultSpeaker:
        return "assets/stage/normalSpeaker.png";
      case SpeakerSetup.normalSpeaker:
        return "assets/stage/normalSpeaker.png";
      case SpeakerSetup.bambooSpeaker:
        return "assets/stage/bambooSpeaker.png";
      case SpeakerSetup.loudSpeaker:
        return "assets/stage/loudSpeaker.png";
    }
  }
}

class _StageFloorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(-size.width * 0.05, 0);
    p.lineTo(size.width * 1.05, 0);

    p.lineTo(size.width * 0.82, size.height);
    p.lineTo(size.width * 0.18, size.height);

    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}

class _LightConeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();

    p.moveTo(size.width * 0.5, 0);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();

    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
