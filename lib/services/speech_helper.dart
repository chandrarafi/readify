import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Status pengenalan suara
enum SpeechState { notListening, listening, done }

// Callback untuk hasil pengenalan suara
typedef SpeechResultCallback = void Function(String text, double confidence);
typedef SpeechCompletionCallback = void Function();

class SpeechHelper {
  // Singleton pattern
  static final SpeechHelper _instance = SpeechHelper._internal();
  factory SpeechHelper() => _instance;
  SpeechHelper._internal();

  // Status dan hasil
  String _recognizedText = '';
  double _confidence = 0.0;
  bool _isListening = false;
  DateTime? _listenStartTime;
  String _currentTargetText = '';
  bool _isInitialized = false;

  // Speech to text engine
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Pengaturan
  String _currentLocale = 'id_ID'; // Default: Bahasa Indonesia
  int _listenTimeout = 10000; // Timeout dalam milidetik (10 detik - lebih lama untuk anak-anak)

  // Callbacks
  SpeechResultCallback? _onResult;
  SpeechCompletionCallback? _onDone;
  Timer? _manualTimeoutTimer;

  /// Inisialisasi speech recognition
  Future<bool> initialize({String? googleApiKey}) async {
    await _loadSettings();

    // Inisialisasi speech recognition dengan callback terpadu
    if (!_isInitialized) {
      try {
        _isInitialized = await _speech.initialize(
          onError: (error) {
            print('SpeechHelper: Error: $error');
            
            // Handle berbagai jenis error
            if (error.errorMsg == 'error_no_match') {
              print('SpeechHelper: Tidak ada ucapan yang dikenali');
              if (_onResult != null) {
                _onResult!('', 0.0);
              }
            } else if (error.errorMsg == 'error_speech_timeout') {
              print('SpeechHelper: Timeout - tidak mendeteksi suara');
              print('SpeechHelper: Tip: Pastikan microphone aktif dan berbicara lebih keras');
              if (_onResult != null) {
                _onResult!('', 0.0);
              }
            } else if (error.errorMsg == 'error_network') {
              print('SpeechHelper: Error jaringan (jika menggunakan online recognition)');
            } else {
              print('SpeechHelper: Error lain: ${error.errorMsg}');
            }
            
            if (_isListening && _onDone != null) {
              _isListening = false;
              _onDone!();
            }
          },
          onStatus: (status) {
            print('SpeechHelper: Status: $status');
            // PENTING: Abaikan semua status event, hanya andalkan onResult dengan finalResult=true
            // Karena Windows SAPI mengirim "notListening" terlalu cepat
            // Status callback diabaikan untuk mencegah premature stop
          },
          debugLogging: kDebugMode,
        );
      } catch (e) {
        print('SpeechHelper: Exception saat inisialisasi: $e');
        _isInitialized = false;
        return false;
      }
    }

    if (_isInitialized) {
      print('SpeechHelper: Inisialisasi berhasil (Bahasa: $_currentLocale)');
      // Cek bahasa yang tersedia
      try {
        var locales = await _speech.locales();
        print('SpeechHelper: Bahasa tersedia: ${locales.length}');
        for (var locale in locales) {
          if (locale.localeId.contains('id')) {
            print('SpeechHelper: Bahasa Indonesia tersedia: ${locale.localeId}');
          }
        }
      } catch (e) {
        print('SpeechHelper: Error mendapatkan locales: $e');
      }
      return true;
    } else {
      print('SpeechHelper: Gagal menginisialisasi pengenalan suara');
      print('SpeechHelper: Speech recognition tidak tersedia pada perangkat ini');
      return false;
    }
  }

  /// Memulai proses mendengarkan
  Future<bool> startListening({
    required Function(String text, double confidence) onResult,
    required Function() onDone,
    String targetText = '', // Parameter baru untuk target text (opsional)
  }) async {
    if (_isListening) {
      stopListening();
    }

    // Batalkan timer manual lama jika ada
    _manualTimeoutTimer?.cancel();
    _manualTimeoutTimer = null;

    _onResult = onResult;
    _onDone = onDone;
    _isListening = true;
    _recognizedText = '';
    _confidence = 0.0;
    _currentTargetText = targetText;
    _listenStartTime = DateTime.now();

    // Jika speech recognition belum diinisialisasi, coba inisialisasi ulang
    if (!_isInitialized) {
      _isInitialized = await initialize();
      if (!_isInitialized) {
        print('SpeechHelper: Gagal inisialisasi ulang');
        _isListening = false;
        return false;
      }
    }

    // Gunakan speech_to_text built-in
    if (_isInitialized && _speech.isAvailable) {
      try {
        print(
          'SpeechHelper: Mencoba memulai pengenalan suara dengan bahasa $_currentLocale',
        );

        // Cek dan sesuaikan bahasa yang tersedia
        var locales = await _speech.locales();
        if (locales.isEmpty) {
          print('SpeechHelper: Tidak ada bahasa yang tersedia');
          _isListening = false;
          return false;
        }

        // Coba beberapa kemungkinan lokal untuk bahasa Indonesia
        List<String> possibleIndonesianLocales = [
          'id_ID',
          'id-ID',
          'in_ID',
          'in-ID',
          'id',
          'in',
        ];

        String localeToUse = '';
        bool foundIndonesian = false;

        // Pertama coba cari lokal Indonesia yang cocok persis
        for (var searchLocale in possibleIndonesianLocales) {
          for (var locale in locales) {
            if (locale.localeId == searchLocale) {
              localeToUse = locale.localeId;
              foundIndonesian = true;
              print(
                'SpeechHelper: Menemukan locale Indonesia yang cocok: $localeToUse',
              );
              break;
            }
          }
          if (foundIndonesian) break;
        }

        // Jika tidak ditemukan yang cocok persis, coba cari yang mengandung 'id'
        if (!foundIndonesian) {
          for (var locale in locales) {
            if (locale.localeId.startsWith('id') ||
                locale.localeId.startsWith('in') ||
                locale.localeId.contains('_id') ||
                locale.localeId.contains('_in')) {
              localeToUse = locale.localeId;
              foundIndonesian = true;
              print(
                'SpeechHelper: Menggunakan locale yang mirip bahasa Indonesia: $localeToUse',
              );
              break;
            }
          }
        }

        // Jika masih tidak ditemukan, gunakan bahasa Inggris sebagai fallback
        if (!foundIndonesian || localeToUse.isEmpty) {
          print(
            'SpeechHelper: Bahasa Indonesia tidak ditemukan di sistem Windows',
          );
          print('SpeechHelper: PERINGATAN - Akan menggunakan bahasa Inggris, hasil mungkin tidak akurat');
          print('SpeechHelper: Untuk hasil terbaik, install language pack Bahasa Indonesia di Windows');
          
          // Cari bahasa Inggris sebagai fallback
          for (var locale in locales) {
            if (locale.localeId.startsWith('en')) {
              localeToUse = locale.localeId;
              print('SpeechHelper: Menggunakan bahasa Inggris sebagai fallback: $localeToUse');
              break;
            }
          }
          
          // Jika masih kosong, gunakan default sistem
          if (localeToUse.isEmpty && locales.isNotEmpty) {
            localeToUse = locales.first.localeId;
            print('SpeechHelper: Menggunakan bahasa pertama yang tersedia: $localeToUse');
          }
        }

        // Catat semua bahasa yang tersedia untuk debugging
        print('SpeechHelper: Semua bahasa tersedia:');
        for (var i = 0; i < math.min(10, locales.length); i++) {
          print('Locale ${i + 1}: ${locales[i].localeId} - ${locales[i].name}');
        }
        if (locales.length > 10) {
          print('... dan ${locales.length - 10} bahasa lainnya');
        }

        // Buat konfigurasi yang lebih toleran untuk anak-anak
        bool? listenResult = await _speech.listen(
          onResult: (result) {
            print(
              'SpeechHelper: onResult called - finalResult: ${result.finalResult}',
            );

            // Selalu perbarui teks yang dikenali, baik hasil akhir maupun sementara
            _recognizedText = result.recognizedWords;
            _confidence = result.confidence > 0 ? result.confidence : 0.1;

            // PENTING: Panggil callback lebih cepat untuk hasil sementara
            if (_onResult != null) {
              _onResult!(_recognizedText, _confidence);
            }

            if (result.finalResult) {
              print(
                'SpeechHelper: Hasil final dari SAPI - "$_recognizedText" (${(_confidence * 100).toStringAsFixed(1)}%)',
              );

              // Jika hasil kosong dan ini hasil final, beri feedback
              if (_recognizedText.isEmpty && _onResult != null) {
                print(
                  'SpeechHelper: Hasil final kosong dari SAPI',
                );
                _onResult!('', 0.0);
              }

              // JANGAN langsung panggil onDone - biarkan timer manual yang handle
              // Ini mencegah speech recognition berhenti terlalu cepat
              print('SpeechHelper: Menunggu timer manual untuk menyelesaikan sesi');
            } else {
              print('SpeechHelper: Hasil sementara - "$_recognizedText"');
            }
          },
          listenFor: Duration(milliseconds: _listenTimeout), // 10 detik
          pauseFor: const Duration(
            milliseconds: 3000,
          ), // 3 detik - lebih lama untuk anak-anak yang berbicara pelan
          localeId: localeToUse,
          cancelOnError: false,
          partialResults: true,
          listenMode: stt.ListenMode.dictation, // Dictation mode lebih toleran
          onSoundLevelChange: (level) {
            // Log semua level suara untuk debugging
            print('SpeechHelper: Level suara: $level');
          },
        );

        // Handle kemungkinan null result (di Windows SAPI, listen() mengembalikan null saat berhasil dimulai)
        bool started = listenResult ?? true;

        if (started) {
          print('SpeechHelper: Pengenalan suara dimulai');

          // Batalkan timer lama jika ada
          _manualTimeoutTimer?.cancel();
          
          // Set timer manual untuk memastikan minimum durasi listening
          _manualTimeoutTimer = Timer(Duration(milliseconds: _listenTimeout), () {
            if (_isListening) {
              print('SpeechHelper: Manual timeout tercapai ($_listenTimeout ms)');
              
              // Jika tidak ada hasil, gunakan fallback
              if (_recognizedText.isEmpty) {
                print('SpeechHelper: Tidak ada hasil setelah timeout, menggunakan fallback');
                _useFallbackRecognition(_currentTargetText);
              } else {
                // Ada hasil, proses sekarang
                print('SpeechHelper: Memproses hasil yang ada: "$_recognizedText"');
                if (_onDone != null) {
                  _isListening = false;
                  _onDone!();
                }
              }
              
              // Hentikan speech recognition
              stopListening();
            }
          });

          return true;
        } else {
          print(
            'SpeechHelper: Gagal memulai pengenalan suara (nilai kembalian: $listenResult)',
          );

          _useFallbackRecognition(targetText);
          return false;
        }
      } catch (e) {
        print('SpeechHelper: Error saat memulai pengenalan suara: $e');

        _useFallbackRecognition(targetText);
        return false;
      }
    } else {
      // Jika speech recognition tidak tersedia
      print(
        'SpeechHelper: Speech recognition tidak tersedia (initialized: $_isInitialized, isAvailable: ${_speech.isAvailable})',
      );

      _useFallbackRecognition(targetText);
      return false;
    }
  }

  // Metode fallback jika pengenalan gagal (mode latihan untuk Windows tanpa bahasa Indonesia)
  // Metode ini menonaktifkan aplikasi jika speech recognition tidak berfungsi
  void _useFallbackRecognition(String targetText) {
    print('SpeechHelper: Speech recognition tidak tersedia');
    print('SpeechHelper: Silakan gunakan perangkat dengan bahasa Indonesia terinstall');
    print('SpeechHelper: Atau setup Whisper model untuk offline recognition');

    // Langsung panggil callback dengan hasil kosong
    if (_onResult != null) {
      _onResult!('', 0.0);
    }

    // Selesaikan sesi
    if (_onDone != null) {
      _isListening = false;
      _onDone!();
    }
  }

  /// Hentikan proses mendengarkan
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    // Batalkan timer manual
    _manualTimeoutTimer?.cancel();
    _manualTimeoutTimer = null;

    // Stop speech recognition
    if (_speech.isAvailable && _speech.isListening) {
      _speech.stop();
      print('SpeechHelper: speech_to_text dihentikan');
    }

    _isListening = false;
  }

  /// Cek apakah speech yang dikenali sesuai dengan harapan
  bool checkSpeech(String targetText, {double threshold = 0.3}) {
    if (_recognizedText.isEmpty) return false;

    // Normalisasi teks target dan hasil
    String normalizedTarget = _normalizeText(targetText);
    String normalizedDetected = _normalizeText(_recognizedText);

    print('SpeechHelper: Memeriksa kesesuaian:');
    print('Target: "$normalizedTarget"');
    print('Terdeteksi: "$normalizedDetected"');

    // Cara 1: Cek substring
    bool containsTarget =
        normalizedDetected.contains(normalizedTarget) ||
        normalizedTarget.contains(normalizedDetected);

    // Cara 2: Hitung kata yang sama
    List<String> targetWords = normalizedTarget.split(' ');
    List<String> detectedWords = normalizedDetected.split(' ');

    // Periksa jika ada kata yang sama persis
    bool hasExactMatch = false;
    for (String targetWord in targetWords) {
      if (detectedWords.contains(targetWord)) {
        print('SpeechHelper: Menemukan kata yang sama persis: "$targetWord"');
        hasExactMatch = true;
        break;
      }
    }

    // Jika ada kata yang sama persis, langsung kembalikan true
    if (hasExactMatch) {
      print(
        'SpeechHelper: Ada kata yang sama persis, mengembalikan hasil benar',
      );
      return true;
    }

    int matchedWords = 0;
    for (String targetWord in targetWords) {
      for (String detectedWord in detectedWords) {
        if (detectedWord.contains(targetWord) ||
            targetWord.contains(detectedWord)) {
          matchedWords++;
          break;
        }
      }
    }

    double wordMatchRatio =
        targetWords.isEmpty ? 0.0 : matchedWords / targetWords.length;

    // Lebih toleran untuk aplikasi anak-anak
    double adjustedRatio = math.min(1.0, wordMatchRatio + 0.1);

    print(
      'SpeechHelper: Kecocokan kata: $matchedWords/${targetWords.length}, Skor: $adjustedRatio',
    );

    return containsTarget || adjustedRatio >= threshold;
  }

  /// Memeriksa status speech recognition
  bool get isListening => _isListening;

  /// Mendapatkan teks yang terakhir dikenali
  String get lastRecognizedText => _recognizedText;

  /// Memeriksa ketersediaan speech recognition
  bool get isAvailable {
    return _isInitialized && _speech.isAvailable;
  }

  /// Informasi engine yang digunakan
  String get engineInfo {
    if (_isInitialized && _speech.isAvailable) {
      return 'speech_to_text (Built-in) 📱';
    } else {
      return 'Tidak tersedia ❌';
    }
  }
  
  /// Set Google API Key (deprecated - tidak digunakan lagi)
  @deprecated
  void setGoogleApiKey(String apiKey) {
    // No-op: Google Speech sudah tidak digunakan
  }

  /// Mendapatkan semua bahasa yang tersedia untuk speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (_isInitialized) {
      return await _speech.locales();
    } else {
      return [];
    }
  }

  /// Normalisasi teks untuk perbandingan
  String _normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Hapus tanda baca
        .replaceAll(RegExp(r'\s+'), ' '); // Hapus spasi berlebih
  }

  /// Muat pengaturan dari shared preferences
  Future<void> _loadSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentLocale = prefs.getString('speech_locale') ?? 'id_ID';
      _listenTimeout = prefs.getInt('speech_timeout') ?? 5000;
    } catch (e) {
      print('Error memuat pengaturan speech: $e');
    }
  }

  /// Perbarui pengaturan speech
  Future<void> updateSettings({
    String? locale,
    double? confidenceThreshold,
    int? listenTimeout,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (locale != null) {
        _currentLocale = locale;
        await prefs.setString('speech_locale', locale);
      }

      if (confidenceThreshold != null) {
        await prefs.setDouble('speech_confidence', confidenceThreshold);
      }

      if (listenTimeout != null) {
        _listenTimeout = listenTimeout;
        await prefs.setInt('speech_timeout', listenTimeout);
      }

      print('SpeechHelper: Pengaturan diperbarui');
    } catch (e) {
      print('Error menyimpan pengaturan speech: $e');
    }
  }
}
