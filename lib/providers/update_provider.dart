import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateProvider extends ChangeNotifier {
  String? _currentVersion;
  String? _latestVersion;
  bool _isChecking = false;
  List<String> releases = [];

  static final String? githubToken = dotenv.env['GIT_TOKEN'];

  bool get isChecking => _isChecking;
  String? get latestVersion => _latestVersion;
  String? get currentVersion => _currentVersion;

  bool get isUpdateAvailable {
    if (_currentVersion == null || _latestVersion == null) return false;

    final currentParts = _currentVersion!.split('.').map(int.parse).toList();
    final latestParts = _latestVersion!.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length && i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }

    return latestParts.length > currentParts.length;
  }

  Map<String, String> get _headers {
    final headers = {'Accept': 'application/vnd.github.v3+json'};
    headers['Authorization'] = 'token $githubToken';
    return headers;
  }

  Future<void> checkForUpdate() async {
    _isChecking = true;
    notifyListeners();

    // Get current app version
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;

    // Get latest release on GitHub
    const url =
        'https://api.github.com/repos/UsedTempy/automotive_dashboard/releases';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json is List && json.isNotEmpty) {
        _latestVersion = json[0]['tag_name']?.replaceAll('v', '');
        print('Latest version: $_latestVersion');
      }
    } else {
      print('Failed to fetch version. Status: ${response.statusCode}');
    }

    _isChecking = false;
    notifyListeners();
  }

  Future<void> fetchReleases() async {
    const url =
        'https://api.github.com/repos/UsedTempy/automotive_dashboard/releases';

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        releases = jsonData
            .map((release) => release['tag_name']?.toString() ?? 'unknown')
            .toList();

        // Print releases in console
        for (var release in releases) {
          print('GitHub Release: $release');
        }
      } else {
        print('Failed to fetch releases: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching releases: $e');
    }

    notifyListeners();
  }
}
