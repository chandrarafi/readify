import 'package:flutter/material.dart';
import 'dart:math';
import '../services/audio_service.dart';

class KosaKataScreen extends StatefulWidget {
  const KosaKataScreen({super.key});

  @override
  State<KosaKataScreen> createState() => _KosaKataScreenState();
}

class _KosaKataScreenState extends State<KosaKataScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  
  // Warna untuk suku kata
  final List<Color> _syllableColors = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];
  
  // Kosa kata data dengan gambar
  final List<Map<String, dynamic>> _duaSuku = [
    {'kata': 'buku', 'suku': ['bu', 'ku'], 'gambar': 'assets/untukbelajar/kosakata/buku.png'},
    {'kata': 'padi', 'suku': ['pa', 'di'], 'gambar': 'assets/untukbelajar/kosakata/padi.png'},
    {'kata': 'topi', 'suku': ['to', 'pi'], 'gambar': 'assets/untukbelajar/kosakata/topi.png'},
    {'kata': 'roda', 'suku': ['ro', 'da'], 'gambar': 'assets/untukbelajar/kosakata/roda.png'},
    {'kata': 'dadu', 'suku': ['da', 'du'], 'gambar': 'assets/untukbelajar/kosakata/dadu.png'},
    {'kata': 'baju', 'suku': ['ba', 'ju'], 'gambar': 'assets/untukbelajar/kosakata/baju.png'},
    {'kata': 'kayu', 'suku': ['ka', 'yu'], 'gambar': 'assets/untukbelajar/kosakata/kayu.png'},
    {'kata': 'tali', 'suku': ['ta', 'li'], 'gambar': 'assets/untukbelajar/kosakata/tali.png'},
    {'kata': 'pita', 'suku': ['pi', 'ta'], 'gambar': 'assets/untukbelajar/kosakata/pita.png'},
    {'kata': 'besi', 'suku': ['be', 'si'], 'gambar': 'assets/untukbelajar/kosakata/besi.png'},
  ];
  
  final List<Map<String, dynamic>> _konsonanAkhir = [
    {'kata': 'bedak', 'suku': ['be', 'dak'], 'gambar': 'assets/untukbelajar/kosakata/bedak.png'},
    {'kata': 'mawar', 'suku': ['ma', 'war'], 'gambar': 'assets/untukbelajar/kosakata/mawar.png'},
    {'kata': 'kasur', 'suku': ['ka', 'sur'], 'gambar': 'assets/untukbelajar/kosakata/kasur.png'},
    {'kata': 'jarum', 'suku': ['ja', 'rum'], 'gambar': 'assets/untukbelajar/kosakata/jaru.png'},
    {'kata': 'gitar', 'suku': ['gi', 'tar'], 'gambar': 'assets/untukbelajar/kosakata/gitar.png'},
    {'kata': 'wajan', 'suku': ['wa', 'jan'], 'gambar': 'assets/untukbelajar/kosakata/panci.png'},
    {'kata': 'pasir', 'suku': ['pa', 'sir'], 'gambar': 'assets/untukbelajar/kosakata/pasir.png'},
    {'kata': 'pagar', 'suku': ['pa', 'gar'], 'gambar': 'assets/untukbelajar/kosakata/pagar.png'},
    {'kata': 'jaket', 'suku': ['ja', 'ket'], 'gambar': 'assets/untukbelajar/kosakata/jaket.png'},
    {'kata': 'tikar', 'suku': ['ti', 'kar'], 'gambar': 'assets/untukbelajar/kosakata/tikar.png'},
  ];
  
  // State
  int _currentCategory = 0;
  int _currentWordIndex = 0;
  bool _showParticles = false;
  List<Particle> _particles = [];
  bool _isLeftPressed = false;
  bool _isRightPressed = false;
  
  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _particleController;
  late AnimationController _bounceController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  List<Map<String, dynamic>> get _currentList => 
      _currentCategory == 0 ? _duaSuku : _konsonanAkhir;
  
  Map<String, dynamic> get _currentWord => _currentList[_currentWordIndex];

  int _speechId = 0; // ID untuk track speech yang sedang berjalan

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  Future<void> _speakWord() async {
    // Increment ID untuk cancel speech sebelumnya
    _speechId++;
    final currentSpeechId = _speechId;
    
    final kata = _currentWord['kata'] as String;
    final suku = _currentWord['suku'] as List<String>;
    
    try {
      // Stop audio sebelumnya dulu
      await _audio.stopSpeech();
      
      // Delay kecil untuk smooth transition
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Cek apakah sudah di-cancel
      if (currentSpeechId != _speechId) return;
      
      // Play suku kata satu per satu dengan delay lebih pendek
      for (var s in suku) {
        // Cek sebelum play
        if (currentSpeechId != _speechId) return;
        
        await _audio.playSyllableSound(s);
        await Future.delayed(const Duration(milliseconds: 600));
        
        // Cek setelah delay
        if (currentSpeechId != _speechId) return;
      }
      
      // Delay sebentar lalu play kata lengkap
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Cek sebelum play kata lengkap
      if (currentSpeechId != _speechId) return;
      
      await _audio.playWordSound(kata);
    } catch (e) {
      debugPrint('Speak error: $e');
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
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _particleController.addListener(() {
      if (_showParticles) setState(() {});
    });
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    _entryController.forward();
  }

  @override
  void dispose() {
    _audio.stopSpeech();
    _entryController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _particleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _spawnParticles() {
    final random = Random();
    _particles = List.generate(30, (index) {
      return Particle(
        x: (random.nextDouble() - 0.5) * 50,
        y: (random.nextDouble() - 0.5) * 30,
        vx: (random.nextDouble() - 0.5) * 280,
        vy: (random.nextDouble() - 0.7) * 220,
        color: _syllableColors[random.nextInt(_syllableColors.length)],
        size: random.nextDouble() * 10 + 5,
      );
    });
    _showParticles = true;
    _particleController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showParticles = false);
    });
  }

  void _nextWord() {
    // Stop audio sebelumnya
    _audio.stopSpeech();
    _audio.playButtonSound();
    setState(() {
      _currentWordIndex = (_currentWordIndex + 1) % _currentList.length;
    });
    _spawnParticles();
    _speakWord();
  }

  void _prevWord() {
    // Stop audio sebelumnya
    _audio.stopSpeech();
    _audio.playButtonSound();
    setState(() {
      _currentWordIndex = (_currentWordIndex - 1 + _currentList.length) % _currentList.length;
    });
    _spawnParticles();
    _speakWord();
  }

  void _switchCategory(int category) {
    if (_currentCategory != category) {
      // Stop audio sebelumnya
      _audio.stopSpeech();
      _audio.playButtonSound();
      setState(() {
        _currentCategory = category;
        _currentWordIndex = 0;
      });
      _spawnParticles();
    }
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
            
            // Animated clouds
            AnimatedBuilder(
              animation: _cloud1Controller,
              builder: (context, child) {
                return Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * (_cloud1Controller.value * 1.5 - 0.3),
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset('assets/untukbelajar/alfabet/awan 1.png', height: screenHeight * 0.1),
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
                    child: Image.asset('assets/untukbelajar/alfabet/awan 2.png', height: screenHeight * 0.08),
                  ),
                );
              },
            ),
            
            // Back button using alfabet asset
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    _audio.stopSpeech();
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
            
            // Category tabs 3D
            Positioned(
              top: screenHeight * 0.03,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _build3DCategoryTab('kv-kv', 0, Colors.green, screenWidth, screenHeight),
                    SizedBox(width: screenWidth * 0.03),
                    _build3DCategoryTab('kv-kvk', 1, Colors.purple, screenWidth, screenHeight),
                  ],
                ),
              ),
            ),
            
            // Main content - Papan with word and image
            Positioned(
              top: screenHeight * 0.12,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Papan background
                      Image.asset(
                        'assets/untukbelajar/alfabet/papan.png',
                        height: screenHeight * 0.52,
                      ),
                      // Word display with image - centered content
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image with bounce animation + speaker button
                            AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _bounceAnimation.value * 0.5),
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: _speakWord,
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(screenHeight * 0.01),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Image.asset(
                                        _currentWord['gambar'],
                                        height: screenHeight * 0.12,
                                        errorBuilder: (context, error, stackTrace) => 
                                    Container(height: screenHeight * 0.12),
                                      ),
                                    ),
                                    // Speaker icon overlay
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(screenHeight * 0.008),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.volume_up_rounded,
                                          color: Colors.white,
                                          size: screenHeight * 0.025,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            // Full word with rainbow effect
                            _buildRainbowText(
                              _currentWord['kata'].toUpperCase(),
                              screenHeight * 0.055,
                            ),
                            SizedBox(height: screenHeight * 0.012),
                            // Syllables with 3D effect
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                (_currentWord['suku'] as List<String>).length,
                                (index) {
                                  final suku = (_currentWord['suku'] as List<String>)[index];
                                  final color = _syllableColors[index % _syllableColors.length];
                                  return _build3DSyllable(suku, color, screenWidth, screenHeight);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Navigation arrows using alfabet assets
            Positioned(
              left: screenWidth * 0.12,
              top: screenHeight * 0.34,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: _prevWord,
                  child: Image.asset(
                    'assets/untukbelajar/alfabet/navigasi menyusun_kiri.png',
                    height: screenHeight * 0.1,
                  ),
                ),
              ),
            ),
            Positioned(
              right: screenWidth * 0.12,
              top: screenHeight * 0.34,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: _nextWord,
                  child: Image.asset(
                    'assets/untukbelajar/alfabet/navigasi menyusun_kanan.png',
                    height: screenHeight * 0.1,
                  ),
                ),
              ),
            ),
            
            // Word counter 3D
            Positioned(
              bottom: screenHeight * 0.22,
              left: 0, right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.012,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.amber.shade300, Colors.orange.shade400],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.orange.shade600, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.shade900, offset: const Offset(0, 4), blurRadius: 0),
                        BoxShadow(color: Colors.black26, offset: const Offset(0, 6), blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      '${_currentWordIndex + 1} / ${_currentList.length}',
                      style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: screenHeight * 0.035,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Particles
            if (_showParticles)
              ...(_particles.map((p) {
                final progress = _particleController.value;
                final x = p.x + p.vx * progress;
                final y = p.y + p.vy * progress + 80 * progress * progress;
                final opacity = (1 - progress).clamp(0.0, 1.0);
                return Positioned(
                  left: screenWidth * 0.5 + x - p.size / 2,
                  top: screenHeight * 0.35 + y - p.size / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [p.color.withValues(alpha: 0.8), p.color],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: p.color.withValues(alpha: 0.5), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }

  Widget _buildRainbowText(String text, double fontSize) {
    // Hanya 2 warna bergantian
    final colors = [Colors.red, Colors.blue];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: text.split('').asMap().entries.map((entry) {
        final color = colors[entry.key % 2];
        return Text(
          entry.value,
          style: TextStyle(
            fontFamily: 'SpicySale',
            fontSize: fontSize,
            color: color,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.5), offset: const Offset(2, 2), blurRadius: 4),
              const Shadow(color: Colors.black26, offset: Offset(3, 3), blurRadius: 6),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _build3DSyllable(String suku, Color color, double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.9), color],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.8), offset: const Offset(0, 5), blurRadius: 0),
            BoxShadow(color: Colors.black38, offset: const Offset(0, 8), blurRadius: 10),
          ],
        ),
        child: Text(
          suku.toUpperCase(),
          style: TextStyle(
            fontFamily: 'SpicySale',
            fontSize: screenHeight * 0.05,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
            ],
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
            BoxShadow(color: color.withValues(alpha: 0.8), offset: const Offset(0, 4), blurRadius: 0),
            BoxShadow(color: Colors.black26, offset: const Offset(0, 6), blurRadius: 8),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _build3DCategoryTab(String title, int index, Color color, double screenWidth, double screenHeight) {
    final isActive = _currentCategory == index;
    final activeColor = isActive ? color : Colors.grey.shade400;
    
    return GestureDetector(
      onTap: () => _switchCategory(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive 
                ? [color.withValues(alpha: 0.9), color]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.white.withValues(alpha: 0.5) : Colors.grey.shade500,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.7),
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
          title,
          style: TextStyle(
            fontFamily: 'SpicySale',
            fontSize: screenHeight * 0.028,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DNavButton({
    required VoidCallback onTap,
    required ValueChanged<bool> onPressChanged,
    required bool isPressed,
    required IconData icon,
    required Color color,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressChanged(true),
      onTapUp: (_) { onPressChanged(false); onTap(); },
      onTapCancel: () => onPressChanged(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, isPressed ? 4 : 0, 0),
        child: Container(
          width: screenHeight * 0.1,
          height: screenHeight * 0.1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.9), Color.lerp(color, Colors.black, 0.2)!],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
            boxShadow: isPressed ? [] : [
              BoxShadow(color: Color.lerp(color, Colors.black, 0.4)!, offset: const Offset(0, 5), blurRadius: 0),
              BoxShadow(color: Colors.black26, offset: const Offset(0, 8), blurRadius: 10),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: screenHeight * 0.07),
        ),
      ),
    );
  }
}

// Particle class
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
