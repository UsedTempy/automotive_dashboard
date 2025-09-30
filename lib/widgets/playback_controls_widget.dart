import 'package:flutter/material.dart';

class PlaybackControlsWidget extends StatefulWidget {
  const PlaybackControlsWidget({super.key});

  @override
  State<PlaybackControlsWidget> createState() => _PlaybackControlsWidgetState();
}

class _PlaybackControlsWidgetState extends State<PlaybackControlsWidget> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.shuffle,
                    color: Color(0xFF999999),
                    size: 30,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Flexible(
              flex: 5,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {},
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
                    onPressed: () {
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
            Flexible(
              flex: 5,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {},
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
            Flexible(
              flex: 3,
              child: FittedBox(
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.repeat,
                    color: Color(0xFF999999),
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
