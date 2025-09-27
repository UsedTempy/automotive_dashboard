import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/center_button.dart';
import '../widgets/fan_slider_thumb.dart';
import '../widgets/recenter_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late String currentTime;
  String selectedCenterButton = "gps";
  bool fanActive = false;
  double fanSliderValue = 0.5;
  int fanSpeed = 1;

  bool frontDefrost = false;
  bool rearDefrost = false;

  LatLng? currentLocation;
  final MapController _mapController = MapController();
  bool _isMapCentered = true;

  @override
  void initState() {
    super.initState();
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateTime();
    });
    _getCurrentLocation();
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final period = now.hour >= 12 ? "PM" : "AM";

    setState(() {
      currentTime = "$hour12:${now.minute.toString().padLeft(2, '0')} $period";
    });
  }

  void _selectCenterButton(String button) {
    setState(() => selectedCenterButton = button);
  }

  void _toggleFan() => setState(() => fanActive = !fanActive);
  void _decreaseFanSpeed() => setState(() {
        if (fanSpeed > 1) fanSpeed--;
      });
  void _increaseFanSpeed() => setState(() {
        if (fanSpeed < 3) fanSpeed++;
      });

  void _toggleFrontDefrost() => setState(() => frontDefrost = !frontDefrost);
  void _toggleRearDefrost() => setState(() => rearDefrost = !rearDefrost);

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

    _mapController.move(currentLocation!, 15);
  }

  void _recenterMap() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, _mapController.camera.zoom);
      setState(() {
        _isMapCentered = true;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Container(
          width: 1000,
          height: 450,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF252525)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(51.509364, -0.128928),
                            initialZoom: 6,
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
                            bottom: 20,
                            left: 20,
                            child: RecenterButton(onTap: _recenterMap),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF111111),
                      border: Border(top: BorderSide(color: Color(0xFF252525))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CenterButton(
                          icon: FontAwesomeIcons.locationDot,
                          isSelected: selectedCenterButton == "gps",
                          onTap: () => _selectCenterButton("gps"),
                        ),
                        const SizedBox(width: 12),
                        CenterButton(
                          icon: FontAwesomeIcons.music,
                          isSelected: selectedCenterButton == "music",
                          onTap: () => _selectCenterButton("music"),
                        ),
                        const SizedBox(width: 12),
                        CenterButton(
                          icon: FontAwesomeIcons.camera,
                          isSelected: selectedCenterButton == "camera",
                          onTap: () => _selectCenterButton("camera"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 15,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    currentTime,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (fanActive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: SizedBox(
                          height: 180,
                          width: 30,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.blue, Colors.red],
                                  ),
                                ),
                              ),
                              FanSliderThumb(
                                value: fanSliderValue,
                                onChanged: (v) =>
                                    setState(() => fanSliderValue = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          child: fanActive && fanSpeed > 1
                              ? GestureDetector(
                                  onTap: _decreaseFanSpeed,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.chevron_left,
                                        color: Colors.white70, size: 20),
                                  ),
                                )
                              : null,
                        ),
                        CenterButton(
                          icon: FontAwesomeIcons.fan,
                          isSelected: fanActive,
                          onTap: _toggleFan,
                          activeColor: Colors.yellow,
                          fanSpeed: fanSpeed,
                        ),
                        SizedBox(
                          width: 28,
                          child: fanActive && fanSpeed < 3
                              ? GestureDetector(
                                  onTap: _increaseFanSpeed,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.chevron_right,
                                        color: Colors.white70, size: 20),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 30,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CenterButton(
                      icon: MdiIcons.carDefrostFront,
                      isSelected: frontDefrost,
                      onTap: _toggleFrontDefrost,
                      activeColor: Colors.yellow,
                    ),
                    const SizedBox(width: 10),
                    CenterButton(
                      icon: MdiIcons.carDefrostRear,
                      isSelected: rearDefrost,
                      onTap: _toggleRearDefrost,
                      activeColor: Colors.yellow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
