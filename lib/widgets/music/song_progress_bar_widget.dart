import 'dart:async';

import 'package:car_dashboard/auth/spotify_service.dart';
import 'package:flutter/material.dart';

class SongProgressBarWidget extends StatefulWidget {
  const SongProgressBarWidget({super.key});

  @override
  State<SongProgressBarWidget> createState() => _SongProgressBarWidgetState();
}

class _SongProgressBarWidgetState extends State<SongProgressBarWidget> {
  double _currentPosition = 0;
  double _maxDuration = 1; // prevent division by 0
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgressPolling();
  }

  void _startProgressPolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final playback = await SpotifyService.getCurrentPlayback();
      if (!mounted) return; // <-- prevent setState after dispose
      if (playback != null) {
        setState(() {
          _currentPosition = playback["progress_ms"] / 1000;
          _maxDuration = playback["duration_ms"] / 1000;
        });
      } else {
        setState(() {
          _currentPosition = 0;
          _maxDuration = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final mins = (seconds ~/ 60).toString();
    final secs = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$mins:$secs';
  }

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
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Color(0xFF3A3A3A),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _currentPosition.clamp(0, _maxDuration),
                  min: 0,
                  max: _maxDuration,
                  onChanged: (value) async {
                    setState(() {
                      _currentPosition = value;
                    });
                    // Optional: seek Spotify to this position
                    // await SpotifyService.seek(value.toInt() * 1000);
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
                Text(
                  _formatDuration(_currentPosition),
                  style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  _formatDuration(_maxDuration - _currentPosition),
                  style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
