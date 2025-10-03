import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for ImageFilter

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
    this.speed = 72, // Set to 72 to demonstrate the max warning opacity (5 over)
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

  // --- Utility Functions (Modified for smooth warning) ---

  Color _getLightColor(LightMode mode) {
    switch (mode) {
      case LightMode.city:
        return Colors.orange.shade400; // parking/city lights
      case LightMode.normal:
        return Colors.green.shade400; // normal/low beam
      case LightMode.highBeam:
        return Colors.blue.shade300; // high beam
      case LightMode.off:
      default:
        return Colors.white24; // gray/off
    }
  }

  /// Calculates the warning color with a smooth opacity transition.
  /// Opacity scales from 0.0 at 0 overspeed to 0.5 at 5 km/h overspeed, and then caps at 0.5.
  Color _getSpeedWarningColor(int speed, int speedLimit) {
    if (speed <= speedLimit) {
      // Logic retained for backend, though no longer displayed visually.
      return Colors.transparent; 
    }

    final overspeed = (speed - speedLimit).toDouble();
    
    // Scale factor: 0.5 (max desired opacity) / 5 (overspeed delta for max opacity) = 0.1
    final rawOpacity = overspeed * 0.1; 
    
    // Clamp the opacity between 0.0 and 0.5
    final opacity = rawOpacity.clamp(0.0, 0.5);

    return Colors.red.withOpacity(opacity);
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final width = 500 * 0.66; // 2/3 width
    final height = 200 * 0.75; // smaller height
    
    // Speeding logic is kept for future use, even if not currently visible
    final warningColor = _getSpeedWarningColor(widget.speed, widget.speedLimit);
    final isSpeeding = widget.speed > widget.speedLimit;

    // Determine the target color for the speed text based on the warning state
    final speedTextColor = isSpeeding 
      ? warningColor.withOpacity(0.9) 
      : Colors.white;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20), // Adjusted bottom padding
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
                    // --- LEFT: NEW CIRCULAR FUEL GAUGE ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularFuelIndicator(
                          fuelPercentage: widget.fuelPercentage,
                          animation: _waveController,
                        ),
                        const SizedBox(height: 4), // Added small spacing
                        // Litres Remaining Display
                        Text(
                          // Current Litres / Total Tank Capacity
                          '${(widget.fuelPercentage / 100 * widget.tankCapacity).toStringAsFixed(1)} L / ${widget.tankCapacity.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13, // Reduced size
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // --- END LEFT FUEL GAUGE ---

                    // --- CENTER: RESTORED SPEED & GEAR DISPLAY ---
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // AnimatedContainer for the text padding and fixed height
                        AnimatedContainer( 
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            borderRadius: BorderRadius.circular(30.0), 
                            boxShadow: const [],
                          ),
                          // Use a Row to style the speed number and unit separately
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Animated the speed number's color
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                style: TextStyle(
                                  color: speedTextColor,
                                  fontSize: 24, // Larger, bolder speed number
                                  fontWeight: FontWeight.w900,
                                ),
                                child: Text(
                                  '${widget.speed}',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'km/h',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14, // Smaller, normal weight unit
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              width: 60, // widened
                              height: 2,
                              color: Colors.white24,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // --- END CENTER SPEED/GEAR ---

                    // RIGHT: Light button with custom icon
                    SizedBox(
                      width: 80, // Constrain width to prevent layout shift
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, // Center contents horizontally
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
                                    color: _getLightColor(lightMode),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4), // Added small spacing
                          Text(
                            // Display the light mode name, now with standard capitalization
                            lightMode.name[0].toUpperCase() + lightMode.name.substring(1).toLowerCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13, // Reduced size
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
    final size = 50.0; // Size of the circular indicator (Reduced from 70.0 to match light button)
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
        // ClipOval ensures the fluid and icon are contained within the circle
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
                size: 24, // Reduced from 30 to fit better in 50x50 container
              ),
            ),
          ],
        ),
      ),
    );
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

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    switch (lightMode) {
      case LightMode.off:
        // Simple outline of headlight
        canvas.drawCircle(center, size.width * 0.35, paint);
        break;

      case LightMode.city:
        // Small parking light icon (small filled circle)
        canvas.drawCircle(center, size.width * 0.3, fillPaint);
        // Two small lines below for parking lights
        final path = Path();
        path.moveTo(center.dx - 4, center.dy + 8);
        path.lineTo(center.dx - 4, center.dy + 12);
        path.moveTo(center.dx + 4, center.dy + 8);
        path.lineTo(center.dx + 4, center.dy + 12);
        canvas.drawPath(path, paint);
        break;

      case LightMode.normal:
        // Low beam - headlight with angled beams downward
        canvas.drawCircle(center, size.width * 0.3, fillPaint);
        // Draw 3 angled lines going down-left
        for (int i = 0; i < 3; i++) {
          final startX = center.dx + 6;
          final startY = center.dy - 4 + (i * 4.0);
          canvas.drawLine(
            Offset(startX, startY),
            Offset(startX + 6, startY + 4),
            paint,
          );
        }
        break;

      case LightMode.highBeam:
        // High beam - headlight with straight horizontal beams
        canvas.drawCircle(center, size.width * 0.3, fillPaint);
        // Draw 4 horizontal lines going right
        for (int i = 0; i < 4; i++) {
          final startY = center.dy - 6 + (i * 4.0);
          canvas.drawLine(
            Offset(center.dx + 6, startY),
            Offset(center.dx + 14, startY),
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
    // Calculate the height from the bottom based on fill percentage
    final height = size.height * (1 - fillPercent);

    path.moveTo(0, size.height);
    path.lineTo(0, height);

    const waveAmplitude = 1.5; // Reduced from 3.0 to 1.5
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
