import 'dart:math';
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

class FlutterMapWidgetState extends State<FlutterMapWidget> {
  final MapController _mapController = MapController();
  LatLng? currentLocation;
  bool _isMapCentered = true;
  List<LatLng> routePoints = [];
  bool isNavigating = false;
  double? initialRouteHeading; // Store the initial direction
  double currentDeviceHeading = 0.0; // Device compass heading

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Live location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      setState(() {
        currentLocation = LatLng(pos.latitude, pos.longitude);
        // Update device heading from GPS bearing
        if (pos.heading.isFinite && pos.heading >= 0) {
          currentDeviceHeading = pos.heading;
        }
      });

      if (isNavigating) {
        _trimPassedRoute();
        _updateCameraToHeading();
      }
    });
  }

  // Trim passed polyline points
  void _trimPassedRoute() {
    if (currentLocation == null || routePoints.isEmpty) return;

    const distanceThreshold = 15.0; // meters
    while (routePoints.length > 1) {
      final dist = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        routePoints.first.latitude,
        routePoints.first.longitude,
      );
      if (dist < distanceThreshold) {
        routePoints.removeAt(0);
        // Recalculate heading when route points change
        if (routePoints.length >= 2) {
          initialRouteHeading = calculateBearing(routePoints[0], routePoints[1]);
        }
      } else {
        break;
      }
    }
    setState(() {});
  }

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
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
      if (pos.heading.isFinite && pos.heading >= 0) {
        currentDeviceHeading = pos.heading;
      }
    });

    _mapController.move(currentLocation!, 18);
  }

  void _recenterMap() {
    if (currentLocation != null) {
      if (isNavigating && currentDeviceHeading != null) {
        // When navigating, recenter with the device heading
        _updateCameraToHeading();
      } else {
        // Normal recenter without rotation
        _mapController.move(currentLocation!, 18);
      }
      setState(() {
        _isMapCentered = true;
      });
    }
  }

  // Calculate bearing
  double calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * pi / 180;
    final lon1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lon2 = end.longitude * pi / 180;

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x);
    return (bearing * 180 / pi + 360) % 360;
  }

  // Camera aligned with device heading
  void _updateCameraToHeading() {
    if (currentLocation != null) {
      // Move camera to current location
      _mapController.move(currentLocation!, 19.5);
      
      // Rotate map opposite to device heading so arrow points up
      _mapController.rotate(-currentDeviceHeading);
    }
  }

  Future<NavigationData?> startNavigation({
    required double destinationLongitude,
    required double destinationLatitude,
  }) async {
    if (currentLocation == null) {
      print('ERROR: Cannot start navigation - current location not available');
      return null;
    }

    final navData = await NavigationService.getDirections(
      startLongitude: currentLocation!.longitude,
      startLatitude: currentLocation!.latitude,
      endLongitude: destinationLongitude,
      endLatitude: destinationLatitude,
    );

    if (navData != null) {
      setState(() {
        routePoints = navData.routePoints;
        isNavigating = true;
        
        // Calculate and store the initial heading from the first two points
        if (routePoints.length >= 2) {
          initialRouteHeading = calculateBearing(routePoints[0], routePoints[1]);
        }
      });

      if (routePoints.length > 1) {
        _updateCameraToHeading();
      }
    }

    return navData;
  }

  void clearNavigation() {
    setState(() {
      routePoints = [];
      isNavigating = false;
      initialRouteHeading = null;
    });
    _recenterMap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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

            // Route
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

            // Destination marker (counter-rotates to always face up)
            if (routePoints.isNotEmpty)
              MarkerLayer(
                rotate: true,
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

            // Navigation arrow at current location, facing device heading
            if (isNavigating && currentLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation!,
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                      angle: currentDeviceHeading * pi / 180,
                      child: const Icon(
                        Icons.navigation,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else if (currentLocation != null)
              // Show dot if not navigating
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

        if (currentLocation != null && !_isMapCentered)
          Positioned(
            bottom: 85,
            left: 20,
            child: RecenterButton(onTap: _recenterMap),
          ),
      ],
    );
  }
}