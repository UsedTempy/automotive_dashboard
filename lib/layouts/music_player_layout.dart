import 'package:flutter/material.dart';

import 'package:car_dashboard/widgets/album_art_widget.dart';
import 'package:car_dashboard/widgets/playback_controls_widget.dart';
import 'package:car_dashboard/widgets/song_info_widget.dart';
import 'package:car_dashboard/widgets/song_progress_bar_widget.dart';

class MusicPlayerLayout extends StatefulWidget {
  const MusicPlayerLayout({super.key});

  @override
  State<MusicPlayerLayout> createState() => _MusicPlayerLayoutState();
}

class _MusicPlayerLayoutState extends State<MusicPlayerLayout> {
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
          },
        ),
      ),
    );
  }
}