import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class NavigationService {
  static Future<Map<String, dynamic>?> retrieveLocation(String mapboxId, String sessionToken) async {
    try {
      final accessToken = dotenv.env['ACCESS_TOKEN'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ACCESS_TOKEN not found in .env file');
      }

      final url = Uri.parse(
        'https://api.mapbox.com/search/searchbox/v1/retrieve/$mapboxId'
        '?session_token=$sessionToken'
        '&access_token=$accessToken'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract coordinates
        final coordinates = data['features']?[0]?['geometry']?['coordinates'];
        
        if (coordinates != null && coordinates is List && coordinates.length >= 2) {
          double longitude = coordinates[0];
          double latitude = coordinates[1];
          
          return {
            'longitude': longitude,
            'latitude': latitude,
          };
        } else {
          print('No coordinates found in response');
          return null;
        }
      } else {
        throw Exception('Failed to retrieve location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving location: $e');
      return null;
    }
  }

  static Future<NavigationData?> getDirections({
    required double startLongitude,
    required double startLatitude,
    required double endLongitude,
    required double endLatitude,
  }) async {
    try {
      final accessToken = dotenv.env['ACCESS_TOKEN'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('ACCESS_TOKEN not found in .env file');
      }

      final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/'
        '$startLongitude,$startLatitude;$endLongitude,$endLatitude'
        '?alternatives=true'
        '&annotations=maxspeed,congestion,closure'
        '&banner_instructions=true'
        '&geometries=geojson'
        '&language=en'
        '&overview=full'
        '&roundabout_exits=true'
        '&steps=true'
        '&voice_instructions=true'
        '&voice_units=metric'
        '&access_token=$accessToken'
      );

      print('Directions API call initiated');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse routes and extract GeoJSON coordinates
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]; // Use the first route
          final geometry = route['geometry'];
          
          print('DEBUG: Route geometry type: ${geometry?['type']}');
          print('DEBUG: Coordinates available: ${geometry?['coordinates'] != null}');
          
          // Extract coordinates from GeoJSON LineString
          List<LatLng> routePoints = [];
          if (geometry != null && geometry['coordinates'] != null) {
            final coordinates = geometry['coordinates'] as List;
            routePoints = coordinates.map((coord) {
              // GeoJSON format is [longitude, latitude]
              return LatLng(coord[1].toDouble(), coord[0].toDouble());
            }).toList();
            
            print('DEBUG: Successfully extracted ${routePoints.length} route points');
            if (routePoints.isNotEmpty) {
              print('DEBUG: First point: ${routePoints.first}');
              print('DEBUG: Last point: ${routePoints.last}');
            }
          } else {
            print('DEBUG: No geometry or coordinates found in route');
          }
          
          final navData = NavigationData(
            routePoints: routePoints,
            distance: route['distance']?.toDouble() ?? 0.0,
            duration: route['duration']?.toDouble() ?? 0.0,
            rawData: data,
          );
          
          print('DEBUG: NavigationData created - Distance: ${(navData.distance / 1000).toStringAsFixed(2)} km, Duration: ${(navData.duration / 60).toStringAsFixed(1)} min');
          
          return navData;
        } else {
          print('DEBUG: No routes found in response');
        }
        
        return null;
      } else {
        print('Failed to get directions: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to get directions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }
}

class NavigationData {
  final List<LatLng> routePoints;
  final double distance;
  final double duration;
  final Map<String, dynamic> rawData;

  NavigationData({
    required this.routePoints,
    required this.distance,
    required this.duration,
    required this.rawData,
  });
}