import 'package:car_dashboard/auth/spotify_service.dart';
import 'package:flutter/material.dart';

import 'package:car_dashboard/screens/navigation.dart';
import 'package:car_dashboard/layouts/bottom_left_bar_layout.dart';
import 'package:car_dashboard/layouts/bottom_bar_layout.dart';
import 'package:car_dashboard/layouts/island_layout.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(alignment: Alignment.bottomCenter, children: [
      NavigationScreen(),
      BottomBarLayout(),
      BottomLeftBarLayout(),
      IslandLayout(),
    ]);
  }
}
