import 'dart:math';
import 'dart:io';
import 'package:car_dashboard/widgets/navigation/re_center_button.dart';
import 'package:car_dashboard/services/navigation_service.dart';
import 'package:car_dashboard/widgets/updates/app_updater_widget.dart';
import 'package:car_dashboard/widgets/updates/app_version_widget.dart';
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
  List<String> congestionLevels = [];
  bool isNavigating = false;
  bool _followUser = true;
  double? initialRouteHeading;
  double currentDeviceHeading = 0.0;

  // Store all alternative routes
  List<NavigationData> allRoutes = [];
  int selectedRouteIndex = 0;

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

  Future<List<NavigationData>> startNavigation({
    required double destinationLongitude,
    required double destinationLatitude,
    String profile = 'driving-traffic',
  }) async {
    if (currentLocation == null) {
      print('ERROR: Cannot start navigation - current location not available');
      return [];
    }

    final routes = await NavigationService.getDirections(
      startLongitude: currentLocation!.longitude,
      startLatitude: currentLocation!.latitude,
      endLongitude: destinationLongitude,
      endLatitude: destinationLatitude,
      profile: profile,
    );

    if (routes.isNotEmpty) {
      setState(() {
        allRoutes = routes;
        selectedRouteIndex = 0;
        routePoints = routes[0].routePoints;
        congestionLevels = routes[0].congestion;
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

    return routes;
  }

  void selectRoute(int index) {
    if (index >= 0 && index < allRoutes.length) {
      setState(() {
        selectedRouteIndex = index;
        routePoints = allRoutes[index].routePoints;
        congestionLevels = allRoutes[index].congestion;

        if (routePoints.length >= 2) {
          initialRouteHeading =
              calculateBearing(routePoints[0], routePoints[1]);
        }
      });

      if (routePoints.length > 1 && currentLocation != null) {
        _mapController.moveAndRotate(
          currentLocation!,
          19.5,
          -currentDeviceHeading,
          id: 'route-switch',
        );
      }
    }
  }

  void clearNavigation() {
    setState(() {
      routePoints = [];
      congestionLevels = [];
      allRoutes = [];
      selectedRouteIndex = 0;
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
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLngBounds bounds = _getCameraBounds(65000);

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
              tileDimension: 256,
              maxZoom: 22,
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/joost-kraan/cmi0mx1cp004y01qxbikff87k/tiles/256/{z}/{x}/{y}?access_token={accessToken}",
              additionalOptions: {
                'accessToken': dotenv.env["ACCESS_TOKEN"]!,
              },
            ),
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
                    color: Colors.blue.withValues(alpha: 0.9),
                    borderStrokeWidth: 2.5,
                    borderColor: Colors.white.withValues(alpha: 0.7),
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
        Positioned(bottom: 0, right: 0, child: AppVersionWidget()),
      ],
    );
  }
}
