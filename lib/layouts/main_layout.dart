import 'package:flutter/material.dart';

import 'package:car_dashboard/screens/navigation.dart';
import 'package:car_dashboard/layouts/bottom_left_bar_layout.dart';
import 'package:car_dashboard/layouts/bottom_bar_layout.dart';
import 'package:car_dashboard/layouts/island_layout.dart';
import 'package:car_dashboard/auth/spotify_service.dart';

class MainLayout extends StatelessWidget {
  final Function(bool) onMusicButtonToggle;
  final bool isMusicPlayerVisible;

  const MainLayout({
    super.key,
    required this.onMusicButtonToggle,
    required this.isMusicPlayerVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const NavigationScreen(),
        BottomBarLayout(
          onMusicButtonToggle: onMusicButtonToggle,
          isMusicPlayerVisible: isMusicPlayerVisible,
        ),
        const BottomLeftBarLayout(),
        const IslandLayout(),

        // Voeg dit even normaal goed toe ofzo
        // Center(
        //   child: SpotifyAuthWidget(
        //       serverUrl:
        //           'https://matilde-unconquerable-vincibly.ngrok-free.dev'))
      ],
    );
  }
}
