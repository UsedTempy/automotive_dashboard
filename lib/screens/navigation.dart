import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:car_dashboard/widgets/re_center_button.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  LatLng? currentLocation;
  bool _isMapCentered = true;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
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

    // Consider centered if within 10 meters (more sensitive)
    final isCentered = distance < 10;

    if (isCentered != _isMapCentered) {
      print("Debugged?");
      setState(() {
        _isMapCentered = isCentered;
      });
    }
  }

  // Re-center map to current location
  void _recenterMap() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, _mapController.camera.zoom);
      setState(() {
        _isMapCentered = true;
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

    _mapController.move(currentLocation!, 15); // Center map
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(51.509364, -0.128928), // Default London
          initialZoom: 1,
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
      if (currentLocation != null && !_isMapCentered)
        Positioned(
          bottom: 85,
          left: 20,
          child: RecenterButton(onTap: _recenterMap),
        ),
    ]);
  }
}
