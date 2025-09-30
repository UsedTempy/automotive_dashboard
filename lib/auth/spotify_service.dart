import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(const SpotifyService());

class SpotifyService extends StatelessWidget {
  const SpotifyService({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SpotifyAuthPage(),
    );
  }
}

class SpotifyAuthPage extends StatefulWidget {
  const SpotifyAuthPage({super.key});

  @override
  State<SpotifyAuthPage> createState() => _SpotifyAuthPageState();
}

class _SpotifyAuthPageState extends State<SpotifyAuthPage> {
  String? refreshToken;
  String? accessToken;
  int? expiresIn;
  bool loading = false;
  HttpServer? _server;

  // Your ngrok login URL
  final String loginUrl =
      'https://matilde-unconquerable-vincibly.ngrok-free.dev/login';

  // Local server for capturing the redirect
  final int localPort = 8889;

  // Replace your startAuth() method in Flutter:

  Future<void> startAuth() async {
    setState(() => loading = true);

    try {
      // Step 1: Start local HTTP server - bind to all interfaces
      _server = await HttpServer.bind(InternetAddress.anyIPv4, localPort);
      print('✓ Server started on port $localPort');
      print('  Listening on all network interfaces (0.0.0.0:$localPort)');

      // Step 2: Listen for callback
      _listenForCallback();

      // Step 3: Show QR code for login
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotifyQrPage(loginUrl: loginUrl),
          ),
        );
      }
    } catch (e) {
      print('Error starting server: $e');
      setState(() {
        loading = false;
        refreshToken = 'Error: Could not start local server - $e';
      });
    }
  }

  Future<void> _listenForCallback() async {
    if (_server == null) return;

    await for (HttpRequest request in _server!) {
      try {
        print('Received request: ${request.uri}');
        print('Query parameters: ${request.uri.queryParameters}');

        final params = request.uri.queryParameters;

        // Send CORS headers immediately
        request.response.headers
          ..set('Access-Control-Allow-Origin', '*')
          ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ..set('Access-Control-Allow-Headers', 'Content-Type');

        // Handle preflight requests
        if (request.method == 'OPTIONS') {
          request.response
            ..statusCode = 200
            ..close();
          continue;
        }

        if (params.containsKey('refresh_token')) {
          print('✓ Tokens received!');
          print(
              'Refresh token: ${params['refresh_token']?.substring(0, 20)}...');
          print('Access token: ${params['access_token']?.substring(0, 20)}...');

          setState(() {
            refreshToken = params['refresh_token'];
            accessToken = params['access_token'];
            expiresIn = int.tryParse(params['expires_in'] ?? '');
            loading = false;
          });

          request.response
            ..statusCode = 200
            ..headers.set('Content-Type', 'text/html')
            ..write(
                '<html><body><h2>Spotify login successful!</h2><p>You can close this window.</p></body></html>')
            ..close();

          // Close server and navigate
          await _server?.close(force: true);
          _server = null;

          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          break;
        } else if (params.containsKey('error')) {
          print('✗ Error received: ${params['error']}');

          setState(() {
            refreshToken = 'Error: ${params['error']}';
            loading = false;
          });

          request.response
            ..statusCode = 400
            ..headers.set('Content-Type', 'text/html')
            ..write('<html><body><h2>Login failed</h2>'
                '<p>${params['error']}</p></body></html>')
            ..close();

          await _server?.close(force: true);
          _server = null;

          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          break;
        } else {
          print('Invalid callback - no tokens or error');
          request.response
            ..statusCode = 200
            ..write('OK')
            ..close();
        }
      } catch (e) {
        print('Error processing callback: $e');
        request.response
          ..statusCode = 500
          ..write('Error processing callback')
          ..close();
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify OAuth Demo'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 80, color: Colors.green[700]),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: loading ? null : startAuth,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.qr_code),
                  label:
                      Text(loading ? 'Waiting for login...' : 'Login via QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
                if (refreshToken != null && !refreshToken!.startsWith('Error'))
                  _buildSuccessBox()
                else if (refreshToken != null)
                  _buildErrorBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 28),
              const SizedBox(width: 8),
              const Text(
                'Login Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Access Token Section
          _buildTokenCard(
            title: 'Access Token',
            token: accessToken ?? 'Not available',
            icon: Icons.key,
            onCopy: accessToken != null
                ? () => _copyToClipboard(accessToken!, 'Access Token')
                : null,
          ),

          const SizedBox(height: 16),

          // Refresh Token Section
          _buildTokenCard(
            title: 'Refresh Token',
            token: refreshToken ?? 'Not available',
            icon: Icons.refresh,
            onCopy: refreshToken != null
                ? () => _copyToClipboard(refreshToken!, 'Refresh Token')
                : null,
          ),

          if (expiresIn != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Expires in: ${expiresIn! ~/ 60} minutes (${expiresIn}s)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTokenCard({
    required String title,
    required String token,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: onCopy,
                  tooltip: 'Copy to clipboard',
                  color: Colors.green[700],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              token,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red[700], size: 48),
          const SizedBox(height: 12),
          const Text(
            'Login Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            refreshToken ?? '',
            style: TextStyle(color: Colors.red[900]),
          ),
        ],
      ),
    );
  }
}

class SpotifyQrPage extends StatelessWidget {
  final String loginUrl;
  const SpotifyQrPage({super.key, required this.loginUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR to Login"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan with your phone',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: QrImageView(
                data: loginUrl,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Waiting for authentication...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
