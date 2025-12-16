import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ------------------------------------------------------------
/// GLOBAL FESTIVAL AUDIO ENGINE
/// ONE CONTROLLER THAT WORKS ACROSS ALL PAGES
/// ------------------------------------------------------------
class StageAudioController {
  StageAudioController._internal();
  static final StageAudioController instance = StageAudioController._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _muted = false;
  bool get isMuted => _muted;

  String? _currentBand;  
  int _currentIndex = 0;

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
    ]
  };

  Future<void> initialize() async {
  final prefs = await SharedPreferences.getInstance();

  _muted = prefs.getBool("global_muted") ?? false;
  _currentBand = prefs.getString("global_band");

  // LISTENER FOR LOOPING PLAYLIST
  _player.onPlayerComplete.listen((_) => _playNextTrack());

  // Remove auto-play here, don't start the music on app launch
  // if (_currentBand != null && !_muted) {
  //   await _startPlaylist(_currentBand!);
  // }
}


  Future<void> _startPlaylist(String band) async {
  final tracks = _playlists[band];
  if (tracks == null || tracks.isEmpty) return;

  _currentBand = band;
  _currentIndex = Random().nextInt(tracks.length);

  if (!_muted) {
    await _player.stop();
    await _player.play(AssetSource(tracks[_currentIndex]));
  }

  // Save band
  (await SharedPreferences.getInstance()).setString("global_band", band);
}


  /// ------------------------------------------------------------
  /// CHOOSE A BAND (called when player selects performer)
  /// ------------------------------------------------------------
  Future<void> chooseBand(String band) async {
    await _startPlaylist(band);
  }

  /// ------------------------------------------------------------
  /// PLAY NEXT SONG IN PLAYLIST
  /// ------------------------------------------------------------
  Future<void> _playNextTrack() async {
    if (_currentBand == null) return;

    final tracks = _playlists[_currentBand!]!;
    _currentIndex = (_currentIndex + 1) % tracks.length;

    if (!_muted) {
      await _player.stop();
      await _player.play(AssetSource(tracks[_currentIndex]));
    }
  }

  /// ------------------------------------------------------------
  /// TOGGLE MUTE (saves globally)
  /// ------------------------------------------------------------
  Future<void> toggleMute() async {
    _muted = !_muted;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("global_muted", _muted);

    if (_muted) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }
}
