import 'package:car_dashboard/widgets/navigation/flutter_map_widget.dart';
import 'package:car_dashboard/widgets/navigation/navigation_widget.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:car_dashboard/widgets/navigation/re_center_button.dart';
import 'package:latlong2/latlong.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Flutter Map
        FlutterMapWidget(),
        // Search bar and results
        Navigation()
      ]
    );
  }
}