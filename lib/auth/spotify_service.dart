import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

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

  // Replace with your ngrok login URL
  final String loginUrl =
      'https://matilde-unconquerable-vincibly.ngrok-free.dev/login';

  // Local server for capturing the redirect
  final int localPort = 8889;

  Future<void> startAuth() async {
    setState(() => loading = true);

    // Step 1: Start local HTTP server
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, localPort);
    print('Listening at http://127.0.0.1:$localPort');

    // Step 2: Listen for callback
    _listenForCallback();

    // Step 3: Open WebView (Windows)
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpotifyWebViewPage(loginUrl: loginUrl),
        ),
      );
    }
  }

  Future<void> _listenForCallback() async {
    if (_server == null) return;

    await for (HttpRequest request in _server!) {
      try {
        print('Received request: ${request.uri}');
        final params = request.uri.queryParameters;

        if (params.containsKey('refresh_token')) {
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
                '<html><body><h2>Spotify login successful!</h2><p>You can close this window.</p><script>window.close();</script></body></html>')
            ..close();

          await _server?.close(force: true);
          _server = null;

          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          break;
        } else if (params.containsKey('error')) {
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
          break;
        } else {
          request.response
            ..statusCode = 400
            ..write('Invalid callback')
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
                    : const Icon(Icons.login),
                label: Text(loading ? 'Logging in...' : 'Login with Spotify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
    );
  }

  Widget _buildSuccessBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✓ Login Successful!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 16),
          const Text('Refresh Token:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(refreshToken ?? '',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          if (accessToken != null) ...[
            const SizedBox(height: 12),
            const Text('Access Token:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText(accessToken!,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ],
          if (expiresIn != null) ...[
            const SizedBox(height: 12),
            Text('Expires in: $expiresIn seconds',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: SelectableText(refreshToken ?? '',
          style: const TextStyle(color: Colors.red)),
    );
  }
}

class SpotifyWebViewPage extends StatefulWidget {
  final String loginUrl;
  const SpotifyWebViewPage({super.key, required this.loginUrl});

  @override
  State<SpotifyWebViewPage> createState() => _SpotifyWebViewPageState();
}

class _SpotifyWebViewPageState extends State<SpotifyWebViewPage> {
  final WebviewController _controller = WebviewController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    initWebView();
  }

  Future<void> initWebView() async {
    await _controller.initialize();
    await _controller.loadUrl(widget.loginUrl);

    _controller.url.listen((url) {
      print("Navigated to: $url");
      if (url.contains("127.0.0.1:8889") || url.contains("localhost:8889")) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login to Spotify"),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            Webview(_controller, permissionRequested: _onPermissionRequested),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  WebviewPermissionDecision _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) {
    return WebviewPermissionDecision.allow;
  }
}
