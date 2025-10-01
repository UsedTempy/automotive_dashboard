import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      print('API Endpoint: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract coordinates
        final coordinates = data['features']?[0]?['geometry']?['coordinates'];
        
        if (coordinates != null && coordinates is List && coordinates.length >= 2) {
          double longitude = coordinates[0];
          double latitude = coordinates[1];
          
          print('Coordinates: Longitude: $longitude, Latitude: $latitude');
          
          return {
            'longitude': longitude,
            'latitude': latitude,
            // 'fullData': data,
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

  static Future<Map<String, dynamic>?> getDirections({
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
        '&geometries=polyline6'
        '&language=en'
        '&overview=full'
        '&roundabout_exits=true'
        '&steps=true'
        '&voice_instructions=true'
        '&voice_units=metric'
        '&access_token=$accessToken'
      );

      print('Directions API Endpoint: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('\n=== DIRECTIONS API RESPONSE ===\n');
        print('Full Response: ${JsonEncoder.withIndent('  ').convert(data)}');
        
        // Parse and print all major data points
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          print('\n=== ROUTES (${data['routes'].length} found) ===');
          
          for (int i = 0; i < data['routes'].length; i++) {
            final route = data['routes'][i];
            print('\n--- Route ${i + 1} ---');
            print('Distance: ${route['distance']} meters (${(route['distance'] / 1000).toStringAsFixed(2)} km)');
            print('Duration: ${route['duration']} seconds (${(route['duration'] / 60).toStringAsFixed(1)} minutes)');
            print('Weight: ${route['weight']}');
            print('Weight Name: ${route['weight_name']}');
            
            if (route['legs'] != null) {
              print('\nLegs: ${route['legs'].length}');
              for (int j = 0; j < route['legs'].length; j++) {
                final leg = route['legs'][j];
                print('\n  Leg ${j + 1}:');
                print('  - Distance: ${leg['distance']} meters');
                print('  - Duration: ${leg['duration']} seconds');
                print('  - Summary: ${leg['summary']}');
                
                if (leg['steps'] != null) {
                  print('  - Steps: ${leg['steps'].length}');
                  for (int k = 0; k < leg['steps'].length; k++) {
                    final step = leg['steps'][k];
                    print('\n    Step ${k + 1}:');
                    print('    - Distance: ${step['distance']} meters');
                    print('    - Duration: ${step['duration']} seconds');
                    print('    - Name: ${step['name']}');
                    print('    - Mode: ${step['mode']}');
                    print('    - Maneuver: ${step['maneuver']?['type']} (${step['maneuver']?['instruction']})');
                    
                    if (step['bannerInstructions'] != null) {
                      print('    - Banner Instructions: ${step['bannerInstructions'].length}');
                    }
                    
                    if (step['voiceInstructions'] != null) {
                      print('    - Voice Instructions: ${step['voiceInstructions'].length}');
                    }
                  }
                }
                
                if (leg['annotation'] != null) {
                  print('\n  Annotations:');
                  final annotation = leg['annotation'];
                  if (annotation['maxspeed'] != null) {
                    print('  - Max Speed: ${annotation['maxspeed']}');
                  }
                  if (annotation['congestion'] != null) {
                    print('  - Congestion: ${annotation['congestion']}');
                  }
                  if (annotation['closure'] != null) {
                    print('  - Closures: ${annotation['closure']}');
                  }
                }
              }
            }
          }
        }
        
        if (data['waypoints'] != null) {
          print('\n=== WAYPOINTS ===');
          for (int i = 0; i < data['waypoints'].length; i++) {
            final waypoint = data['waypoints'][i];
            print('Waypoint ${i + 1}: ${waypoint['name']} at ${waypoint['location']}');
          }
        }
        
        print('\n=== END OF RESPONSE ===\n');
        
        return data;
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