import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../models/score_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _scoreService = ScoreService();
  
  List<ScoreHistory> _history = [];
  bool _isLoading = true;

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _cloud1Controller;
  late AnimationController _cloud2Controller;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
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

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  Future<void> _loadData() async {
    final history = await _scoreService.getHistory();
    setState(() {
      _history = history.take(5).toList(); // Hanya 5 terakhir agar muat
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _bounceController.dispose();
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
                      vertical: sh * 0.012,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.pink.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade900,
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      '⭐ Nilai Kamu ⭐',
                      style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: sh * 0.035,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main papan content
            Positioned(
              top: sh * 0.13,
              left: 0,
              right: 0,
              bottom: sh * 0.12,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : _buildPapanContent(sw, sh),
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

  Widget _buildPapanContent(double sw, double sh) {
    return SizedBox(
      width: sw * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Papan background
          Image.asset(
            'assets/untukbelajar/alfabet/papan.png',
            width: sw * 0.8,
            fit: BoxFit.contain,
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.07,
              vertical: sh * 0.025,
            ),
            child: _history.isEmpty
                ? _buildEmptyContent(sw, sh)
                : _buildHistoryTable(sw, sh),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(double sw, double sh) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('📚', style: TextStyle(fontSize: sh * 0.07)),
        SizedBox(height: sh * 0.01),
        Text(
          'Belum Ada Nilai',
          style: TextStyle(
            fontFamily: 'SpicySale',
            fontSize: sh * 0.03,
            color: Colors.brown.shade800,
          ),
        ),
        Text(
          'Ayo main latihan dulu!',
          style: TextStyle(
            fontFamily: 'SpicySale',
            fontSize: sh * 0.018,
            color: Colors.brown.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTable(double sw, double sh) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.02,
            vertical: sh * 0.006,
          ),
          decoration: BoxDecoration(
            color: Colors.brown.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: sw * 0.06,
                child: Text(
                  'No',
                  style: _headerStyle(sh),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text('Latihan', style: _headerStyle(sh)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Skor',
                  style: _headerStyle(sh),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: sw * 0.1,
                child: Text(
                  '⭐',
                  style: _headerStyle(sh),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.006),
        // Data rows
        ...List.generate(_history.length, (i) {
          return _buildRow(_history[i], i, sw, sh);
        }),
      ],
    );
  }

  Widget _buildRow(ScoreHistory item, int index, double sw, double sh) {
    final percentage = item.percentage;
    final stars = percentage >= 80 ? 3 : percentage >= 60 ? 2 : percentage >= 30 ? 1 : 0;
    final rowColor = index.isEven
        ? Colors.brown.shade100.withValues(alpha: 0.4)
        : Colors.brown.shade200.withValues(alpha: 0.3);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.02,
          vertical: sh * 0.008,
        ),
        decoration: BoxDecoration(
          color: rowColor,
          borderRadius: BorderRadius.circular(6),
          border: Border(
            bottom: BorderSide(
              color: Colors.brown.shade300.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Number
            SizedBox(
              width: sw * 0.06,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'SpicySale',
                  fontSize: sh * 0.02,
                  color: Colors.brown.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Category
            Expanded(
              flex: 3,
              child: Text(
                item.category,
                style: TextStyle(
                  fontFamily: 'SpicySale',
                  fontSize: sh * 0.017,
                  color: Colors.brown.shade700,
                ),
              ),
            ),
            // Score
            Expanded(
              flex: 2,
              child: Text(
                '${item.score}/${item.totalQuestions}',
                style: TextStyle(
                  fontFamily: 'SpicySale',
                  fontSize: sh * 0.02,
                  color: percentage >= 80
                      ? Colors.green.shade700
                      : percentage >= 60
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Stars
            SizedBox(
              width: sw * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: i < stars ? Colors.amber : Colors.brown.shade300,
                    size: sh * 0.02,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle(double sh) {
    return TextStyle(
      fontFamily: 'SpicySale',
      fontSize: sh * 0.016,
      color: Colors.white,
    );
  }
}
