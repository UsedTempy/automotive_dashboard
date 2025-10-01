import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyService {
  static const String _currentlyPlayingUrl =
      "https://api.spotify.com/v1/me/player/currently-playing";

  static const SPOTIFY_CLIENT_ID = '214388d81ea9484a8e38e7ed2582306b';
  static const SPOTIFY_CLIENT_SECRET = '78624d3139d34cc0b3b6e2d76e4e63c8';
  static const REDIRECT_URI =
      'https://matilde-unconquerable-vincibly.ngrok-free.dev/callback';

  static final StreamController<Map<String, String>?> _songController =
      StreamController.broadcast();

  static Timer? _pollTimer;
  static Map<String, String>? _lastSong;

  /// Start polling the currently playing song every [interval] ms
  static void startSongListener({int interval = 300}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(milliseconds: interval), (_) async {
      final song = await getCurrentlyPlaying();
      // Only emit if song changed
      if (_lastSong == null ||
          (song != null &&
              (song['title'] != _lastSong?['title'] ||
                  song['artist'] != _lastSong?['artist']))) {
        _lastSong = song;
        _songController.add(song);
      }
    });
  }

  static void stopSongListener() {
    _pollTimer?.cancel();
  }

  static Stream<Map<String, String>?> get songStream => _songController.stream;

  /// ================= AUTH & TOKEN MANAGEMENT =================
  static Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('SPOTIFY_ACCESS_TOKEN');
    final refreshToken = prefs.getString('SPOTIFY_REFRESH_TOKEN');
    final expiresIn = prefs.getInt('SPOTIFY_EXPIRES_IN') ?? 0;
    final tokenTimestamp = prefs.getInt('SPOTIFY_TOKEN_TIMESTAMP') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      if (now >= tokenTimestamp + expiresIn) {
        return await _refreshAccessToken(refreshToken);
      } else {
        return accessToken;
      }
    }
    return null;
  }

  static Future<String?> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(
                utf8.encode('$SPOTIFY_CLIENT_ID:$SPOTIFY_CLIENT_SECRET')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('SPOTIFY_ACCESS_TOKEN', data['access_token']);
      await prefs.setInt('SPOTIFY_EXPIRES_IN', data['expires_in']);
      await prefs.setInt('SPOTIFY_TOKEN_TIMESTAMP',
          DateTime.now().millisecondsSinceEpoch ~/ 1000);

      return data['access_token'];
    } else {
      print('Failed to refresh token: ${response.body}');
      return null;
    }
  }

  /// ================= API HELPERS =================
  static Future<dynamic> _get(String endpoint) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse("https://api.spotify.com/v1$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("GET $endpoint failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  static Future<dynamic> _put(String endpoint,
      {Map<String, dynamic>? body}) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await http.put(
      Uri.parse("https://api.spotify.com/v1$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: body != null ? json.encode(body) : null,
    );

    if ([200, 201, 204].contains(response.statusCode)) {
      return true;
    } else {
      print("PUT $endpoint failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  static Future<dynamic> _delete(String endpoint) async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await http.delete(
      Uri.parse("https://api.spotify.com/v1$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );

    if ([200, 204].contains(response.statusCode)) {
      return true;
    } else {
      print("DELETE $endpoint failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  /// ================= PLAYER CONTROL =================
  static Future<Map<String, String>?> getCurrentlyPlaying() async {
    final token = await _getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(_currentlyPlayingUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = json.decode(response.body);
      return {
        "title": data["item"]["name"],
        "artist":
            (data["item"]["artists"] as List).map((a) => a["name"]).join(", "),
        "albumArt": (data["item"]["album"]["images"] as List).isNotEmpty
            ? data["item"]["album"]["images"][0]["url"]
            : "",
        "id": data["item"]["id"], // needed for like/unlike
      };
    } else if (response.statusCode == 204) {
      return null;
    } else {
      print("Spotify API error: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentPlayback() async {
    return await _get("/me/player");
  }

  static Future<void> play() async {
    await _put("/me/player/play");
  }

  static Future<void> pause() async {
    await _put("/me/player/pause");
  }

  static Future<void> next() async {
    final token = await _getAccessToken();
    if (token == null) return;
    await http.post(
      Uri.parse("https://api.spotify.com/v1/me/player/next"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  static Future<void> previous() async {
    final token = await _getAccessToken();
    if (token == null) return;
    await http.post(
      Uri.parse("https://api.spotify.com/v1/me/player/previous"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  static Future<void> toggleShuffle(bool state) async {
    await _put("/me/player/shuffle?state=$state");
  }

  static Future<void> setRepeat(String mode) async {
    await _put("/me/player/repeat?state=$mode");
  }

  static Future<void> seek(int positionMs) async {
    await _put("/me/player/seek?position_ms=$positionMs");
  }

  /// ================= LIBRARY (LIKED SONGS) =================
  static Future<bool> isTrackSaved(String trackId) async {
    final response = await _get("/me/tracks/contains?ids=$trackId");
    if (response != null && response is List && response.isNotEmpty) {
      return response[0] == true;
    }
    return false;
  }

  static Future<void> saveTrack(String trackId) async {
    await _put("/me/tracks?ids=$trackId", body: {});
  }

  static Future<void> removeTrack(String trackId) async {
    await _delete("/me/tracks?ids=$trackId");
  }
}
