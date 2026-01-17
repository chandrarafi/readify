import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _speechPlayer; // Dedicated player untuk speech/kata
  bool _initialized = false;
  bool _bgmPlaying = false;
  bool _sfxReady = false;

  bool get isBgmPlaying => _bgmPlaying;

  Future<void> init() async {
    if (_initialized) return;
    
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _speechPlayer = AudioPlayer(); // Init speech player

    try {
      await _bgmPlayer!.setAsset('assets/musik.mp3');
      await _bgmPlayer!.setLoopMode(LoopMode.one);
      await _bgmPlayer!.setVolume(0.5);
    } catch (e) {
      debugPrint('Error init BGM: $e');
    }

    try {
      await _sfxPlayer!.setAsset('assets/AudioClip/button.wav');
      await _sfxPlayer!.setVolume(1.0);
      // Pre-load dengan play lalu pause untuk siapkan buffer
      await _sfxPlayer!.load();
      _sfxReady = true;
    } catch (e) {
      debugPrint('Error init SFX: $e');
    }

    _initialized = true;
  }

  Future<void> playBgm() async {
    if (!_initialized || _bgmPlayer == null) return;
    try {
      await _bgmPlayer!.play();
      _bgmPlaying = true;
    } catch (e) {
      debugPrint('Error play BGM: $e');
    }
  }

  Future<void> pauseBgm() async {
    if (!_initialized || _bgmPlayer == null) return;
    try {
      await _bgmPlayer!.pause();
      _bgmPlaying = false;
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
    if (!_initialized || _sfxPlayer == null || !_sfxReady) return;
    try {
      // Stop dulu jika sedang play, lalu seek ke awal
      await _sfxPlayer!.stop();
      await _sfxPlayer!.seek(Duration.zero);
      _sfxPlayer!.play();
    } catch (e) {
      debugPrint('Error play SFX: $e');
    }
  }

  // Play letter sound A-Z
  Future<void> playLetterSound(int index) async {
    if (!_initialized) return;
    try {
      final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
      if (index >= 0 && index < letters.length) {
        final player = AudioPlayer();
        await player.setAsset('assets/AudioClip/${letters[index]}.wav');
        await player.play();
        // Dispose after playing
        player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            player.dispose();
          }
        });
      }
    } catch (e) {
      debugPrint('Error play letter sound: $e');
    }
  }

  // Stop semua speech audio
  Future<void> stopSpeech() async {
    if (_speechPlayer != null) {
      try {
        await _speechPlayer!.stop();
        await _speechPlayer!.seek(Duration.zero);
      } catch (e) {
        debugPrint('Error stop speech: $e');
      }
    }
  }

  // Play word sound untuk kosakata
  Future<void> playWordSound(String word) async {
    if (!_initialized || _speechPlayer == null) return;
    try {
      await _speechPlayer!.stop();
      await _speechPlayer!.seek(Duration.zero);
      await _speechPlayer!.setAsset('assets/AudioClip/kosakata/$word.wav');
      await _speechPlayer!.play();
    } catch (e) {
      debugPrint('Error play word sound "$word": $e');
    }
  }

  // Play syllable sound untuk suku kata
  Future<void> playSyllableSound(String syllable) async {
    if (!_initialized || _speechPlayer == null) return;
    try {
      await _speechPlayer!.stop();
      await _speechPlayer!.seek(Duration.zero);
      
      final assetPath = 'assets/AudioClip/sukukata/$syllable.wav';
      debugPrint('Loading syllable: $assetPath');
      
      await _speechPlayer!.setAsset(assetPath);
      await _speechPlayer!.play();
      
      debugPrint('Playing syllable: $syllable');
    } catch (e) {
      debugPrint('Error play syllable sound "$syllable": $e');
      // Coba fallback ke file yang ada di root AudioClip
      try {
        // Cek apakah ada file dengan format lain
        final fallbackPath = 'assets/AudioClip/$syllable.wav';
        debugPrint('Trying fallback: $fallbackPath');
        await _speechPlayer!.setAsset(fallbackPath);
        await _speechPlayer!.play();
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
      }
    }
  }

  void dispose() {
    _bgmPlayer?.dispose();
    _sfxPlayer?.dispose();
    _speechPlayer?.dispose();
    _initialized = false;
  }
}
