import 'package:flutter/material.dart';

import 'package:car_dashboard/layouts/music_layouts/login_layout.dart';
import 'package:car_dashboard/layouts/music_layouts/player_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicPlayerLayout extends StatefulWidget {
  const MusicPlayerLayout({super.key});

  @override
  State<MusicPlayerLayout> createState() => _MusicPlayerLayoutState();
}

class _MusicPlayerLayoutState extends State<MusicPlayerLayout> {
  bool _isLoading = true;
  bool _hasTokens = false;

  @override
  void initState() {
    super.initState();
    _checkTokens();
  }

  Future<void> _checkTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('SPOTIFY_ACCESS_TOKEN');
      final refreshToken = prefs.getString('SPOTIFY_REFRESH_TOKEN');
      print(accessToken);
      print(refreshToken);

      setState(() {
        _hasTokens = accessToken != null &&
            refreshToken != null &&
            accessToken.isNotEmpty &&
            refreshToken.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasTokens = false;
        _isLoading = false;
      });
    }
  }
  void refreshLayout() {
    setState(() {
      _isLoading = true;
    });
    _checkTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            }
            return _hasTokens
                ? const PlayerLayout()
                : LoginLayout(onLoginSuccess: refreshLayout); // ✅
          },
        ),
      ),
    );
  }
}
