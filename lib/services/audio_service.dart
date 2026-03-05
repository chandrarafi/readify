import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // All players use audioplayers now
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;
  late AudioPlayer _speechPlayer;
  late AudioPlayer _feedbackPlayer;
  
  bool _initialized = false;
  bool _bgmPlaying = false;

  bool get isBgmPlaying => _bgmPlaying;

  Future<void> init() async {
    if (_initialized) return;

    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _speechPlayer = AudioPlayer();
    _feedbackPlayer = AudioPlayer();

    // CRITICAL: Configure global AudioContext to NOT request focus.
    // This allows multiple sounds to play without killing the BGM.
    try {
      final audioContext = AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // Never steal focus
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback, // Changed to playback to allow mixing options
          options: {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      );
      
      await AudioPlayer.global.setAudioContext(audioContext);
    } catch (e) {
      debugPrint('Error configuring AudioContext: $e');
    }

    // Init BGM
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _bgmPlayer.setSource(AssetSource('musik.mp3'));
      await _bgmPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint('Error init BGM: $e');
    }

    // Init SFX Players (Use mediaPlayer for stability)
    try {
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      await _feedbackPlayer.setReleaseMode(ReleaseMode.stop);
      await _feedbackPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      await _speechPlayer.setReleaseMode(ReleaseMode.stop);
      await _speechPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    } catch (e) {
      debugPrint('Error init SFX configs: $e');
    }

    _initialized = true;
  }

  Future<void> playBgm() async {
    if (!_initialized) return;
    try {
      if (!_bgmPlaying) {
        await _bgmPlayer.resume(); // Use resume for looping players
        _bgmPlaying = true;
      }
    } catch (e) {
      debugPrint('Error play BGM: $e');
      // Fallback: try playing from source again if resume fails (e.g. stopped)
      try {
        await _bgmPlayer.play(AssetSource('musik.mp3'));
        _bgmPlaying = true;
      } catch (e2) {
        debugPrint('Fallback play BGM failed: $e2');
      }
    }
  }

  Future<void> pauseBgm() async {
    if (!_initialized) return;
    try {
      if (_bgmPlaying) {
        await _bgmPlayer.pause();
        _bgmPlaying = false;
      }
    } catch (e) {
      debugPrint('Error pause BGM: $e');
    }
  }

  void toggleBgm() {
    if (_bgmPlaying) {
      pauseBgm();
    } else {
      playBgm();
    }
  }

  Future<void> playButtonSound() async {
    if (!_initialized) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource('AudioClip/button.wav'));
    } catch (e) {
      debugPrint('Error play button SFX: $e');
    }
  }

  Future<void> playCorrectSound() async {
    if (!_initialized) return;
    try {
      await _feedbackPlayer.stop();
      await _feedbackPlayer.play(AssetSource('untuklatihan/benar.mp3'));
    } catch (e) {
      debugPrint('Error play correct SFX: $e');
    }
  }

  Future<void> playWrongSound() async {
    if (!_initialized) return;
    try {
      await _feedbackPlayer.stop();
      await _feedbackPlayer.play(AssetSource('untuklatihan/salah.mp3'));
    } catch (e) {
      debugPrint('Error play wrong SFX: $e');
    }
  }

  Future<void> playLetterSound(int index) async {
    if (!_initialized) return;
    try {
      final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
      if (index >= 0 && index < letters.length) {
        await _feedbackPlayer.stop();
        await _feedbackPlayer.play(AssetSource('AudioClip/${letters[index]}.wav'));
      }
    } catch (e) {
      debugPrint('Error play letter sound: $e');
    }
  }

  Future<void> stopSpeech() async {
    if (!_initialized) return;
    try {
      await _speechPlayer.stop();
    } catch (e) {
      debugPrint('Error stop speech: $e');
    }
  }

  Future<void> playWordSound(String word) async {
    if (!_initialized) return;
    try {
      await stopSpeech();
      await _speechPlayer.play(AssetSource('AudioClip/kosakata/$word.wav'));
    } catch (e) {
      debugPrint('Error play word sound "$word": $e');
    }
  }

  Future<void> playLatihanSound(String word) async {
    if (!_initialized) return;
    try {
      await stopSpeech();
      await _speechPlayer.play(AssetSource('untuklatihan/$word.wav'));
    } catch (e) {
      debugPrint('Error play latihan sound "$word": $e');
    }
  }

  Future<void> playSyllableSound(String syllable) async {
    if (!_initialized) return;
    try {
      await stopSpeech();
      final assetPath = 'AudioClip/sukukata/$syllable.wav';
      await _speechPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error play syllable sound "$syllable": $e');
      // Fallback
      try {
        final fallbackPath = 'AudioClip/$syllable.wav';
        await _speechPlayer.play(AssetSource(fallbackPath));
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
      }
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _speechPlayer.dispose();
    _sfxPlayer.dispose();
    _feedbackPlayer.dispose();
    _initialized = false;
  }
}
