import 'package:car_dashboard/layouts/providers_island_layout.dart';
import 'package:flutter/material.dart';
import 'package:car_dashboard/screens/navigation.dart';
import 'package:car_dashboard/layouts/island_layout.dart';

class MainLayout extends StatelessWidget {
  final Function(bool) onMusicButtonToggle;
  final Function(bool) onCarButtonToggle;
  final bool isMusicPlayerVisible;
  final bool isCarModelVisible;

  const MainLayout({
    super.key,
    required this.onMusicButtonToggle,
    required this.isMusicPlayerVisible,
    required this.isCarModelVisible,
    required this.onCarButtonToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const NavigationScreen(),
        const IslandLayout(),
        const ProvidersIslandLayout(),
        //const CenterConsoleWidget(),
      ],
    );
  }
}
