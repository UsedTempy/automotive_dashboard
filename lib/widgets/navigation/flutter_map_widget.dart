import 'package:car_dashboard/widgets/navigation/re_center_button.dart';
import 'package:car_dashboard/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

class FlutterMapWidget extends StatefulWidget {
  const FlutterMapWidget({super.key});

  @override
  State<FlutterMapWidget> createState() => FlutterMapWidgetState();
}

// Changed to public so it can be accessed via GlobalKey
class FlutterMapWidgetState extends State<FlutterMapWidget> {
  final MapController _mapController = MapController();
  LatLng? currentLocation;
  bool _isMapCentered = true;
  List<LatLng> routePoints = [];
  bool isNavigating = false;

  void _checkIfMapCentered() {
    if (currentLocation == null) return;

    final center = _mapController.camera.center;
    final distance = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      center.latitude,
      center.longitude,
    );

    final isCentered = distance < 10;

    if (isCentered != _isMapCentered) {
      setState(() {
        _isMapCentered = isCentered;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });

    _mapController.move(currentLocation!, 18);
  }

  void _recenterMap() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 18);
      setState(() {
        _isMapCentered = true;
      });
    }
  }

  // Public method to start navigation with directions
  Future<void> startNavigation({
    required double destinationLongitude,
    required double destinationLatitude,
  }) async {
    if (currentLocation == null) {
      print('ERROR: Cannot start navigation - current location not available');
      return;
    }

    print(
        'DEBUG: Starting navigation from ${currentLocation!.latitude}, ${currentLocation!.longitude} to $destinationLatitude, $destinationLongitude');

    final navData = await NavigationService.getDirections(
      startLongitude: currentLocation!.longitude,
      startLatitude: currentLocation!.latitude,
      endLongitude: destinationLongitude,
      endLatitude: destinationLatitude,
    );

    if (navData != null) {
      print(
          'DEBUG: Navigation data received with ${navData.routePoints.length} points');

      setState(() {
        routePoints = navData.routePoints;
        isNavigating = true;
      });

      print(
          'DEBUG: State updated - routePoints: ${routePoints.length}, isNavigating: $isNavigating');

      // Adjust map to show the full route
      if (routePoints.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
          ),
        );
        print('DEBUG: Map camera adjusted to fit route bounds');
      }
    } else {
      print('ERROR: Failed to get navigation data from API');
    }
  }

  // Method to clear navigation
  void clearNavigation() {
    setState(() {
      routePoints = [];
      isNavigating = false;
    });
    _recenterMap();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (routePoints.isNotEmpty) {
      print('DEBUG: Rendering polyline with ${routePoints.length} points');
    }

    return Stack(
      children: [
        // The map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(51.509364, -0.128928),
            initialZoom: 18,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && currentLocation != null) {
                _checkIfMapCentered();
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
              additionalOptions: {
                'accessToken': dotenv.env["ACCESS_TOKEN"]!,
                'id': 'dark-v11',
              },
            ),
            // Navigation route polyline (draw first, under everything)
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    color: Colors.blue.withOpacity(0.8),
                    strokeWidth: 6.0,
                  ),
                ],
              ),
            // Destination marker
            if (routePoints.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: routePoints.last,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            // Current location marker (on top)
            if (currentLocation != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: currentLocation!,
                    radius: 5,
                    color: Colors.blue.withOpacity(0.9),
                    borderStrokeWidth: 2.5,
                    borderColor: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
          ],
        ),

        // Recenter button
        if (currentLocation != null && !_isMapCentered)
          Positioned(
            bottom: 85,
            left: 20,
            child: RecenterButton(onTap: _recenterMap),
          ),

        // Clear navigation button (when navigating)
        if (isNavigating)
          Positioned(
            bottom: 85,
            right: 20,
            child: FloatingActionButton(
              onPressed: clearNavigation,
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
            ),
          ),
      ],
    );
  }
}
