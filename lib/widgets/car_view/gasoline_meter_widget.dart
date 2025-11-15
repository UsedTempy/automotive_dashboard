import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class FuelMeter extends StatelessWidget {
  final double currentLitres;
  final double maxLitres;
  final bool showPercentage;

  const FuelMeter({
    Key? key,
    required this.currentLitres,
    required this.maxLitres,
    this.showPercentage = false,
  }) : super(key: key);

  Color _getFuelColor() {
    final percentage = (currentLitres / maxLitres) * 100;
    if (percentage < 25) {
      return const Color(0xFFFF4444);
    } else if (percentage < 60) {
      return const Color(0xFFFFAA00);
    } else {
      return const Color(0xFF00FF88);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (currentLitres / maxLitres).clamp(0.0, 1.0);
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Changed from .start to .end
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Container(
          width: screenWidth / 3,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: _getFuelColor(),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(right: 5, top: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF111111),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text(
                        '35/47L',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Symbols.local_gas_station,
                        size: 20,
                        color: Color(0xFF555555),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
