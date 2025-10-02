import 'package:car_dashboard/widgets/navigation/navigation_overlay_widget.dart';
import 'package:flutter/material.dart';

import 'package:car_dashboard/widgets/navigation/flutter_map_widget.dart';
import 'package:car_dashboard/widgets/navigation/navigation_widget.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  final GlobalKey<FlutterMapWidgetState> mapKey =
      GlobalKey<FlutterMapWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMapWidget(key: mapKey),
        Navigation(onNavigate: (lat, lon) {
          mapKey.currentState?.startNavigation(
            destinationLatitude: lat,
            destinationLongitude: lon,
          );
        }),

        // Overlay UI on top
        NavigationOverlay(
          totalTime: "10 hr 53 min",
          totalDistance: "1033 km",
          onCancel: () {
            print("Route cancelled");
          },
        ),
      ],
    );
  }
}
