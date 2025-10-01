import 'package:flutter/material.dart';
import 'package:car_dashboard/auth/spotify_service.dart';

class SongInfoWidget extends StatefulWidget {
  const SongInfoWidget({super.key});

  @override
  State<SongInfoWidget> createState() => _SongInfoWidgetState();
}

class _SongInfoWidgetState extends State<SongInfoWidget> {
  String _title = "—";
  String _artist = "";

  @override
  void initState() {
    super.initState();

    // 1️⃣ Get current song immediately
    SpotifyService.getCurrentlyPlaying().then((song) {
      if (!mounted) return;
      if (song != null) {
        setState(() {
          _title = song["title"]!;
          _artist = song["artist"]!;
        });
      }
    });

    // 2️⃣ Subscribe to song changes
    SpotifyService.startSongListener();
    SpotifyService.songStream.listen((song) {
      if (!mounted) return; // prevent setState after dispose
      if (song != null) {
        setState(() {
          _title = song["title"]!;
          _artist = song["artist"]!;
        });
      }
    });
  }

  @override
  void dispose() {
    SpotifyService.stopSongListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
                        _title,
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
                        _artist,
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
    );
  }
}
