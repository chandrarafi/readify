import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxPlayer;
  bool _initialized = false;
  bool _bgmPlaying = false;
  bool _sfxReady = false;

  bool get isBgmPlaying => _bgmPlaying;

  Future<void> init() async {
    if (_initialized) return;
    
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

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

  void dispose() {
    _bgmPlayer?.dispose();
    _sfxPlayer?.dispose();
    _initialized = false;
  }
}
