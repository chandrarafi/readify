import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../models/score_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TebakKataScreen extends StatefulWidget {
  const TebakKataScreen({super.key});

  @override
  State<TebakKataScreen> createState() => _TebakKataScreenState();
}

class _TebakKataScreenState extends State<TebakKataScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _scoreService = ScoreService();

  // Data soal tebak kata
  final List<Map<String, dynamic>> _soalList = [
    {
      'gambar': 'assets/untukbelajar/kosakata/buku.png',
      'jawaban': 'buku',
      'pilihan': ['buku', 'kaki', 'kuku']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/padi.png',
      'jawaban': 'padi',
      'pilihan': ['dadu', 'budi', 'padi']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/roda.png',
      'jawaban': 'roda',
      'pilihan': ['roda', 'dora', 'tali']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/kayu.png',
      'jawaban': 'kayu',
      'pilihan': ['kaku', 'kayu', 'kamu']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/besi.png',
      'jawaban': 'besi',
      'pilihan': ['beri', 'besi', 'basi']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/bedak.png',
      'jawaban': 'bedak',
      'pilihan': ['bedak', 'badak', 'batuk']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/gitar.png',
      'jawaban': 'gitar',
      'pilihan': ['gitar', 'getar', 'gatal']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/pasir.png',
      'jawaban': 'pasir',
      'pilihan': ['pasir', 'pasar', 'gelas']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/mawar.png',
      'jawaban': 'mawar',
      'pilihan': ['warna', 'mawar', 'kamar']
    },
    {
      'gambar': 'assets/untukbelajar/kosakata/jaru.png',
      'jawaban': 'jarum',
      'pilihan': ['jarak', 'curam', 'jarum']
    },
  ];

  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  int _score = 0;
  bool _gameFinished = false;
  int _speechId = 0; // Untuk cancel speech

  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _bounceController;
  late AnimationController _resultController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  Map<String, dynamic> get _currentSoal => _soalList[_currentIndex];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // Play audio soal pertama setelah animasi selesai
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _speakQuestion();
    });
  }

  Future<void> _speakQuestion() async {
    _speechId++;
    final currentSpeechId = _speechId;
    
    try {
      await _audio.stopSpeech();
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (currentSpeechId != _speechId) return;
      
      // Play kata yang harus ditebak
      await _audio.playWordSound(_currentSoal['jawaban']);
    } catch (e) {
      debugPrint('Speak question error: $e');
    }
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _cloud1Controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _cloud2Controller = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _audio.stopSpeech();
    _entryController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _bounceController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _checkAnswer(String answer) {
    if (_showResult) return;

    _audio.stopSpeech(); // Stop audio soal
    
    setState(() {
      _selectedAnswer = answer;
      _isCorrect = answer == _currentSoal['jawaban'];
      _showResult = true;

      if (_isCorrect) {
        _score++;
      }
    });

    _resultController.forward(from: 0);
    
    // Play audio jawaban (benar atau salah)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isCorrect) {
        _audio.playWordSound(_currentSoal['jawaban']);
      } else {
        // Play audio untuk jawaban yang salah bisa pakai sound effect
        _audio.playButtonSound();
      }
    });

    // Auto next setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _isCorrect = false;
      });
      // Play audio soal berikutnya
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _speakQuestion();
      });
    } else {
      // Game selesai, simpan score
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
      category: 'Tebak Kata',
    );
    
    await _scoreService.saveScore(score);
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      _isCorrect = false;
      _score = 0;
      _gameFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_gameFinished) {
      return _buildFinishScreen(screenWidth, screenHeight);
    }

    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
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
                height: screenHeight * 0.18,
              ),
            ),

            // Animated clouds
            AnimatedBuilder(
              animation: _cloud1Controller,
              builder: (context, child) {
                return Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * (_cloud1Controller.value * 1.5 - 0.3),
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset(
                      'assets/untukbelajar/alfabet/awan 1.png',
                      height: screenHeight * 0.1,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _cloud2Controller,
              builder: (context, child) {
                return Positioned(
                  top: screenHeight * 0.12,
                  left: screenWidth * (_cloud2Controller.value * 1.5 - 0.2),
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                      'assets/untukbelajar/alfabet/awan 2.png',
                      height: screenHeight * 0.08,
                    ),
                  ),
                );
              },
            ),

            // Back button
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    _audio.playButtonSound();
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/untukbelajar/alfabet/navigasi_0.png',
                    height: screenHeight * 0.1,
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: screenHeight * 0.03,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.015,
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
                      'Tebak Kata',
                      style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: screenHeight * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Score
            Positioned(
              top: screenHeight * 0.03,
              right: screenWidth * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
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
                      fontFamily: 'SpicySale',
                      fontSize: screenHeight * 0.025,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Main content - Papan
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/untukbelajar/alfabet/papan.png',
                        height: screenHeight * 0.65,
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress
                            Text(
                              'Soal ${_currentIndex + 1}/${_soalList.length}',
                              style: TextStyle(
                                fontFamily: 'SpicySale',
                                fontSize: screenHeight * 0.025,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Image dengan bounce dan speaker button
                            AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _bounceAnimation.value),
                                  child: child,
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(screenHeight * 0.015),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: const Offset(0, 4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      _currentSoal['gambar'],
                                      height: screenHeight * 0.15,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(height: screenHeight * 0.15),
                                    ),
                                  ),
                                  // Speaker button
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _audio.playButtonSound();
                                        _speakQuestion();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(screenHeight * 0.01),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.volume_up_rounded,
                                          color: Colors.white,
                                          size: screenHeight * 0.03,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // Pilihan jawaban dalam bentuk row horizontal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: (_currentSoal['pilihan'] as List<String>)
                                  .map((pilihan) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.01,
                                        ),
                                        child: _buildPilihanButton(
                                          pilihan,
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Result overlay
            if (_showResult)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.08),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              offset: const Offset(0, 8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle : Icons.cancel,
                              size: screenHeight * 0.1,
                              color: Colors.white,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              _isCorrect ? 'Benar!' : 'Salah!',
                              style: TextStyle(
                                fontFamily: 'SpicySale',
                                fontSize: screenHeight * 0.05,
                                color: Colors.white,
                              ),
                            ),
                            if (!_isCorrect) ...[
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'Jawaban: ${_currentSoal['jawaban']}',
                                style: TextStyle(
                                  fontFamily: 'SpicySale',
                                  fontSize: screenHeight * 0.03,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPilihanButton(
      String pilihan, double screenWidth, double screenHeight) {
    final isSelected = _selectedAnswer == pilihan;
    final isCorrectAnswer = pilihan == _currentSoal['jawaban'];
    
    Color buttonColor;
    if (_showResult) {
      if (isCorrectAnswer) {
        buttonColor = Colors.green;
      } else if (isSelected) {
        buttonColor = Colors.red;
      } else {
        buttonColor = Colors.grey;
      }
    } else {
      buttonColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        if (!_showResult) {
          _audio.playButtonSound();
          _checkAnswer(pilihan);
        }
      },
      child: Container(
        width: screenWidth * 0.13, // Kurangi dari 0.22 ke 0.18 (lebih pendek)
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
          vertical: screenHeight * 0.025, // Nambah dari 0.012 ke 0.018 (lebih tinggi)
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              buttonColor.withValues(alpha: 0.9),
              buttonColor,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.7),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          pilihan.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SpicySale',
            fontSize: screenHeight * 0.025, // Kurangi dari 0.03 ke 0.025
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black38,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishScreen(double screenWidth, double screenHeight) {
    final percentage = (_score / _soalList.length * 100).round();
    String message;
    Color messageColor;

    if (percentage >= 80) {
      message = 'Luar Biasa!';
      messageColor = Colors.green;
    } else if (percentage >= 60) {
      message = 'Bagus!';
      messageColor = Colors.blue;
    } else {
      message = 'Coba Lagi!';
      messageColor = Colors.orange;
    }

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/untukhome/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.08),
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: screenHeight * 0.05,
                    color: messageColor,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Skor Akhir',
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: screenHeight * 0.03,
                    color: Colors.brown.shade800,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '$_score/${_soalList.length}',
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: screenHeight * 0.06,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: screenHeight * 0.04,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _build3DButton(
                      onTap: () {
                        _audio.playButtonSound();
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      child: Icon(
                        Icons.home,
                        color: Colors.white,
                        size: screenHeight * 0.04,
                      ),
                      width: screenWidth * 0.2,
                      height: screenHeight * 0.08,
                    ),
                    _build3DButton(
                      onTap: () {
                        _audio.playButtonSound();
                        _restart();
                      },
                      color: Colors.green,
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: screenHeight * 0.04,
                      ),
                      width: screenWidth * 0.2,
                      height: screenHeight * 0.08,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DButton({
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
            BoxShadow(
              color: color.withValues(alpha: 0.8),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
