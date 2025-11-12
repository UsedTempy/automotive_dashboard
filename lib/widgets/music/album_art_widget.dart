import 'package:flutter/material.dart';
import 'package:car_dashboard/services/spotify_service.dart';

class AlbumArtWidget extends StatefulWidget {
  const AlbumArtWidget({super.key});

  @override
  State<AlbumArtWidget> createState() => _AlbumArtWidgetState();
}

class _AlbumArtWidgetState extends State<AlbumArtWidget> {
  String? _albumArtUrl;

  @override
  void initState() {
    super.initState();

    // Fetch current song immediately
    SpotifyService.getCurrentlyPlaying().then((song) {
      if (!mounted) return;
      setState(() {
        _albumArtUrl = song?['albumArt'];
      });
    });

    // Start listening for updates
    SpotifyService.startSongListener();
    SpotifyService.songStream.listen((song) {
      if (!mounted) return;
      setState(() {
        _albumArtUrl = song?['albumArt'];
      });
    });
  }

  @override
  void dispose() {
    SpotifyService.stopSongListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2C4A6E),
          image: _albumArtUrl != null && _albumArtUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(_albumArtUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _albumArtUrl == null || _albumArtUrl!.isEmpty
            ? Center(
                child: Icon(
                  Icons.music_note_rounded,
                  color: const Color(0xFF5A7BA8),
                  size: 87.5, // 250 * 0.35
                ),
              )
            : null,
      ),
    );
  }
}
