import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedWaterGlass extends StatefulWidget {
  final double waterLevel; // 0.0 to 1.0+ (can exceed 1.0 for overflow)
  final Color waterColor;
  final Duration animationDuration;

  const AnimatedWaterGlass({
    Key? key,
    required this.waterLevel,
    required this.waterColor,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedWaterGlass> createState() => _AnimatedWaterGlassState();
}

class _AnimatedWaterGlassState extends State<AnimatedWaterGlass>
    with TickerProviderStateMixin {
  late AnimationController _waterController;
  late Animation<double> _waterAnimation;
  late AnimationController _overflowController;

  @override
  void initState() {
    super.initState();
    _waterController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _overflowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedWaterGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waterLevel != widget.waterLevel) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    _waterAnimation =
        Tween<double>(
          begin: _waterController.value,
          end: (widget.waterLevel).clamp(0.0, 1.0),
        ).animate(
          CurvedAnimation(parent: _waterController, curve: Curves.easeOutCubic),
        );

    _waterController.forward(from: 0.0);

    // Start overflow animation if water exceeds 100%
    if (widget.waterLevel > 1.0) {
      _overflowController.repeat(reverse: true);
    } else {
      _overflowController.stop();
    }
  }

  @override
  void dispose() {
    _waterController.dispose();
    _overflowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main glass and water animation
        Center(
          child: SizedBox(
            width: 200,
            height: 300,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _waterAnimation,
                _overflowController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: WaterGlassPainter(
                    waterLevel: _waterAnimation.value,
                    waterColor: widget.waterColor,
                    isOverflowing: widget.waterLevel > 1.0,
                    overflowAnimation: _overflowController.value,
                  ),
                );
              },
            ),
          ),
        ),

        // Overflow water puddle animation at bottom
        if (widget.waterLevel > 1.0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: AnimatedBuilder(
              animation: _overflowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: PuddlePainter(
                    waterColor: widget.waterColor,
                    fillAnimation: _overflowController.value,
                    overflowAmount: (widget.waterLevel - 1.0).clamp(0.0, 0.5),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class WaterGlassPainter extends CustomPainter {
  final double waterLevel;
  final Color waterColor;
  final bool isOverflowing;
  final double overflowAnimation;

  WaterGlassPainter({
    required this.waterLevel,
    required this.waterColor,
    required this.isOverflowing,
    required this.overflowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    const glassThickness = 3.0;
    const glassMargin = 20.0;
    const borderRadius = 20.0;

    // Glass outline (rounded rectangle)
    final glassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        glassMargin,
        glassMargin,
        width - glassMargin * 2,
        height - glassMargin * 2,
      ),
      const Radius.circular(borderRadius),
    );

    // Draw glass outline
    canvas.drawRRect(
      glassRect,
      Paint()
        ..color = Colors.grey[300]!
        ..strokeWidth = glassThickness
        ..style = PaintingStyle.stroke,
    );

    // Draw semi-transparent glass background
    canvas.drawRRect(
      glassRect,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );

    // Calculate water fill height
    final fillHeight = (height - glassMargin * 2 - glassThickness) * waterLevel;
    final waterTop = (height - glassMargin) - fillHeight;

    // Draw water with wave effect at top
    if (waterLevel > 0) {
      // Water body
      final waterPath = Path();
      waterPath.moveTo(glassMargin + glassThickness / 2, waterTop);

      // Add wave effect if water is moving
      if (isOverflowing) {
        final waveAmount = 3.0 * sin(overflowAnimation * 2 * pi);
        waterPath.quadraticBezierTo(
          width / 2,
          waterTop + waveAmount,
          width - glassMargin - glassThickness / 2,
          waterTop,
        );
      } else {
        waterPath.lineTo(width - glassMargin - glassThickness / 2, waterTop);
      }

      // Close the water shape
      waterPath.lineTo(
        width - glassMargin - glassThickness / 2,
        height - glassMargin - glassThickness / 2,
      );
      waterPath.lineTo(
        glassMargin + glassThickness / 2,
        height - glassMargin - glassThickness / 2,
      );
      waterPath.close();

      // Draw water with gradient
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [waterColor.withOpacity(0.8), waterColor],
      );

      canvas.drawPath(
        waterPath,
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(
              glassMargin,
              waterTop,
              width - glassMargin * 2,
              fillHeight,
            ),
          ),
      );

      // Add water shine effect
      canvas.drawPath(
        waterPath,
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // Draw water level text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(waterLevel * 100).clamp(0, 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        width / 2 - textPainter.width / 2,
        height / 2 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(WaterGlassPainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.waterColor != waterColor ||
        oldDelegate.overflowAnimation != overflowAnimation;
  }
}

class PuddlePainter extends CustomPainter {
  final Color waterColor;
  final double fillAnimation;
  final double overflowAmount;

  PuddlePainter({
    required this.waterColor,
    required this.fillAnimation,
    required this.overflowAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (overflowAmount <= 0) return;

    final width = size.width;
    final height = size.height;

    // Create puddle shape that spreads and fills from bottom
    final puddleHeight =
        height * (fillAnimation * overflowAmount * 2).clamp(0.0, 1.0);
    final puddleWidth = width * (fillAnimation + 0.3);

    // Center puddle horizontally
    final puddleLeft = (width - puddleWidth) / 2;

    // Create puddle path with wave effect
    final puddlePath = Path();
    puddlePath.moveTo(puddleLeft, height - puddleHeight);

    // Add wavy top edge
    const segments = 20;
    for (int i = 0; i <= segments; i++) {
      final x = puddleLeft + (puddleWidth / segments) * i;
      final waveY = sin((i / segments) * pi + fillAnimation * 2 * pi) * 4;
      puddlePath.lineTo(x, height - puddleHeight + waveY);
    }

    // Close the puddle
    puddlePath.lineTo(puddleLeft + puddleWidth, height);
    puddlePath.lineTo(puddleLeft, height);
    puddlePath.close();

    // Draw puddle with gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [waterColor.withOpacity(0.4), waterColor.withOpacity(0.6)],
    );

    canvas.drawPath(
      puddlePath,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(
            puddleLeft,
            height - puddleHeight,
            puddleWidth,
            puddleHeight,
          ),
        ),
    );

    // Add shine to puddle
    canvas.drawPath(
      puddlePath,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(PuddlePainter oldDelegate) {
    return oldDelegate.fillAnimation != fillAnimation ||
        oldDelegate.overflowAmount != overflowAmount;
  }
}
