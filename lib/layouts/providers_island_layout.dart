import 'package:car_dashboard/providers/update_provider.dart';
import 'package:car_dashboard/services/wifi_service.dart';
import 'package:car_dashboard/widgets/updates/app_updater_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProvidersIslandLayout extends StatefulWidget {
  const ProvidersIslandLayout({super.key});

  @override
  State<ProvidersIslandLayout> createState() => _ProvidersIslandLayoutState();
}

class _ProvidersIslandLayoutState extends State<ProvidersIslandLayout> {
  final WifiService _wifiService = WifiService();

  @override
  void initState() {
    super.initState();
    _wifiService.checkForInternet();
  }

  @override
  void dispose() {
    _wifiService.hasInternet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15,
      right: 15,
      child: ValueListenableBuilder<bool>(
        valueListenable: _wifiService.hasInternet,
        builder: (context, hasInternet, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
            child: Row(
              children: [
                Icon(
                  hasInternet ? Icons.wifi : Icons.wifi_off,
                  size: 20,
                  color: hasInternet ? Colors.green : Colors.red,
                ),
                AppUpdaterWidget()
              ],
            ),
          );
        },
      ),
    );
  }
}
