import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class PetunjukScreen extends StatefulWidget {
  const PetunjukScreen({super.key});

  @override
  State<PetunjukScreen> createState() => _PetunjukScreenState();
}

class _PetunjukScreenState extends State<PetunjukScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  
  final List<Map<String, dynamic>> _tourSteps = [
    {
      'icon': '👋',
      'title': 'Halo!',
      'desc': 'Ayo belajar cara main!',
      'color': Colors.blue,
    },
    {
      'icon': '📚',
      'title': 'Belajar Huruf',
      'desc': 'Tekan BELAJAR untuk belajar A sampai Z',
      'color': Colors.green,
      'bigIcon': Icons.school,
    },
    {
      'icon': '🔊',
      'title': 'Dengar Suara',
      'desc': 'Tekan tombol SPEAKER untuk dengar suara',
      'color': Colors.orange,
      'bigIcon': Icons.volume_up,
    },
    {
      'icon': '✏️',
      'title': 'Main Kuis',
      'desc': 'Tekan LATIHAN untuk main kuis seru!',
      'color': Colors.purple,
      'bigIcon': Icons.quiz,
    },
    {
      'icon': '⭐',
      'title': 'Lihat Nilai',
      'desc': 'Tekan HISTORI untuk lihat nilaimu',
      'color': Colors.pink,
      'bigIcon': Icons.star,
    },
    {
      'icon': '🎵',
      'title': 'Musik',
      'desc': 'Tekan tombol MUSIK untuk nyalakan/matikan',
      'color': Colors.teal,
      'bigIcon': Icons.music_note,
    },
    {
      'icon': '🏠',
      'title': 'Kembali',
      'desc': 'Tekan PANAH untuk kembali',
      'color': Colors.red,
      'bigIcon': Icons.arrow_back,
    },
    {
      'icon': '🎉',
      'title': 'Siap!',
      'desc': 'Sekarang kamu sudah bisa main!',
      'color': Colors.amber,
    },
  ];

  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _entryController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initAnimations();
  }

  void _initAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _tourSteps.length - 1) {
      _audio.playButtonSound();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _audio.playButtonSound();
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _audio.playButtonSound();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        child: Stack(
          children: [
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

            // Skip button
            Positioned(
              top: screenHeight * 0.03,
              right: screenWidth * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    _audio.playButtonSound();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: screenHeight * 0.02,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page indicator
            Positioned(
              top: screenHeight * 0.03,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _tourSteps.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentStep == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentStep == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              top: screenHeight * 0.1,
              left: 0,
              right: 0,
              bottom: screenHeight * 0.2,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                  _audio.playButtonSound();
                },
                itemCount: _tourSteps.length,
                itemBuilder: (context, index) {
                  return _buildTourStep(
                    _tourSteps[index],
                    screenWidth,
                    screenHeight,
                  );
                },
              ),
            ),

            // Navigation buttons
            Positioned(
              bottom: screenHeight * 0.22,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      if (_currentStep > 0)
                        _buildNavButton(
                          icon: Icons.arrow_back,
                          onTap: _prevStep,
                          color: Colors.grey,
                          screenHeight: screenHeight,
                        )
                      else
                        SizedBox(width: screenHeight * 0.08),

                      // Next/Finish button
                      _buildNavButton(
                        icon: _currentStep == _tourSteps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        onTap: _nextStep,
                        color: Colors.green,
                        screenHeight: screenHeight,
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

  Widget _buildTourStep(
    Map<String, dynamic> step,
    double screenWidth,
    double screenHeight,
  ) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        padding: EdgeInsets.all(screenWidth * 0.08),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji BESAR
            Text(
              step['icon'],
              style: TextStyle(fontSize: screenHeight * 0.15),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Title BESAR
            Text(
              step['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpicySale',
                fontSize: screenHeight * 0.05,
                color: step['color'],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Description BESAR dan JELAS
            Text(
              step['desc'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenHeight * 0.03,
                color: Colors.grey.shade800,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Icon besar untuk visual
            if (step['bigIcon'] != null) ...[
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: EdgeInsets.all(screenHeight * 0.03),
                decoration: BoxDecoration(
                  color: step['color'].withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['bigIcon'],
                  size: screenHeight * 0.08,
                  color: step['color'],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenHeight * 0.08,
        height: screenHeight * 0.08,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
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
        child: Icon(
          icon,
          color: Colors.white,
          size: screenHeight * 0.04,
        ),
      ),
    );
  }
}
