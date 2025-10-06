import 'package:car_dashboard/services/navigation_service.dart';
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
  String _destinationName = "";
  String _totalTime = "Loading...";
  String _totalDistance = "Loading...";
  List<NavigationData> _alternativeRoutes = [];
  int _selectedRouteIndex = 0;
  String _currentProfile = 'driving-traffic';

  // Store destination coordinates for re-routing
  double? _destinationLat;
  double? _destinationLon;

  void _startNavigation(double lat, double lon, String destinationName) async {
    setState(() {
      _isNavigating = true;
      _destinationName = destinationName;
      _destinationLat = lat;
      _destinationLon = lon;
    });

    final routes = await mapKey.currentState?.startNavigation(
      destinationLatitude: lat,
      destinationLongitude: lon,
      profile: _currentProfile,
    );

    if (routes != null && routes.isNotEmpty) {
      setState(() {
        _alternativeRoutes = routes;
        _selectedRouteIndex = 0;
        final selectedRoute = routes[0];

        final totalMinutes = selectedRoute.duration ~/ 60;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        _totalTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes} min';
        _totalDistance =
            '${(selectedRoute.distance / 1000).toStringAsFixed(1)} km';
      });
    } else {
      setState(() {
        _totalTime = "Loading...";
        _totalDistance = "Loading...";
        _alternativeRoutes = [];
      });
    }
  }

  void _selectRoute(int index) {
    if (index >= 0 && index < _alternativeRoutes.length) {
      mapKey.currentState?.selectRoute(index);

      setState(() {
        _selectedRouteIndex = index;
        final selectedRoute = _alternativeRoutes[index];

        final totalMinutes = selectedRoute.duration ~/ 60;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        _totalTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes} min';
        _totalDistance =
            '${(selectedRoute.distance / 1000).toStringAsFixed(1)} km';
      });
    }
  }

  void _changeProfile(String profile) async {
    if (_destinationLat == null || _destinationLon == null) return;

    setState(() {
      _currentProfile = profile;
      _totalTime = "Loading...";
      _totalDistance = "Loading...";
    });

    final routes = await mapKey.currentState?.startNavigation(
      destinationLatitude: _destinationLat!,
      destinationLongitude: _destinationLon!,
      profile: profile,
    );

    if (routes != null && routes.isNotEmpty) {
      setState(() {
        _alternativeRoutes = routes;
        _selectedRouteIndex = 0;
        final selectedRoute = routes[0];

        final totalMinutes = selectedRoute.duration ~/ 60;
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        _totalTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes} min';
        _totalDistance =
            '${(selectedRoute.distance / 1000).toStringAsFixed(1)} km';
      });
    }
  }

  void _cancelNavigation() {
    setState(() {
      _isNavigating = false;
      _destinationName = "";
      _totalTime = "Loading...";
      _totalDistance = "Loading...";
      _alternativeRoutes = [];
      _selectedRouteIndex = 0;
      _currentProfile = 'driving-traffic';
      _destinationLat = null;
      _destinationLon = null;
    });

    mapKey.currentState?.clearNavigation();
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
              _startNavigation(lat, lon, "Destination");
            },
          ),

        // If navigating → show overlay
        if (_isNavigating)
          NavigationOverlay(
            destinationName: _destinationName,
            totalTime: _totalTime,
            totalDistance: _totalDistance,
            alternativeRoutes: _alternativeRoutes,
            selectedRouteIndex: _selectedRouteIndex,
            onRouteSelected: _selectRoute,
            onProfileChanged: _changeProfile,
            currentProfile: _currentProfile,
            onCancel: _cancelNavigation,
          ),
      ],
    );
  }
}
