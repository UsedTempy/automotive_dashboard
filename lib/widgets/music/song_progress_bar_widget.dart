import 'package:flutter/material.dart';

class SongProgressBarWidget extends StatefulWidget {
  const SongProgressBarWidget({super.key});

  @override
  State<SongProgressBarWidget> createState() => _SongProgressBarWidgetState();
}

class _SongProgressBarWidgetState extends State<SongProgressBarWidget> {
  double _currentPosition = 0.41;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SliderTheme(
                data: const SliderThemeData(
                  trackHeight: 3,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Color(0xFF3A3A3A),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _currentPosition,
                  min: 0,
                  max: 1.57,
                  onChanged: (value) {
                    setState(() {
                      _currentPosition = value;
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    child: Text(
                      '0:41',
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      '-1:16',
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
