import 'package:flutter/material.dart';
import 'dart:math';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../models/score_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenyusunHurufScreen extends StatefulWidget {
  const MenyusunHurufScreen({super.key});

  @override
  State<MenyusunHurufScreen> createState() => _MenyusunHurufScreenState();
}

class _MenyusunHurufScreenState extends State<MenyusunHurufScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _scoreService = ScoreService();

  // 10 soal menyusun huruf
  final List<String> _soalList = [
    'dapur',
    'minum',
    'kapas',
    'wajan',
    'pagar',
    'jaket',
    'tikar',
    'kasur',
    'rakit',
    'sawah',
  ];

  // Map huruf ke index keyboard asset (a=0, b=1, ..., z=25)
  int _letterToIndex(String letter) {
    return letter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  int _currentIndex = 0;
  int _score = 0;
  bool _gameFinished = false;
  bool _showResult = false;
  bool _isCorrect = false;

  // Huruf yang tersedia (diacak) dan huruf yang sudah dipilih
  late List<String> _availableLetters;
  late List<String?> _placedLetters;

  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _resultController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String get _currentWord => _soalList[_currentIndex];

  @override
  void initState() {
    super.initState();
    _soalList.shuffle(Random());
    _initLetters();
    _initAnimations();
  }

  void _initLetters() {
    final letters = _currentWord.split('');
    _placedLetters = List.filled(letters.length, null);
    _availableLetters = List.from(letters)..shuffle(Random());
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

    _entryController.forward();

    // Play audio for first word after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _audio.playLatihanSound(_currentWord);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _onLetterTap(int availableIndex) {
    if (_showResult) return;
    final letter = _availableLetters[availableIndex];

    // Cari slot kosong pertama
    final emptySlot = _placedLetters.indexOf(null);
    if (emptySlot == -1) return; // Semua slot terisi

    setState(() {
      _placedLetters[emptySlot] = letter;
      _availableLetters[availableIndex] = ''; // kosongkan
    });

    _audio.playButtonSound();

    // Cek apakah semua slot terisi
    if (!_placedLetters.contains(null)) {
      _checkAnswer();
    }
  }

  void _onSlotTap(int slotIndex) {
    if (_showResult) return;
    final letter = _placedLetters[slotIndex];
    if (letter == null) return;

    // Kembalikan huruf ke available
    final emptyAvailable = _availableLetters.indexOf('');
    if (emptyAvailable == -1) return;

    setState(() {
      _availableLetters[emptyAvailable] = letter;
      _placedLetters[slotIndex] = null;
    });

    _audio.playButtonSound();
  }

  void _checkAnswer() {
    final answer = _placedLetters.join('');
    final correct = answer == _currentWord;

    setState(() {
      _showResult = true;
      _isCorrect = correct;
      if (correct) _score++;
    });

    _resultController.forward(from: 0);

    // Play sound feedback
    if (correct) {
      _audio.playCorrectSound();
    } else {
      _audio.playWrongSound();
    }

    // Auto-advance after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _soalList.length - 1) {
      _saveScore();
      setState(() => _gameFinished = true);
      return;
    }

    setState(() {
      _currentIndex++;
      _showResult = false;
      _isCorrect = false;
      _initLetters();
    });

    // Play audio for new word
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _audio.playLatihanSound(_currentWord);
    });
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'Pemain';

    final history = ScoreHistory(
      userName: userName,
      score: _score,
      totalQuestions: _soalList.length,
      date: DateTime.now(),
      category: 'Menyusun Huruf',
    );
    await _scoreService.saveScore(history);
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _gameFinished = false;
      _showResult = false;
      _isCorrect = false;
      _soalList.shuffle(Random());
      _initLetters();
    });
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
                        colors: [Colors.purple.shade400, Colors.deepPurple.shade400],
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
                      'Menyusun Huruf',
                      style: TextStyle(
                        fontFamily: 'SpicySale',
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
                      fontFamily: 'SpicySale',
                      fontSize: sh * 0.025,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Main papan area
            Positioned(
              top: sh * 0.14,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(double sw, double sh) {
    return SizedBox(
      width: sw * 0.7,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Papan background
          Image.asset(
            'assets/untukbelajar/alfabet/papan.png',
            width: sw * 0.7,
            fit: BoxFit.contain,
          ),
          // Content on papan
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.06,
              vertical: sh * 0.03,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress
                Text(
                  'Soal ${_currentIndex + 1}/${_soalList.length}',
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: sh * 0.02,
                    color: Colors.brown.shade800,
                  ),
                ),
                SizedBox(height: sh * 0.008),

                // Word image + speaker button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Word image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/untuklatihan/$_currentWord.png',
                        height: sh * 0.1,
                        width: sh * 0.1,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Icon(
                          Icons.image_outlined,
                          size: sh * 0.08,
                          color: Colors.brown.shade300,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    // Speaker button
                    GestureDetector(
                      onTap: () => _audio.playLatihanSound(_currentWord),
                      child: Container(
                        padding: EdgeInsets.all(sh * 0.01),
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
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.012),

                // Answer slots (where letters are placed)
                _buildAnswerSlots(sw, sh),

                SizedBox(height: sh * 0.03),

                // Available letters (scrambled)
                _buildAvailableLetters(sw, sh),

                // Result feedback
                if (_showResult) ...[
                  SizedBox(height: sh * 0.015),
                  _buildResultFeedback(sw, sh),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSlots(double sw, double sh) {
    final slotSize = sw * 0.09;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_currentWord.length, (index) {
        final letter = _placedLetters[index];
        final isCorrectSlot = _showResult && letter == _currentWord[index];
        final isWrongSlot = _showResult && letter != null && letter != _currentWord[index];

        return GestureDetector(
          onTap: () => _onSlotTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: slotSize,
            height: slotSize,
            margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
            decoration: BoxDecoration(
              color: letter != null
                  ? (_showResult
                      ? (isCorrectSlot
                          ? Colors.green.shade400
                          : (isWrongSlot ? Colors.red.shade400 : Colors.orange.shade300))
                      : Colors.orange.shade300)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: letter != null
                    ? (_showResult
                        ? (isCorrectSlot ? Colors.green.shade700 : Colors.red.shade700)
                        : Colors.orange.shade600)
                    : Colors.brown.shade300,
                width: 3,
              ),
              boxShadow: letter != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: letter != null
                  ? Image.asset(
                      'assets/untukbelajar/alfabet/abc besar_${_letterToIndex(letter)}.png',
                      height: slotSize * 0.7,
                      errorBuilder: (c, e, s) => Text(
                        letter.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'SpicySale',
                          fontSize: sh * 0.035,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      '?',
                      style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: sh * 0.03,
                        color: Colors.brown.shade300,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAvailableLetters(double sw, double sh) {
    final btnSize = sw * 0.09;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_availableLetters.length, (index) {
        final letter = _availableLetters[index];
        if (letter.isEmpty) {
          // Empty placeholder (already placed)
          return SizedBox(
            width: btnSize,
            height: btnSize,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.008),
              child: const SizedBox(),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.008),
          child: GestureDetector(
            onTap: () => _onLetterTap(index),
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: btnSize,
                height: btnSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade300, Colors.blue.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade700,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/untukbelajar/alfabet/abc besar_${_letterToIndex(letter)}.png',
                    height: btnSize * 0.7,
                    errorBuilder: (c, e, s) => Text(
                      letter.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: sh * 0.035,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResultFeedback(double sw, double sh) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _resultController,
        curve: Curves.elasticOut,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.008,
        ),
        decoration: BoxDecoration(
          color: _isCorrect ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: sh * 0.03,
            ),
            SizedBox(width: sw * 0.01),
            Text(
              _isCorrect
                  ? 'Benar! 🎉'
                  : 'Salah! Jawaban: ${_currentWord.toUpperCase()}',
              style: TextStyle(
                fontFamily: 'SpicySale',
                fontSize: sh * 0.022,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                                fontFamily: 'SpicySale',
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
                                _build3DButton(
                                  onTap: _restart,
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
                                          fontFamily: 'SpicySale',
                                          fontSize: sh * 0.022,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  width: sw * 0.17,
                                  height: sh * 0.06,
                                ),
                                SizedBox(width: sw * 0.03),
                                _build3DButton(
                                  onTap: () => Navigator.pop(context),
                                  color: Colors.red,
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
                                          fontFamily: 'SpicySale',
                                          fontSize: sh * 0.022,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  width: sw * 0.17,
                                  height: sh * 0.06,
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

  Widget _build3DButton({
    required VoidCallback onTap,
    required Color color,
    required Widget child,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () {
        _audio.playButtonSound();
        onTap();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.9), color],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: HSLColor.fromColor(color)
                  .withLightness(
                      (HSLColor.fromColor(color).lightness * 0.6).clamp(0, 1))
                  .toColor(),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
