import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class SpotifyAuthWidget extends StatefulWidget {
  final String serverUrl; // e.g., 'http://81.172.187.107:3000'

  const SpotifyAuthWidget({required this.serverUrl, Key? key})
      : super(key: key);

  @override
  _SpotifyAuthWidgetState createState() => _SpotifyAuthWidgetState();
}

class _SpotifyAuthWidgetState extends State<SpotifyAuthWidget> {
  String? sessionId;
  String? loginUrl;
  String status = 'waiting'; // waiting, pending, success, error
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

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (sessionId == null) return;

      try {
        final response = await http.get(Uri.parse(
            '${widget.serverUrl}/session-status?sessionId=$sessionId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              tokens = data['tokens'];
              status = 'success';
            });
            _pollTimer?.cancel();

            // ✅ Print tokens to Flutter console
            print('🎶 Spotify Tokens: $tokens');
            print('Access Token: ${tokens?['access_token']}');
            print('Refresh Token: ${tokens?['refresh_token']}');
            print('Expires In: ${tokens?['expires_in']}');
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
              width: 250,
              height: 250,
              child: QrImageView(
                data: loginUrl!,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Scan this QR code with your phone to login to Spotify'),
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
