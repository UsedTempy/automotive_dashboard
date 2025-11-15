import 'package:car_dashboard/services/navigation_service.dart';
import 'package:car_dashboard/templates/searchResults.dart';
import 'package:car_dashboard/widgets/navigation/search_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class Navigation extends StatefulWidget {
  final Function(double, double)? onNavigate; // Add callback

  const Navigation({super.key, this.onNavigate});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showResults = false;
  bool _isLoading = false;
  List<SearchResult> _searchResults = [];
  Timer? _debounce;
  late String _sessionToken;

  double longPos = 6.609763;
  double latPos = 52.69607;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _sessionToken = "1309d86d-7c78-4bb6-b282-b8a2ccc72d3e";
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      longPos = position.longitude;
      latPos = position.latitude;
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final query = _searchController.text;

    if (query.isEmpty) {
      _showResults = false;
      _searchResults = [];
      _isLoading = false;
      setState(() {});
      return;
    }

    _showResults = true;
    _isLoading = true;
    setState(() {});

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      final accessToken = dotenv.env['ACCESS_TOKEN'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ACCESS_TOKEN not found in .env file');
      }

      final url = Uri.parse('https://api.mapbox.com/search/searchbox/v1/suggest'
          '?q=${Uri.encodeComponent(query)}'
          '&access_token=$accessToken'
          '&session_token=$_sessionToken'
          '&language=en'
          '&limit=6'
          '&types=country,region,district,postcode,locality,place,neighborhood,address,poi,street,category'
          '&proximity=$longPos,$latPos');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = data['suggestions'] as List<dynamic>;

        final results = suggestions.map((suggestion) {
          final distance = suggestion['distance'];
          String distanceStr = '';
          if (distance != null) {
            final distanceMeters = distance.toDouble();
            if (distanceMeters >= 1000) {
              distanceStr = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
            } else {
              distanceStr = '${distanceMeters.toInt()} m';
            }
          }

          return SearchResult(
              name: suggestion['name'] ?? '',
              location: suggestion['place_formatted'] ??
                  suggestion['full_address'] ??
                  '',
              distance: distanceStr,
              id: suggestion['mapbox_id']);
        }).toList();

        if (_searchController.text.isNotEmpty) {
          _searchResults = results;
          _isLoading = false;
          setState(() {});
        }
      } else {
        throw Exception(
            'Failed to load search results: ${response.statusCode}');
      }
    } catch (e) {
      if (_searchController.text.isNotEmpty) {
        _isLoading = false;
        _searchResults = [];
        setState(() {});
      }
      print('Error performing search: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 280,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  if (_isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF9E9E9E),
                      ),
                    )
                  else
                    const Icon(
                      Icons.search,
                      color: Color(0xFF9E9E9E),
                      size: 18,
                    ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Navigate',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Opacity(
                      opacity: _searchController.text.isNotEmpty ? 1.0 : 0.0,
                      child: InkWell(
                        onTap: _searchController.text.isNotEmpty
                            ? () {
                                _searchController.clear();
                              }
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.clear,
                            color: Color(0xFF9E9E9E),
                            size: 16,
                          ),
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
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _searchResults.isEmpty && !_isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No results found',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _searchResults.map((result) {
                            return SearchItemWidget(
                                result: result,
                                onTap: () async {
                                  final session_Token =
                                      "1309d86d-7c78-4bb6-b282-b8a2ccc72d3e"; // const Uuid().v4();
                                  print('Selected: ${result.id}');

                                  // Retrieve coordinates
                                  final locationData =
                                      await NavigationService.retrieveLocation(
                                          result.id, session_Token);

                                  if (locationData != null) {
                                    // Call the callback to trigger navigation on the map
                                    widget.onNavigate?.call(
                                      locationData['latitude']!,
                                      locationData['longitude']!,
                                    );
                                  }

                                  _searchController.clear();
                                  _focusNode.unfocus();
                                  _sessionToken = session_Token;
                                });
                          }).toList(),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
