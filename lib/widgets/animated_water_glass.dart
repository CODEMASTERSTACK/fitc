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
      // Water body with rounded corners matching glass
      final waterPath = Path();
      final innerRadius = borderRadius - glassThickness;

      // Start from left side with curve
      waterPath.moveTo(
        glassMargin + glassThickness / 2,
        waterTop + innerRadius,
      );

      // Top-left arc (only if water doesn't fill to top)
      if (waterTop > glassMargin + glassThickness / 2) {
        waterPath.arcToPoint(
          Offset(glassMargin + glassThickness / 2 + innerRadius, waterTop),
          radius: Radius.circular(innerRadius),
          clockwise: true,
        );
      }

      // Top edge with wave effect if overflowing
      if (isOverflowing) {
        // Create organic wave shape for overflow effect
        const waveSegments = 30;
        for (int i = 0; i <= waveSegments; i++) {
          final progress = i / waveSegments;
          final x =
              (glassMargin + glassThickness / 2 + innerRadius) +
              progress *
                  (width - glassMargin * 2 - glassThickness - innerRadius * 2);

          // Multiple sine waves for natural splash effect
          final wave1 = sin(progress * pi + overflowAnimation * 2 * pi) * 2.5;
          final wave2 =
              sin(progress * pi * 2 + overflowAnimation * 3 * pi) * 1.5;
          final y = waterTop + wave1 + wave2;

          if (i == 0) {
            waterPath.lineTo(x, y);
          } else {
            waterPath.lineTo(x, y);
          }
        }
      } else {
        waterPath.lineTo(
          width - glassMargin - glassThickness / 2 - innerRadius,
          waterTop,
        );
        // Top-right arc
        waterPath.arcToPoint(
          Offset(
            width - glassMargin - glassThickness / 2,
            waterTop + innerRadius,
          ),
          radius: Radius.circular(innerRadius),
          clockwise: true,
        );
      }

      // Right side
      waterPath.lineTo(
        width - glassMargin - glassThickness / 2,
        height - glassMargin - glassThickness / 2 - innerRadius,
      );

      // Bottom-right arc
      waterPath.arcToPoint(
        Offset(
          width - glassMargin - glassThickness / 2 - innerRadius,
          height - glassMargin - glassThickness / 2,
        ),
        radius: Radius.circular(innerRadius),
        clockwise: true,
      );

      // Bottom edge
      waterPath.lineTo(
        glassMargin + glassThickness / 2 + innerRadius,
        height - glassMargin - glassThickness / 2,
      );

      // Bottom-left arc
      waterPath.arcToPoint(
        Offset(
          glassMargin + glassThickness / 2,
          height - glassMargin - glassThickness / 2 - innerRadius,
        ),
        radius: Radius.circular(innerRadius),
        clockwise: true,
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

    // Draw "WATER OVERFLOW" label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⚠ WATER OVERFLOW',
        style: TextStyle(
          color: waterColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(width / 2 - textPainter.width / 2, height * 0.15),
    );

    // Create organic splash shapes coming from top center
    final centerX = width / 2;
    final splashTopY = height * 0.12;

    // Main puddle at bottom
    final puddleHeight = height * 0.25 * fillAnimation.clamp(0.0, 1.0);
    final baseWidth = width * (0.6 + fillAnimation * 0.3);
    final puddleLeft = (width - baseWidth) / 2;

    // Draw main puddle with irregular organic shape
    final puddlePath = Path();

    // Create puddle with wavy edges
    const puddleSegments = 40;
    for (int i = 0; i <= puddleSegments; i++) {
      final progress = i / puddleSegments;
      final x = puddleLeft + progress * baseWidth;

      // Multiple layered sine waves for organic look
      final wave1 = sin(progress * pi + fillAnimation * 2.5 * pi) * 3;
      final wave2 = sin(progress * pi * 2 + fillAnimation * 1.5 * pi) * 2;
      final wave3 = sin(progress * pi * 3 + fillAnimation * 3 * pi) * 1.5;

      final y = height - puddleHeight + wave1 + wave2 + wave3;

      if (i == 0) {
        puddlePath.moveTo(x, y);
      } else {
        puddlePath.lineTo(x, y);
      }
    }

    // Close puddle to bottom
    puddlePath.lineTo(puddleLeft + baseWidth, height);
    puddlePath.lineTo(puddleLeft, height);
    puddlePath.close();

    // Draw puddle with radial gradient for depth
    final gradient = RadialGradient(
      center: Alignment(0, 0.6),
      radius: 1.0,
      colors: [waterColor.withOpacity(0.5), waterColor.withOpacity(0.25)],
    );

    canvas.drawPath(
      puddlePath,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(
            puddleLeft,
            height - puddleHeight,
            baseWidth,
            puddleHeight,
          ),
        ),
    );

    // Draw water drops/splashes
    const dropCount = 5;
    for (int i = 0; i < dropCount; i++) {
      final angle = (i / dropCount) * pi * 2 + fillAnimation * 2 * pi;
      final distance = 30 + sin(fillAnimation * 3 * pi) * 10;

      final dropX = centerX + cos(angle) * distance;
      final dropY =
          splashTopY +
          sin(angle) * distance * 0.7 +
          sin(fillAnimation * 2 * pi) * 15;

      final dropSize = 2 + sin(fillAnimation * 2 * pi + i) * 1.5;

      canvas.drawCircle(
        Offset(dropX, dropY),
        dropSize,
        Paint()
          ..color = waterColor.withOpacity(0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1),
      );
    }

    // Add shine effect on puddle
    final shineGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
    );

    canvas.drawPath(
      puddlePath,
      Paint()
        ..shader = shineGradient.createShader(
          Rect.fromLTWH(
            puddleLeft,
            height - puddleHeight,
            baseWidth,
            puddleHeight,
          ),
        ),
    );
  }

  @override
  bool shouldRepaint(PuddlePainter oldDelegate) {
    return oldDelegate.fillAnimation != fillAnimation ||
        oldDelegate.overflowAmount != overflowAmount;
  }
}
