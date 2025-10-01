import 'package:car_dashboard/auth/spotify_auth_widget.dart';
import 'package:flutter/material.dart';

class LoginLayout extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginLayout({super.key, required this.onLoginSuccess});

  @override
  State<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFF111111),
        child: Center(
          child: SpotifyAuthWidget(
            serverUrl: 'https://matilde-unconquerable-vincibly.ngrok-free.dev',
            onLoginSuccess: widget.onLoginSuccess,
          ),
        ),
      ),
    );
  }
}
