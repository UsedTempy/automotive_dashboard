import 'package:flutter/material.dart';

import 'package:car_dashboard/widgets/music/album_art_widget.dart';
import 'package:car_dashboard/widgets/music/playback_controls_widget.dart';
import 'package:car_dashboard/widgets/music/song_info_widget.dart';
import 'package:car_dashboard/widgets/music/song_progress_bar_widget.dart';

class PlayerLayout extends StatefulWidget {
  const PlayerLayout({super.key});

  @override
  State<PlayerLayout> createState() => _PlayerLayoutState();
}

class _PlayerLayoutState extends State<PlayerLayout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        // Album Art
        AlbumArtWidget(),
        const Spacer(flex: 2),
        // Song Info
        SongInfoWidget(),
        const Spacer(flex: 1),
        // Progress Bar
        SongProgressBarWidget(),
        const Spacer(flex: 1),
        // Playback Controls
        PlaybackControlsWidget(),
        const Spacer(flex: 1),
      ],
    );
  }
}
