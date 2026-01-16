import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'alfabet_screen.dart';

class MenuScreen extends StatefulWidget {
  final String userName;
  final String userClass;

  const MenuScreen({
    super.key,
    required this.userName,
    required this.userClass,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideMenuAnimation;
  late Animation<Offset> _slideCharacterAnimation;
  late Animation<Offset> _slideCloudAnimation;
  late Animation<double> _scaleAnimation;
  
  final _audio = AudioService();

  bool _isPetunjukPressed = false;
  bool _isBelajarPressed = false;
  bool _isLatihanPressed = false;
  bool _isInformasiPressed = false;
  bool _isExitPressed = false;
  bool _isAlfabetPressed = false;
  bool _isKosaKataPressed = false;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    
    _slideMenuAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack));
    
    _slideCharacterAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack));
    
    _slideCloudAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack));
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    
    _entryController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _entryController.dispose();
    super.dispose();
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
            // Background dari home
            Positioned.fill(
              child: Image.asset('assets/untukhome/bg.png', fit: BoxFit.cover),
            ),
            // Ground dari home
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
            // Exit button
            Positioned(
              top: screenHeight * 0.03,
              right: screenWidth * 0.02,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildAnimatedButton(
                    isPressed: _isExitPressed,
                    onPressChanged: (v) => setState(() => _isExitPressed = v),
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/untukhome/tombol exit.png',
                      height: screenHeight * 0.1,
                    ),
                  ),
                ),
              ),
            ),
            // Menu Title and buttons
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.05,
              child: SlideTransition(
                position: _slideMenuAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.28,
                        child: Text(
                          'MENU',
                          style: TextStyle(
                            fontFamily: 'Bangers',
                            fontSize: screenHeight * 0.1,
                            color: Colors.white,
                            shadows: const [
                              Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildMenuButton(
                        isPressed: _isPetunjukPressed,
                        onPressChanged: (v) => setState(() => _isPetunjukPressed = v),
                        onTap: () => _showComingSoon('Petunjuk Penggunaan'),
                        text: 'petunjuk\npenggunaan',
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.035),
                      _buildMenuButton(
                        isPressed: _isBelajarPressed,
                        onPressChanged: (v) => setState(() => _isBelajarPressed = v),
                        onTap: () => _showBelajarSubmenu(context, screenWidth, screenHeight),
                        text: 'Belajar',
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.035),
                      _buildMenuButton(
                        isPressed: _isLatihanPressed,
                        onPressChanged: (v) => setState(() => _isLatihanPressed = v),
                        onTap: () => _showComingSoon('Latihan'),
                        text: 'Latihan',
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.035),
                      _buildMenuButton(
                        isPressed: _isInformasiPressed,
                        onPressChanged: (v) => setState(() => _isInformasiPressed = v),
                        onTap: () => _showComingSoon('Informasi'),
                        text: 'Informasi',
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Karakter dari home (1 karakter saja)
            Positioned(
              bottom: screenHeight * 0.12,
              right: screenWidth * 0.02,
              child: SlideTransition(
                position: _slideCharacterAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value * 2),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/untukhome/karakter.png',
                      height: screenHeight * 0.65,
                    ),
                  ),
                ),
              ),
            ),
            // Cloud with name
            Positioned(
              top: screenHeight * 0.07,
              right: screenWidth * 0.22,
              child: SlideTransition(
                position: _slideCloudAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/untukmenu/awanisinamadankelas.png', width: screenWidth * 0.28),
                        Transform.translate(
                          offset: Offset(-screenWidth * 0.01, -screenHeight * 0.035),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'halo ${widget.userName}',
                                style: TextStyle(fontFamily: 'Bangers', fontSize: screenHeight * 0.035, color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'dari ${widget.userClass}',
                                style: TextStyle(fontFamily: 'Bangers', fontSize: screenHeight * 0.03, color: Colors.black87),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required bool isPressed,
    required ValueChanged<bool> onPressChanged,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTapDown: (_) { onPressChanged(true); _audio.playButtonSound(); },
      onTapUp: (_) { onPressChanged(false); onTap(); },
      onTapCancel: () => onPressChanged(false),
      child: AnimatedScale(scale: isPressed ? 0.85 : 1.0, duration: const Duration(milliseconds: 150), child: child),
    );
  }

  Widget _buildMenuButton({
    required bool isPressed,
    required ValueChanged<bool> onPressChanged,
    required VoidCallback onTap,
    required String text,
    required double screenHeight,
    required double screenWidth,
  }) {
    return _buildAnimatedButton(
      isPressed: isPressed,
      onPressChanged: onPressChanged,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/untukmenu/tombolmenu.png', width: screenWidth * 0.28, height: screenHeight * 0.12, fit: BoxFit.fill),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: screenHeight * 0.032,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Segera Hadir! 🚀', style: const TextStyle(fontFamily: 'Bangers', fontSize: 16)),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToAlfabet() async {
    // Reverse entry animation for exit effect
    await _entryController.reverse();
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AlfabetScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ).then((_) {
        // Re-animate entry when coming back
        _entryController.forward();
      });
    }
  }

  void _showBelajarSubmenu(BuildContext context, double screenWidth, double screenHeight) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Belajar Submenu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: screenWidth * 0.5,
                  padding: EdgeInsets.all(screenHeight * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'BELAJAR',
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: screenHeight * 0.08,
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4)],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Alfabet button
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Transform.translate(offset: Offset(-50 * (1 - value), 0), child: child),
                          );
                        },
                        child: _buildSubmenuButton(
                          isPressed: _isAlfabetPressed,
                          onPressChanged: (v) => setState(() => _isAlfabetPressed = v),
                          onTap: () { Navigator.pop(context); _navigateToAlfabet(); },
                          text: 'Alfabet',
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      // Kosa Kata button
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Transform.translate(offset: Offset(50 * (1 - value), 0), child: child),
                          );
                        },
                        child: _buildSubmenuButton(
                          isPressed: _isKosaKataPressed,
                          onPressChanged: (v) => setState(() => _isKosaKataPressed = v),
                          onTap: () { Navigator.pop(context); _showComingSoon('Kosa Kata'); },
                          text: 'Kosa Kata',
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Close button
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) => Transform.scale(scale: value, child: child),
                        child: GestureDetector(
                          onTap: () { _audio.playButtonSound(); Navigator.pop(context); },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))],
                            ),
                            child: Text('Kembali', style: TextStyle(fontFamily: 'Bangers', fontSize: screenHeight * 0.03, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmenuButton({
    required bool isPressed,
    required ValueChanged<bool> onPressChanged,
    required VoidCallback onTap,
    required String text,
    required double screenHeight,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTapDown: (_) { onPressChanged(true); _audio.playButtonSound(); },
      onTapUp: (_) { onPressChanged(false); onTap(); },
      onTapCancel: () => onPressChanged(false),
      child: AnimatedScale(
        scale: isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: screenWidth * 0.35,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Bangers',
              fontSize: screenHeight * 0.04,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
