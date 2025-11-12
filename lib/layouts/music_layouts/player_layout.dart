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
    return Container(
      color: const Color(0xFF000000),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            LogoutButton(onLogout: widget.onLogout),
            const SizedBox(height: 24),

            // Album Art
            AlbumArtWidget(),
            const SizedBox(height: 30),

            // Song Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SongInfoWidget(),
            ),

            // Progress Bar
            SongProgressBarWidget(key: sliderKey),
            const SizedBox(height: 20),

            // Playback Controls
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
            const SizedBox(height: 5),

            // Queue - takes natural height based on content
            QueueWidget(),
          ],
        ),
      ),
    );
  }
}
