import 'package:car_dashboard/services/spotify_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutButton extends StatefulWidget {
  final VoidCallback? onLogout;

  const LogoutButton({super.key, this.onLogout});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  String _username = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('SPOTIFY_USERNAME');
    String? profileImage = prefs.getString('SPOTIFY_PROFILE_IMAGE');

    // If data not found, fetch it from Spotify API
    if (username == null || username.isEmpty || profileImage == null) {
      final profile = await SpotifyService.getUserProfile();
      if (profile != null) {
        username = profile['display_name'] ?? profile['id'] ?? 'User';

        // Get profile image from images array
        if (profile['images'] != null &&
            (profile['images'] as List).isNotEmpty) {
          final imageUrl = profile['images'][0]['url'];
          if (imageUrl != null) {
            profileImage = imageUrl;
            await prefs.setString('SPOTIFY_PROFILE_IMAGE', profileImage!);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _username = username ?? 'User';
        _profileImageUrl = profileImage;
      });
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
      await prefs.remove('SPOTIFY_PROFILE_IMAGE');
      await prefs.remove('LAST_PLAYBACK');
      await prefs.remove('LAST_QUEUE');

      // Call the logout callback
      if (widget.onLogout != null) {
        widget.onLogout!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _logout,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _profileImageUrl != null
                      ? CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(_profileImageUrl!),
                          backgroundColor: const Color(0xFF1DB954),
                        )
                      : const CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFF1DB954),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    );
  }
}
