import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/speech_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../models/score_history.dart';
import 'package:permission_handler/permission_handler.dart';

class MengucapkanKataScreen extends StatefulWidget {
  final String category; // 'KV-KV' atau 'KV-KVK'

  const MengucapkanKataScreen({
    super.key,
    required this.category,
  });

  @override
  State<MengucapkanKataScreen> createState() => _MengucapkanKataScreenState();
}

class _MengucapkanKataScreenState extends State<MengucapkanKataScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _scoreService = ScoreService();
  final SpeechHelper _speechHelper = SpeechHelper();
  final FlutterTts _flutterTts = FlutterTts();


  // Daftar soal
  final List<Map<String, dynamic>> _kvKvList = [
    {'kata': 'lari', 'suku': ['la', 'ri'], 'gambar': ''},
    {'kata': 'pita', 'suku': ['pi', 'ta'], 'gambar': 'assets/untukbelajar/kosakata/pita.png'},
    {'kata': 'dadu', 'suku': ['da', 'du'], 'gambar': 'assets/untukbelajar/kosakata/dadu.png'},
    {'kata': 'suka', 'suku': ['su', 'ka'], 'gambar': ''},
    {'kata': 'sore', 'suku': ['so', 're'], 'gambar': ''},
    {'kata': 'roda', 'suku': ['ro', 'da'], 'gambar': 'assets/untukbelajar/kosakata/roda.png'},
    {'kata': 'meja', 'suku': ['me', 'ja'], 'gambar': ''},
    {'kata': 'paku', 'suku': ['pa', 'ku'], 'gambar': ''},
    {'kata': 'gusi', 'suku': ['gu', 'si'], 'gambar': ''},
    {'kata': 'nasi', 'suku': ['na', 'si'], 'gambar': ''},
  ];

  final List<Map<String, dynamic>> _kvKvkList = [
    {'kata': 'bedak', 'suku': ['be', 'dak'], 'gambar': 'assets/untukbelajar/kosakata/bedak.png'},
    {'kata': 'mawar', 'suku': ['ma', 'war'], 'gambar': 'assets/untukbelajar/kosakata/mawar.png'},
    {'kata': 'jarum', 'suku': ['ja', 'rum'], 'gambar': 'assets/untukbelajar/kosakata/jaru.png'},
    {'kata': 'gitar', 'suku': ['gi', 'tar'], 'gambar': 'assets/untukbelajar/kosakata/gitar.png'},
    {'kata': 'sejuk', 'suku': ['se', 'juk'], 'gambar': ''},
    {'kata': 'patuh', 'suku': ['pa', 'tuh'], 'gambar': ''},
    {'kata': 'kotak', 'suku': ['ko', 'tak'], 'gambar': ''},
    {'kata': 'hujan', 'suku': ['hu', 'jan'], 'gambar': ''},
    {'kata': 'licin', 'suku': ['li', 'cin'], 'gambar': ''},
    {'kata': 'takut', 'suku': ['ta', 'kut'], 'gambar': ''},
  ];

  late List<Map<String, dynamic>> _soalList;
  int _currentIndex = 0;
  int _score = 0;
  bool _gameFinished = false;

  // Speech and TTS states
  bool _isListening = false;
  String _lastWords = '';
  String _speechStatus = 'Tekan tombol mic lalu ucapkan kata';
  bool _speechInitialized = false;
  double _listeningProgress = 0.0; // Progress bar untuk waktu listening
  Timer? _progressTimer;
  double _soundLevel = 0.0; // Level suara untuk visual feedback
  int _noSoundCount = 0; // Hitung berapa kali tidak mendeteksi suara

  // Feedback states
  bool _showPopup = false;
  bool _isCorrect = false;

  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _resultController;
  late AnimationController _micPulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _micPulseAnimation;

  Map<String, dynamic> get _currentSoal => _soalList[_currentIndex];
  String get _currentWord => _currentSoal['kata'] as String;

  final List<Color> _syllableColors = [
    Colors.red,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
    _soalList = widget.category == 'KV-KV' ? List.from(_kvKvList) : List.from(_kvKvkList);
    _soalList.shuffle(); // Acak soal saat mulai
    _initAnimations();
    _initSpeech();
    _initTts();

    // Play audio soal pertama setelah halaman terbuka
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _playWordSound(_currentWord);
    });
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _cloud1Controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    _cloud2Controller = AnimationController(
      duration: const Duration(seconds: 45),
      vsync: this,
    )..repeat();

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _micPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  Future<void> _initSpeech() async {
    try {
      // Request microphone permission terlebih dahulu
      bool permissionGranted = await _requestMicrophonePermission();
      
      if (!permissionGranted) {
        setState(() {
          _speechInitialized = false;
          _speechStatus = 'Izin microphone diperlukan';
        });
        
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }
      
      // Initialize speech helper
      bool available = await _speechHelper.initialize();
      
      // Set status berdasarkan ketersediaan
      if (available) {
        setState(() {
          _speechInitialized = available;
          _speechStatus = 'Tekan tombol mic lalu ucapkan kata';
        });
        
        // Tampilkan info engine yang digunakan
        String engine = _speechHelper.engineInfo;
        debugPrint('Speech engine: $engine');
        
        // Jika menggunakan Whisper, tampilkan notifikasi
        if (engine.contains('Whisper')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✓ Menggunakan Whisper Offline (Gratis, Support Indonesian)',
                style: const TextStyle(fontFamily: 'Roboto'),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // Cek apakah bahasa Indonesia tersedia di built-in speech
        final locales = await _speechHelper.getAvailableLocales();
        bool hasIndonesian = locales.any(
          (locale) => locale.localeId.contains('id') || locale.localeId.contains('in')
        );
        
        // Jika tidak ada bahasa Indonesia, tampilkan info
        if (!hasIndonesian && mounted) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'ℹ️ Bahasa Indonesia tidak tersedia. Menggunakan mode fallback untuk development.',
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          });
        }
      } else {
        setState(() {
          _speechInitialized = false;
          _speechStatus = 'Speech recognition tidak tersedia';
        });
        
        // Tampilkan dialog peringatan
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showSpeechNotAvailableDialog();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      setState(() {
        _speechInitialized = false;
        _speechStatus = 'Speech recognition tidak tersedia';
      });
      
      // Tampilkan dialog peringatan
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showSpeechNotAvailableDialog();
          }
        });
      }
    }
  }

  // Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    try {
      // Cek status permission saat ini
      PermissionStatus status = await Permission.microphone.status;
      
      if (status.isGranted) {
        debugPrint('Microphone permission already granted');
        return true;
      }
      
      if (status.isDenied) {
        debugPrint('Requesting microphone permission...');
        // Request permission
        status = await Permission.microphone.request();
        
        if (status.isGranted) {
          debugPrint('Microphone permission granted');
          return true;
        } else if (status.isPermanentlyDenied) {
          debugPrint('Microphone permission permanently denied');
          return false;
        } else {
          debugPrint('Microphone permission denied');
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('Microphone permission permanently denied - need to open settings');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  // Dialog untuk permission denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.mic_off, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text('Izin Microphone Diperlukan', 
                  style: TextStyle(fontSize: 18, fontFamily: 'Roboto')),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Aplikasi memerlukan izin microphone untuk fitur speech recognition.',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tanpa izin ini, Anda tidak dapat menggunakan fitur "Mengucapkan Kata".',
                  style: TextStyle(fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cara memberikan izin:',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Tekan tombol "Buka Pengaturan" di bawah'),
                _buildBulletPoint('Cari "Permissions" atau "Izin"'),
                _buildBulletPoint('Aktifkan izin "Microphone"'),
                _buildBulletPoint('Kembali ke aplikasi dan coba lagi'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Izin microphone HANYA digunakan untuk speech recognition, tidak untuk recording.',
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Kembali ke menu
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kembali',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Buka app settings
                await openAppSettings();
                // Setelah kembali dari settings, coba init lagi
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _initSpeech();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Buka Pengaturan',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk memberitahu user bahwa speech recognition tidak tersedia
  void _showSpeechNotAvailableDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
              SizedBox(width: 12),
              Text('Speech Recognition Tidak Tersedia', 
                style: TextStyle(fontSize: 18, fontFamily: 'Roboto')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Speech recognition tidak tersedia pada perangkat ini.',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kemungkinan penyebab:',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Anda menggunakan emulator (BlueStacks, Nox, dll)'),
                _buildBulletPoint('Google Speech Services tidak terinstall'),
                _buildBulletPoint('Perangkat tidak mendukung speech recognition'),
                const SizedBox(height: 12),
                const Text(
                  'Solusi:',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Gunakan perangkat Android fisik (smartphone/tablet)'),
                _buildBulletPoint('Install Google app dari Play Store'),
                _buildBulletPoint('Pastikan izin microphone diaktifkan'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Text(
                    'ℹ️ Aplikasi ini dirancang untuk perangkat Android fisik. Emulator mungkin tidak mendukung semua fitur.',
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Kembali ke menu utama
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kembali ke Menu',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Coba inisialisasi ulang
                _initSpeech();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper untuk membuat bullet point
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontFamily: 'Roboto', fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontFamily: 'Roboto', fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Dialog tips microphone
  void _showMicrophoneTipsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.blue, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text('Tips Menggunakan Microphone', 
                  style: TextStyle(fontSize: 16, fontFamily: 'Roboto')),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Microphone tidak mendeteksi suara Anda.',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tips agar lebih baik:',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('🎤 Pastikan izin microphone diaktifkan'),
                _buildBulletPoint('🔊 Berbicara lebih keras dan jelas'),
                _buildBulletPoint('📱 Dekatkan mulut ke microphone (20-30cm)'),
                _buildBulletPoint('🔇 Matikan musik latar atau suara bising'),
                _buildBulletPoint('⏱️ Tunggu hingga mic icon berkedip, baru bicara'),
                _buildBulletPoint('🗣️ Ucapkan kata dengan jelas, tidak terlalu cepat'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda punya waktu 10 detik untuk berbicara setelah menekan tombol mic.',
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset counter
                setState(() {
                  _noSoundCount = 0;
                });
              },
              child: const Text(
                'Mengerti',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset counter dan coba lagi
                setState(() {
                  _noSoundCount = 0;
                });
                // Coba listening lagi
                Future.delayed(const Duration(milliseconds: 300), () {
                  _startListening();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontFamily: 'Roboto', fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Training mode dialog dihapus - tidak digunakan lagi

  void _initTts() async {
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.1);
      
      // Cek apakah bahasa Indonesia tersedia
      final languages = await _flutterTts.getLanguages;
      debugPrint('Available TTS languages: $languages');
      
      bool hasIndonesian = false;
      if (languages is List) {
        for (var lang in languages) {
          final langStr = lang.toString().toLowerCase();
          if (langStr.contains('id') || langStr.contains('in-id') || langStr.contains('ind')) {
            hasIndonesian = true;
            await _flutterTts.setLanguage(lang.toString());
            debugPrint('TTS language set to: $lang');
            break;
          }
        }
      }
      
      if (!hasIndonesian) {
        // Paksa set ke id-ID meskipun tidak terdeteksi
        await _flutterTts.setLanguage("id-ID");
        debugPrint('TTS: Indonesian not found in list, forcing id-ID');
      }

      // Cari suara perempuan bahasa Indonesia
      final voices = await _flutterTts.getVoices;
      debugPrint('Available TTS voices: ${voices.length}');
      
      dynamic selectedVoice;
      for (var voice in voices) {
        if (voice is Map) {
          final name = (voice['name'] ?? '').toString().toLowerCase();
          final locale = (voice['locale'] ?? '').toString().toLowerCase();
          final gender = (voice['gender'] ?? '').toString().toLowerCase();
          
          if (locale.contains('id') || locale.contains('in')) {
            // Prioritas 1: Gender perempuan tertulis jelas
            if (gender == 'female') {
              selectedVoice = voice;
              break;
            }
            // Prioritas 2: Nama mengandung "female" atau "damayanti" (iOS)
            if (name.contains('female') || name.contains('damayanti')) {
              selectedVoice = voice;
            }
            // Prioritas 3: Fallback ke suara bahasa Indonesia apa pun yang ditemukan pertama kali
            selectedVoice ??= voice;
          }
        }
      }
      
      if (selectedVoice != null) {
        debugPrint('Setting TTS voice to female/selected Indonesian voice: ${selectedVoice['name']}');
        await _flutterTts.setVoice(Map<String, String>.from(selectedVoice));
      }
    } catch (e) {
      debugPrint('TTS Init error: $e');
    }
  }

  Future<void> _playWordSound(String word) async {
    // Stop speech yang sedang berjalan
    await _audio.stopSpeech();
    await _flutterTts.stop();

    try {
      // Tentukan path audio berdasarkan category
      String categoryFolder = widget.category == 'KV-KV' ? 'kv-kv' : 'kv-kvk';
      String audioPath = 'assets/AudioClip/mengucap/$categoryFolder/${word.toLowerCase()}.mp3';
      
      debugPrint('Playing word audio: $audioPath');
      
      // Coba putar audio file
      await _audio.playAudio(audioPath);
    } catch (e) {
      debugPrint('Error playing word audio: $e');
      
      // Fallback ke TTS jika audio file tidak ada
      try {
        debugPrint('Fallback to TTS for word: $word');
        await _flutterTts.speak(word);
      } catch (ttsError) {
        debugPrint('TTS speak error: $ttsError');
      }
    }
  }

  void _startListening() async {
    debugPrint('_startListening called');
    
    // Cek permission microphone
    PermissionStatus micStatus = await Permission.microphone.status;
    debugPrint('Microphone permission status: $micStatus');
    
    if (!micStatus.isGranted) {
      // Request permission
      bool granted = await _requestMicrophonePermission();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin microphone diperlukan untuk menggunakan fitur ini.',
              style: TextStyle(fontFamily: 'Roboto'),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        _showPermissionDeniedDialog();
        return;
      }
    }
    
    // Cek apakah speech helper tersedia
    if (!_speechHelper.isAvailable) {
      // Tampilkan notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition tidak tersedia. Gunakan perangkat fisik atau install Google Speech Services.',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Tampilkan dialog lagi
      _showSpeechNotAvailableDialog();
      return;
    }
    
    // Inisialisasi jika belum
    if (!_speechInitialized) {
      await _initSpeech();
      
      // Cek lagi setelah inisialisasi
      if (!_speechHelper.isAvailable) {
        return;
      }
    }

    // Stop semua audio sebelum mulai listening
    await _audio.stopSpeech();
    await _flutterTts.stop();
    _audio.playButtonSound();

    setState(() {
      _lastWords = '';
      _isListening = true;
      _listeningProgress = 0.0;
      _speechStatus = 'Dengarkan... Ucapkan kata yang ditampilkan!';
    });

    _micPulseController.repeat(reverse: true);
    
    // Start progress timer (5 detik)
    _startProgressTimer();

    bool started = await _speechHelper.startListening(
      targetText: _currentWord,
      onResult: (text, confidence) {
        if (mounted) {
          setState(() {
            _lastWords = text;
            // Perbarui status saat mendeteksi suara
            if (text.isNotEmpty) {
              _speechStatus = 'Mendengarkan: "$text"';
            }
          });
        }
      },
      onDone: () {
        if (mounted) {
          _stopProgressTimer();
          
          // Track jika tidak ada suara
          if (_lastWords.isEmpty) {
            _noSoundCount++;
            
            // Setelah 2 kali gagal, tampilkan tips
            if (_noSoundCount >= 2 && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _showMicrophoneTipsDialog();
                }
              });
            }
          } else {
            // Reset counter jika berhasil
            _noSoundCount = 0;
          }
          
          setState(() {
            _isListening = false;
            _micPulseController.stop();
            _listeningProgress = 1.0;
            _speechStatus = _lastWords.isEmpty 
                ? 'Tidak ada suara terdeteksi. Coba lebih keras!' 
                : 'Memproses hasil...';
          });
          _evaluatePronunciation();
        }
      },
    );
    
    // Jika gagal mulai listening
    if (!started) {
      _stopProgressTimer();
      setState(() {
        _isListening = false;
        _micPulseController.stop();
        _listeningProgress = 0.0;
        _speechStatus = 'Gagal memulai pengenalan suara';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal memulai speech recognition. Cek izin microphone atau gunakan perangkat fisik.',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    const duration = 10000; // 10 detik - lebih lama untuk anak-anak
    const interval = 50; // Update setiap 50ms
    int elapsed = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: interval), (timer) {
      elapsed += interval;
      if (mounted) {
        setState(() {
          _listeningProgress = (elapsed / duration).clamp(0.0, 1.0);
        });
      }
      
      if (elapsed >= duration) {
        timer.cancel();
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _stopListening() {
    _speechHelper.stopListening();
    _stopProgressTimer();
    setState(() {
      _isListening = false;
      _micPulseController.stop();
    });
  }

  void _evaluatePronunciation() {
    if (_lastWords.isEmpty) {
      setState(() {
        _speechStatus = 'Tidak ada suara terdeteksi. Silakan coba lagi.';
      });
      return;
    }

    final correct = _speechHelper.checkSpeech(_currentWord);

    debugPrint('Evaluasi: target="$_currentWord", spoken="$_lastWords", correct=$correct');

    setState(() {
      _isCorrect = correct;
      _showPopup = true;
      if (correct) {
        _score++;
      }
    });

    _resultController.forward(from: 0);

    if (correct) {
      _audio.playCorrectSound();
      Future.delayed(const Duration(milliseconds: 2000), () async {
        if (!mounted) return;
        await _resultController.reverse();
        setState(() {
          _showPopup = false;
        });
        _nextQuestion();
      });
    } else {
      _audio.playWrongSound();
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() {
        _currentIndex++;
        _lastWords = '';
        _showPopup = false;
        _speechStatus = 'Tekan tombol mic lalu ucapkan kata';
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _playWordSound(_currentWord);
      });
    } else {
      _saveScore();
      setState(() {
        _gameFinished = true;
      });
    }
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'Pemain';

    final score = ScoreHistory(
      userName: userName,
      score: _score,
      totalQuestions: _soalList.length,
      date: DateTime.now(),
      category: 'Mengucapkan ${widget.category}',
    );

    await _scoreService.saveScore(score);
  }

  void _restart() {
    setState(() {
      _soalList.shuffle();
      _currentIndex = 0;
      _score = 0;
      _gameFinished = false;
      _lastWords = '';
      _showPopup = false;
      _speechStatus = 'Tekan tombol mic lalu ucapkan kata';
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _playWordSound(_currentWord);
    });
  }

  @override
  void dispose() {
    _audio.stopSpeech();
    _flutterTts.stop();
    _speechHelper.stopListening();

    _entryController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _resultController.dispose();
    _micPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (_gameFinished) {
      return _buildFinishScreen(sw, sh);
    }

    return Scaffold(
      body: SizedBox(
        width: sw,
        height: sh,
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset('assets/untukhome/bg.png', fit: BoxFit.cover),
            ),
            // Ground
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/untukhome/ground.png',
                fit: BoxFit.cover,
                height: sh * 0.18,
              ),
            ),

            // Animated clouds
            AnimatedBuilder(
              animation: _cloud1Controller,
              builder: (context, child) {
                return Positioned(
                  top: sh * 0.05,
                  left: sw * (_cloud1Controller.value * 1.5 - 0.3),
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset(
                      'assets/untukbelajar/alfabet/awan 1.png',
                      height: sh * 0.1,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _cloud2Controller,
              builder: (context, child) {
                return Positioned(
                  top: sh * 0.12,
                  left: sw * (_cloud2Controller.value * 1.5 - 0.2),
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                      'assets/untukbelajar/alfabet/awan 2.png',
                      height: sh * 0.08,
                    ),
                  ),
                );
              },
            ),

            // Back button
            Positioned(
              top: sh * 0.03,
              left: sw * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    _audio.playButtonSound();
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/untukbelajar/alfabet/navigasi_0.png',
                    height: sh * 0.1,
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: sh * 0.03,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.05,
                      vertical: sh * 0.015,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.red.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'Mengucapkan ${widget.category}',
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: sh * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Score badge
            Positioned(
              top: sh * 0.03,
              right: sw * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sh * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Skor: $_score/${_soalList.length}',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: sh * 0.025,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Main Board Content
            Positioned(
              top: sh * 0.15,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: _buildMainContent(sw, sh),
                  ),
                ),
              ),
            ),

            // Feedback Overlay Popup
            if (_showPopup) _buildResultFeedback(sw, sh),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(double sw, double sh) {
    return SizedBox(
      width: sw * 0.55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Papan background
          Image.asset(
            'assets/untukbelajar/alfabet/papan.png',
            width: sw * 0.55,
            height: sh * 0.65,
            fit: BoxFit.fill,
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.06,
              vertical: sh * 0.04,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nomor soal
                Text(
                  'Soal ${_currentIndex + 1}/${_soalList.length}',
                  style: TextStyle(
                    fontFamily: 'Bangers',
                    fontSize: sh * 0.025,
                    color: Colors.brown.shade800,
                  ),
                ),
                SizedBox(height: sh * 0.02),
                // Suku kata berkotak 3D
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: sw * 0.015,
                  runSpacing: sh * 0.01,
                  children: [
                    ...List.generate(
                      (_currentSoal['suku'] as List<String>).length,
                      (index) {
                        final suku = (_currentSoal['suku'] as List<String>)[index];
                        final color = _syllableColors[index % _syllableColors.length];
                        return _buildSyllableBox(suku, color, sw, sh);
                      },
                    ),
                    // Speaker button next to syllables
                    _buildSpeakerButton(sh),
                  ],
                ),
                SizedBox(height: sh * 0.02),
                // Speech Status / Instructions
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sh * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _speechStatus,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: sh * 0.02,
                      color: _isListening ? Colors.red.shade700 : Colors.brown.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: sh * 0.02),
                // Transcribed text bubble
                if (_lastWords.isNotEmpty) _buildTranscriptBubble(sw, sh),
                SizedBox(height: sh * 0.02),
                // Microphone and skip buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMicButton(sh),
                    if (!_isListening) ...[
                      SizedBox(width: sw * 0.03),
                      _buildSkipButton(sw, sh),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSyllableBox(String suku, Color color, double sw, double sh) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.02,
        vertical: sh * 0.015,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.9), color],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.8), offset: const Offset(0, 4), blurRadius: 0),
          const BoxShadow(color: Colors.black26, offset: Offset(0, 6), blurRadius: 6),
        ],
      ),
      child: Text(
        suku.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Bangers',
          fontSize: sh * 0.04,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerButton(double sh) {
    return GestureDetector(
      onTap: () => _playWordSound(_currentWord),
      child: Container(
        padding: EdgeInsets.all(sh * 0.012),
        decoration: BoxDecoration(
          color: Colors.orange.shade400,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade700,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.volume_up_rounded,
          color: Colors.white,
          size: sh * 0.03,
        ),
      ),
    );
  }

  Widget _buildTranscriptBubble(double sw, double sh) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sh * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: sh * 0.024,
            color: Colors.black87,
          ),
          children: [
            const TextSpan(text: 'Kamu mengucapkan: '),
            TextSpan(
              text: '"$_lastWords"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(double sh) {
    return GestureDetector(
      onTap: () {
        debugPrint('Mic button tapped! _isListening: $_isListening');
        if (_isListening) {
          _stopListening();
        } else {
          _startListening();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress bar circular di belakang
          if (_isListening)
            SizedBox(
              width: sh * 0.14,
              height: sh * 0.14,
              child: CircularProgressIndicator(
                value: _listeningProgress,
                strokeWidth: 6,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _listeningProgress > 0.7 
                      ? Colors.orange 
                      : Colors.white,
                ),
              ),
            ),
          // Mic button
          ScaleTransition(
            scale: _isListening ? _micPulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: sh * 0.12,
              height: sh * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Colors.red.shade400, Colors.red.shade600]
                      : [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _isListening ? Colors.red.shade700 : Colors.green.shade700,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                  const BoxShadow(color: Colors.black26, offset: Offset(0, 6), blurRadius: 8),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: sh * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton(double sw, double sh) {
    return GestureDetector(
      onTap: () {
        _audio.playButtonSound();
        _nextQuestion();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical: sh * 0.015,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade700,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
            const BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEWATI',
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: sh * 0.024,
                color: Colors.white,
              ),
            ),
            SizedBox(width: sw * 0.01),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: sh * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildResultFeedback(double sw, double sh) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _resultController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.06,
                vertical: sh * 0.04,
              ),
              margin: EdgeInsets.symmetric(horizontal: sw * 0.15),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    _isCorrect ? 'assets/feedbenar.png' : 'assets/feedsalah.png',
                    height: sh * 0.22,
                  ),
                  SizedBox(height: sh * 0.015),
                  Text(
                    _isCorrect ? 'Benar!' : 'Kurang Tepat!',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: sh * 0.045,
                      color: Colors.white,
                    ),
                  ),
                  if (!_isCorrect) ...[
                    SizedBox(height: sh * 0.01),
                    Text(
                      'Kamu mengucapkan: "$_lastWords"',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: sh * 0.024,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: sh * 0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeedbackButton(
                          onTap: () {
                            _audio.playButtonSound();
                            setState(() {
                              _showPopup = false;
                              _lastWords = '';
                              _speechStatus = 'Tekan tombol mic lalu ucapkan kata';
                            });
                          },
                          color: Colors.orange,
                          text: 'Coba Lagi',
                          icon: Icons.replay_rounded,
                          sw: sw,
                          sh: sh,
                        ),
                        SizedBox(width: sw * 0.02),
                        _buildFeedbackButton(
                          onTap: () {
                            _audio.playButtonSound();
                            setState(() {
                              _showPopup = false;
                            });
                            _nextQuestion();
                          },
                          color: Colors.blue,
                          text: 'Lanjut',
                          icon: Icons.arrow_forward_rounded,
                          sw: sw,
                          sh: sh,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackButton({
    required VoidCallback onTap,
    required Color color,
    required String text,
    required IconData icon,
    required double sw,
    required double sh,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical: sh * 0.012,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.darken(),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: sh * 0.022),
            SizedBox(width: sw * 0.01),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Bangers',
                fontSize: sh * 0.022,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishScreen(double sw, double sh) {
    final percentage = (_score / _soalList.length * 100).round();
    final stars = _score >= 8
        ? 3
        : _score >= 5
            ? 2
            : _score >= 3
                ? 1
                : 0;

    return Scaffold(
      body: SizedBox(
        width: sw,
        height: sh,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/untukhome/bg.png', fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/untukhome/ground.png',
                fit: BoxFit.cover,
                height: sh * 0.18,
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: SizedBox(
                  width: sw * 0.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/untukbelajar/alfabet/papan.png',
                        width: sw * 0.6,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.06,
                          vertical: sh * 0.04,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SELESAI! 🎉',
                              style: TextStyle(
                                fontFamily: 'Bangers',
                                fontSize: sh * 0.06,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            SizedBox(height: sh * 0.01),
                            // Stars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.01),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                        milliseconds: 500 + (i * 200)),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                          scale: value, child: child);
                                    },
                                    child: Icon(
                                      i < stars
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: i < stars
                                          ? Colors.amber
                                          : Colors.brown.shade300,
                                      size: sh * 0.06,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: sh * 0.01),
                            Text(
                              'Skor: $_score/${_soalList.length}',
                              style: TextStyle(
                                fontFamily: 'Bangers',
                                fontSize: sh * 0.04,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontFamily: 'Bangers',
                                fontSize: sh * 0.035,
                                color: Colors.brown.shade600,
                              ),
                            ),
                            SizedBox(height: sh * 0.02),
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _build3DFinishButton(
                                  onTap: () {
                                    _audio.playButtonSound();
                                    _restart();
                                  },
                                  color: Colors.orange,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.replay_rounded,
                                          color: Colors.white,
                                          size: sh * 0.025),
                                      SizedBox(width: sw * 0.01),
                                      Text(
                                        'Ulangi',
                                        style: TextStyle(
                                          fontFamily: 'Bangers',
                                          fontSize: sh * 0.025,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  width: sw * 0.18,
                                  height: sh * 0.08,
                                ),
                                SizedBox(width: sw * 0.02),
                                _build3DFinishButton(
                                  onTap: () {
                                    _audio.playButtonSound();
                                    Navigator.pop(context);
                                  },
                                  color: Colors.green,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.home_rounded,
                                          color: Colors.white,
                                          size: sh * 0.025),
                                      SizedBox(width: sw * 0.01),
                                      Text(
                                        'Menu',
                                        style: TextStyle(
                                          fontFamily: 'Bangers',
                                          fontSize: sh * 0.025,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  width: sw * 0.18,
                                  height: sh * 0.08,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DFinishButton({
    required VoidCallback onTap,
    required Color color,
    required Widget child,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.9), color],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(color: color.darken(), offset: const Offset(0, 4), blurRadius: 0),
            const BoxShadow(color: Colors.black26, offset: Offset(0, 6), blurRadius: 8),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsv = HSVColor.fromColor(this);
    final hsvDark = hsv.withValue((hsv.value - amount).clamp(0.0, 1.0));
    return hsvDark.toColor();
  }
}
