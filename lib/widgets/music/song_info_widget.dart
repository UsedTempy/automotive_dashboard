import 'package:flutter/material.dart';
import 'package:car_dashboard/services/spotify_service.dart';
import 'dart:async';

class SongInfoWidget extends StatefulWidget {
  const SongInfoWidget({super.key});

  @override
  State<SongInfoWidget> createState() => _SongInfoWidgetState();
}

class _SongInfoWidgetState extends State<SongInfoWidget> {
  String _title = "—";
  String _artist = "";
  String? _trackId;
  bool _isFavorite = false;
  Timer? _likeStatusTimer;

  @override
  void initState() {
    super.initState();

    SpotifyService.getCurrentlyPlaying().then((song) async {
      if (!mounted || song == null) return;

      final liked = await SpotifyService.isTrackSaved(song["id"]!);
      if (!mounted) return;

      setState(() {
        _title = song["title"]!;
        _artist = song["artist"]!;
        _trackId = song["id"];
        _isFavorite = liked;
      });

      _startLikeStatusPolling();
    });

    SpotifyService.startSongListener();
    SpotifyService.songStream.listen((song) async {
      if (!mounted || song == null) return;

      final liked = await SpotifyService.isTrackSaved(song["id"]!);
      if (!mounted) return;

      setState(() {
        _title = song["title"]!;
        _artist = song["artist"]!;
        _trackId = song["id"];
        _isFavorite = liked;
      });

      _startLikeStatusPolling();
    });
  }

  void _startLikeStatusPolling() {
    _likeStatusTimer?.cancel();
    _likeStatusTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _trackId == null) return;

      final liked = await SpotifyService.isTrackSaved(_trackId!);
      if (!mounted) return;

      if (liked != _isFavorite) {
        setState(() => _isFavorite = liked);
      }
    });
  }

  @override
  void dispose() {
    _likeStatusTimer?.cancel();
    SpotifyService.stopSongListener();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_trackId == null) return;

    if (_isFavorite) {
      await SpotifyService.removeTrack(_trackId!);
      setState(() => _isFavorite = false);
    } else {
      await SpotifyService.saveTrack(_trackId!);
      setState(() => _isFavorite = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _artist,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
