import 'package:car_dashboard/auth/spotify_service.dart';
import 'package:flutter/material.dart';

class PlaybackControlsWidget extends StatefulWidget {
  const PlaybackControlsWidget({super.key});

  @override
  State<PlaybackControlsWidget> createState() => _PlaybackControlsWidgetState();
}

class _PlaybackControlsWidgetState extends State<PlaybackControlsWidget> {
  bool _isPlaying = false;
  bool _shuffle = false;
  String _repeatMode = 'off';

  @override
  void initState() {
    super.initState();
    _initPlaybackState();
  }

  Future<void> _initPlaybackState() async {
    final playback = await SpotifyService.getCurrentPlayback();
    if (!mounted) return;

    setState(() {
      _isPlaying = playback?["is_playing"] ?? false;
      _shuffle = playback?["shuffle_state"] ?? false;
      _repeatMode = playback?["repeat_state"] ?? "off";
    });
  }

  void _cycleRepeat() async {
    String nextMode;
    switch (_repeatMode) {
      case 'off':
        nextMode = 'context';
        break;
      case 'context':
        nextMode = 'track';
        break;
      case 'track':
      default:
        nextMode = 'off';
        break;
    }

    await SpotifyService.setRepeat(nextMode);
    if (!mounted) return;
    setState(() {
      _repeatMode = nextMode;
    });
  }

  /// Toggle shuffle
  void _toggleShuffle() async {
    final nextState = !_shuffle;
    await SpotifyService.toggleShuffle(nextState);
    if (!mounted) return;
    setState(() {
      _shuffle = nextState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shuffle
            Flexible(
              flex: 3,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: _toggleShuffle,
                  icon: Icon(
                    Icons.shuffle,
                    color: _shuffle ? Colors.green : Color(0xFF999999),
                    size: 30,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),

            // Previous Track
            Flexible(
              flex: 5,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () async => await SpotifyService.previous(),
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white,
                    size: 54,
                    weight: 700,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),

            // Play / Pause
            Flexible(
              flex: 6,
              child: FittedBox(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      if (_isPlaying) {
                        await SpotifyService.pause();
                      } else {
                        await SpotifyService.play();
                      }
                      if (!mounted) return;
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                    },
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),

            // Next Track
            Flexible(
              flex: 5,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () async => await SpotifyService.next(),
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white,
                    size: 54,
                    weight: 700,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),

            // Repeat
            Flexible(
              flex: 3,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: _cycleRepeat,
                  icon: Icon(
                    Icons.repeat,
                    color:
                        _repeatMode == 'off' ? Color(0xFF999999) : Colors.green,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
