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
    with SingleTickerProviderStateMixin {
  final _audio = AudioService();
  final _scoreService = ScoreService();
  
  List<ScoreHistory> _history = [];
  bool _isLoading = true;

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadData();
  }

  void _initAnimation() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  Future<void> _loadData() async {
    final history = await _scoreService.getHistory();
    
    setState(() {
      _history = history.take(10).toList(); // Ambil 10 terakhir saja
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
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
                  child: Image.asset(
                    'assets/untukbelajar/alfabet/navigasi_0.png',
                    height: screenHeight * 0.1,
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: screenHeight * 0.03,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.pink.shade400],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade900,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: screenHeight * 0.04,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Nilai Kamu',
                          style: TextStyle(
                            fontFamily: 'SpicySale',
                            fontSize: screenHeight * 0.04,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: screenHeight * 0.04,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              bottom: screenHeight * 0.2,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : _history.isEmpty
                        ? _buildEmptyState(screenWidth, screenHeight)
                        : _buildHistoryList(screenWidth, screenHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.08),
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '😊',
              style: TextStyle(fontSize: screenHeight * 0.1),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Belum Ada Nilai',
              style: TextStyle(
                fontFamily: 'SpicySale',
                fontSize: screenHeight * 0.035,
                color: Colors.brown.shade800,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Ayo main latihan dulu!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenHeight * 0.022,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(double screenWidth, double screenHeight) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(
          _history[index],
          index,
          screenWidth,
          screenHeight,
        );
      },
    );
  }

  Widget _buildHistoryCard(
    ScoreHistory item,
    int index,
    double screenWidth,
    double screenHeight,
  ) {
    final percentage = item.percentage;
    
    // Emoji dan warna berdasarkan nilai
    String emoji;
    Color cardColor;
    String message;
    
    if (percentage >= 80) {
      emoji = '🌟';
      cardColor = Colors.green;
      message = 'Hebat!';
    } else if (percentage >= 60) {
      emoji = '😊';
      cardColor = Colors.blue;
      message = 'Bagus!';
    } else {
      emoji = '💪';
      cardColor = Colors.orange;
      message = 'Semangat!';
    }

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Stack(
        children: [
          // Shadow
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.12,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Card
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cardColor.withValues(alpha: 0.9),
                  cardColor,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Row(
              children: [
                // Emoji besar
                Text(
                  emoji,
                  style: TextStyle(fontSize: screenHeight * 0.06),
                ),
                SizedBox(width: screenWidth * 0.04),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'SpicySale',
                          fontSize: screenHeight * 0.03,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        '${item.score} dari ${item.totalQuestions} benar',
                        style: TextStyle(
                          fontSize: screenHeight * 0.022,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Score besar
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '$percentage',
                    style: TextStyle(
                      fontFamily: 'SpicySale',
                      fontSize: screenHeight * 0.035,
                      color: cardColor,
                    ),
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
