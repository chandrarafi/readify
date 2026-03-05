import 'dart:async';
import 'package:flutter/material.dart';

/// Data class for a single tour step
class TourStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final String emoji;
  final Color color;

  const TourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.emoji = '👆',
    this.color = Colors.blue,
  });
}

/// Driver.js-style spotlight overlay tour widget
class TourOverlay extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onFinish;

  const TourOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  Rect? _targetRect;
  Timer? _autoNextTimer;

  late AnimationController _spotlightController;
  late AnimationController _tooltipController;
  late AnimationController _pulseController;
  late Animation<double> _tooltipScale;
  late Animation<double> _tooltipFade;
  late Animation<double> _pulseAnimation;

  // Animated spotlight position/size
  Rect _animatedRect = Rect.zero;
  Rect _fromRect = Rect.zero;
  Rect _toRect = Rect.zero;

  @override
  void initState() {
    super.initState();

    _spotlightController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..addListener(() {
        setState(() {
          final t = Curves.easeInOutCubic.transform(_spotlightController.value);
          _animatedRect = Rect.lerp(_fromRect, _toRect, t)!;
        });
      });

    _tooltipController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _tooltipScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _tooltipController, curve: Curves.easeOutBack),
    );
    _tooltipFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tooltipController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToStep(0);
    });
  }

  @override
  void dispose() {
    _autoNextTimer?.cancel();
    _spotlightController.dispose();
    _tooltipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToStep(int index) async {
    _autoNextTimer?.cancel(); // Cancel any pending auto-next
    
    if (index < 0 || index >= widget.steps.length) return;

    // hide tooltip while moving spotlight
    await _tooltipController.reverse();

    setState(() {
      _currentStep = index;
      _targetRect = _getTargetRect(widget.steps[index].targetKey);
    });

    if (_targetRect != null) {
      _fromRect = _animatedRect == Rect.zero ? _targetRect! : _animatedRect;
      _toRect = _targetRect!;
      _spotlightController.forward(from: 0.0).then((_) {
        // show tooltip after spotlight arrives
        _tooltipController.forward(from: 0.0);
        
        // Auto-advance after 5 seconds, unless it's the last step
        if (index < widget.steps.length - 1) {
          _autoNextTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) _next();
          });
        }
      });
    }
  }

  Rect? _getTargetRect(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    // Add padding around the target
    const padding = 8.0;
    return Rect.fromLTWH(
      position.dx - padding,
      position.dy - padding,
      size.width + padding * 2,
      size.height + padding * 2,
    );
  }

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _finish() async {
    await _tooltipController.reverse();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final step = widget.steps[_currentStep];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay with spotlight cutout
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: screenSize,
                painter: _SpotlightPainter(
                  targetRect: _animatedRect,
                  pulseValue: _pulseAnimation.value,
                  highlightColor: step.color,
                ),
              );
            },
          ),

          // Tap handler on overlay (not on spotlight hole)
          Positioned.fill(
            child: GestureDetector(
              onTap: _next,
              behavior: HitTestBehavior.translucent,
            ),
          ),

          // Tooltip popup
          if (_targetRect != null)
            _buildTooltip(context, step, screenSize),
        ],
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, TourStep step, Size screenSize) {
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final rect = _animatedRect;

    // Determine tooltip position: above or below the target
    // Reserve top ~8% for navigation bar
    final minTop = screenHeight * 0.08;
    final spaceBelow = screenHeight - rect.bottom;
    final spaceAbove = rect.top - minTop; // Usable space above (excluding nav bar)
    final showBelow = spaceBelow > spaceAbove || spaceAbove < screenHeight * 0.1;

    // Estimated tooltip height for clamping
    final estimatedTooltipHeight = screenHeight * 0.22;
    final tooltipTop = showBelow 
        ? (rect.bottom + 12).clamp(minTop, screenHeight - estimatedTooltipHeight - 12)
        : null;
    final tooltipBottom = !showBelow 
        ? screenHeight - rect.top + 12 
        : null;

    // Horizontal position: centered on target, clamped to screen
    double tooltipLeft = rect.center.dx - (screenWidth * 0.4) / 2;
    tooltipLeft = tooltipLeft.clamp(12.0, screenWidth - screenWidth * 0.4 - 12);

    return Positioned(
      top: tooltipTop,
      bottom: tooltipBottom,
      left: tooltipLeft,
      child: FadeTransition(
        opacity: _tooltipFade,
        child: ScaleTransition(
          scale: _tooltipScale,
          alignment: showBelow ? Alignment.topCenter : Alignment.bottomCenter,
          child: Container(
            width: screenWidth * 0.4,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: step.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator + emoji
                Row(
                  children: [
                    Text(
                      step.emoji,
                      style: TextStyle(fontSize: screenHeight * 0.03),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontFamily: 'SpicySale',
                          fontSize: screenHeight * 0.025,
                          color: step.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Skip button
                    GestureDetector(
                      onTap: _finish,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: screenHeight * 0.02,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),

                // Description
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: screenHeight * 0.018,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // Navigation row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Step counter
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentStep + 1} / ${widget.steps.length}',
                        style: TextStyle(
                          fontSize: screenHeight * 0.015,
                          color: step.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Prev / Next buttons
                    Row(
                      children: [
                        if (_currentStep > 0)
                          _buildNavBtn(
                            icon: Icons.arrow_back_rounded,
                            label: 'Kembali',
                            onTap: _prev,
                            isPrimary: false,
                            step: step,
                            screenHeight: screenHeight,
                          ),
                        SizedBox(width: 8),
                        _buildNavBtn(
                          icon: _currentStep == widget.steps.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          label: _currentStep == widget.steps.length - 1
                              ? 'Selesai'
                              : 'Lanjut',
                          onTap: _next,
                          isPrimary: true,
                          step: step,
                          screenHeight: screenHeight,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required TourStep step,
    required double screenHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? step.color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: step.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPrimary)
              Icon(icon, size: screenHeight * 0.016, color: Colors.grey.shade600),
            if (!isPrimary) SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: screenHeight * 0.016,
                color: isPrimary ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPrimary) SizedBox(width: 4),
            if (isPrimary)
              Icon(icon, size: screenHeight * 0.016, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter that draws a dark overlay with a spotlight cutout
class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double pulseValue;
  final Color highlightColor;

  _SpotlightPainter({
    required this.targetRect,
    required this.pulseValue,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (targetRect == Rect.zero) {
      // Just draw full overlay if no target yet
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black.withValues(alpha: 0.7),
      );
      return;
    }

    // Expanded rect for pulse glow
    final pulseRect = targetRect.inflate(pulseValue);

    // Draw dark overlay with spotlight hole
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final spotlightPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect,
        Radius.circular(16),
      ));

    final combinedPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      spotlightPath,
    );

    // Draw the overlay
    canvas.drawPath(
      combinedPath,
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // Draw pulse glow ring
    final glowPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.3 - (pulseValue / 40))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(pulseRect, Radius.circular(20)),
      glowPaint,
    );

    // Draw border around spotlight
    final borderPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseValue != pulseValue;
  }
}
