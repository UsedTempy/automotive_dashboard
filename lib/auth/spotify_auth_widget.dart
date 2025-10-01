import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyAuthWidget extends StatefulWidget {
  final String serverUrl;
  final VoidCallback? onLoginSuccess;

  const SpotifyAuthWidget({
    required this.serverUrl,
    this.onLoginSuccess,
    Key? key,
  }) : super(key: key);

  @override
  _SpotifyAuthWidgetState createState() => _SpotifyAuthWidgetState();
}

class _SpotifyAuthWidgetState extends State<SpotifyAuthWidget> {
  String? sessionId;
  String? loginUrl;
  String status = 'waiting';
  Map<String, dynamic>? tokens;
  Timer? _pollTimer;
  @override
  void initState() {
    super.initState();
    _createSession();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _createSession() async {
    try {
      final response =
          await http.post(Uri.parse('${widget.serverUrl}/create-session'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sessionId = data['sessionId'];
          loginUrl = data['loginUrl'];
          status = 'pending';
        });
        _startPolling();
      } else {
        setState(() => status = 'error');
      }
    } catch (e) {
      setState(() => status = 'error');
      print('Error creating session: $e');
    }
  }

  Future<void> _startPolling() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (sessionId == null) return;

      try {
        final response = await http.get(Uri.parse(
            '${widget.serverUrl}/session-status?sessionId=$sessionId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            if (data['status'] == 'success') {
              setState(() {
                tokens = data['tokens'];
                status = 'success';
              });
              _pollTimer?.cancel();

              // ✅ Save tokens properly
              await prefs.setString(
                  'SPOTIFY_ACCESS_TOKEN', tokens?['access_token'] ?? '');
              await prefs.setString(
                  'SPOTIFY_REFRESH_TOKEN', tokens?['refresh_token'] ?? '');
              await prefs.setInt(
                  'SPOTIFY_EXPIRES_IN', tokens?['expires_in'] ?? 0);

              if (widget.onLoginSuccess != null) {
                widget.onLoginSuccess!();
              }
            }
          } else if (data['status'] == 'error') {
            setState(() => status = 'error');
            _pollTimer?.cancel();
          }
        }
      } catch (e) {
        print('Polling error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'pending' && loginUrl != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: QrImageView(
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                data: loginUrl!,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                  'Scan this QR code with your phone to login to Spotify'),
            ),
          ],
        ),
      );
    } else if (status == 'success') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 10),
            Text('Spotify login successful!'),
          ],
        ),
      );
    } else if (status == 'error') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 10),
            Text('Something went wrong!'),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
