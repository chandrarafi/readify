import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_service.dart';
import 'screens/input_name_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio first
  await AudioService().init();
  AudioService().playBgm();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    runApp(const ReadifyApp());
  });
}

class ReadifyApp extends StatelessWidget {
  const ReadifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Readify - Belajar Kosakata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  final _audio = AudioService();

  bool _isPlayPressed = false;
  bool _isMenuPressed = false;
  bool _isExitPressed = false;
  bool _isSoundPressed = false;
  bool _isVideoPressed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _goToInputName() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InputNameScreen()),
    );
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
          fit: StackFit.expand,
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
                height: screenHeight * 0.18,
              ),
            ),
            Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.03,
                  left: screenWidth * 0.02,
                  child: _buildAnimatedButton(
                    isPressed: _isMenuPressed,
                    onPressChanged: (v) => setState(() => _isMenuPressed = v),
                    onTap: () => _showComingSoon(context, 'Menu'),
                    child: Image.asset(
                      'assets/Sprite/tombol orang tua.png',
                      height: screenHeight * 0.12,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.03,
                  right: screenWidth * 0.02,
                  child: _buildAnimatedButton(
                    isPressed: _isExitPressed,
                    onPressChanged: (v) => setState(() => _isExitPressed = v),
                    onTap: () => _showExitDialog(context),
                    child: Image.asset(
                      'assets/untukhome/tombol exit.png',
                      height: screenHeight * 0.12,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFloatingLetter(0, 'assets/untukhome/huruf kecil_r.png', screenHeight * 0.14),
                      _buildFloatingLetter(1, 'assets/untukhome/huruf kecil_e.png', screenHeight * 0.14),
                      _buildFloatingLetter(2, 'assets/untukhome/huruf kecil_a.png', screenHeight * 0.14),
                      _buildFloatingLetter(3, 'assets/untukhome/huruf kecil_d.png', screenHeight * 0.14),
                      _buildFloatingLetter(4, 'assets/untukhome/huruf kecil_i.png', screenHeight * 0.14),
                      _buildFloatingLetter(5, 'assets/untukhome/huruf kecil_f.png', screenHeight * 0.14),
                      _buildFloatingLetter(6, 'assets/untukhome/huruf kecil_y.png', screenHeight * 0.14),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.52,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildAnimatedButton(
                      isPressed: _isPlayPressed,
                      onPressChanged: (v) => setState(() => _isPlayPressed = v),
                      onTap: _goToInputName,
                      child: Image.asset(
                        'assets/untukhome/button_play.png',
                        height: screenHeight * 0.18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.12,
                  right: screenWidth * 0.02,
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
                Positioned(
                  bottom: screenHeight * 0.05,
                  right: screenWidth * 0.12,
                  child: _buildAnimatedButton(
                    isPressed: _isSoundPressed,
                    onPressChanged: (v) => setState(() => _isSoundPressed = v),
                    onTap: () {
                      _audio.toggleBgm();
                      setState(() {});
                    },
                    child: Opacity(
                      opacity: _audio.isBgmPlaying ? 1.0 : 0.5,
                      child: Image.asset(
                        'assets/untukhome/tombol sound.png',
                        height: screenHeight * 0.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.05,
                  right: screenWidth * 0.03,
                  child: _buildAnimatedButton(
                    isPressed: _isVideoPressed,
                    onPressChanged: (v) => setState(() => _isVideoPressed = v),
                    onTap: () => _showComingSoon(context, 'Video'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tv,
                        size: screenHeight * 0.08,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
              ],
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
      onTapDown: (_) {
        onPressChanged(true);
        _audio.playButtonSound();
      },
      onTapUp: (_) {
        onPressChanged(false);
        onTap();
      },
      onTapCancel: () => onPressChanged(false),
      child: AnimatedScale(
        scale: isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: child,
      ),
    );
  }

  Widget _buildFloatingLetter(int index, String asset, double height) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final offset = (index % 2 == 0 ? 1 : -1) * _bounceAnimation.value * 1.5;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(asset, height: height),
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Segera Hadir! 🚀',
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
        ),
        backgroundColor: const Color(0xFF2196F3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Sprite/bg exit.png', height: 120),
              const SizedBox(height: 16),
              const Text(
                'Yakin mau keluar?',
                style: TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 24,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DialogButton(
                    asset: 'assets/Sprite/tombol merah.png',
                    onTap: () {
                      _audio.playButtonSound();
                      Navigator.pop(context);
                    },
                  ),
                  _DialogButton(
                    asset: 'assets/Sprite/tombol 1.png',
                    onTap: () {
                      _audio.playButtonSound();
                      Navigator.pop(context);
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final String asset;
  final VoidCallback onTap;

  const _DialogButton({required this.asset, required this.onTap});

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Image.asset(widget.asset, height: 50),
      ),
    );
  }
}
