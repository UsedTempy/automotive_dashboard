import 'dart:async';
import 'package:car_dashboard/services/spotify_service.dart';
import 'package:flutter/material.dart';

class SongProgressBarWidget extends StatefulWidget {
  const SongProgressBarWidget({super.key});

  @override
  State<SongProgressBarWidget> createState() => SongProgressBarWidgetState();
}

class SongProgressBarWidgetState extends State<SongProgressBarWidget> {
  double _currentPosition = 0;
  double _maxDuration = 1;
  Timer? _syncTimer;
  Timer? _uiTimer;
  bool _isDragging = false;
  bool _isPlaying = false;
  int _lastProgressMs = 0;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _startProgressSystem();
  }

  void _startProgressSystem() {
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await syncWithSpotify();
    });

    _uiTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isDragging && _isPlaying && _lastUpdateTime != null) {
        final now = DateTime.now();
        final elapsedMs = now.difference(_lastUpdateTime!).inMilliseconds;

        setState(() {
          _currentPosition =
              ((_lastProgressMs + elapsedMs) / 1000).clamp(0.0, _maxDuration);
        });
      }
    });

    syncWithSpotify();
  }

  Future<void> syncWithSpotify() async {
    if (_isDragging) return;

    final playback = await SpotifyService.getCurrentPlayback();
    if (!mounted) return;

    if (playback != null) {
      final progress = (playback["progress_ms"] ?? 0) as int;
      final duration = (playback["item"]?["duration_ms"] ?? 0) as int;
      final isPlaying = playback["is_playing"] == true;

      if (duration > 0) {
        setState(() {
          _maxDuration = duration / 1000;
          _currentPosition = (progress / 1000).clamp(0.0, _maxDuration);
          _isPlaying = isPlaying;
          _lastProgressMs = progress;
          _lastUpdateTime = DateTime.now();
        });
      }
    }
  }

  void resetSlider() {
    setState(() {
      _currentPosition = 0;
      _lastProgressMs = 0;
      _lastUpdateTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _uiTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final mins = (seconds ~/ 60).toString();
    final secs = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Color(0xFF3A3A3A),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _currentPosition,
              min: 0,
              max: _maxDuration,
              onChangeStart: (_) => _isDragging = true,
              onChanged: (value) {
                setState(() {
                  _currentPosition = value;
                });
              },
              onChangeEnd: (value) async {
                final seekMs = (value * 1000).toInt();
                await SpotifyService.seek(seekMs);
                setState(() {
                  _isDragging = false;
                  _lastProgressMs = seekMs;
                  _lastUpdateTime = DateTime.now();
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) syncWithSpotify();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _formatDuration(_maxDuration),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
