import 'package:flutter/material.dart';

class FanSliderThumb extends StatefulWidget {
  final double value;
  final Function(double) onChanged;

  const FanSliderThumb(
      {super.key, required this.value, required this.onChanged});

  @override
  State<FanSliderThumb> createState() => FanSliderThumbState();
}

class FanSliderThumbState extends State<FanSliderThumb>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
  }

  void _onPress() {
    _scaleController.forward(from: 0);
  }

  void _onRelease() {
    _scaleController.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final trackHeight = constraints.maxHeight;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (details) {
          _onPress();
          double newValue = 1 - (details.localPosition.dy / trackHeight);
          newValue = newValue.clamp(0.0, 1.0);
          widget.onChanged(newValue);
        },
        onVerticalDragUpdate: (details) {
          double newValue = 1 - (details.localPosition.dy / trackHeight);
          newValue = newValue.clamp(0.0, 1.0);
          widget.onChanged(newValue);
        },
        onVerticalDragEnd: (_) => _onRelease(),
        onTapDown: (details) {
          _onPress();
          double newValue = 1 - (details.localPosition.dy / trackHeight);
          newValue = newValue.clamp(0.0, 1.0);
          widget.onChanged(newValue);
        },
        onTapUp: (_) => _onRelease(),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) {
                  double pos = (trackHeight - 20) * widget.value;
                  Color color =
                  Color.lerp(Colors.blue, Colors.red, widget.value)!;
                  return Transform.translate(
                    offset: Offset(0, -pos),
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2)
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}