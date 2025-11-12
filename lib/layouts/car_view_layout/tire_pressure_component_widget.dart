import 'package:flutter/material.dart';

class TirePressureComponentWidget extends StatefulWidget {
  const TirePressureComponentWidget({super.key});

  @override
  State<TirePressureComponentWidget> createState() =>
      _TirePressureWidgetState();
}

class _TirePressureWidgetState extends State<TirePressureComponentWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '2.3 bar',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 15,
              ),
              const SizedBox(width: 2),
              Text(
                '12m ago',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
