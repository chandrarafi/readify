import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class PetunjukScreen extends StatefulWidget {
  const PetunjukScreen({super.key});

  @override
  State<PetunjukScreen> createState() => _PetunjukScreenState();
}

class _PetunjukScreenState extends State<PetunjukScreen>
    with SingleTickerProviderStateMixin {
  final _audio = AudioService();
  
  final List<Map<String, dynamic>> _petunjukList = [
    {
      'icon': '📚',
      'title': 'Belajar',
      'desc': 'Pilih menu Belajar untuk belajar alfabet dan kosa kata',
    },
    {
      'icon': '✏️',
      'title': 'Latihan',
      'desc': 'Kerjakan soal latihan untuk mengasah kemampuanmu',
    },
    {
      'icon': '🔊',
      'title': 'Suara',
      'desc': 'Tekan tombol speaker untuk mendengar suara',
    },
    {
      'icon': '⭐',
      'title': 'Histori',
      'desc': 'Lihat nilai latihanmu di menu Histori',
    },
    {
      'icon': '🎵',
      'title': 'Musik',
      'desc': 'Tekan tombol musik untuk nyalakan atau matikan musik',
    },
    {
      'icon': '🏠',
      'title': 'Kembali',
      'desc': 'Tekan tombol panah untuk kembali ke menu sebelumnya',
    },
  ];

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
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
                        colors: [Colors.orange.shade400, Colors.red.shade400],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade900,
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
                          Icons.help_outline,
                          color: Colors.white,
                          size: screenHeight * 0.04,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Cara Main',
                          style: TextStyle(
                            fontFamily: 'SpicySale',
                            fontSize: screenHeight * 0.04,
                            color: Colors.white,
                          ),
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
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  itemCount: _petunjukList.length,
                  itemBuilder: (context, index) {
                    return _buildPetunjukCard(
                      _petunjukList[index],
                      index,
                      screenWidth,
                      screenHeight,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetunjukCard(
    Map<String, dynamic> item,
    int index,
    double screenWidth,
    double screenHeight,
  ) {
    // Warna berbeda untuk setiap card
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

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
              height: screenHeight * 0.13,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5),
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
                  color.withValues(alpha: 0.9),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Row(
              children: [
                // Emoji/Icon besar
                Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
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
                  child: Center(
                    child: Text(
                      item['icon'],
                      style: TextStyle(fontSize: screenHeight * 0.05),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontFamily: 'SpicySale',
                          fontSize: screenHeight * 0.03,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        item['desc'],
                        style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.3,
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
}
