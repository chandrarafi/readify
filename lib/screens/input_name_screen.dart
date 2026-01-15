import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';
import 'menu_screen.dart';

class InputNameScreen extends StatefulWidget {
  const InputNameScreen({super.key});

  @override
  State<InputNameScreen> createState() => _InputNameScreenState();
}

class _InputNameScreenState extends State<InputNameScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _audio = AudioService();
  bool _isButtonPressed = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  Future<void> _saveData() async {
    if (_nameController.text.isEmpty || _classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Nama dan Kelas harus diisi!',
            style: TextStyle(fontFamily: 'Bangers', fontSize: 16),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Show loading
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_class', _classController.text);
    
    // Precache gambar menu screen
    await precacheImage(const AssetImage('assets/untukmenu/bg.png'), context);
    await precacheImage(const AssetImage('assets/untukmenu/awanisinamadankelas.png'), context);
    await precacheImage(const AssetImage('assets/untukmenu/karakter1.png'), context);
    await precacheImage(const AssetImage('assets/untukmenu/karakter2.png'), context);
    await precacheImage(const AssetImage('assets/untukmenu/tombolmenu.png'), context);
    
    if (!mounted) return;
    
    // Navigate to menu screen with data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MenuScreen(
          userName: _nameController.text,
          userClass: _classController.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _animController.dispose();
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
          fit: StackFit.expand,
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/untukisinama/background.png',
                fit: BoxFit.cover,
              ),
            ),

            // Form popup with animation
            Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Popup background
                        Image.asset(
                          'assets/untukisinama/popupform.png',
                          width: screenWidth * 0.6,
                          fit: BoxFit.contain,
                        ),

                        // Form content
                        Container(
                          width: screenWidth * 0.45,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                'Isi Data Kamu',
                                style: TextStyle(
                                  fontFamily: 'Bangers',
                                  fontSize: screenHeight * 0.08,
                                  color: const Color(0xFF5D4037),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),

                              // Name field
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Nama',
                                screenHeight: screenHeight,
                              ),
                              SizedBox(height: screenHeight * 0.02),

                              // Class field
                              _buildTextField(
                                controller: _classController,
                                hint: 'Kelas',
                                screenHeight: screenHeight,
                              ),
                              SizedBox(height: screenHeight * 0.04),

                              // Submit button
                              GestureDetector(
                                onTapDown: (_) {
                                  setState(() => _isButtonPressed = true);
                                  _audio.playButtonSound();
                                },
                                onTapUp: (_) {
                                  setState(() => _isButtonPressed = false);
                                  _saveData();
                                },
                                onTapCancel: () =>
                                    setState(() => _isButtonPressed = false),
                                child: AnimatedScale(
                                  scale: _isButtonPressed ? 0.9 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Image.asset(
                                    'assets/untukisinama/tombol mulai.png',
                                    height: screenHeight * 0.12,
                                  ),
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
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Memuat...',
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: screenHeight * 0.05,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double screenHeight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'Anton',
          fontSize: screenHeight * 0.045,
          color: const Color(0xFF5D4037),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Anton',
            fontSize: screenHeight * 0.045,
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: screenHeight * 0.02,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
