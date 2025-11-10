import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart';

class WifiService {
  // Singleton pattern
  static final WifiService _instance = WifiService._internal();
  factory WifiService() => _instance;
  WifiService._internal();

  final ValueNotifier<bool> hasInternet = ValueNotifier(true);
  bool _isChecking = false;

  Future<void> checkForInternet() async {
    if (_isChecking) return; // Prevent multiple loops
    _isChecking = true;

    while (true) {
      try {
        await Future.delayed(const Duration(seconds: 5));
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasInternet.value = true;
        }
      } on SocketException catch (_) {
        hasInternet.value = false;
        log('not connected: ${hasInternet.value}');
      }
    }
  }
}
