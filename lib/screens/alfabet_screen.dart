import 'package:flutter/material.dart';
import 'dart:math';
import '../services/audio_service.dart';

class AlfabetScreen extends StatefulWidget {
  const AlfabetScreen({super.key});

  @override
  State<AlfabetScreen> createState() => _AlfabetScreenState();
}

class _AlfabetScreenState extends State<AlfabetScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  
  // State
  int _selectedLetterIndex = 0;
  bool _isUpperCase = true;
  bool _keyboardVisible = true;
  bool _showParticles = false;
  bool _hasSelectedLetter = false;
  final Set<int> _clickedLetters = {};
  
  // Particle state
  List<Particle> _particles = [];
  
  // Product tour state
  int _tourStep = 0; // 0 = tour active, -1 = tour completed
  final List<String> _tourMessages = [
    'Tekan huruf A untuk\nmenampilkan di papan',
    'Bagus! Klik tombol ini\nuntuk ganti huruf besar/kecil',
    'Selamat belajar! 🎉',
  ];
  
  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _keyboardController;
  late AnimationController _particleController;
  late AnimationController _handController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _keyboardSlideAnimation;
  late Animation<double> _papanScaleAnimation;
  late Animation<double> _handAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    
    // Cloud 1 animation (slower)
    _cloud1Controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
    
    // Cloud 2 animation (faster)
    _cloud2Controller = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
    
    // Keyboard slide animation
    _keyboardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _keyboardSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _keyboardController, curve: Curves.easeInOut),
    );
    _papanScaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _keyboardController, curve: Curves.easeInOut),
    );
    
    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _particleController.addListener(() {
      if (_showParticles) setState(() {});
    });
    
    // Hand animation
    _handController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _handAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );
    
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _keyboardController.dispose();
    _particleController.dispose();
    _handController.dispose();
    super.dispose();
  }

  void _spawnParticles() {
    final random = Random();
    _particles = List.generate(30, (index) {
      return Particle(
        x: (random.nextDouble() - 0.5) * 50,
        y: (random.nextDouble() - 0.5) * 30,
        vx: (random.nextDouble() - 0.5) * 300,
        vy: (random.nextDouble() - 0.7) * 250,
        color: [
          Colors.red, Colors.orange, Colors.yellow, 
          Colors.green, Colors.blue, Colors.purple,
          Colors.pink, Colors.cyan, Colors.amber,
        ][random.nextInt(9)],
        size: random.nextDouble() * 10 + 5,
      );
    });
    _showParticles = true;
    _particleController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showParticles = false);
    });
  }

  void _onLetterTap(int index) {
    _audio.playLetterSound(index); // Play letter sound A-Z
    setState(() {
      _selectedLetterIndex = index;
      _hasSelectedLetter = true;
      
      // Progress tour when tapping letter A (index 0) on step 0
      if (_tourStep == 0 && index == 0) {
        _tourStep = 1;
      }
      
      // Spawn particles every time a letter is tapped
      _spawnParticles();
    });
  }

  void _toggleKeyboard() {
    _audio.playButtonSound();
    setState(() {
      _keyboardVisible = !_keyboardVisible;
      if (_keyboardVisible) {
        _keyboardController.reverse();
      } else {
        _keyboardController.forward();
      }
    });
  }

  void _navigateLetter(int direction) {
    setState(() {
      _selectedLetterIndex = (_selectedLetterIndex + direction) % 26;
      if (_selectedLetterIndex < 0) _selectedLetterIndex = 25;
    });
    // Play letter sound after state update
    _audio.playLetterSound(_selectedLetterIndex);
    _spawnParticles();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              bottom: 0, left: 0, right: 0,
              child: Image.asset('assets/untukhome/ground.png', fit: BoxFit.cover, height: screenHeight * 0.18),
            ),
            
            // Animated cloud 1
            AnimatedBuilder(
              animation: _cloud1Controller,
              builder: (context, child) {
                double value = _cloud1Controller.value;
                return Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * (value * 1.5 - 0.3),
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset('assets/untukbelajar/alfabet/awan 1.png', height: screenHeight * 0.1),
                  ),
                );
              },
            ),
            
            // Animated cloud 2
            AnimatedBuilder(
              animation: _cloud2Controller,
              builder: (context, child) {
                double value = _cloud2Controller.value;
                return Positioned(
                  top: screenHeight * 0.12,
                  left: screenWidth * (value * 1.5 - 0.2),
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.asset('assets/untukbelajar/alfabet/awan 2.png', height: screenHeight * 0.08),
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
                  child: Image.asset('assets/untukbelajar/alfabet/navigasi_0.png', height: screenHeight * 0.1),
                ),
              ),
            ),
            
            // Papan with letter display
            Positioned(
              top: screenHeight * 0.08,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _papanScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _papanScaleAnimation.value,
                      child: child,
                    );
                  },
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Papan background
                        Image.asset(
                          'assets/untukbelajar/alfabet/papan.png',
                          height: screenHeight * 0.45,
                        ),
                        // Letter display or hint text
                        if (_hasSelectedLetter)
                          Image.asset(
                            _isUpperCase
                                ? 'assets/untukbelajar/alfabet/abc besar_$_selectedLetterIndex.png'
                                : 'assets/untukbelajar/alfabet/huruf kecil_$_selectedLetterIndex.png',
                            height: screenHeight * 0.25,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(height: screenHeight * 0.25),
                          )
                        else
                          Padding(
                            padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tekan tombol untuk',
                                  style: TextStyle(
                                    fontFamily: 'Bangers',
                                    fontSize: screenHeight * 0.035,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'menampilkan huruf',
                                  style: TextStyle(
                                    fontFamily: 'Bangers',
                                    fontSize: screenHeight * 0.035,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
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
            
            // Particle animation (outside papan stack)
            if (_showParticles)
              ...(_particles.map((p) {
                final progress = _particleController.value;
                final x = p.x + p.vx * progress;
                final y = p.y + p.vy * progress + 100 * progress * progress;
                final opacity = (1 - progress).clamp(0.0, 1.0);
                return Positioned(
                  left: screenWidth * 0.5 + x - p.size / 2,
                  top: screenHeight * 0.25 + y - p.size / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              })),
            
            // Navigation arrows (when keyboard hidden and letter selected)
            if (_hasSelectedLetter)
              AnimatedBuilder(
                animation: _keyboardSlideAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _keyboardSlideAnimation.value,
                    child: IgnorePointer(
                      ignoring: _keyboardVisible,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Positioned(
                      left: screenWidth * 0.18,
                      top: screenHeight * 0.22,
                      child: GestureDetector(
                        onTap: () => _navigateLetter(-1),
                        child: Image.asset('assets/untukbelajar/alfabet/navigasi menyusun_kiri.png', height: screenHeight * 0.12),
                      ),
                    ),
                    Positioned(
                      right: screenWidth * 0.18,
                      top: screenHeight * 0.22,
                      child: GestureDetector(
                        onTap: () => _navigateLetter(1),
                        child: Image.asset('assets/untukbelajar/alfabet/navigasi menyusun_kanan.png', height: screenHeight * 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Keyboard section
            AnimatedBuilder(
              animation: _keyboardSlideAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: -screenHeight * 0.05 - (_keyboardSlideAnimation.value * screenHeight * 0.35),
                  left: 0, right: 0,
                  child: child!,
                );
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Keyboard background with letters (centered)
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.025),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/untukbelajar/alfabet/bgkeyboar.png', width: screenWidth * 0.65),
                          _buildKeyboard(screenWidth, screenHeight),
                        ],
                      ),
                    ),
                    // Keyboard toggle button (on top of keyboard)
                    GestureDetector(
                      onTap: _toggleKeyboard,
                      child: Image.asset(
                        _keyboardVisible
                            ? 'assets/untukbelajar/alfabet/navigasi keyboar_down.png'
                            : 'assets/untukbelajar/alfabet/navigasi keyboar_up.png',
                        height: screenHeight * 0.10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Case toggle button (left side with papanabc background) - show only active
            Positioned(
              left: screenWidth * 0.02,
              bottom: screenHeight * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () { 
                    _audio.playButtonSound(); 
                    setState(() {
                      _isUpperCase = !_isUpperCase;
                      // Progress tour when toggling case on step 1
                      if (_tourStep == 1) {
                        _tourStep = 2;
                        // Auto dismiss after 2 seconds
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _tourStep = -1);
                        });
                      }
                    }); 
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Background papanabc
                          Image.asset(
                            'assets/untukbelajar/alfabet/papanabc.png',
                            height: screenHeight * 0.22,
                          ),
                          // Show only active button with zoom animation
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.01),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.elasticOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Image.asset(
                                _isUpperCase
                                    ? 'assets/untukbelajar/alfabet/tombol huruf besar.png'
                                    : 'assets/untukbelajar/alfabet/tombol huruf kecil.png',
                                key: ValueKey(_isUpperCase),
                                height: screenHeight * 0.12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Semak di bawah papanabc
                      Transform.translate(
                        offset: Offset(0, -screenHeight * 0.03),
                        child: Image.asset(
                          'assets/untukbelajar/alfabet/semak.png',
                          height: screenHeight * 0.08,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Product Tour Overlay
            if (_tourStep >= 0)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
            
            // Tour Step 0: Hand pointing to letter A
            if (_tourStep == 0)
              Positioned(
                bottom: screenHeight * 0.10,
                left: screenWidth * 0.22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _handAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _handAnimation.value),
                          child: child,
                        );
                      },
                      child: Image.asset('assets/untukbelajar/alfabet/hand.png', height: screenHeight * 0.07),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        _tourMessages[0],
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: screenHeight * 0.025,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Tour Step 1: Hand pointing to case toggle (papanabc on left)
            if (_tourStep == 1)
              Positioned(
                left: screenWidth * 0.06,
                bottom: screenHeight * 0.12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _handAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(-_handAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Image.asset('assets/untukbelajar/alfabet/hand.png', height: screenHeight * 0.07),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        _tourMessages[1],
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: screenHeight * 0.025,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Tour Step 2: Completion message
            if (_tourStep == 2)
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Text(
                      _tourMessages[2],
                      style: TextStyle(
                        fontFamily: 'Bangers',
                        fontSize: screenHeight * 0.05,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(double screenWidth, double screenHeight) {
    // Layout: 10 huruf baris 1 (A-J), 10 huruf baris 2 (K-T), 6 huruf baris 3 (U-Z)
    final row1 = List.generate(10, (i) => i);      // 0-9 (A-J)
    final row2 = List.generate(10, (i) => i + 10); // 10-19 (K-T)
    final row3 = List.generate(6, (i) => i + 20);  // 20-25 (U-Z)
    
    Widget buildLetterButton(int index) {
      return GestureDetector(
        onTap: () => _onLetterTap(index),
        child: AnimatedScale(
          scale: _selectedLetterIndex == index ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Image.asset(
            _isUpperCase
                ? 'assets/untukbelajar/alfabet/keyboard_$index.png'
                : 'assets/untukbelajar/alfabet/tombol huruf_$index.png',
            width: screenWidth * 0.052,
            errorBuilder: (context, error, stackTrace) => 
              Container(width: screenWidth * 0.052, height: screenWidth * 0.052, color: Colors.grey),
          ),
        ),
      );
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.012),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: A-J
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row1.map((i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
              child: buildLetterButton(i),
            )).toList(),
          ),
          SizedBox(height: screenHeight * 0.006),
          // Row 2: K-T
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row2.map((i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
              child: buildLetterButton(i),
            )).toList(),
          ),
          SizedBox(height: screenHeight * 0.006),
          // Row 3: U-Z
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row3.map((i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
              child: buildLetterButton(i),
            )).toList(),
          ),
        ],
      ),
    );
  }
}


// Particle class for confetti effect
class Particle {
  double x, y, vx, vy;
  Color color;
  double size;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}
