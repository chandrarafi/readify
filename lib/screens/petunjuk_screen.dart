import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../widgets/tour_overlay.dart';

/// Petunjuk screen that shows cloned versions of real screens
/// with driver.js-style spotlight overlay tour on each.
class PetunjukScreen extends StatefulWidget {
  const PetunjukScreen({super.key});

  @override
  State<PetunjukScreen> createState() => _PetunjukScreenState();
}

class _PetunjukScreenState extends State<PetunjukScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();

  int _currentScreenIndex = 0;
  bool _isTourActive = true;

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  final List<String> _screenLabels = [
    'Menu Utama',
    'Belajar Alfabet',
    'Belajar Kosa Kata',
    'Latihan',
  ];

  // ============ GlobalKeys for Menu mockup ============
  final _menuKeyBelajar = GlobalKey();
  final _menuKeyLatihan = GlobalKey();
  final _menuKeyHistori = GlobalKey();
  final _menuKeyPetunjuk = GlobalKey();
  final _menuKeyKarakter = GlobalKey();

  // ============ GlobalKeys for Alfabet mockup ============
  final _alfKeyPapan = GlobalKey();
  final _alfKeyKeyboard = GlobalKey();
  final _alfKeyCaseToggle = GlobalKey();
  final _alfKeyBack = GlobalKey();

  // ============ GlobalKeys for Kosakata mockup ============
  final _kosKeyCategory = GlobalKey();
  final _kosKeyPapan = GlobalKey();
  final _kosKeySpeaker = GlobalKey();
  final _kosKeySyllable = GlobalKey();
  final _kosKeyNav = GlobalKey();

  // ============ GlobalKeys for Latihan mockup ============
  final _latKeyTitle = GlobalKey();
  final _latKeyScore = GlobalKey();
  final _latKeySoal = GlobalKey();
  final _latKeySpeaker = GlobalKey();
  final _latKeyPilihan = GlobalKey();

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isTourActive = true);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  List<TourStep> _getStepsForScreen(int index) {
    switch (index) {
      case 0:
        return [
          TourStep(
            targetKey: _menuKeyPetunjuk,
            title: 'Petunjuk Penggunaan',
            description:
                'Tekan tombol ini kapan saja untuk melihat panduan cara menggunakan aplikasi Readify.',
            emoji: '❓',
            color: Color(0xFF9C27B0),
          ),
          TourStep(
            targetKey: _menuKeyBelajar,
            title: 'Belajar',
            description:
                'Pilih materi belajar! Ada 2 pilihan: Alfabet untuk mengenal huruf A-Z, dan Kosa Kata untuk belajar kata-kata baru.',
            emoji: '📚',
            color: Color(0xFF4CAF50),
          ),
          TourStep(
            targetKey: _menuKeyLatihan,
            title: 'Latihan',
            description:
                'Uji kemampuan membacamu! Dengarkan suara kata lalu pilih jawaban yang benar. Kumpulkan skor!',
            emoji: '✏️',
            color: Color(0xFFFF9800),
          ),
          TourStep(
            targetKey: _menuKeyHistori,
            title: 'Histori Nilai',
            description:
                'Lihat semua nilai dari kuis yang pernah kamu kerjakan. Pantau apakah nilaimu semakin meningkat!',
            emoji: '⭐',
            color: Color(0xFFE91E63),
          ),
        ];
      case 1:
        return [
          TourStep(
            targetKey: _alfKeyPapan,
            title: 'Papan Huruf',
            description:
                'Di sini huruf yang kamu pilih akan ditampilkan dengan ukuran besar. Tekan huruf di keyboard bawah untuk menampilkannya.',
            emoji: '🔤',
            color: Color(0xFF4CAF50),
          ),
          TourStep(
            targetKey: _alfKeyKeyboard,
            title: 'Keyboard Huruf',
            description:
                'Tekan huruf A-Z di sini untuk memilih huruf yang ingin dipelajari. Suara huruf akan terdengar otomatis!',
            emoji: '⌨️',
            color: Color(0xFF2196F3),
          ),
          TourStep(
            targetKey: _alfKeyCaseToggle,
            title: 'Huruf Besar / Kecil',
            description:
                'Tekan tombol ini untuk beralih antara huruf BESAR (ABC) dan huruf kecil (abc).',
            emoji: '🔠',
            color: Color(0xFFFF9800),
          ),
          TourStep(
            targetKey: _alfKeyBack,
            title: 'Kembali',
            description:
                'Tekan tombol ini untuk kembali ke halaman Menu utama.',
            emoji: '⬅️',
            color: Color(0xFF795548),
          ),
        ];
      case 2:
        return [
          TourStep(
            targetKey: _kosKeyCategory,
            title: 'Pilih Kategori',
            description:
                'Pilih kategori suku kata: KV-KV (seperti bu-ku) atau KV-KVK (seperti ka-sur). Tekan tab untuk beralih.',
            emoji: '📂',
            color: Color(0xFF9C27B0),
          ),
          TourStep(
            targetKey: _kosKeyPapan,
            title: 'Gambar & Kata',
            description:
                'Di sini ditampilkan gambar dan kata yang sedang dipelajari. Kata ditampilkan besar dan berwarna.',
            emoji: '🖼️',
            color: Color(0xFF4CAF50),
          ),
          TourStep(
            targetKey: _kosKeySpeaker,
            title: 'Dengar Pengucapan',
            description:
                'Tekan gambar atau ikon speaker untuk mendengar cara membaca suku kata dan kata lengkapnya.',
            emoji: '🔊',
            color: Color(0xFFFF9800),
          ),
          TourStep(
            targetKey: _kosKeySyllable,
            title: 'Suku Kata Berwarna',
            description:
                'Setiap kata dipecah menjadi suku kata dengan warna berbeda untuk memudahkan membaca. Contoh: BU - KU.',
            emoji: '🧩',
            color: Color(0xFFE91E63),
          ),
          TourStep(
            targetKey: _kosKeyNav,
            title: 'Ganti Kata',
            description:
                'Tekan tombol panah kiri/kanan untuk berpindah ke kata sebelumnya atau berikutnya.',
            emoji: '↔️',
            color: Color(0xFF2196F3),
          ),
        ];
      case 3:
        return [
          TourStep(
            targetKey: _latKeyTitle,
            title: 'Judul Latihan',
            description:
                'Ini adalah halaman Tebak Kata. Kamu akan mendengar suara kata dan harus memilih jawaban yang benar.',
            emoji: '🎯',
            color: Color(0xFFFF5722),
          ),
          TourStep(
            targetKey: _latKeyScore,
            title: 'Skor',
            description:
                'Di sini terlihat berapa skor yang sudah kamu kumpulkan dari total soal yang ada.',
            emoji: '⭐',
            color: Color(0xFF4CAF50),
          ),
          TourStep(
            targetKey: _latKeySoal,
            title: 'Gambar Soal',
            description:
                'Gambar petunjuk untuk kata yang harus kamu tebak. Bisa juga tekan gambar untuk mendengar suaranya.',
            emoji: '🖼️',
            color: Color(0xFF2196F3),
          ),
          TourStep(
            targetKey: _latKeySpeaker,
            title: 'Tombol Suara',
            description:
                'Tekan tombol speaker untuk mendengar pengucapan kata yang harus kamu tebak.',
            emoji: '🔊',
            color: Color(0xFFFF9800),
          ),
          TourStep(
            targetKey: _latKeyPilihan,
            title: 'Pilihan Jawaban',
            description:
                'Pilih salah satu jawaban yang benar! Jika benar skor bertambah, jika salah jawaban yang benar akan ditampilkan.',
            emoji: '✅',
            color: Color(0xFF9C27B0),
          ),
        ];
      default:
        return [];
    }
  }

  void _onTourFinish() {
    if (_currentScreenIndex < _screenLabels.length - 1) {
      // Auto-advance to next screen's tour
      _audio.playButtonSound();
      setState(() {
        _currentScreenIndex++;
        _isTourActive = true;
      });
    } else {
      // Last screen finished, show "Selesai" button state (inactive tour)
      _audio.playButtonSound();
      setState(() => _isTourActive = false);
    }
  }

  void _goToNextScreen() {
    if (_currentScreenIndex < _screenLabels.length - 1) {
      _audio.playButtonSound();
      setState(() {
        _currentScreenIndex++;
        _isTourActive = true;
      });
    } else {
      _audio.playButtonSound();
      Navigator.pop(context);
    }
  }

  void _goToPrevScreen() {
    if (_currentScreenIndex > 0) {
      _audio.playButtonSound();
      setState(() {
        _currentScreenIndex--;
        _isTourActive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Screen mockup
            _buildCurrentScreen(sw, sh),

            // Tour overlay
            if (_isTourActive)
              Positioned.fill(
                child: TourOverlay(
                  key: ValueKey('tour_$_currentScreenIndex'),
                  steps: _getStepsForScreen(_currentScreenIndex),
                  onFinish: _onTourFinish,
                ),
              ),

            // Screen navigation bar at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildScreenNav(sw, sh),
            ),

            // Bottom bar when tour is inactive
            if (!_isTourActive)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(sw, sh),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenNav(double sw, double sh) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + sh * 0.03, // Increased padding to move buttons down
        bottom: sh * 0.005,
        left: sw * 0.02,
        right: sw * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Close Button
          GestureDetector(
            onTap: () {
              _audio.playButtonSound();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(sh * 0.008),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.close, color: Colors.white, size: sh * 0.025),
            ),
          ),
          SizedBox(width: sw * 0.02),
          
          // Tabs
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: _screenLabels.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final label = entry.value;
                        final isActive = idx == _currentScreenIndex;
                        return GestureDetector(
                          onTap: () {
                            _audio.playButtonSound();
                            setState(() {
                              _currentScreenIndex = idx;
                              _isTourActive = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.symmetric(horizontal: sw * 0.005),
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025,
                              vertical: sh * 0.008,
                            ),
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [Colors.amber.shade400, Colors.orange.shade600],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.3),
                                        Colors.white.withValues(alpha: 0.1)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: isActive
                                  ? const [
                                      BoxShadow(
                                        color: Colors.orange,
                                        offset: Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Bangers',
                                fontSize: sh * 0.022,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: sw * 0.02),
          
          // Replay Button
          GestureDetector(
            onTap: () {
              _audio.playButtonSound();
              setState(() => _isTourActive = true);
            },
            child: Container(
              padding: EdgeInsets.all(sh * 0.008),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.replay_rounded, color: Colors.white, size: sh * 0.025),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double sw, double sh) {
    final isFirst = _currentScreenIndex == 0;
    final isLast = _currentScreenIndex == _screenLabels.length - 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.05,
        vertical: sh * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isFirst)
              _buildBarButton(
                icon: Icons.arrow_back_rounded,
                label: 'Sebelumnya',
                onTap: _goToPrevScreen,
                isPrimary: false,
                sw: sw,
                sh: sh,
              )
            else
              SizedBox(width: sw * 0.3),
            _buildBarButton(
              icon: isLast
                  ? Icons.check_circle_outline_rounded
                  : Icons.arrow_forward_rounded,
              label: isLast ? 'Selesai' : 'Berikutnya',
              onTap: _goToNextScreen,
              isPrimary: true,
              sw: sw,
              sh: sh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required double sw,
    required double sh,
  }) {
    // Styling colors similar to the game style
    final List<Color> gradientColors = isPrimary
        ? [Colors.green.shade400, Colors.green.shade700] // Green for Next/Finish
        : [Colors.orange.shade400, Colors.orange.shade700]; // Orange for Prev

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.06,
          vertical: sh * 0.015,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last,
              offset: const Offset(0, 4),
              blurRadius: 0, 
            ),
            const BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 6),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPrimary)
              Padding(
                padding: EdgeInsets.only(right: sw * 0.02),
                child: Icon(icon, color: Colors.white, size: sh * 0.03),
              ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Bangers', 
                fontSize: sh * 0.03,
                color: Colors.white,
                shadows: const [
                  Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
                ],
                letterSpacing: 1.0,
              ),
            ),
            if (isPrimary)
              Padding(
                padding: EdgeInsets.only(left: sw * 0.02),
                child: Icon(icon, color: Colors.white, size: sh * 0.03),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(double sw, double sh) {
    switch (_currentScreenIndex) {
      case 0:
        return _buildMenuMockup(sw, sh);
      case 1:
        return _buildAlfabetMockup(sw, sh);
      case 2:
        return _buildKosakataMockup(sw, sh);
      case 3:
        return _buildLatihanMockup(sw, sh);
      default:
        return _buildMenuMockup(sw, sh);
    }
  }

  // =====================================================
  // SHARED: Background + Ground
  // =====================================================
  Widget _buildBgGround(double sw, double sh) {
    return Stack(
      children: [
        Positioned.fill(
          child:
              Image.asset('assets/untukhome/bg.png', fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset('assets/untukhome/ground.png',
              fit: BoxFit.cover, height: sh * 0.18),
        ),
      ],
    );
  }

  // =====================================================
  // MENU SCREEN MOCKUP
  // =====================================================
  Widget _buildMenuMockup(double sw, double sh) {
    return SizedBox(
      width: sw,
      height: sh,
      child: Stack(
        children: [
          _buildBgGround(sw, sh),
          // Menu buttons (left side)
          Positioned(
            left: sw * 0.05,
            top: sh * 0.18, // Adjusted to avoid nav bar overlap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: sw * 0.28,
                  child: Text(
                    'MENU',
                    style: TextStyle(
                      fontFamily: 'Bangers',
                      fontSize: sh * 0.08,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            color: Colors.black38,
                            offset: Offset(2, 2),
                            blurRadius: 4),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: sh * 0.015),
                Container(
                    key: _menuKeyPetunjuk,
                    child: _buildMockMenuBtn(
                        'petunjuk\npenggunaan', sh, sw)),
                SizedBox(height: sh * 0.025),
                Container(
                    key: _menuKeyBelajar,
                    child: _buildMockMenuBtn('Belajar', sh, sw)),
                SizedBox(height: sh * 0.025),
                Container(
                    key: _menuKeyLatihan,
                    child: _buildMockMenuBtn('Latihan', sh, sw)),
                SizedBox(height: sh * 0.025),
                Container(
                    key: _menuKeyHistori,
                    child: _buildMockMenuBtn('Histori', sh, sw)),
              ],
            ),
          ),
          // Character
          Positioned(
            bottom: sh * 0.12,
            right: sw * 0.02,
            child: Container(
              key: _menuKeyKarakter,
              child: Image.asset('assets/untukhome/karakter.png',
                  height: sh * 0.55),
            ),
          ),
          // Cloud
          Positioned(
            top: sh * 0.18, // Adjusted to avoid nav bar overlap
            right: sw * 0.22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/untukmenu/awanisinamadankelas.png',
                    width: sw * 0.28),
                Transform.translate(
                  offset: Offset(-sw * 0.01, -sh * 0.035),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('halo Anak',
                          style: TextStyle(
                              fontFamily: 'Bangers',
                              fontSize: sh * 0.035,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
                      Text('dari Kelas 1',
                          style: TextStyle(
                              fontFamily: 'Bangers',
                              fontSize: sh * 0.03,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
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

  Widget _buildMockMenuBtn(String text, double sh, double sw) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/untukmenu/tombolmenu.png',
            width: sw * 0.28, height: sh * 0.1, fit: BoxFit.fill),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Bangers',
            fontSize: sh * 0.028,
            color: Colors.white,
            shadows: const [
              Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // =====================================================
  // ALFABET SCREEN MOCKUP — matches real alfabet_screen
  // =====================================================
  Widget _buildAlfabetMockup(double sw, double sh) {
    return SizedBox(
      width: sw,
      height: sh,
      child: Stack(
        children: [
          _buildBgGround(sw, sh),

          // Back button
          Positioned(
            top: sh * 0.16, // Adjusted to avoid nav bar overlap
            left: sw * 0.02,
            child: Container(
              key: _alfKeyBack,
              child: Image.asset(
                  'assets/untukbelajar/alfabet/navigasi_0.png',
                  height: sh * 0.1),
            ),
          ),

          // Papan with letter display
          Positioned(
            top: sh * 0.21, // Adjusted to avoid nav bar overlap
            left: 0,
            right: 0,
            child: Container(
              key: _alfKeyPapan,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                        'assets/untukbelajar/alfabet/papan.png',
                        height: sh * 0.45),
                    // Show letter "A" as example
                    Image.asset(
                      'assets/untukbelajar/alfabet/abc besar_0.png',
                      height: sh * 0.25,
                      errorBuilder: (c, e, s) => Text('A',
                          style: TextStyle(
                              fontFamily: 'SpicySale',
                              fontSize: sh * 0.2,
                              color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation arrows
          Positioned(
            left: sw * 0.18,
            top: sh * 0.35, // Adjusted to align with new papan position
            child: Image.asset(
              'assets/untukbelajar/alfabet/navigasi menyusun_kiri.png',
              height: sh * 0.12,
              errorBuilder: (c, e, s) =>
                  Icon(Icons.arrow_back, size: sh * 0.05, color: Colors.white),
            ),
          ),
          Positioned(
            right: sw * 0.18,
            top: sh * 0.35, // Adjusted to align with new papan position
            child: Image.asset(
              'assets/untukbelajar/alfabet/navigasi menyusun_kanan.png',
              height: sh * 0.12,
              errorBuilder: (c, e, s) => Icon(Icons.arrow_forward,
                  size: sh * 0.05, color: Colors.white),
            ),
          ),

          // Keyboard section — uses actual image assets like the real screen
          Positioned(
            bottom: -sh * 0.05,
            left: 0,
            right: 0,
            child: Container(
              key: _alfKeyKeyboard,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Keyboard background + letter buttons
                  Padding(
                    padding: EdgeInsets.only(top: sh * 0.025),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                            'assets/untukbelajar/alfabet/bgkeyboar.png',
                            width: sw * 0.65),
                        _buildRealKeyboard(sw, sh),
                      ],
                    ),
                  ),
                  // Keyboard toggle button
                  Image.asset(
                    'assets/untukbelajar/alfabet/navigasi keyboar_down.png',
                    height: sh * 0.10,
                    errorBuilder: (c, e, s) => Icon(
                        Icons.keyboard_arrow_down,
                        size: sh * 0.05,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Case toggle (left bottom) — matches real alfabet_screen exactly
          Positioned(
            left: sw * 0.02,
            bottom: sh * 0.02,
            child: Container(
              key: _alfKeyCaseToggle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Image.asset(
                          'assets/untukbelajar/alfabet/papanabc.png',
                          height: sh * 0.22),
                      Padding(
                        padding: EdgeInsets.only(top: sh * 0.01),
                        child: Image.asset(
                          'assets/untukbelajar/alfabet/tombol huruf besar.png',
                          height: sh * 0.12,
                          errorBuilder: (c, e, s) => Text('ABC',
                              style: TextStyle(
                                  fontFamily: 'SpicySale',
                                  fontSize: sh * 0.04,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: Offset(0, -sh * 0.03),
                    child: Image.asset(
                      'assets/untukbelajar/alfabet/semak.png',
                      height: sh * 0.08,
                      errorBuilder: (c, e, s) => SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the real keyboard with actual image assets (keyboard_0.png to keyboard_25.png)
  Widget _buildRealKeyboard(double sw, double sh) {
    final row1 = List.generate(10, (i) => i); // 0-9 (A-J)
    final row2 = List.generate(10, (i) => i + 10); // 10-19 (K-T)
    final row3 = List.generate(6, (i) => i + 20); // 20-25 (U-Z)

    Widget buildKey(int index) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.004),
        child: Image.asset(
          'assets/untukbelajar/alfabet/keyboard_$index.png',
          width: sw * 0.052,
          errorBuilder: (c, e, s) => Container(
            width: sw * 0.052,
            height: sw * 0.052,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.02, vertical: sh * 0.012),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row1.map(buildKey).toList()),
          SizedBox(height: sh * 0.006),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row2.map(buildKey).toList()),
          SizedBox(height: sh * 0.006),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row3.map(buildKey).toList()),
        ],
      ),
    );
  }

  // =====================================================
  // KOSAKATA SCREEN MOCKUP
  // =====================================================
  Widget _buildKosakataMockup(double sw, double sh) {
    return SizedBox(
      width: sw,
      height: sh,
      child: Stack(
        children: [
          _buildBgGround(sw, sh),

          // Back button
          Positioned(
            top: sh * 0.16, // Adjusted to avoid nav bar overlap
            left: sw * 0.02,
            child: Image.asset(
                'assets/untukbelajar/alfabet/navigasi_0.png',
                height: sh * 0.1,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.arrow_back, size: sh * 0.05, color: Colors.white)),
          ),

          // Category tabs
          Positioned(
            top: sh * 0.16, // Adjusted to avoid nav bar overlap
            left: 0,
            right: 0,
            child: Container(
              key: _kosKeyCategory,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMockCategoryTab(
                      'kv-kv', true, Colors.green, sw, sh),
                  SizedBox(width: sw * 0.03),
                  _buildMockCategoryTab(
                      'kv-kvk', false, Colors.purple, sw, sh),
                ],
              ),
            ),
          ),

          // Papan with word
          Positioned(
            top: sh * 0.25, // Adjusted to avoid nav bar overlap
            left: 0,
            right: 0,
            child: Container(
              key: _kosKeyPapan,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                        'assets/untukbelajar/alfabet/papan.png',
                        height: sh * 0.52),
                    Padding(
                      padding: EdgeInsets.only(bottom: sh * 0.03),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Image + speaker
                          Container(
                            key: _kosKeySpeaker,
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(sh * 0.01),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.5),
                                    borderRadius:
                                        BorderRadius.circular(15),
                                  ),
                                  child: Image.asset(
                                    'assets/untukbelajar/kosakata/buku.png',
                                    height: sh * 0.12,
                                    errorBuilder: (c, e, s) =>
                                        Container(
                                      height: sh * 0.12,
                                      width: sh * 0.12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.image,
                                          size: sh * 0.05,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(sh * 0.008),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                        Icons.volume_up_rounded,
                                        color: Colors.white,
                                        size: sh * 0.025),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sh * 0.015),
                          // Word — rainbow text
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: 'BUKU'
                                .split('')
                                .asMap()
                                .entries
                                .map((e) {
                              final c = e.key % 2 == 0
                                  ? Colors.red
                                  : Colors.blue;
                              return Text(e.value,
                                  style: TextStyle(
                                    fontFamily: 'SpicySale',
                                    fontSize: sh * 0.055,
                                    color: c,
                                    shadows: [
                                      Shadow(
                                          color: c.withValues(
                                              alpha: 0.5),
                                          offset: Offset(2, 2),
                                          blurRadius: 4),
                                    ],
                                  ));
                            }).toList(),
                          ),
                          SizedBox(height: sh * 0.012),
                          // Syllables
                          Container(
                            key: _kosKeySyllable,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMockSyllable(
                                    'BU', Colors.red, sw, sh),
                                SizedBox(width: sw * 0.03),
                                _buildMockSyllable(
                                    'KU', Colors.blue, sw, sh),
                              ],
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

          // Navigation arrows
          Positioned(
            left: sw * 0.12,
            top: sh * 0.34,
            child: Container(
              key: _kosKeyNav,
              child: Row(
                children: [
                  Image.asset(
                    'assets/untukbelajar/alfabet/navigasi menyusun_kiri.png',
                    height: sh * 0.1,
                    errorBuilder: (c, e, s) => Icon(Icons.arrow_back,
                        size: sh * 0.05, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: sw * 0.12,
            top: sh * 0.34,
            child: Image.asset(
              'assets/untukbelajar/alfabet/navigasi menyusun_kanan.png',
              height: sh * 0.1,
              errorBuilder: (c, e, s) => Icon(Icons.arrow_forward,
                  size: sh * 0.05, color: Colors.white),
            ),
          ),

          // Word counter
          Positioned(
            bottom: sh * 0.22,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05, vertical: sh * 0.012),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.amber.shade300,
                    Colors.orange.shade400
                  ]),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: Colors.orange.shade600, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.orange.shade900,
                        offset: Offset(0, 4),
                        blurRadius: 0),
                  ],
                ),
                child: Text('1 / 10',
                    style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: sh * 0.035,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockCategoryTab(
      String title, bool isActive, Color color, double sw, double sh) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sh * 0.015),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [color.withValues(alpha: 0.9), color]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.grey.shade500,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isActive ? color : Colors.grey).withValues(alpha: 0.7),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(title,
          style: TextStyle(
              fontFamily: 'SpicySale',
              fontSize: sh * 0.028,
              color: Colors.white)),
    );
  }

  Widget _buildMockSyllable(
      String text, Color color, double sw, double sh) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sh * 0.015),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color]),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.8),
              offset: Offset(0, 5),
              blurRadius: 0),
        ],
      ),
      child: Text(text,
          style: TextStyle(
              fontFamily: 'SpicySale',
              fontSize: sh * 0.05,
              color: Colors.white)),
    );
  }

  // =====================================================
  // LATIHAN (TEBAK KATA) SCREEN MOCKUP
  // =====================================================
  Widget _buildLatihanMockup(double sw, double sh) {
    return SizedBox(
      width: sw,
      height: sh,
      child: Stack(
        children: [
          _buildBgGround(sw, sh),

          // Back button
          Positioned(
            top: sh * 0.16, // Adjusted to avoid nav bar overlap
            left: sw * 0.02,
            child: Image.asset(
                'assets/untukbelajar/alfabet/navigasi_0.png',
                height: sh * 0.1,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.arrow_back, size: sh * 0.05, color: Colors.white)),
          ),

          // Title — "Tebak Kata"
          Positioned(
            top: sh * 0.16, // Adjusted to avoid nav bar overlap
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                key: _latKeyTitle,
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05, vertical: sh * 0.015),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.red.shade400]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8),
                  ],
                ),
                child: Text('Tebak Kata',
                    style: TextStyle(
                        fontFamily: 'SpicySale',
                        fontSize: sh * 0.04,
                        color: Colors.white)),
              ),
            ),
          ),

          // Score badge
          Positioned(
            top: sh * 0.16, // Adjusted to avoid nav bar overlap
            right: sw * 0.02,
            child: Container(
              key: _latKeyScore,
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sh * 0.01),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4),
                ],
              ),
              child: Text('Skor: 0/10',
                  style: TextStyle(
                      fontFamily: 'SpicySale',
                      fontSize: sh * 0.025,
                      color: Colors.white)),
            ),
          ),

          // Main papan with soal
          Positioned(
            top: sh * 0.26, // Adjusted to avoid nav bar overlap
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                      'assets/untukbelajar/alfabet/papan.png',
                      height: sh * 0.58), // Reduced height to fit
                  Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.02),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress text
                        Text('Soal 1/10',
                            style: TextStyle(
                                fontFamily: 'SpicySale',
                                fontSize: sh * 0.025,
                                color: Colors.brown.shade800)),
                        SizedBox(height: sh * 0.02),

                        // Image with speaker button
                        Container(
                          key: _latKeySoal,
                          child: Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.all(sh * 0.015),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.7),
                                  borderRadius:
                                      BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 4),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/untukbelajar/kosakata/buku.png',
                                  height: sh * 0.15,
                                  errorBuilder: (c, e, s) =>
                                      Container(
                                    height: sh * 0.15,
                                    width: sh * 0.15,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.image,
                                        size: sh * 0.07,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              // Speaker button
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  key: _latKeySpeaker,
                                  padding:
                                      EdgeInsets.all(sh * 0.01),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Icon(
                                      Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: sh * 0.03),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: sh * 0.03),

                        // 3 answer choices
                        Container(
                          key: _latKeyPilihan,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              _buildMockPilihan(
                                  'BUKU', Colors.blue, sw, sh,
                                  isCorrect: true),
                              SizedBox(width: sw * 0.02),
                              _buildMockPilihan(
                                  'KAKI', Colors.blue, sw, sh),
                              SizedBox(width: sw * 0.02),
                              _buildMockPilihan(
                                  'KUKU', Colors.blue, sw, sh),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockPilihan(
      String text, Color color, double sw, double sh,
      {bool isCorrect = false}) {
    return Container(
      width: sw * 0.13,
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.01, vertical: sh * 0.025),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color]),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.7),
              offset: Offset(0, 4),
              blurRadius: 0),
          BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 6),
              blurRadius: 8),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SpicySale',
          fontSize: sh * 0.025,
          color: Colors.white,
          shadows: const [
            Shadow(
                color: Colors.black38,
                offset: Offset(1, 1),
                blurRadius: 2),
          ],
        ),
      ),
    );
  }
}
