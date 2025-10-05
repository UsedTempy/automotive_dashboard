import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:car_dashboard/widgets/navigation/re_center_button.dart';
import 'package:car_dashboard/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

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

  // POIs
  List<Map<String, dynamic>> pois = [];
  static const double poiVisibleZoomThreshold = 15.0;

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

  // Deduplicate POIs with same name and close proximity
  List<Map<String, dynamic>> _deduplicatePOIs(List<Map<String, dynamic>> rawPOIs) {
    const double proximityThreshold = 50.0; // meters
    List<Map<String, dynamic>> deduplicated = [];
    Map<String, List<Map<String, dynamic>>> groupedByName = {};

    // Group POIs by name
    for (var poi in rawPOIs) {
      String name = poi["name"];
      if (name.isEmpty) {
        deduplicated.add(poi);
        continue;
      }
      if (!groupedByName.containsKey(name)) {
        groupedByName[name] = [];
      }
      groupedByName[name]!.add(poi);
    }

    // Process each group
    for (var group in groupedByName.values) {
      if (group.length == 1) {
        deduplicated.add(group[0]);
        continue;
      }

      // Cluster nearby POIs with same name
      List<List<Map<String, dynamic>>> clusters = [];
      for (var poi in group) {
        bool addedToCluster = false;
        for (var cluster in clusters) {
          // Check if POI is close to any member of this cluster
          bool isClose = cluster.any((clusterPoi) {
            double distance = Geolocator.distanceBetween(
              poi["lat"],
              poi["lon"],
              clusterPoi["lat"],
              clusterPoi["lon"],
            );
            return distance <= proximityThreshold;
          });
          if (isClose) {
            cluster.add(poi);
            addedToCluster = true;
            break;
          }
        }
        if (!addedToCluster) {
          clusters.add([poi]);
        }
      }

      // For each cluster, create a single POI at the center
      for (var cluster in clusters) {
        double avgLat = cluster.map((p) => p["lat"] as double).reduce((a, b) => a + b) / cluster.length;
        double avgLon = cluster.map((p) => p["lon"] as double).reduce((a, b) => a + b) / cluster.length;
        deduplicated.add({
          "lat": avgLat,
          "lon": avgLon,
          "type": cluster[0]["type"],
          "name": cluster[0]["name"],
        });
      }
    }

    return deduplicated;
  }

  // --- POI FETCHING ---
  Future<void> fetchPOIs(LatLngBounds bounds) async {
    final query = '''
      [out:json];
      (
        node["amenity"="restaurant"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["amenity"="fast_food"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["amenity"="fuel"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["shop"="supermarket"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["railway"="station"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["railway"="halt"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["public_transport"="stop_position"]["bus"="yes"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
        node["highway"="bus_stop"](${bounds.south},${bounds.west},${bounds.north},${bounds.east});
      );
      out;
    ''';
    final url = Uri.parse('https://overpass-api.de/api/interpreter?data=$query');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final elements = (data["elements"] as List).map((e) {
          String type = "";
          if (e["tags"]?["amenity"] != null) {
            type = e["tags"]["amenity"];
          } else if (e["tags"]?["shop"] != null) {
            type = e["tags"]["shop"];
          } else if (e["tags"]?["railway"] != null) {
            type = "train_station";
          } else if (e["tags"]?["highway"] == "bus_stop" || 
                     e["tags"]?["public_transport"] == "stop_position") {
            type = "bus_stop";
          }
          
          return {
            "lat": e["lat"],
            "lon": e["lon"],
            "type": type,
            "name": e["tags"]?["name"] ?? "",
          };
        }).toList();
        
        final deduplicatedPOIs = _deduplicatePOIs(elements);
        setState(() => pois = deduplicatedPOIs);
      }
    } catch (e) {
      debugPrint("POI fetch error: $e");
    }
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
        if (congestionLevels.isNotEmpty) congestionLevels.removeAt(0);
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
      setState(() => _isMapCentered = isCentered);
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
    final pos =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
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
      setState(() => _isMapCentered = true);
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
    return (atan2(y, x) * 180 / pi + 360) % 360;
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
      debugPrint('Cannot start navigation - no location');
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
        congestionLevels = navData.congestion;
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
        return Colors.blue;
    }
  }

  IconData _getIconForPOI(String type) {
    switch (type) {
      case "fast_food":
        return Icons.fastfood;
      case "fuel":
        return Icons.local_gas_station;
      case "supermarket":
        return Icons.shopping_cart;
      case "train_station":
        return Icons.train;
      case "bus_stop":
        return Icons.directions_bus;
      default:
        return Icons.restaurant;
    }
  }

  Color _getColorForPOI(String type) {
    switch (type) {
      case "fast_food":
        return Colors.purple;
      case "fuel":
        return Colors.green;
      case "supermarket":
        return Colors.blue;
      case "train_station":
        return Colors.red;
      case "bus_stop":
        return Colors.teal;
      default:
        return Colors.orange;
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
            onMapReady: () async => await fetchPOIs(_getCameraBounds(1000)),
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && currentLocation != null) {
                _followUser = false;
                _checkIfMapCentered();
              }
              // Fetch POIs when moving around
              if (position.zoom != null && position.center != null) {
                fetchPOIs(_getCameraBounds(1000));
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}",
              additionalOptions: {
                'accessToken': dotenv.env["ACCESS_TOKEN"]!,
                'id': 'dark-v11',
              },
              tileSize: 512,
              zoomOffset: -1,
            ),

            // Draw route
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

            // --- POIs ---
            if (pois.isNotEmpty &&
                _mapController.camera.zoom >= poiVisibleZoomThreshold)
              MarkerLayer(
                markers: pois.map((poi) {
                  final String type = poi["type"];
                  final String name = poi["name"];
                  final Color color = _getColorForPOI(type);

                  return Marker(
                    point: LatLng(poi["lat"], poi["lon"]),
                    width: 80,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Colored circle with white outline
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            _getIconForPOI(type),
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Text with white outline stroke
                        Stack(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2.5
                                  ..color = Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // Current location marker
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