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

  bool _isNavigating = false;
  String _totalTime = "Loading..."; // placeholder
  String _totalDistance = "Loading..."; // placeholder

  void _startNavigation(double lat, double lon) async {
    setState(() {
      _isNavigating = true;
    });

    final returnedData = await mapKey.currentState?.startNavigation(
      destinationLatitude: lat,
      destinationLongitude: lon,
    );

    // later you can calculate total time/distance dynamically
    if (returnedData != null) {
      setState(() {
        final totalMinutes = returnedData.duration ~/ 60; // total minutes
        final hours = totalMinutes ~/ 60; // full hours
        final minutes = totalMinutes % 60; // remaining minutes
        _totalTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes} min';

        _totalDistance =
            '${(returnedData.distance / 1000).toStringAsFixed(1)} km';
        _isNavigating = true; // show overlay only now
      });
    } else {
      setState(() {
        _totalTime = "Loading...";
        _totalDistance = "Loading...";
        _isNavigating = true; // still show overlay with "loading"
      });
    }
  }

  void _cancelNavigation() {
    setState(() {
      _isNavigating = false;
    });

    mapKey.currentState?.clearNavigation(); // if you have such a function
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMapWidget(key: mapKey),

        // If not navigating → show search
        if (!_isNavigating)
          Navigation(
            onNavigate: (lat, lon) {
              _startNavigation(lat, lon);
            },
          ),

        // If navigating → show overlay
        if (_isNavigating)
          NavigationOverlay(
            totalTime: _totalTime,
            totalDistance: _totalDistance,
            onCancel: _cancelNavigation,
          ),
      ],
    );
  }
}
