import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class InformasiScreen extends StatefulWidget {
  const InformasiScreen({super.key});

  @override
  State<InformasiScreen> createState() => _InformasiScreenState();
}

class _InformasiScreenState extends State<InformasiScreen>
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
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

            // Main content — Profile card
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Center(
                    child: _buildProfileCard(sw, sh),
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
              top: sh * 0.04,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    'INFORMASI',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: sh * 0.07,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            color: Colors.black38,
                            offset: Offset(2, 3),
                            blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Character
            Positioned(
              bottom: sh * 0.12,
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
                    height: sh * 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(double sw, double sh) {
    return SizedBox(
      width: sw * 0.55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Papan background (like alfabet screen)
          Image.asset(
            'assets/untukbelajar/alfabet/papan.png',
            width: sw * 0.55,
            fit: BoxFit.contain,
          ),
          // Info content on top of papan
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.06,
              vertical: sh * 0.04,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info rows
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nama',
                  value: 'Sukma Ramadhani',
                  color: Colors.blue,
                  sw: sw,
                  sh: sh,
                ),
                SizedBox(height: sh * 0.012),
                _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'NIM',
                  value: '22003152',
                  color: Colors.green,
                  sw: sw,
                  sh: sh,
                ),
                SizedBox(height: sh * 0.012),
                _buildInfoRow(
                  icon: Icons.school_outlined,
                  label: 'Program Studi',
                  value: 'Pendidikan Luar Biasa',
                  color: Colors.purple,
                  sw: sw,
                  sh: sh,
                ),
                SizedBox(height: sh * 0.012),
                _buildInfoRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Kampus',
                  value: 'Universitas Negeri Padang',
                  color: Colors.red,
                  sw: sw,
                  sh: sh,
                ),
                SizedBox(height: sh * 0.025),

                // App info footer
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sh * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.brown.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          size: sh * 0.025, color: Colors.orange.shade400),
                      SizedBox(width: sw * 0.01),
                      Text(
                        'Readify App',
                        style: TextStyle(
                          fontFamily: 'SpicySale',
                          fontSize: sh * 0.022,
                          color: Colors.brown.shade700,
                        ),
                      ),
                      SizedBox(width: sw * 0.01),
                      Text(
                        '• v1.0',
                        style: TextStyle(
                          fontSize: sh * 0.018,
                          color: Colors.brown.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double sw,
    required double sh,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sh * 0.01),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: EdgeInsets.all(sh * 0.008),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: sh * 0.025, color: color),
          ),
          SizedBox(width: sw * 0.015),
          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: sh * 0.016,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'SpicySale',
                    fontSize: sh * 0.022,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
