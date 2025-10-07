import 'dart:math';
import 'package:flutter/material.dart';

enum LightMode { off, city, normal, highBeam }

class CenterConsoleWidget extends StatefulWidget {
  final int speedLimit;
  final int speed;
  final int gear; // 1-5
  final double fuelPercentage; // 0-100
  final int estimatedKm;
  final double tankCapacity; // in litres

  const CenterConsoleWidget({
    super.key,
    this.speedLimit = 67,
    this.speed = 72, 
    this.gear = 1,
    this.fuelPercentage = 20,
    this.estimatedKm = 500,
    this.tankCapacity = 47.0,
  });

  @override
  State<CenterConsoleWidget> createState() => _CenterConsoleWidgetState();
}

class _CenterConsoleWidgetState extends State<CenterConsoleWidget>
    with SingleTickerProviderStateMixin {
  LightMode lightMode = LightMode.normal;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _cycleLight() {
    setState(() {
      lightMode =
          LightMode.values[(lightMode.index + 1) % LightMode.values.length];
    });
  }

  // --- Utility Functions ---

  Color _getLightColor(LightMode mode) {
    switch (mode) {
      case LightMode.city:
        return Colors.orange.shade400;
      case LightMode.normal:
        return Colors.green.shade400;
      case LightMode.highBeam:
        return Colors.blue.shade300;
      case LightMode.off:
      default:
        return Colors.white38;
    }
  }

  /// Calculates the warning color with a smooth opacity transition.
  Color _getSpeedWarningColor(int speed, int speedLimit) {
    if (speed <= speedLimit) {
      return Colors.transparent; 
    }

    final overspeed = (speed - speedLimit).toDouble();
    final rawOpacity = overspeed * 0.1; 
    final opacity = rawOpacity.clamp(0.0, 0.5);

    return Colors.red.withOpacity(opacity);
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final width = 500 * 0.66;
    final height = 200 * 0.75;
    
    final warningColor = _getSpeedWarningColor(widget.speed, widget.speedLimit);
    final isSpeeding = widget.speed > widget.speedLimit;

    final speedTextColor = isSpeeding 
      ? warningColor.withOpacity(0.9) 
      : Colors.white;

    final lightColor = _getLightColor(lightMode);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top Row: Circular Fuel | Speed/Gear | Lights
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- LEFT: CIRCULAR FUEL GAUGE ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularFuelIndicator(
                          fuelPercentage: widget.fuelPercentage,
                          animation: _waveController,
                        ),
                        const SizedBox(height: 4),
                        // Litres Remaining Display
                        Text(
                          '${(widget.fuelPercentage / 100 * widget.tankCapacity).toStringAsFixed(1)} L / ${widget.tankCapacity.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // --- END LEFT FUEL GAUGE ---

                    // --- CENTER: MODIFIED SPEED & GEAR DISPLAY ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      // The Column is centered horizontally by the main Row's design
                      children: [
                        // 👇 MODIFIED: Just the Text widget is here now. It centers itself in the Column.
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            color: speedTextColor,
                            fontSize: 40, 
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ]
                          ),
                          child: Text(
                            '${widget.speed}',
                          ),
                        ),
                        // 👆 END MODIFIED SPEED DISPLAY
                        
                        const SizedBox(height: 4),
                        Column(
                          children: [
                            Text(
                              'Gear ${widget.gear}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Wider divider
                            Container(
                              width: 60,
                              height: 2,
                              color: Colors.white24,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // --- END CENTER SPEED/GEAR ---

                    // RIGHT: Light button with CustomPainter
                    SizedBox(
                      width: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _cycleLight,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(28, 28),
                                  painter: HeadlightIconPainter(
                                    lightMode: lightMode,
                                    color: lightColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lightMode.name[0].toUpperCase() + lightMode.name.substring(1).toLowerCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}

/// Custom circular fuel gauge displaying a fluid wave effect inside a circle.
class CircularFuelIndicator extends StatelessWidget {
  final double fuelPercentage;
  final Animation<double> animation;

  const CircularFuelIndicator({
    required this.fuelPercentage,
    required this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = 50.0;
    final clampedFuel = fuelPercentage.clamp(0.0, 100.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white12,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Wave effect using the painter
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.square(size),
                  painter: _FuelFluidPainter(
                    fillPercent: clampedFuel / 100,
                    color: const Color(0xFF8B4513), // Fuel color
                    phase: animation.value * 2 * pi,
                  ),
                );
              },
            ),
            // Gas Pump Icon centered over the wave
            const Center(
              child: Icon(
                Icons.local_gas_station,
                color: Colors.white70,
                size: 24, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the animated fluid wave effect.
class _FuelFluidPainter extends CustomPainter {
  final double fillPercent; // 0-1
  final Color color;
  final double phase; // for animation

  _FuelFluidPainter({
    required this.fillPercent,
    required this.color,
    this.phase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final height = size.height * (1 - fillPercent);

    path.moveTo(0, size.height);
    path.lineTo(0, height);

    const waveAmplitude = 1.5; 
    const waveFrequency = 2.0;

    // Draw the top line as a sine wave
    for (double x = 0; x <= size.width; x++) {
      final y = height +
          waveAmplitude * sin(x / size.width * waveFrequency * 2 * pi + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FuelFluidPainter oldDelegate) {
    return oldDelegate.fillPercent != fillPercent ||
        oldDelegate.phase != phase ||
        oldDelegate.color != color;
  }
}

/// Custom painter for authentic car dashboard headlight icons
class HeadlightIconPainter extends CustomPainter {
  final LightMode lightMode;
  final Color color;

  HeadlightIconPainter({required this.lightMode, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final width = size.width;
    final height = size.height;

    switch (lightMode) {
      case LightMode.off:
        // Off: Circle with a diagonal line through it
        final center = Offset(width / 2, height / 2);
        canvas.drawCircle(center, width * 0.35, paint);
        canvas.drawLine(Offset(width * 0.1, height * 0.9), Offset(width * 0.9, height * 0.1), paint);
        break;

      case LightMode.city:
        // City/Parking: Two sets of symmetrical lights pointing down-left and down-right.
        // Left side light lines (down-left angle)
        paint.strokeWidth = 1.5;
        canvas.drawLine(Offset(width * 0.35, height * 0.3), Offset(width * 0.1, height * 0.55), paint);
        canvas.drawLine(Offset(width * 0.5, height * 0.45), Offset(width * 0.25, height * 0.7), paint);
        // Right side light lines (down-right angle)
        canvas.drawLine(Offset(width * 0.65, height * 0.3), Offset(width * 0.9, height * 0.55), paint);
        canvas.drawLine(Offset(width * 0.5, height * 0.45), Offset(width * 0.75, height * 0.7), paint);
        break;

      case LightMode.normal:
        // Normal/Low Beam: Headlight shape with angled beams pointing down-right (green).
        paint.style = PaintingStyle.stroke;
        // Headlight shape (D-shape on the left)
        final headLightPath = Path()
          ..moveTo(width * 0.3, height * 0.3)
          ..lineTo(width * 0.3, height * 0.7)
          ..lineTo(width * 0.5, height * 0.8)
          ..lineTo(width * 0.5, height * 0.2)
          ..close();
        canvas.drawPath(headLightPath, paint);
        
        // Angled beams (down-right)
        paint.strokeWidth = 1.5;
        for (int i = 0; i < 3; i++) {
          final startY = height * 0.25 + (i * 0.15 * height);
          canvas.drawLine(
            Offset(width * 0.55, startY),
            Offset(width * 0.85, startY + (0.15 * height)), // Angled down
            paint,
          );
        }
        break;

      case LightMode.highBeam:
        // High Beam: Filled headlight shape with straight beams (blue).
        paint.style = PaintingStyle.fill;
        // Headlight shape (filled D-shape on the left)
        final headLightPath = Path()
          ..moveTo(width * 0.2, height * 0.3)
          ..lineTo(width * 0.2, height * 0.7)
          ..lineTo(width * 0.45, height * 0.8)
          ..lineTo(width * 0.45, height * 0.2)
          ..close();
        canvas.drawPath(headLightPath, paint);

        // Straight beams (horizontal lines)
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        for (int i = 0; i < 4; i++) {
          final startY = height * 0.3 + (i * 0.1 * height);
          canvas.drawLine(
            Offset(width * 0.5, startY),
            Offset(width * 0.8, startY),
            paint,
          );
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant HeadlightIconPainter oldDelegate) {
    return oldDelegate.lightMode != lightMode || oldDelegate.color != color;
  }
}