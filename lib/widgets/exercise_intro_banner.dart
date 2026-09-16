import 'dart:async';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// Pop-up intro banner interaktif saat pengguna masuk ke halaman latihan
class ExerciseIntroBanner extends StatefulWidget {
  final String title;
  final String instruction;
  final String emoji;
  final Color primaryColor;
  final String audioAsset;
  final VoidCallback onFinished;

  const ExerciseIntroBanner({
    super.key,
    required this.title,
    required this.instruction,
    this.emoji = '🎯',
    required this.primaryColor,
    required this.audioAsset,
    required this.onFinished,
  });

  @override
  State<ExerciseIntroBanner> createState() => _ExerciseIntroBannerState();
}

class _ExerciseIntroBannerState extends State<ExerciseIntroBanner>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;
  final _audio = AudioService();
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    _entryController.forward();

    // Memutar audio instruksi
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_isDismissing) {
        _audio.playAudio(widget.audioAsset);
      }
    });

    // Otomatis menutup setelah 5.8 detik (tambah 1 detik)
    _autoDismissTimer = Timer(const Duration(milliseconds: 5800), () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _autoDismissTimer?.cancel();

    _entryController.reverse().then((_) {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Darkened background barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),

        // Animated Card Banner
        Center(
          child: AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: sw * 0.75,
                      padding: EdgeInsets.all(sh * 0.03),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.primaryColor,
                            Color.lerp(widget.primaryColor, Colors.orangeAccent, 0.4) ?? widget.primaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header: Emoji & Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (_pulseController.value * 0.15),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(sh * 0.015),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.emoji,
                                    style: TextStyle(fontSize: sh * 0.05),
                                  ),
                                ),
                              ),
                              SizedBox(width: sw * 0.02),
                              Flexible(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontFamily: 'Bangers',
                                    fontSize: sh * 0.065,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: sh * 0.02),

                          // Instruction box with audio wave icon
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.03,
                              vertical: sh * 0.018,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Icon(
                                      Icons.volume_up_rounded,
                                      color: widget.primaryColor,
                                      size: sh * 0.045 + (_pulseController.value * 4),
                                    );
                                  },
                                ),
                                SizedBox(width: sw * 0.02),
                                Expanded(
                                  child: Text(
                                    widget.instruction,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: sh * 0.028,
                                      color: Colors.grey.shade900,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sh * 0.025),

                          // Action button "Ayo Mulai! 🚀"
                          GestureDetector(
                            onTap: () {
                              _audio.playButtonSound();
                              _dismiss();
                            },
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.05),
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.05,
                                  vertical: sh * 0.014,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ayo Mulai! 🚀',
                                      style: TextStyle(
                                        fontFamily: 'Bangers',
                                        fontSize: sh * 0.036,
                                        color: Colors.white,
                                        letterSpacing: 1.1,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black38,
                                            offset: Offset(1, 2),
                                            blurRadius: 3,
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
