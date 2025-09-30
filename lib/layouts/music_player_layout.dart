import 'package:flutter/material.dart';

class MusicPlayerLayout extends StatefulWidget {
  const MusicPlayerLayout({super.key});

  @override
  State<MusicPlayerLayout> createState() => _MusicPlayerLayoutState();
}

class _MusicPlayerLayoutState extends State<MusicPlayerLayout> {
  double _currentPosition = 0.41;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                
                // Album Art - Large and centered
                Flexible(
                  flex: 12,
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        final size = boxConstraints.maxHeight < boxConstraints.maxWidth * 0.8
                            ? boxConstraints.maxHeight * 0.9
                            : boxConstraints.maxWidth * 0.7;
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF2C4A6E),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.music_note_rounded,
                              color: const Color(0xFF5A7BA8),
                              size: size * 0.35,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Song Info
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'search & destroy',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'ericdoa',
                                    style: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 0,
                          child: FittedBox(
                            child: IconButton(
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Progress Bar
                Flexible(
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
                ),
                
                const Spacer(flex: 1),
                
                // Playback Controls
                Flexible(
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
                ),
                
                const Spacer(flex: 1),
                
                const Spacer(flex: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}