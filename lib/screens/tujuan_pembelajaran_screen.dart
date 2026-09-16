import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class TujuanPembelajaranScreen extends StatefulWidget {
  const TujuanPembelajaranScreen({super.key});

  @override
  State<TujuanPembelajaranScreen> createState() => _TujuanPembelajaranScreenState();
}

class _TujuanPembelajaranScreenState extends State<TujuanPembelajaranScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: sw,
        height: sh,
        child: Stack(
          children: [
            // Background sky
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

            // Main content card / board
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: _buildContentBoard(sw, sh),
                  ),
                ),
              ),
            ),

            // Back button (top-left)
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
                    errorBuilder: (c, e, s) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade700,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: sh * 0.04),
                    ),
                  ),
                ),
              ),
            ),

            // Title at top
            Positioned(
              top: sh * 0.03,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    'TUJUAN PEMBELAJARAN',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: sh * 0.075,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(2, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Character at bottom right
            Positioned(
              bottom: sh * 0.10,
              right: sw * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value * 0.8),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/untukhome/karakter.png',
                    height: sh * 0.38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBoard(double sw, double sh) {
    return Container(
      width: sw * 0.72,
      height: sh * 0.70,
      margin: EdgeInsets.only(top: sh * 0.10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Cream background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8D6E63), width: 6), // Wooden brown border
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: CAPAIAN PEMBELAJARAN ---
              _buildSectionHeader(
                icon: Icons.track_changes_rounded,
                title: 'CAPAIAN PEMBELAJARAN',
                color: const Color(0xFF0288D1),
                sh: sh,
              ),
              SizedBox(height: sh * 0.015),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sh * 0.025),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFB3E5FC), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Membaca kata-kata sederhana dengan fasih dari bacaan dan/atau tayangan yang dipirsa tentang diri, keluarga, kesehatan, dan/atau lingkungan sekitar; dan memahami isi bacaan dan/atau tayangan yang dipirsa tentang diri, keluarga, kesehatan, dan/atau lingkungan sekitar.',
                  style: TextStyle(
                    fontSize: sh * 0.034,
                    height: 1.4,
                    color: const Color(0xFF263238),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: sh * 0.03),

              // --- SECTION 2: TUJUAN PEMBELAJARAN ---
              _buildSectionHeader(
                icon: Icons.stars_rounded,
                title: 'TUJUAN PEMBELAJARAN',
                color: const Color(0xFF43A047),
                sh: sh,
              ),
              SizedBox(height: sh * 0.015),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sh * 0.025),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Setelah menggunakan media pembelajaran ini, peserta didik diharapkan dapat membaca kata-kata sederhana dengan fasih dari bacaan yang dipirsa.',
                  style: TextStyle(
                    fontSize: sh * 0.036,
                    height: 1.5,
                    color: const Color(0xFF263238),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required double sh,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: sh * 0.04),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: sh * 0.04,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
