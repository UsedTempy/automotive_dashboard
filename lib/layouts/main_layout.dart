import 'package:car_dashboard/layouts/car_view_layout/3d_model_layout.dart';
import 'package:car_dashboard/layouts/providers_island_layout.dart';
import 'package:car_dashboard/widgets/console/center_console_widget.dart';
import 'package:flutter/material.dart';

import 'package:car_dashboard/screens/navigation.dart';
import 'package:car_dashboard/layouts/bottom_left_bar_layout.dart';
import 'package:car_dashboard/layouts/bottom_bar_layout.dart';
import 'package:car_dashboard/layouts/island_layout.dart';

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
        // Use a Column to divide the screen vertically
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: ModelLayout(),
            ),
            Expanded(
              flex: 2,
              child: const NavigationScreen(),
            ),
          ],
        ),
        const BottomLeftBarLayout(),

        BottomBarLayout(
          onMusicButtonToggle: onMusicButtonToggle,
          isMusicPlayerVisible: isMusicPlayerVisible,
        ),

        const IslandLayout(),
        const ProvidersIslandLayout(),
        //const CenterConsoleWidget(),
      ],
    );
  }
}
