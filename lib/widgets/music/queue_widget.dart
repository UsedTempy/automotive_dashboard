import 'package:flutter/material.dart';
import 'dart:async';
import 'package:car_dashboard/services/spotify_service.dart';

class QueueWidget extends StatefulWidget {
  const QueueWidget({super.key});

  @override
  State<QueueWidget> createState() => _QueueWidgetState();
}

class _QueueWidgetState extends State<QueueWidget> {
  List<Map<String, String>> _queue = [];
  bool _isLoading = false;
  StreamSubscription<Map<String, String>?>? _songSubscription;

  @override
  void initState() {
    super.initState();
    _loadQueue();

    // Listen to song changes and refresh queue
    _songSubscription = SpotifyService.songStream.listen((song) {
      if (song != null) {
        _loadQueue();
      }
    });
  }

  @override
  void dispose() {
    _songSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadQueue() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    setState(() => _isLoading = true);
    final queue = await SpotifyService.getQueue(limit: 10);
    if (mounted) {
      setState(() {
        _queue = queue;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(String durationMs) {
    final ms = int.tryParse(durationMs) ?? 0;
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Color.fromRGBO(17, 17, 17, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next in Queue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2,
                      ),
                    )
                  : _queue.isEmpty
                      ? Center(
                          child: Text(
                            'No songs in queue',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _queue.length,
                          itemBuilder: (context, index) {
                            final song = _queue[index];
                            return InkWell(
                              onTap: () async {
                                final position =
                                    int.tryParse(song['position'] ?? '0');
                                if (position != null) {
                                  await SpotifyService.skipToQueuePosition(
                                      position);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    // Album Art
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child:
                                          song['albumArt']?.isNotEmpty == true
                                              ? Image.network(
                                                  song['albumArt']!,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _buildPlaceholder(),
                                                )
                                              : _buildPlaceholder(),
                                    ),
                                    SizedBox(width: 12),
                                    // Song Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song['title'] ?? 'Unknown',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            song['artist'] ?? 'Unknown Artist',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    // Duration
                                    Text(
                                      _formatDuration(song['duration'] ?? '0'),
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.white30,
        size: 20,
      ),
    );
  }
}
