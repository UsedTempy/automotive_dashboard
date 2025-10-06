import 'dart:math';
import 'dart:io'; // <-- add this
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
  List<String> congestionLevels = []; // congestion for each segment
  bool isNavigating = false;
  bool _followUser = true;
  double? initialRouteHeading;
  double currentDeviceHeading = 0.0;

  @override
  void initState() {
    super.initState();

    if (!Platform.isLinux) {
      _getCurrentLocation();
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((pos) {
      if (pos.speed > 0.3 && pos.heading.isFinite && pos.heading >= 0) {
        currentDeviceHeading = pos.heading;
      }

      setState(() {
        currentLocation = LatLng(pos.latitude, pos.longitude);
      });

      if (isNavigating) {
        _trimPassedRoute();
        _updateCameraToHeading();
      }
    });
  }

  LatLngBounds _getCameraBounds(double radiusMeters) {
    if (currentLocation == null) {
      return LatLngBounds(LatLng(0, 0), LatLng(0, 0));
    }

    final center = _mapController.camera.center;
    const earthRadius = 6378137.0;

    final dLat = radiusMeters / earthRadius * (180 / pi);
    final dLon = radiusMeters /
        (earthRadius * cos(pi * center.latitude / 180)) *
        (180 / pi);

    return LatLngBounds(
      LatLng(center.latitude - dLat, center.longitude - dLon),
      LatLng(center.latitude + dLat, center.longitude + dLon),
    );
  }

  void _trimPassedRoute() {
    if (currentLocation == null || routePoints.isEmpty) return;

    const distanceThreshold = 15.0;
    while (routePoints.length > 1) {
      final dist = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        routePoints.first.latitude,
        routePoints.first.longitude,
      );
      if (dist < distanceThreshold) {
        routePoints.removeAt(0);
        if (congestionLevels.isNotEmpty) {
          congestionLevels.removeAt(0);
        }
        if (routePoints.length >= 2) {
          initialRouteHeading =
              calculateBearing(routePoints[0], routePoints[1]);
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
      desiredAccuracy: LocationAccuracy.bestForNavigation,
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
      _followUser = true;
      if (isNavigating) {
        _mapController.moveAndRotate(
          currentLocation!,
          19.5,
          -currentDeviceHeading,
          id: 'navigation-recenter',
        );
      } else {
        _mapController.move(currentLocation!, 18);
      }
      setState(() {
        _isMapCentered = true;
      });
    }
  }

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

  void _updateCameraToHeading() {
    if (currentLocation != null && _followUser) {
      _mapController.moveAndRotate(
        currentLocation!,
        _mapController.camera.zoom,
        -currentDeviceHeading,
        id: 'navigation-tracking',
      );
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
        congestionLevels = navData.congestion; // congestion per segment
        isNavigating = true;
        _followUser = true;

        if (routePoints.length >= 2) {
          initialRouteHeading =
              calculateBearing(routePoints[0], routePoints[1]);
        }
      });

      if (routePoints.length > 1) {
        _mapController.moveAndRotate(
          currentLocation!,
          19.5,
          -currentDeviceHeading,
          id: 'navigation-start',
        );
      }
    }

    return navData;
  }

  void clearNavigation() {
    setState(() {
      routePoints = [];
      congestionLevels = [];
      isNavigating = false;
      initialRouteHeading = null;
      _followUser = true;
    });
    _recenterMap();
  }

  Color _getCongestionColor(String level) {
    switch (level) {
      case 'low':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      case 'heavy':
        return Colors.red;
      case 'severe':
        return Colors.black45;
      default:
        return Colors.blue; // default/unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLngBounds bounds =
        _getCameraBounds(65000); // 65000 meters around camera

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(51.509364, -0.128928),
            initialZoom: 18,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && currentLocation != null) {
                _followUser = false;
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

            // Draw route with congestion only if within camera bounds
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  for (int i = 0; i < routePoints.length - 1; i++)
                    if (bounds.contains(routePoints[i]) ||
                        bounds.contains(routePoints[i + 1]))
                      Polyline(
                        points: [routePoints[i], routePoints[i + 1]],
                        color: i < congestionLevels.length
                            ? _getCongestionColor(congestionLevels[i])
                            : Colors.blue,
                        strokeWidth: 6.0,
                      ),
                ],
              ),

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
