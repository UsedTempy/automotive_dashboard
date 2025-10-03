import 'package:car_dashboard/services/spotify_service.dart';
import 'package:flutter/material.dart';

import 'package:car_dashboard/widgets/music/album_art_widget.dart';
import 'package:car_dashboard/widgets/music/playback_controls_widget.dart';
import 'package:car_dashboard/widgets/music/song_info_widget.dart';
import 'package:car_dashboard/widgets/music/song_progress_bar_widget.dart';
import 'package:car_dashboard/widgets/music/queue_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerLayout extends StatefulWidget {
  final VoidCallback? onLogout;

  const PlayerLayout({super.key, this.onLogout});

  @override
  State<PlayerLayout> createState() => _PlayerLayoutState();
}

class _PlayerLayoutState extends State<PlayerLayout> {
  final GlobalKey<SongProgressBarWidgetState> sliderKey = GlobalKey();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('SPOTIFY_USERNAME');

    // If username not found, fetch it from Spotify API
    if (username == null || username.isEmpty) {
      final profile = await SpotifyService.getUserProfile();
      username = profile?['display_name'] ?? profile?['id'] ?? 'User';
    }

    if (mounted) {
      setState(() => _username = username!);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout from $_username?',
          style: const TextStyle(color: Color(0xFFB3B3B3)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Stop the song listener
      SpotifyService.stopSongListener();

      // Clear all Spotify-related data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('SPOTIFY_ACCESS_TOKEN');
      await prefs.remove('SPOTIFY_REFRESH_TOKEN');
      await prefs.remove('SPOTIFY_EXPIRES_IN');
      await prefs.remove('SPOTIFY_TOKEN_TIMESTAMP');
      await prefs.remove('SPOTIFY_USERNAME');
      await prefs.remove('LAST_PLAYBACK');
      await prefs.remove('LAST_QUEUE');

      if (widget.onLogout != null) {
        widget.onLogout!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282828),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
