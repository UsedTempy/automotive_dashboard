import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:car_dashboard/widgets/navigation/re_center_button.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  LatLng? currentLocation;
  bool _isMapCentered = true;
  bool _showResults = false;

  // Sample search results - replace with actual search logic
  final List<SearchResult> _searchResults = [
    SearchResult(
        name: 'Noordscheschut',
        location: 'Noordscheschut, Nederland',
        distance: '6,2 km'),
    SearchResult(
        name: 'Noordwijk',
        location: 'Noordwijk, Nederland',
        distance: '154 km'),
    SearchResult(
        name: 'Noordwolde',
        location: 'Noordwolde, Nederland',
        distance: '39 km'),
    SearchResult(
        name: 'Noord-Sleen',
        location: 'Noord-Sleen, Nederland',
        distance: '18 km'),
    SearchResult(
        name: 'Nooitgedacht',
        location: 'Nooitgedacht, Nederland',
        distance: '32 km'),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(() {
      setState(() {
        _showResults = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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
      setState(() {
        _isMapCentered = isCentered;
      });
    }
  }

  // Re-center map to current location
  void _recenterMap() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 18);
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

    _mapController.move(currentLocation!, 18); // Center map
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(51.509364, -0.128928), // Default London
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

        // Search bar and results
        Positioned(
          top: 20,
          left: 20,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF9E9E9E),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5, // slightly smaller
                            fontWeight:
                                FontWeight.w500, // less bold while typing
                            height: 1.2, // tighter line height
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Navigate',
                            hintStyle: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400, // lighter hint
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _showResults = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 28, // bigger circle for tap
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.clear,
                                color: Color(0xFF9E9E9E),
                                size: 16, // keep icon size, just bigger circle
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Search results dropdown
                if (_showResults)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _searchResults.map((result) {
                          return _SearchResultItem(
                            result: result,
                            onTap: () {
                              // Handle location selection
                              print('Selected: ${result.name}');
                              _searchController.clear();
                              _focusNode.unfocus();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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

class _SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF3A3A3A),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF3A3A3A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF9E9E9E),
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      result.location,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                result.distance,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  final String name;
  final String location;
  final String distance;

  SearchResult({
    required this.name,
    required this.location,
    required this.distance,
  });
}
