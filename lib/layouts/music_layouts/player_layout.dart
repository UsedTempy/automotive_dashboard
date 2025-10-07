import 'package:car_dashboard/services/spotify_service.dart';
import 'package:car_dashboard/widgets/music/logout.widget.dart';
import 'package:flutter/material.dart';

import 'package:car_dashboard/widgets/music/album_art_widget.dart';
import 'package:car_dashboard/widgets/music/playback_controls_widget.dart';
import 'package:car_dashboard/widgets/music/song_info_widget.dart';
import 'package:car_dashboard/widgets/music/song_progress_bar_widget.dart';
import 'package:car_dashboard/widgets/music/queue_widget.dart';

class PlayerLayout extends StatefulWidget {
  final VoidCallback? onLogout;

  const PlayerLayout({super.key, this.onLogout});

  @override
  State<PlayerLayout> createState() => _PlayerLayoutState();
}

class _PlayerLayoutState extends State<PlayerLayout> {
  final GlobalKey<SongProgressBarWidgetState> sliderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 16),
            LogoutButton(onLogout: widget.onLogout),
            const Spacer(flex: 1),
            AlbumArtWidget(),
            const Spacer(flex: 2),
            SizedBox(width: double.infinity, child: SongInfoWidget()),
            const Spacer(flex: 1),
            SongProgressBarWidget(key: sliderKey),
            const Spacer(flex: 1),
            PlaybackControlsWidget(
              onSkipNext: () async {
                sliderKey.currentState?.resetSlider();
                await SpotifyService.next();
                Future.delayed(const Duration(milliseconds: 200), () {
                  sliderKey.currentState?.syncWithSpotify();
                });
              },
              onSkipPrevious: () async {
                sliderKey.currentState?.resetSlider();
                await SpotifyService.previous();
                Future.delayed(const Duration(milliseconds: 200), () {
                  sliderKey.currentState?.syncWithSpotify();
                });
              },
            ),
            const SizedBox(height: 10),
            QueueWidget(),
          ],
        ),
      ),
    );
  }
}
